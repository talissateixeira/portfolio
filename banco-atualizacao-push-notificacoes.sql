-- ============================================================================
-- banco-atualizacao-push-notificacoes.sql
-- Tabela que guarda as "inscrições" de push — um registro por dispositivo/
-- navegador que ativou as notificações (ex.: o iPhone da Talissa). A Edge
-- Function "enviar-notificacoes-tarefas" lê daqui para saber pra onde mandar
-- as notificações das tarefas do dia.
--
-- Como aplicar: cole tudo isto no SQL Editor do Supabase e rode (Run).
-- ============================================================================

create table if not exists push_subscriptions (
  id         uuid primary key default gen_random_uuid(),
  endpoint   text not null unique,
  p256dh     text not null,
  auth       text not null,
  user_agent text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table push_subscriptions enable row level security;

-- Só você (logada) pode gerenciar as inscrições. O público não mexe aqui.
-- A Edge Function usa a chave service_role, que passa por cima do RLS.
drop policy if exists "Você pode gerenciar as inscrições de push" on push_subscriptions;
create policy "Você pode gerenciar as inscrições de push"
  on push_subscriptions for all
  to authenticated
  using (true)
  with check (true);
