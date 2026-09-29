-- ============================================================================
-- banco-atualizacao-conteudo.sql — Talissa Müller
-- ============================================================================
-- Cria a tabela da aba "Conteúdo": o planejamento dos SEUS posts do Instagram
-- como creator (não é entrega de marca — isso fica na aba Produção). Cada linha
-- é um post seu passando pelas etapas Ideia → Roteiro → Gravado → Editado →
-- Postado, com pilar, formato, data de publicação, gancho, roteiro e legenda.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

create table if not exists conteudo_instagram (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  -- Sem check constraint de propósito: dá pra você criar/renomear pilares e
  -- etapas direto pela cabeça sem quebrar o banco.
  pilar text not null default 'Sem pilar',
  formato text not null default 'Reels',
  etapa text not null default 'Ideia',
  ordem integer not null default 0,
  -- Quando o post vai ao ar (ou a data planejada). É o que aparece no calendário.
  data_postagem date,
  gancho text,        -- a primeira frase / o gancho que segura os 3 segundos
  roteiro text,       -- o roteiro / a fala do vídeo
  legenda text,       -- a legenda pronta pra colar no Instagram
  referencia text,    -- link de uma referência que te inspirou
  observacoes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  postado_em timestamptz
);
create index if not exists idx_conteudo_instagram_etapa on conteudo_instagram (etapa, ordem);
create index if not exists idx_conteudo_instagram_data on conteudo_instagram (data_postagem);

alter table conteudo_instagram enable row level security;
create policy "Você pode gerenciar o seu conteúdo do Instagram"
  on conteudo_instagram for all
  to authenticated
  using (true)
  with check (true);
