# 📣 Aba Prospecção — guia de configuração

A aba já está pronta e funcionando no **modo rascunho** (Gmail) sem precisar de
nada. Este guia é só pra ligar o **envio automático pelo Resend**.

---

## O que funciona SEM configurar nada

- Selecionar marcas, escrever o e-mail (texto ou HTML), ver a prévia.
- **Modo Rascunho**: ele monta o e-mail de cada marca, você copia ou abre o
  Gmail já preenchido, e envia na mão. Quando marca como enviada, sai da fila.

## O que o Resend adiciona

- Envio **automático** pra várias marcas de uma vez, com barra de progresso.

> Importante: o Resend só entrega pra **outras pessoas** depois que você
> verificar um **domínio seu**. Enquanto não verificar, ele só manda **pra você
> mesma** (ótimo pra testar). Sem domínio, use o modo Rascunho pra prospectar.

---

## Passo a passo do Resend (uma vez)

### 1. Criar conta e chave
1. Entre em **resend.com** e crie a conta (pode usar o Gmail).
2. Vá em **API Keys** → **Create API Key** → nome "painel" → **copie a chave**
   (começa com `re_...`). Guarde num lugar seguro. **Nunca cole no site.**

### 2. (Opcional, pra mandar pros outros) verificar domínio
Em **Domains** → **Add Domain** → coloque `talissamuller.com` e siga as
instruções (uns registros no seu provedor de domínio). Depois de verificado,
você poderá mandar de um e-mail tipo `ola@talissamuller.com`.

### 3. Criar a função no Supabase
1. Supabase → **Edge Functions** → **Open Editor** (Via Editor).
2. Nome: `enviar-emails`
3. Apague o exemplo e cole o conteúdo de
   [`supabase/functions/enviar-emails/index.ts`](supabase/functions/enviar-emails/index.ts).
4. **Deploy**. (Pode deixar o "Verify JWT" LIGADO, a função já confere que é você.)

### 4. Salvar os segredos
Supabase → **Edge Functions** → **Secrets** → adicione:

| Nome | Valor |
|------|-------|
| `RESEND_API_KEY` | a sua chave do Resend (`re_...`) |
| `EMAIL_REMETENTE` | *(opcional)* sem domínio: `Talissa Müller <onboarding@resend.dev>`. Com domínio: `Talissa <ola@talissamuller.com>` |
| `EMAIL_REPLY_TO` | *(opcional)* `mullertalissa@gmail.com` (já é o padrão) |

Pronto. Agora o modo **Automático (Resend)** funciona.

---

## Como testar que deu certo
1. Na aba Prospecção, escreva o assunto e o texto (use `{{nome}}` e `{{marca}}`).
2. Clique em **Enviar teste pra mim**.
3. Abra seu e-mail (de preferência no **celular**) e confira: o seu nome e o
   nome da marca de exemplo entraram nos lugares certos? Ficou bonito no celular?
4. Só depois disso, dispare pra lista de verdade.

## Como trocar o texto do e-mail depois (sem código)
É só abrir a aba Prospecção e escrever no campo de assunto e no campo de texto.
Nada de mexer em arquivo. Use `{{nome}}` onde quiser o primeiro nome da marca e
`{{marca}}` pro nome completo.

## O que muda com domínio verificado
- **Sem domínio:** o Resend só entrega pra você mesma (serve pra testar).
- **Com domínio verificado:** você manda pra qualquer marca, de um e-mail da
  sua marca (ex.: `ola@talissamuller.com`), com melhor entrega.
