-- ============================================================================
-- disparo.sql — Talissa Müller
-- Fundação da aba PROSPECÇÃO (disparo de e-mails pras marcas).
--
-- O que este arquivo faz:
--   1) cria a tabela email_envios  (registro: 1 linha por e-mail enviado)
--   2) cria a tabela email_optout  (quem pediu SAIR, nunca mais recebe)
--   3) acrescenta 2 colunas em "marcas": "selecionada" e "enviado_em"
--
-- Nada é apagado. As tabelas usam "create table if not exists" e as colunas
-- usam "add column if not exists", então é seguro rodar mais de uma vez.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query >
-- cole tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) email_envios — o "diário de bordo" dos disparos.
--    Guarda UMA LINHA POR DESTINATÁRIO. Se um disparo morrer no meio, é aqui
--    que você vê quem recebeu e quem não recebeu.
-- ---------------------------------------------------------------------------
create table if not exists email_envios (
  id         uuid primary key default gen_random_uuid(),
  email      text not null,                 -- pra quem foi
  assunto    text,                          -- assunto do e-mail
  status     text not null default 'ok',    -- 'ok' ou 'erro'
  erro       text,                          -- a mensagem de erro, quando deu errado
  resend_id  text,                          -- o id que o Resend devolve (quando deu certo)
  data       timestamptz not null default now()
);
create index if not exists idx_email_envios_email on email_envios (email);
create index if not exists idx_email_envios_data  on email_envios (data desc);

-- ---------------------------------------------------------------------------
-- 2) email_optout — a lista de descadastro (quem respondeu SAIR).
--    Quem está aqui é pulado em TODOS os disparos, pra sempre.
-- ---------------------------------------------------------------------------
create table if not exists email_optout (
  id     uuid primary key default gen_random_uuid(),
  email  text not null unique,
  data   timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 3) Colunas novas em "marcas" (sem apagar nada do que já existe):
--    - selecionada: você marca a dedo pra quem quer mandar (fica salvo).
--    - enviado_em : a data do último disparo que essa marca recebeu.
-- ---------------------------------------------------------------------------
alter table marcas add column if not exists selecionada boolean not null default false;
alter table marcas add column if not exists enviado_em  date;

-- ---------------------------------------------------------------------------
-- Segurança (RLS): só você, logada, lê e escreve nas duas tabelas novas.
-- Ninguém deslogado enxerga nada. A Edge Function usa a chave service_role,
-- que passa por cima do RLS pra conseguir gravar os registros.
-- ---------------------------------------------------------------------------
alter table email_envios enable row level security;
alter table email_optout enable row level security;

drop policy if exists "Você gerencia os envios" on email_envios;
create policy "Você gerencia os envios"
  on email_envios for all
  to authenticated
  using (true) with check (true);

drop policy if exists "Você gerencia o descadastro" on email_optout;
create policy "Você gerencia o descadastro"
  on email_optout for all
  to authenticated
  using (true) with check (true);

-- Avisa o Supabase pra recarregar o "mapa" das tabelas (senão o painel pode
-- demorar a enxergar as colunas novas).
notify pgrst, 'reload schema';
