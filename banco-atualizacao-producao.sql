-- ============================================================================
-- banco-atualizacao-producao.sql — Talissa Müller
-- ============================================================================
-- Cria as tabelas da aba "Produção": o quadro Kanban de entregas de conteúdo
-- por projeto/marca (briefing → roteiro → gravação → ... → concluído).
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

create table if not exists projetos_producao (
  id uuid primary key default gen_random_uuid(),
  marca text not null,
  contato text,
  prazo_final date,
  valor numeric(10,2),
  link_briefing text,
  observacoes text,
  status text not null default 'ativo' check (status in ('ativo', 'concluido', 'arquivado')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_projetos_producao_status on projetos_producao (status);

alter table projetos_producao enable row level security;
create policy "Você pode gerenciar os projetos de produção"
  on projetos_producao for all
  to authenticated
  using (true)
  with check (true);

-- ----------------------------------------------------------------------------
-- Cada linha é um card do quadro: uma entrega de conteúdo dentro de um
-- projeto. "coluna" guarda a etapa atual (Briefing, Roteiro, Gravação...) e
-- "ordem" guarda a posição do card dentro da coluna.
-- ----------------------------------------------------------------------------
create table if not exists tarefas_producao (
  id uuid primary key default gen_random_uuid(),
  projeto_id uuid not null references projetos_producao(id) on delete cascade,
  titulo text not null,
  formato text not null default 'Outro' check (formato in ('Reels', 'TikTok', 'Stories', 'Foto', 'Carrossel', 'Outro')),
  coluna text not null default 'Briefing' check (coluna in (
    'Briefing', 'Roteiro', 'Aprovação do roteiro', 'Gravação', 'Edição',
    'Revisão', 'Envio pra marca', 'Aprovação', 'Concluído'
  )),
  ordem integer not null default 0,
  prazo date,
  prioridade text not null default 'media' check (prioridade in ('baixa', 'media', 'alta')),
  descricao text,
  checklist jsonb not null default '[]',
  link_roteiro text,
  link_arquivos_brutos text,
  link_video_final text,
  comentarios jsonb not null default '[]',
  created_at timestamptz not null default now(),
  concluido_em timestamptz
);
create index if not exists idx_tarefas_producao_projeto on tarefas_producao (projeto_id);
create index if not exists idx_tarefas_producao_coluna on tarefas_producao (coluna, ordem);

alter table tarefas_producao enable row level security;
create policy "Você pode gerenciar as tarefas de produção"
  on tarefas_producao for all
  to authenticated
  using (true)
  with check (true);
