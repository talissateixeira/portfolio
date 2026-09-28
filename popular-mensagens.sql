-- ============================================================================
-- popular-mensagens.sql — Talissa Müller
-- ============================================================================
-- Cadastra os 9 modelos de mensagem a partir dos prints de referência que
-- você mandou, adaptados pra usar {{meu_nome}}, {{meu_instagram}},
-- {{meu_telefone}} e {{meu_link}} no lugar do nome/@/telefone/link fixos do
-- exemplo (a persona "Manu Ribeiro" era só ilustrativa). "Seguidores" ficou
-- como colchete manual [SEGUIDORES], já que esse número muda com o tempo.
--
-- Precisa já ter rodado banco-atualizacao-mensagens.sql antes.
-- COMO USAR: Supabase (projeto "Talissa ADM") > SQL Editor > New query > cole
-- tudo isto > Run. Se rodar duas vezes, os modelos ficam duplicados — nesse
-- caso é só apagar os repetidos pelo próprio painel.
-- ============================================================================

insert into mensagens_modelos (categoria, titulo, corpo, ordem) values

('Primeiro contato', 'Apresentação por e-mail (marca que eu já uso)', $$Assunto: Conteúdo para a [MARCA] · {{meu_instagram}}

Oi, [NOME]!

Meu nome é {{meu_nome}}, sou creator de beleza e casa e tenho [SEGUIDORES] seguidores no Instagram.

Eu uso [PRODUTO] há [TEMPO] e vejo muita gente perguntando sobre ele nos meus comentários. Por isso pensei em fazer um conteúdo mostrando [IDEIA EM UMA FRASE].

Deixo aqui meu portfólio: {{meu_link}}

Se fizer sentido, me conta qual é o orçamento de vocês para creators que eu monto uma proposta redondinha.

Um beijo,
{{meu_nome}}
{{meu_instagram}} · {{meu_telefone}}$$, 0),

('Primeiro contato', 'Direct curto (marca pequena)', $$Oi, [MARCA]! Tudo bem?

Sou {{meu_nome}}, faço conteúdo de beleza e casa aqui pro Instagram. Acompanho vocês faz um tempo e tive uma ideia de vídeo com [PRODUTO] que acho que a minha audiência ia amar.

Posso te mandar meu portfólio e os valores? :)$$, 1),

('Follow up', 'Cobrar retorno da proposta (sem parecer chata)', $$Oi, [NOME]! Tudo bem?

Passando pra saber se você chegou a ver a proposta que mandei dia [DATA]. Sem pressa nenhuma, é só pra eu saber se seguro a agenda de [MÊS] pra vocês ou se libero.

Qualquer ajuste que precisar, é só falar que eu adapto.

Beijo!$$, 0),

('Follow up', 'Terceira tentativa (a última)', $$Oi, [NOME]!

Vou fechar minha agenda de [MÊS] essa semana, então esse é meu último toque por aqui :)

Se der certo mais pra frente, minha porta segue aberta. E se não for o momento, sem problema nenhum, só me avisa que eu tiro da minha lista de acompanhamento.

Obrigada!$$, 1),

('Negociação', 'Quando a marca acha caro', $$Oi, [NOME]! Entendo perfeitamente.

Meu valor cobre roteiro, gravação, edição e a cessão de imagem, que é o que garante o vídeo pronto pra usar sem retrabalho pra vocês.

Mas dá pra caber no orçamento de [VALOR] assim:

Opção 1: tiro a permissão de anúncio e entrego só o post orgânico.
Opção 2: mantenho a permissão de anúncio e reduzo de [X] pra [Y] entregas.

Me conta qual faz mais sentido que eu já ajusto a proposta.$$, 0),

('Negociação', 'Quando oferecem só permuta', $$Oi, [NOME]! Obrigada pelo convite, fiquei feliz de vocês terem pensado em mim.

Hoje eu não fecho só com permuta porque a produção do vídeo tem um custo real pra mim (roteiro, gravação, edição e o dia de trabalho).

O que eu consigo fazer é uma primeira parceria enxuta de [VALOR], já com o produto incluso. Se rodar bem, a gente evolui pra um pacote maior.

Faz sentido pra vocês?$$, 1),

('Fechamento', 'Alinhamento antes de gravar', $$Oi, [NOME]! Fechado então :)

Só pra deixar tudo alinhado antes de eu gravar:

· Entregas: [O QUE VOCÊ VAI ENTREGAR]
· Data de entrega: [DATA]
· Valor: [VALOR], pago [CONDIÇÃO]
· Ajustes: [X] rodada inclusa
· Uso do conteúdo: [ORGÂNICO / ANÚNCIO POR X DIAS]

Se estiver tudo certo, é só me confirmar por aqui que eu já começo o roteiro. Ah, me manda também o que NÃO pode aparecer ou ser falado, pra eu não errar :)$$, 0),

('Cobrança', 'Pagamento atrasado (primeiro toque)', $$Oi, [NOME]! Tudo bem?

O pagamento do conteúdo que entreguei dia [DATA] venceu em [DATA VENCIMENTO] e ainda não caiu na conta. Deve ser só algum trâmite aí do financeiro.

Você consegue verificar pra mim? Se precisar que eu reenvie a nota, é só falar.

Obrigada!$$, 0),

('Pós-entrega', 'Mandar o resultado (e plantar a próxima)', $$Oi, [NOME]! Passando os números do conteúdo:

· Alcance: [X]
· Salvamentos: [X]
· Comentários: [X]
· Compartilhamentos: [X]

O comentário que mais apareceu foi "[COMENTÁRIO]", o que mostra que a audiência entendeu bem [PONTO].

Se quiserem, eu já tenho uma ideia de continuação pra [MÊS QUE VEM]: [IDEIA]. Me avisa que eu separo a data :)$$, 0);
