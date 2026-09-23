-- ============================================================================
-- banco-atualizacao-producao-anexos.sql — Talissa Müller
-- ============================================================================
-- Permite anexar um arquivo (PDF, imagem etc.) em cada tarefa da aba
-- Produção, e abrir ele dentro da própria página (sem baixar).
--
-- Cria um espaço de armazenamento de arquivos (bucket) no Supabase, separado
-- do banco de dados normal, e duas colunas novas na tabela de tarefas pra
-- guardar o link e o nome do arquivo enviado.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

insert into storage.buckets (id, name, public)
values ('producao-arquivos', 'producao-arquivos', true)
on conflict (id) do nothing;

drop policy if exists "Autenticado pode enviar arquivos de producao" on storage.objects;
create policy "Autenticado pode enviar arquivos de producao"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'producao-arquivos');

drop policy if exists "Autenticado pode apagar arquivos de producao" on storage.objects;
create policy "Autenticado pode apagar arquivos de producao"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'producao-arquivos');

drop policy if exists "Qualquer um pode ver arquivos de producao" on storage.objects;
create policy "Qualquer um pode ver arquivos de producao"
  on storage.objects for select
  to public
  using (bucket_id = 'producao-arquivos');

alter table tarefas_producao add column if not exists anexo_url text;
alter table tarefas_producao add column if not exists anexo_nome text;
