-- ============================================================================
-- reordenar-collum-novo.sql — Talissa Müller
-- ============================================================================
-- O vídeo antigo da Collum (Pet) foi apagado e recriado com o link novo do
-- YouTube. Este script só põe o vídeo novo na mesma posição (13) que o
-- antigo ocupava nos Destaques.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Rode uma vez só.
-- ============================================================================

update videos set ordem = 13 where id = '4353bdfb-b12d-42e9-b3b1-d2f47765b3db';
