# 🎬 Aba Roteiros — guia de configuração

A aba **Roteiros** deixa você montar o roteiro de um vídeo (hook, cenas, legenda,
moodboard) e mandar um **link pra marca aprovar**. A marca abre uma página na sua
cara (`talissamuller.com/roteiro/?id=…&token=…`), lê tudo e pode **deixar um
comentário** — que chega como **notificação no seu iPhone**.

São 2 configurações, uma única vez. Depois é só usar.

---

## O que funciona com SÓ o passo 1 (o banco)

- Criar roteiro preenchendo os campos **na mão**, montar as cenas, copiar o link.
- A marca ver a página e **comentar**.
- O comentário cair na aba Roteiros **e** chegar de **push no seu celular**
  (reaproveita a mesma push das tarefas do dia — nada novo a configurar aqui).

## O que o passo 2 adiciona

- O botão **✨ Gerar com IA**: você cola o briefing da marca e o Claude monta o
  roteiro inteiro (hook, cenas, legenda). Você revisa e ajusta antes de mandar.

---

## Passo 1 — Rodar o banco (obrigatório)

1. Abra o **Supabase** → projeto **Talissa ADM** → **SQL Editor**.
2. Abra o arquivo [`banco-atualizacao-roteiros.sql`](banco-atualizacao-roteiros.sql),
   **copie tudo**, cole no editor e clique em **Run**.
3. Deve aparecer "Success". (Pode rodar de novo sem medo, não duplica nada.)

Pronto — a aba Roteiros já funciona no modo manual.

---

## Passo 2 — Ligar o "Gerar com IA"

### 2.1 — Pegar a chave do Claude
1. Entre em **console.anthropic.com** e faça login (ou crie a conta).
2. Vá em **API Keys** → **Create Key** → dê um nome ("painel") → **copie a chave**
   (começa com `sk-ant-…`). Guarde num lugar seguro. **Nunca cole no site.**
3. A API é paga por uso, mas um roteiro custa centavos. Dá pra pôr um limite de
   gasto em **Billing → Limits** se quiser dormir tranquila.

### 2.2 — Criar a função `gerar-roteiro`
1. Supabase → **Edge Functions** → **Open Editor**.
2. Nova função, nome exatamente: `gerar-roteiro`
3. Apague o exemplo e cole o conteúdo de
   [`supabase/functions/gerar-roteiro/index.ts`](supabase/functions/gerar-roteiro/index.ts).
4. **Deploy**. (Deixe o "Verify JWT" **LIGADO** — a função já confere que é você.)

### 2.3 — Criar a função `avisar-comentario` (a push do comentário)
1. Mesma tela → nova função, nome: `avisar-comentario`
2. Cole o conteúdo de
   [`supabase/functions/avisar-comentario/index.ts`](supabase/functions/avisar-comentario/index.ts).
3. **Deploy**. (Pode deixar o "Verify JWT" **LIGADO**.)

> Essa função usa as **mesmas chaves VAPID** que já estão configuradas pra push
> das tarefas do dia (`VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_SUBJECT`).
> Se a push do dia já funciona, aqui não precisa de segredo novo.

### 2.4 — Salvar o segredo da IA
Supabase → **Edge Functions** → **Secrets** → adicione:

| Nome | Valor |
|------|-------|
| `ANTHROPIC_API_KEY` | a sua chave do Claude (`sk-ant-…`) |
| `ROTEIRO_MODELO` | *(opcional)* o modelo. Padrão: `claude-sonnet-5-5`. Se der erro de modelo, troque aqui sem mexer no código. |

Pronto. Agora o botão **✨ Gerar com IA** funciona.

---

## Como usar no dia a dia

1. Painel → aba **Roteiros** → **+ Novo roteiro**.
2. Cole o **briefing** da marca e clique em **Gerar com IA** (ou preencha na mão).
3. Revise as cenas, ajuste a legenda, dê um **título**.
4. **Salvar** → aparece o **link pra marca**. Clique em **Copiar** e mande pra ela.
5. Quando a marca comentar, chega **push no seu celular** e aparece uma bolinha
   vermelha na aba Roteiros. Abra o roteiro pra ler o comentário.

## Como testar que deu certo

1. Crie um roteiro de teste e salve.
2. Clique em **Abrir página** (abre o link como a marca veria).
3. Escreva um comentário de teste e envie.
4. Veja se chega a push no seu iPhone e se o comentário aparece no roteiro.

---

## Dúvidas comuns

- **A marca precisa de senha?** Não. O link já carrega um token secreto. Quem não
  tem o link não acha o roteiro, e ninguém consegue ver os roteiros das outras
  marcas.
- **Dá pra usar sem a IA?** Dá. É só preencher os campos na mão — o passo 2 é só
  pro botão de gerar automático.
- **Troquei de ideia no roteiro depois de mandar.** É só editar e salvar: o mesmo
  link mostra a versão nova na hora. (Se apagar o roteiro, o link para de abrir.)
