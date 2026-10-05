-- ============================================================================
-- banco-atualizacao-ordem-projetos.sql — Talissa Müller
-- ============================================================================
-- Adiciona a coluna "ordem" em projetos_producao, pra dar pra arrastar e
-- ordenar os projetos manualmente por prioridade (na grade de Projetos; a
-- barra lateral acompanha a mesma ordem). Projetos sem "ordem" ficam no fim,
-- do mais recente pro mais antigo, até você arrastá-los.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

alter table projetos_producao add column if not exists ordem integer;
