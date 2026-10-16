# 🔔 Notificações das tarefas do dia no iPhone

Guia pra ligar as notificações. A parte de código (o painel, o service worker,
a Edge Function) já está pronta no projeto. Faltam só estes passos no Supabase
e no seu iPhone. Faça **uma vez** e pronto.

As chaves já geradas pra você estão no final deste arquivo.

---

## Passo 1 — Criar a tabela (SQL)

No Supabase → **SQL Editor** → cole o conteúdo de
[`banco-atualizacao-push-notificacoes.sql`](banco-atualizacao-push-notificacoes.sql)
e clique em **Run**.

## Passo 2 — Criar a Edge Function

1. Supabase → menu **Edge Functions** → **Create a new function**.
2. Nome exato: `enviar-notificacoes-tarefas`
3. Apague o exemplo e cole todo o conteúdo de
   [`supabase/functions/enviar-notificacoes-tarefas/index.ts`](supabase/functions/enviar-notificacoes-tarefas/index.ts).
4. Clique em **Deploy**.
5. Entre na função → **Settings** → **desligue** a opção **"Verify JWT"**
   (a segurança aqui é feita pelo segredo do Passo 3).

## Passo 3 — Salvar os segredos

Supabase → **Edge Functions** → **Secrets** (ou "Manage secrets") → adicione:

| Nome | Valor |
|------|-------|
| `VAPID_PUBLIC_KEY`  | `BBoRD8_Vd5fS2uNR9tAIfAylSC9srpVGPPhit5nPjLwv0pipQW2X-OTGoMY270Zx0S_TKbEaloSpbG6qVcVYlK8` |
| `VAPID_PRIVATE_KEY` | *(veja `NOTIFICACOES-SEGREDOS.local.txt`)* |
| `VAPID_SUBJECT`     | `mailto:mullertalissa@gmail.com` |
| `FUNCAO_SEGREDO`    | *(veja `NOTIFICACOES-SEGREDOS.local.txt`)* |

> ⚠️ A `VAPID_PRIVATE_KEY` e o `FUNCAO_SEGREDO` são secretos e por isso **não
> ficam neste repositório** (que é público). Eles estão no arquivo local
> `NOTIFICACOES-SEGREDOS.local.txt`, que o Git ignora.

## Passo 4 — Ativar no iPhone

1. Abra **talissamuller.com/admin** no **Safari**.
2. Toque em **Compartilhar** (quadradinho com a seta) → **Adicionar à Tela de Início**.
3. Abra o painel **pelo ícone** que apareceu na tela de início (não pelo Safari).
4. No topo da página inicial, toque em **"Ativar notificações"** e aceite.
5. Toque em **"Enviar um teste"** — deve aparecer uma notificação na hora. ✅

## Passo 5 — Agendar o envio diário (SQL)

No **SQL Editor**, cole [`banco-agendar-notificacoes.sql`](banco-agendar-notificacoes.sql)
e clique em **Run**. Pronto — todo dia às **07:00** você recebe o resumo.

(Pra mudar o horário, é só editar o arquivo e rodar de novo. A explicação de
como converter a hora está nos comentários dele.)

---

## Como testar sem esperar o dia seguinte

Na página da Edge Function no Supabase, use o botão de **testar/invoke**
adicionando o header `x-funcao-segredo` com o valor do Passo 3. Se houver
tarefas pra hoje, a notificação chega no iPhone na hora.

## Dúvidas comuns

- **Não chegou nada:** confirme que abriu pelo ícone (modo app), que aceitou a
  permissão, e que existe pelo menos 1 tarefa com data/prazo de **hoje** no
  Calendário ou na Produção.
- **Parou de chegar:** se você reinstalar/limpar o app, é só abrir e tocar em
  "Ativar notificações" de novo (gera uma inscrição nova).
- **Trocar o horário:** edite `banco-agendar-notificacoes.sql` e rode de novo.

## Chaves

A chave **pública** (`BBoRD8_…`) pode ficar no código — ela já está no painel.
As chaves **secretas** (VAPID privada e segredo da função) estão só no arquivo
local `NOTIFICACOES-SEGREDOS.local.txt` (ignorado pelo Git).
