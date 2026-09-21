-- ============================================================================
-- banco-atualizacao-metricas.sql — Talissa Müller
-- ============================================================================
-- Isto é um COMPLEMENTO ao banco.sql que você já rodou, não substitui nada.
-- Cria só uma tabela nova ("eventos"), pras métricas extras do dashboard do
-- Portfólio: quais vídeos são mais clicados, e quantas pessoas chegam até
-- rolar pro formulário e até mandar mensagem.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

create table if not exists eventos (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('clique_video', 'rolou_formulario', 'mensagem_enviada')),
  video_titulo text,   -- só preenchido quando tipo = 'clique_video': qual vídeo foi clicado
  pagina text,
  data timestamptz not null default now()
);
create index if not exists idx_eventos_data on eventos (data desc);
create index if not exists idx_eventos_tipo on eventos (tipo);

alter table eventos enable row level security;

-- Mesma regra da tabela "visitas": só você lê e gerencia; o site público só
-- pode INSERIR (é o próprio navegador do visitante que grava o evento).
create policy "Você pode ler e gerenciar os eventos"
  on eventos for all
  to authenticated
  using (true)
  with check (true);

create policy "Site público pode registrar um evento"
  on eventos for insert
  to anon
  with check (true);
