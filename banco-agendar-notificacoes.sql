-- ============================================================================
-- banco-agendar-notificacoes.sql
-- Agenda o envio diário das notificações das tarefas do dia.
-- Roda a Edge Function "enviar-notificacoes-tarefas" todo dia de manhã.
--
-- IMPORTANTE: só rode ISTO depois que a Edge Function já estiver criada e com
-- os segredos salvos (veja CONFIGURAR-NOTIFICACOES.md).
--
-- Horário: o pg_cron trabalha em UTC. O Brasil (Brasília/SC) é UTC-3 o ano
-- todo, então 07:00 da manhã aqui = 10:00 UTC. Para mudar a hora, troque o
-- "0 10" abaixo: o primeiro número é o minuto, o segundo é a hora (em UTC).
--   07:00 BRT -> 0 10      08:00 BRT -> 0 11      06:30 BRT -> 30 9
-- ============================================================================

create extension if not exists pg_cron;
create extension if not exists pg_net;

-- Se já existir um agendamento com esse nome, remove antes de recriar.
select cron.unschedule('notificacoes-tarefas-diaria')
where exists (select 1 from cron.job where jobname = 'notificacoes-tarefas-diaria');

select cron.schedule(
  'notificacoes-tarefas-diaria',
  '0 10 * * *',   -- todos os dias às 10:00 UTC (= 07:00 no Brasil)
  $$
  select net.http_post(
    url := 'https://evafozzxhackvtlguqpq.supabase.co/functions/v1/enviar-notificacoes-tarefas',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-funcao-segredo', 'COLE_AQUI_O_FUNCAO_SEGREDO'   -- veja NOTIFICACOES-SEGREDOS.local.txt
    ),
    body := '{}'::jsonb
  );
  $$
);

-- Para conferir se ficou agendado:
--   select jobname, schedule, active from cron.job;
-- Para ver as últimas execuções:
--   select * from cron.job_run_details order by start_time desc limit 10;
