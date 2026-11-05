-- ============================================================================
-- banco-atualizacao-roteiros-logo.sql — Talissa Müller
-- ============================================================================
-- Adiciona a coluna "logo_url" em roteiros: a logo da marca enviada no painel,
-- que aparece no topo da página do roteiro (talissamuller.com/roteiro/).
--
-- COMO USAR: Supabase (entrar com "Continue with GitHub") > projeto
-- "talissateixeira's Project" > SQL Editor > New query > cole isto > Run.
-- Só precisa rodar uma vez.
-- ============================================================================

alter table roteiros add column if not exists logo_url text;
