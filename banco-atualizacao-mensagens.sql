-- ============================================================================
-- banco-atualizacao-mensagens.sql — Talissa Müller
-- ============================================================================
-- Cria a tabela dos modelos de mensagem da aba "Mensagens": textos prontos
-- pra copiar e colar pro cliente (primeiro contato, follow up, negociação,
-- fechamento, cobrança, pós-entrega). "Meus dados" (nome, @ do Instagram,
-- telefone, link do portfólio) usam a tabela "configuracoes" que já existe,
-- não precisam de nada novo aqui.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

create table if not exists mensagens_modelos (
  id uuid primary key default gen_random_uuid(),
  categoria text not null,
  titulo text not null,
  corpo text not null,
  ordem integer not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists idx_mensagens_modelos_categoria on mensagens_modelos (categoria, ordem);

alter table mensagens_modelos enable row level security;
create policy "Você pode gerenciar os modelos de mensagem"
  on mensagens_modelos for all
  to authenticated
  using (true)
  with check (true);
