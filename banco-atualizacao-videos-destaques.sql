-- ============================================================================
-- banco-atualizacao-videos-destaques.sql — Talissa Müller
-- ============================================================================
-- Adiciona a coluna "nos_destaques" em videos: um vídeo de nicho com fileira
-- própria (Skincare, Auto Cuidados, Educação e Negócios) pode aparecer também
-- na fileira Destaques do portfólio, na posição em que estiver na lista.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

alter table videos add column if not exists nos_destaques boolean not null default false;
