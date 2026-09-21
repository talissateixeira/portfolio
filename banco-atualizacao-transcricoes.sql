-- ============================================================================
-- banco-atualizacao-transcricoes.sql — Talissa Müller
-- ============================================================================
-- Outro COMPLEMENTO ao banco.sql, não mexe em nenhuma tabela existente. Cria
-- só a tabela "transcricoes", pra sua nova aba de transcrição de vídeos que
-- você gosta (YouTube, Instagram, TikTok).
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

create table if not exists transcricoes (
  id uuid primary key default gen_random_uuid(),
  link text not null,
  plataforma text,      -- "youtube", "instagram", "tiktok" ou "outro" (detectado sozinho pelo link)
  roteiro text,         -- a transcrição, colada por você (ex: gerada no tokscript.com)
  observacoes text,
  created_at timestamptz not null default now()
);
create index if not exists idx_transcricoes_data on transcricoes (created_at desc);

alter table transcricoes enable row level security;

-- Só você lê e gerencia — isto é uma ferramenta pessoal sua, sem nenhuma
-- exceção pro público (ninguém de fora nunca precisa ler ou gravar aqui).
create policy "Você pode gerenciar as transcrições"
  on transcricoes for all
  to authenticated
  using (true)
  with check (true);
