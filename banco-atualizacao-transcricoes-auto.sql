-- ============================================================================
-- banco-atualizacao-transcricoes-auto.sql — Talissa Müller
-- ============================================================================
-- Complemento à tabela "transcricoes" (criada em
-- banco-atualizacao-transcricoes.sql, com nicho/capa em
-- banco-atualizacao-transcricoes-nicho.sql): adiciona a transcrição
-- automática por IA (via Supadata) à aba Transcrições, além da etiqueta
-- "Meu / De outra" pra você separar seus vídeos dos vídeos de outras
-- creators, e tags livres pra buscar depois.
--
-- Cria também a tabela "configuracoes", que guarda a sua chave da API da
-- Supadata (colada por você direto no admin, nunca escrita no código), pra
-- funcionar em qualquer computador que você entrar logada.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

alter table transcricoes add column if not exists de_quem text not null default 'outra' check (de_quem in ('minha', 'outra'));
alter table transcricoes add column if not exists perfil text;
alter table transcricoes add column if not exists titulo text;
alter table transcricoes add column if not exists tags text[] not null default '{}';
alter table transcricoes add column if not exists status text not null default 'pronto' check (status in ('processando', 'pronto', 'falhou'));
alter table transcricoes add column if not exists erro text;
alter table transcricoes add column if not exists segmentos jsonb;

-- ----------------------------------------------------------------------------
-- Tabela de configurações: guarda pares chave/valor, como a chave da API da
-- Supadata. Só quem está logada no painel lê e escreve aqui.
-- ----------------------------------------------------------------------------
create table if not exists configuracoes (
  chave text primary key,
  valor text,
  updated_at timestamptz not null default now()
);

alter table configuracoes enable row level security;

drop policy if exists "Painel logado pode gerenciar configuracoes" on configuracoes;
create policy "Painel logado pode gerenciar configuracoes"
  on configuracoes for all
  to authenticated
  using (true)
  with check (true);
