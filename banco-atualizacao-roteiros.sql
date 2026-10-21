-- ============================================================================
-- banco-atualizacao-roteiros.sql
-- Aba "Roteiros": você monta um roteiro de vídeo (hook, cenas, legenda,
-- moodboard) dentro do painel e manda um link pra marca aprovar. A marca abre
-- uma página pública bonita (talissamuller.com/roteiro/?id=...&token=...), lê
-- o roteiro e pode deixar um comentário — que chega como push no seu iPhone.
--
-- Como aplicar: abra o SQL Editor do Supabase (projeto "Talissa ADM"), cole
-- TUDO isto e clique em Run. Pode rodar de novo sem medo (é idempotente).
--
-- Segurança (importante): a página da marca NÃO faz login. Pra ela não
-- conseguir listar os roteiros das outras marcas usando a chave pública, o
-- público não enxerga as tabelas diretamente — ele só acessa por duas funções
-- (ver_roteiro / comentar_roteiro) que exigem o "token" secreto do link.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Tabelas
-- ---------------------------------------------------------------------------

-- Um registro por roteiro enviado pra uma marca.
create table if not exists roteiros (
  id                 uuid primary key default gen_random_uuid(),
  -- "senha" que vai embutida no link. Quem não tem o link não acha o roteiro.
  token              text not null default replace(gen_random_uuid()::text, '-', ''),
  titulo             text not null,
  subtitulo          text,                 -- ex.: "Imersão", "Campanha verão"
  marca              text,                 -- nome da marca (referência sua)
  formato            text,                 -- ex.: "Reels · 60s"
  objetivo           text,
  pontos_importantes text,
  sugestao_legenda   text,
  -- rascunho | enviado | aprovado | ajustes
  status             text not null default 'rascunho',
  criado_em          timestamptz not null default now(),
  atualizado_em      timestamptz not null default now()
);

-- As cenas do roteiro (Hook, Contexto, Desenvolvimento, CTA...).
create table if not exists roteiro_cenas (
  id          uuid primary key default gen_random_uuid(),
  roteiro_id  uuid not null references roteiros(id) on delete cascade,
  ordem       int  not null default 0,
  tag         text,          -- HOOK, CONTEXTO, DESENVOLVIMENTO, CTA...
  tempo       text,          -- ex.: "0-5s"
  narracao    text,          -- a FALA da cena
  cena        text,          -- o que APARECE na tela
  criado_em   timestamptz not null default now()
);
create index if not exists idx_roteiro_cenas_roteiro on roteiro_cenas(roteiro_id, ordem);

-- Imagens/vídeos de referência (moodboard). Guarda só a URL.
create table if not exists roteiro_moodboard (
  id          uuid primary key default gen_random_uuid(),
  roteiro_id  uuid not null references roteiros(id) on delete cascade,
  url         text not null,
  ordem       int  not null default 0
);
create index if not exists idx_roteiro_moodboard_roteiro on roteiro_moodboard(roteiro_id, ordem);

-- Comentários que a marca deixa na página pública.
create table if not exists roteiro_comentarios (
  id          uuid primary key default gen_random_uuid(),
  roteiro_id  uuid not null references roteiros(id) on delete cascade,
  nome        text,
  texto       text not null,
  visto       boolean not null default false,  -- pra bolinha de "novo" no painel
  criado_em   timestamptz not null default now()
);
create index if not exists idx_roteiro_coment_roteiro on roteiro_comentarios(roteiro_id, criado_em);

-- Mantém atualizado_em em dia quando você edita o roteiro.
create or replace function roteiros_touch() returns trigger
language plpgsql as $$
begin new.atualizado_em := now(); return new; end; $$;
drop trigger if exists trg_roteiros_touch on roteiros;
create trigger trg_roteiros_touch before update on roteiros
  for each row execute function roteiros_touch();

-- ---------------------------------------------------------------------------
-- RLS: só você (logada) mexe direto nas tabelas. O público NÃO.
-- ---------------------------------------------------------------------------
alter table roteiros            enable row level security;
alter table roteiro_cenas       enable row level security;
alter table roteiro_moodboard   enable row level security;
alter table roteiro_comentarios enable row level security;

drop policy if exists "dona mexe nos roteiros" on roteiros;
create policy "dona mexe nos roteiros" on roteiros
  for all to authenticated using (true) with check (true);

drop policy if exists "dona mexe nas cenas" on roteiro_cenas;
create policy "dona mexe nas cenas" on roteiro_cenas
  for all to authenticated using (true) with check (true);

drop policy if exists "dona mexe no moodboard" on roteiro_moodboard;
create policy "dona mexe no moodboard" on roteiro_moodboard
  for all to authenticated using (true) with check (true);

drop policy if exists "dona mexe nos comentarios" on roteiro_comentarios;
create policy "dona mexe nos comentarios" on roteiro_comentarios
  for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------------
-- Funções públicas (a página da marca usa SÓ estas, validando o token)
-- ---------------------------------------------------------------------------

-- Entrega o roteiro inteiro (sem o token, sem os comentários) se o token bater.
create or replace function ver_roteiro(p_id uuid, p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare r roteiros;
begin
  select * into r from roteiros where id = p_id and token = p_token;
  if not found then return null; end if;
  return jsonb_build_object(
    'roteiro', to_jsonb(r) - 'token',
    'cenas', coalesce(
      (select jsonb_agg(to_jsonb(c) order by c.ordem, c.criado_em)
         from roteiro_cenas c where c.roteiro_id = r.id), '[]'::jsonb),
    'moodboard', coalesce(
      (select jsonb_agg(to_jsonb(m) order by m.ordem)
         from roteiro_moodboard m where m.roteiro_id = r.id), '[]'::jsonb)
  );
end; $$;

-- A marca deixa um comentário (valida o token antes de gravar).
create or replace function comentar_roteiro(p_id uuid, p_token text, p_nome text, p_texto text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare r roteiros;
begin
  select * into r from roteiros where id = p_id and token = p_token;
  if not found then raise exception 'roteiro nao encontrado'; end if;
  if coalesce(btrim(p_texto), '') = '' then raise exception 'comentario vazio'; end if;
  insert into roteiro_comentarios (roteiro_id, nome, texto)
    values (r.id, nullif(btrim(p_nome), ''), btrim(p_texto));
  return jsonb_build_object('ok', true);
end; $$;

-- O público (anon) só pode executar essas duas funções. Nada de tabela direta.
revoke all on function ver_roteiro(uuid, text) from public;
revoke all on function comentar_roteiro(uuid, text, text, text) from public;
grant execute on function ver_roteiro(uuid, text) to anon, authenticated;
grant execute on function comentar_roteiro(uuid, text, text, text) to anon, authenticated;

-- Pronto. Depois de rodar isto, configure a chave ANTHROPIC_API_KEY nos
-- segredos do Supabase pra liberar o "Gerar com IA" (veja CONFIGURAR-ROTEIROS.md).
