-- ============================================================================
-- banco-atualizacao-seguidores-leads.sql — Talissa Müller
-- ============================================================================
-- Adiciona a coluna "seguidores" na tabela marcas (base de Leads/prospecção),
-- pra anotar o tamanho da marca (ex: "25 mil", "1.2M"). É texto, então aceita
-- qualquer formato que você escrever.
--
-- A tabela marcas já existe e já tem o RLS ligado (só você, logada, enxerga),
-- então NÃO precisa mexer em permissão — essa coluna herda a mesma segurança.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- isto > Run. Só precisa rodar uma vez.
-- ============================================================================

alter table marcas add column if not exists seguidores text;
