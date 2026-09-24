-- ============================================================================
-- reordenar-destaques.sql — Talissa Müller
-- ============================================================================
-- Troca de lugar dois pares de vídeos nos "Destaques" do portfólio:
-- Bela Gastro Bar e Collum Pet (Super Colostro) vêm pra frente, pro lugar
-- onde hoje estão Coala 02 e Azulim — que vão pro final, pro lugar que Bela
-- e Collum ocupavam.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Rode uma vez só (não precisa rodar de novo depois).
-- ============================================================================

update videos set ordem = 19 where id = 'd60f7f48-d100-4db7-9226-da07918b92fa'; -- Coala 02: 12 -> 19
update videos set ordem = 20 where id = 'b10dd6dd-f20b-4861-bc62-0021eb91e302'; -- Azulim: 13 -> 20
update videos set ordem = 12 where id = 'd28a10d4-7b1c-44b7-b713-10338fc3a6c6'; -- Bela Gastro Bar: 19 -> 12
update videos set ordem = 13 where id = 'ae962028-e7f3-4610-aef1-260bac56c074'; -- Super Colostro (Collum Pet): 20 -> 13
