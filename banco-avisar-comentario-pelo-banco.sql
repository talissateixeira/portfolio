-- ============================================================================
-- Push do comentário/aprovação do roteiro disparado PELO BANCO
--
-- Antes, quem chamava a função avisar-comentario era o navegador da marca,
-- logo depois de enviar. Se a aba fechasse rápido ou o navegador bloqueasse,
-- o comentário entrava mas a notificação não saía.
-- Agora: entrou comentário na tabela -> o próprio Supabase chama a função.
--
-- Rodar UMA vez no SQL Editor do Supabase (projeto evafozzxhackvtlguqpq).
-- ============================================================================

create extension if not exists pg_net;

create or replace function avisar_comentario_push() returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_token text;
begin
  select token into v_token from roteiros where id = new.roteiro_id;
  if v_token is null then
    return new;
  end if;

  perform net.http_post(
    url     := 'https://evafozzxhackvtlguqpq.supabase.co/functions/v1/avisar-comentario',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      -- chave pública (anon), a mesma que já está no site
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWZvenp4aGFja3Z0bGd1cXBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0NDY3OTMsImV4cCI6MjEwNDAyMjc5M30.VIlphy_vB4suN-0wQ93jotNgzWZGZQL3jpyq5XS8yVc'
    ),
    body    := jsonb_build_object(
      'id',    new.roteiro_id,
      'token', v_token,
      'nome',  coalesce(new.nome, ''),
      'texto', new.texto
    )
  );
  return new;
exception when others then
  -- Push nunca pode impedir o comentário de ser salvo.
  return new;
end; $$;

drop trigger if exists trg_avisar_comentario on roteiro_comentarios;
create trigger trg_avisar_comentario
  after insert on roteiro_comentarios
  for each row execute function avisar_comentario_push();
