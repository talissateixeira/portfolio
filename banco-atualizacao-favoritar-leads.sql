-- ============================================================================
-- banco-atualizacao-favoritar-leads.sql
-- Adiciona a coluna "favorita" na tabela marcas (base de Leads), pra você
-- poder favoritar uma marca e deixá-la fixada no topo da lista.
--
-- Como aplicar: cole no SQL Editor do Supabase e rode (Run).
-- ============================================================================

alter table marcas add column if not exists favorita boolean not null default false;
