-- ============================================================================
-- banco-atualizacao-campanha-producao-link.sql — Talissa Müller
-- ============================================================================
-- Liga o projeto de Produção criado automaticamente a partir de uma campanha
-- de volta pra campanha que o originou (campanha_id), com "on delete cascade":
-- ao apagar a campanha, o projeto de Produção (e as tarefas dele, que já têm
-- cascade pra projetos_producao) some junto.
--
-- Só vale pra campanhas criadas DEPOIS de rodar isto — campanhas/projetos já
-- existentes não têm como saber com certeza qual projeto veio de qual
-- campanha, então continuam soltos (apague-os manualmente se quiser).
--
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Só precisa rodar uma vez.
-- ============================================================================

alter table projetos_producao
  add column if not exists campanha_id uuid references campanhas(id) on delete cascade;
