-- ============================================================================
-- banco-atualizacao-roteiros-board.sql — Talissa Müller
-- ============================================================================
-- Roteiro no formato MOOD BOARD (paleta da marca, clima, gancho, produtos,
-- suas fotos, diferenciais, o que evitar, CTA, pendências) + cenas com TOM e
-- TEXTO NA TELA.
--
-- COMO USAR: Supabase (entrar com "Continue with GitHub") > projeto
-- "talissateixeira's Project" > SQL Editor > New query > cole isto > Run.
-- Só precisa rodar uma vez. Não mexe em nada que já existe.
--
-- As funções ver_roteiro / comentar_roteiro NÃO mudam: ver_roteiro já devolve
-- todas as colunas do roteiro e das cenas, então a página da marca recebe os
-- campos novos sozinha.
-- ============================================================================

alter table roteiros      add column if not exists board jsonb;
alter table roteiro_cenas add column if not exists tom text;
alter table roteiro_cenas add column if not exists texto_tela text;
