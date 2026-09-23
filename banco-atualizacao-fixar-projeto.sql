-- ============================================================================
-- banco-atualizacao-fixar-projeto.sql — Talissa Müller
-- ============================================================================
-- Adiciona a coluna "fixado" em projetos_producao, pra dar pra fixar um
-- projeto sempre no topo da lista (na barra lateral e na grade de Projetos).
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

alter table projetos_producao add column if not exists fixado boolean not null default false;
