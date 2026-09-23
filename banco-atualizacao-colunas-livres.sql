-- ============================================================================
-- banco-atualizacao-colunas-livres.sql — Talissa Müller
-- ============================================================================
-- O quadro de Produção agora deixa criar colunas novas direto no site (botão
-- "+ Nova coluna"), mas "tarefas_producao.coluna" tinha um check constraint
-- travando os valores numa lista fixa (Briefing, Roteiro, Gravação...). Isso
-- faz salvar uma tarefa em qualquer coluna nova (como "To Do") dar o erro
-- "new row for relation tarefas_producao violates check constraint
-- tarefas_producao_coluna_check". Este script remove essa trava.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

alter table tarefas_producao drop constraint if exists tarefas_producao_coluna_check;
alter table tarefas_producao alter column coluna set default 'To Do';
