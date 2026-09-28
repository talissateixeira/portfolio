-- ============================================================================
-- banco-atualizacao-crm.sql — Talissa Müller
-- ============================================================================
-- Fase 1 do CRM: expande "marcas" (vira a base de Leads) e "campanhas" com o
-- vínculo pra lead, e cria "atividades" (timeline/follow-up). Não cria
-- tabelas paralelas de leads/propostas — reaproveita o que já existe.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

-- ---- marcas → campos novos de Lead ----
alter table marcas add column if not exists contato_nome text;
alter table marcas add column if not exists site text;
alter table marcas add column if not exists nicho text;
alter table marcas add column if not exists cargo text;
alter table marcas add column if not exists origem text;
alter table marcas add column if not exists prioridade text not null default 'media';
alter table marcas add column if not exists tags jsonb not null default '[]';
alter table marcas add column if not exists valor_potencial numeric(10,2);
alter table marcas add column if not exists proximo_contato date;

-- "situacao" deixa de ser uma lista fixa (CHECK) pra virar texto livre com
-- lista padrão controlada no painel — mesma solução já usada nas colunas do
-- Kanban de Produção, que travava toda vez que eu tentava adicionar uma
-- etapa nova.
alter table marcas drop constraint if exists marcas_situacao_check;
alter table marcas alter column situacao set default 'Novo lead';
update marcas set situacao = 'Novo lead' where situacao = 'lead';
update marcas set situacao = 'Interessado' where situacao = 'conversando';
update marcas set situacao = 'Fechado' where situacao = 'cliente';
update marcas set situacao = 'Perdido' where situacao = 'parada';

-- ---- campanhas → vínculo com o lead que originou a proposta ----
alter table campanhas add column if not exists marca_id uuid references marcas(id) on delete set null;

-- ---- atividades: timeline do lead (ligação, WhatsApp, e-mail, Instagram,
-- reunião, proposta enviada, follow-up, observação) ----
create table if not exists atividades (
  id uuid primary key default gen_random_uuid(),
  marca_id uuid not null references marcas(id) on delete cascade,
  campanha_id uuid references campanhas(id) on delete set null,
  tipo text not null,
  descricao text,
  data timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists idx_atividades_marca on atividades (marca_id, data desc);

alter table atividades enable row level security;
create policy "Você pode gerenciar as atividades"
  on atividades for all
  to authenticated
  using (true)
  with check (true);
