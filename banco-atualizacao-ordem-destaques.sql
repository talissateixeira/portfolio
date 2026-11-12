-- Ordem própria da fileira Destaques (independente da ordem das fileiras de nicho).
-- Rodar UMA vez no Supabase → SQL Editor.
alter table videos add column if not exists ordem_destaques integer;

-- Começa com a ordem que os Destaques tinham antes, com o vídeo da Ótima Energia
-- (Troca Luz) de volta logo depois do Collum.
with destaques as (
  select id, row_number() over (
    order by case when marca = 'Otima Energia' and titulo = 'Troca Luz' then 12.5 else ordem end
  ) - 1 as pos
  from videos
  where nicho not in ('Educação e Negócios', 'Skincare', 'Auto Cuidados') or nos_destaques
)
update videos set ordem_destaques = destaques.pos from destaques where videos.id = destaques.id;
