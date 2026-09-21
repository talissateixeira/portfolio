-- ============================================================================
-- banco-atualizacao-transcricoes-nicho.sql — Talissa Müller
-- ============================================================================
-- Complemento à tabela "transcricoes" (criada em
-- banco-atualizacao-transcricoes.sql): adiciona duas colunas pra deixar os
-- cards da aba Transcrições mostrarem o nicho do vídeo e uma imagem de capa.
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

alter table transcricoes add column if not exists nicho text;
alter table transcricoes add column if not exists capa_url text; -- opcional: link de uma imagem de capa (pro YouTube isso é automático, não precisa preencher)
