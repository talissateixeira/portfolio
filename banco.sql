-- ============================================================================
-- banco.sql — Talissa Müller, painel administrativo
-- ============================================================================
-- COMO USAR: no painel do Supabase (projeto "Talissa ADM"), abra
-- SQL Editor > New query, cole TODO este arquivo, e clique em Run.
-- Pode rodar de uma vez só, de cima a baixo.
-- ============================================================================


-- ============================================================================
-- TABELA 1: videos
-- Os vídeos do seu portfólio, os mesmos que hoje aparecem fixos no código do
-- site. Editando aqui (pelo admin), o site atualiza sozinho.
-- ============================================================================
create table if not exists videos (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  marca text not null,
  nicho text not null,
  formato text,
  link text not null,          -- link do vídeo (YouTube), o mesmo que abre no player do site
  capa_url text not null,      -- foto de capa vertical (pode ser um arquivo já hospedado no site, ex: "capas-portfolio/nome.jpg", ou um link de fora)
  preview_url text,            -- vídeo curto e mudo pra prévia ao passar o mouse (opcional, mesma lógica da capa)
  destaque text,               -- texto livre, ex: "2,4M views" (opcional)
  ordem integer not null default 0,   -- controla a ordem de exibição (menor aparece primeiro)
  visivel boolean not null default true,  -- desmarcar esconde do site sem apagar
  created_at timestamptz not null default now()
);
create index if not exists idx_videos_ordem on videos (ordem);

-- Seus vídeos ATUAIS, copiados do código do site, pra você não perder nenhum
-- na hora de trocar pra usar o banco. Assim que você rodar isto, o portfólio
-- continua exatamente como está — depois é só editar, reordenar ou trocar
-- pelo admin, em talissamuller.com/admin.
insert into videos (titulo, marca, nicho, link, capa_url, preview_url, ordem, visivel) values
  ('Beyoung', 'Beyoung', 'Skincare', 'https://youtube.com/watch?v=sfpTB2b1i_U', 'capas-portfolio/beyoung-1.jpg', 'videos-portfolio/beyoung-1.mp4', 0, true),
  ('Beyoung', 'Beyoung', 'Skincare', 'https://youtube.com/watch?v=SXzC56EE0-M', 'capas-portfolio/beyoung-2.jpg', 'videos-portfolio/beyoung-2.mp4', 1, true),
  ('Beyoung', 'Beyoung', 'Skincare', 'https://youtube.com/watch?v=A7AE62HxZT0', 'capas-portfolio/beyoung-3.jpg', 'videos-portfolio/beyoung-3.mp4', 2, true),
  ('Beyoung', 'Beyoung', 'Skincare', 'https://youtube.com/watch?v=frx7bnLQgmg', 'capas-portfolio/beyoung-4.jpg', 'videos-portfolio/beyoung-4.mp4', 3, true),
  ('Beyoung', 'Beyoung', 'Skincare', 'https://youtube.com/watch?v=K27GZeS6nwk', 'capas-portfolio/beyoung-5.jpg', 'videos-portfolio/beyoung-5.mp4', 4, true),
  ('Rosa Selvagem', 'Rosa Selvagem', 'Auto Cuidados', 'https://youtube.com/watch?v=l4n0RHiJF4M', 'capas-portfolio/body-splash.jpg', 'videos-portfolio/body-splash.mp4', 5, true),
  ('Rosa Selvagem', 'Rosa Selvagem', 'Auto Cuidados', 'https://youtube.com/watch?v=fsm1-NujM4E', 'capas-portfolio/rosa-selvagem-1.jpg', 'videos-portfolio/rosa-selvagem-1.mp4', 6, true),
  ('Rosa Selvagem', 'Rosa Selvagem', 'Auto Cuidados', 'https://youtube.com/watch?v=WT3aTSHEwrY', 'capas-portfolio/rosa-selvagem-pelo-encravado.jpg', 'videos-portfolio/rosa-selvagem-pelo-encravado.mp4', 7, true),
  ('Rosa Selvagem', 'Rosa Selvagem', 'Auto Cuidados', 'https://youtube.com/watch?v=Ul8vf57er9w', 'capas-portfolio/rosa-selvagem-3.jpg', 'videos-portfolio/rosa-selvagem-3.mp4', 8, true),
  ('Rosa Selvagem', 'Rosa Selvagem', 'Auto Cuidados', 'https://youtube.com/watch?v=cQqoUutHA2w', 'capas-portfolio/rosa-selvagem-4.jpg', 'videos-portfolio/rosa-selvagem-4.mp4', 9, true),
  ('Widi Care', 'Widi Care', 'Hair Care', 'https://youtube.com/watch?v=W5-9s20jfb8', 'capas-portfolio/widicare-juba.jpg', 'videos-portfolio/widicare-juba.mp4', 10, true),
  ('Coala', 'Coala', 'Casa e Decoração', 'https://youtube.com/watch?v=CUNMgC-bEaE', 'capas-portfolio/coala.jpg', 'videos-portfolio/coala.mp4', 11, true),
  ('Coala', 'Coala', 'Casa e Decoração', 'https://youtube.com/watch?v=6YB4VU45G3w', 'capas-portfolio/coala-02.jpg', 'videos-portfolio/coala-02.mp4', 12, true),
  ('Azulim', 'Azulim', 'Casa e Decoração', 'https://youtube.com/watch?v=_i0G3bURBB4', 'capas-portfolio/azulim.jpg', 'videos-portfolio/azulim.mp4', 13, true),
  ('Mare Beauty', 'Mare Beauty', 'Unboxing', 'https://youtube.com/watch?v=1A-qNlGnW5Y', 'capas-portfolio/mare-beauty.jpg', 'videos-portfolio/mare-beauty.mp4', 14, true),
  ('Vita Premium', 'Vita Premium', 'Fitness e Wellness', 'https://youtube.com/watch?v=Y2Ip24_amvo', 'capas-portfolio/melatonina.jpg', 'videos-portfolio/melatonina.mp4', 15, true),
  ('Vita Premium', 'Vita Premium', 'Fitness e Wellness', 'https://youtube.com/watch?v=7ofP4-PhqN8', 'capas-portfolio/vinagre-maca.jpg', 'videos-portfolio/vinagre-maca.mp4', 16, true),
  ('Miallegra', 'Miallegra', 'Moda e Acessórios', 'https://youtube.com/watch?v=3BQErVgKPMM', 'capas-portfolio/miallegra.jpg', 'videos-portfolio/miallegra.mp4', 17, true),
  ('Full English', 'Full English', 'Educação', 'https://youtube.com/watch?v=a4JLSf0Ew3k', 'capas-portfolio/depoimento-aluno.jpg', 'videos-portfolio/full-english.mp4', 18, true),
  ('Bela Gastro Bar', 'Bela Gastro Bar', 'Gastronomia', 'https://youtube.com/watch?v=k0tvIPNULyk', 'capas-portfolio/bela-gastro-bar.jpg', 'videos-portfolio/bela-gastro-bar.mp4', 19, true);


-- ============================================================================
-- TABELA 2: marcas
-- Sua base de contatos de empresas/marcas (o CRM da aba "Marcas").
-- ============================================================================
create table if not exists marcas (
  id uuid primary key default gen_random_uuid(),
  marca text not null,
  instagram text,
  email text,
  telefone text,
  situacao text not null default 'lead' check (situacao in ('lead', 'conversando', 'cliente', 'parada')),
  obs text,
  ultimo_contato date,
  created_at timestamptz not null default now()
);

insert into marcas (marca, instagram, email, situacao, obs)
values ('(exemplo) Apague depois de ver o formato', '@marcaexemplo', 'contato@exemplo.com', 'lead', 'Isto é só um exemplo.');


-- ============================================================================
-- TABELA 3: calendario
-- Sua agenda de gravar, editar e postar (a aba "Calendário").
-- ============================================================================
create table if not exists calendario (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  marca text,
  tipo text not null check (tipo in ('gravar', 'editar', 'postar')),
  data date not null,
  status text not null default 'a_fazer' check (status in ('a_fazer', 'feito')),
  created_at timestamptz not null default now()
);
create index if not exists idx_calendario_data on calendario (data);

insert into calendario (titulo, marca, tipo, data, status)
values ('(exemplo) Apague depois de ver o formato', 'Marca Exemplo', 'gravar', current_date, 'a_fazer');


-- ============================================================================
-- TABELA 4: campanhas
-- Suas campanhas fechadas com marcas (a aba "Campanhas").
-- Os status seguem sempre esta ordem de funil, nunca ordem alfabética:
-- Briefing -> Roteiro -> Aprovação Roteiro -> Gravação -> Edição -> Aprovado -> Entregue
-- ============================================================================
create table if not exists campanhas (
  id uuid primary key default gen_random_uuid(),
  campanha text not null,
  cliente text not null,
  tipo text not null check (tipo in ('Conteúdo', 'Publicidade')),
  status text not null default 'Briefing'
    check (status in ('Briefing', 'Roteiro', 'Aprovação Roteiro', 'Gravação', 'Edição', 'Aprovado', 'Entregue')),
  qtd integer not null default 1,
  valor numeric(10,2) not null default 0,
  prazo date,
  pagamento text not null default 'pendente' check (pagamento in ('pendente', 'pago')),
  ativa boolean not null default true,
  favorita boolean not null default false,
  created_at timestamptz not null default now()
);

insert into campanhas (campanha, cliente, tipo, status, qtd, valor, prazo, pagamento, ativa)
values ('(exemplo) Apague depois de ver o formato', 'Cliente Exemplo', 'Conteúdo', 'Briefing', 1, 0, current_date, 'pendente', false);


-- ============================================================================
-- TABELA 5: marcados
-- Guarda o que você já marcou como feito no checklist do portfólio (aba
-- "Checklist"). Cada item do checklist tem uma "chave" única de texto; aqui
-- só anotamos se aquela chave está marcada ou não.
-- ============================================================================
create table if not exists marcados (
  chave text primary key,
  marcado boolean not null default true,
  atualizado_em timestamptz not null default now()
);


-- ============================================================================
-- TABELA 6: visitas
-- Métricas simples do portfólio: cada visita à página grava uma linha aqui.
-- ============================================================================
create table if not exists visitas (
  id uuid primary key default gen_random_uuid(),
  data timestamptz not null default now(),
  pagina text,
  origem text,   -- de onde a pessoa veio (referrer), ex: "instagram.com" ou "direto"
  created_at timestamptz not null default now()
);
create index if not exists idx_visitas_data on visitas (data desc);


-- ============================================================================
-- SEGURANÇA (RLS — Row Level Security)
-- Liga a trava em todas as 6 tabelas. Depois disso, por padrão, NINGUÉM
-- consegue ler nem escrever nada — cada tabela só libera o que é descrito
-- logo abaixo dela.
-- ============================================================================
alter table videos     enable row level security;
alter table marcas     enable row level security;
alter table calendario enable row level security;
alter table campanhas  enable row level security;
alter table marcados   enable row level security;
alter table visitas    enable row level security;

-- ---- videos: você (logada) pode fazer tudo; o público só pode LER os vídeos
-- marcados como "visivel = true" — é o que faz seu portfólio aparecer pra
-- quem visita o site sem estar logado. Editar/apagar continua só com você.
create policy "Você pode gerenciar os vídeos"
  on videos for all
  to authenticated
  using (true)
  with check (true);

create policy "Qualquer pessoa pode ver os vídeos visíveis"
  on videos for select
  to anon
  using (visivel = true);

-- ---- marcas: só você lê e edita. O público só pode INSERIR (o formulário
-- de contato do site), e só com situação "lead" — ninguém de fora consegue
-- criar um contato já como "cliente", por exemplo.
create policy "Você pode gerenciar as marcas"
  on marcas for all
  to authenticated
  using (true)
  with check (true);

create policy "Site público pode enviar um novo contato como lead"
  on marcas for insert
  to anon
  with check (situacao = 'lead');

-- ---- calendario: só você, sem nenhuma exceção pro público.
create policy "Você pode gerenciar o calendário"
  on calendario for all
  to authenticated
  using (true)
  with check (true);

-- ---- campanhas: só você, sem nenhuma exceção pro público.
create policy "Você pode gerenciar as campanhas"
  on campanhas for all
  to authenticated
  using (true)
  with check (true);

-- ---- marcados: só você, sem nenhuma exceção pro público.
create policy "Você pode gerenciar o checklist marcado"
  on marcados for all
  to authenticated
  using (true)
  with check (true);

-- ---- visitas: só você lê. O público só pode INSERIR (o registro de visita
-- do site), nunca ler os dados de volta.
create policy "Você pode ler e gerenciar as visitas"
  on visitas for all
  to authenticated
  using (true)
  with check (true);

create policy "Site público pode registrar uma visita"
  on visitas for insert
  to anon
  with check (true);
