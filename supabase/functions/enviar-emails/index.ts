// ============================================================================
// Edge Function: enviar-emails
//
// O "carteiro" da aba Prospecção. Recebe uma lista de marcas, o assunto e o
// HTML do e-mail, e manda pelo Resend, trocando {{nome}} e {{marca}} por marca.
// Grava uma linha por destinatário na tabela email_envios.
//
// Segredos que esta função usa (configurados no painel do Supabase):
//   RESEND_API_KEY   — a chave do Resend (re_...). SECRETA, só vive aqui.
//   EMAIL_REMETENTE  — opcional. O "de" do e-mail. Sem domínio verificado,
//                      deixe como "Talissa Müller <onboarding@resend.dev>"
//                      (o Resend só entrega pra você mesma nesse caso).
//                      Com domínio verificado: "Talissa <ola@seudominio.com>".
//   EMAIL_REPLY_TO   — opcional. Pra onde vão as respostas. Padrão: seu Gmail.
//   DONO_EMAIL       — opcional. Só este usuário logado pode disparar.
//
// SUPABASE_URL, SUPABASE_ANON_KEY e SUPABASE_SERVICE_ROLE_KEY são injetadas
// automaticamente pelo Supabase.
// ============================================================================
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON = Deno.env.get("SUPABASE_ANON_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const EMAIL_REMETENTE = Deno.env.get("EMAIL_REMETENTE") ?? "Talissa Müller <onboarding@resend.dev>";
const REPLY_TO = Deno.env.get("EMAIL_REPLY_TO") ?? "mullertalissa@gmail.com";
const DONO_EMAIL = (Deno.env.get("DONO_EMAIL") ?? "mullertalissa@gmail.com").toLowerCase();

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...CORS, "Content-Type": "application/json" } });
}
function primeiroNome(n: string): string {
  return (n || "").trim().split(/\s+/)[0] || "";
}
function aplicar(txt: string, d: { nome?: string; marca?: string }): string {
  return (txt || "")
    .replace(/\{\{nome\}\}/g, primeiroNome(d.marca || d.nome || ""))
    .replace(/\{\{marca\}\}/g, d.marca || "");
}
const dormir = (ms: number) => new Promise((r) => setTimeout(r, ms));

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ erro: "método não permitido" }, 405);

  // 1) Só a dona, logada, pode disparar.
  const token = (req.headers.get("Authorization") || "").replace(/^Bearer\s+/i, "");
  if (!token) return json({ erro: "não autorizado" }, 401);
  const sbAuth = createClient(SUPABASE_URL, ANON, { global: { headers: { Authorization: "Bearer " + token } } });
  const { data: userData, error: userErr } = await sbAuth.auth.getUser();
  if (userErr || !userData?.user || (userData.user.email || "").toLowerCase() !== DONO_EMAIL) {
    return json({ erro: "não autorizado" }, 401);
  }

  if (!RESEND_API_KEY) return json({ erro: "O Resend ainda não foi configurado (falta a RESEND_API_KEY)." }, 400);

  let payload: { destinatarios?: { email?: string; nome?: string; marca?: string }[]; assunto?: string; html?: string };
  try { payload = await req.json(); } catch { return json({ erro: "corpo inválido" }, 400); }

  const destinatarios = Array.isArray(payload.destinatarios) ? payload.destinatarios : [];
  const assunto = payload.assunto || "";
  const html = payload.html || "";
  if (destinatarios.length === 0) return json({ erro: "sem destinatários" }, 400);
  if (destinatarios.length > 250) return json({ erro: "máximo de 250 destinatários por chamada" }, 400);

  const sb = createClient(SUPABASE_URL, SERVICE_ROLE);

  // 5) Quem está no descadastro é pulado.
  const { data: optoutRows } = await sb.from("email_optout").select("email");
  const optout = new Set((optoutRows || []).map((o: { email?: string }) => (o.email || "").toLowerCase()));

  let enviados = 0, falhas = 0, pulados = 0, cotaAcabou = false;

  for (const d of destinatarios) {
    const email = (d.email || "").trim();
    if (!email) { pulados++; continue; }
    if (optout.has(email.toLowerCase())) { pulados++; continue; }

    const assuntoR = aplicar(assunto, d);
    const htmlR = aplicar(html, d);

    try {
      const resp = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: { "Authorization": "Bearer " + RESEND_API_KEY, "Content-Type": "application/json" },
        body: JSON.stringify({
          from: EMAIL_REMETENTE,
          to: [email],
          subject: assuntoR,
          html: htmlR,
          reply_to: REPLY_TO,                                   // 7) resposta cai no seu e-mail
          headers: { "List-Unsubscribe": "<mailto:" + REPLY_TO + "?subject=SAIR>" }, // 8)
        }),
      });
      const data = await resp.json().catch(() => ({}));
      if (resp.ok && data.id) {
        enviados++;
        await sb.from("email_envios").insert({ email, assunto, status: "ok", resend_id: data.id }); // 9)
      } else {
        const msg = data.message || data.name || ("status " + resp.status);
        falhas++;
        await sb.from("email_envios").insert({ email, assunto, status: "erro", erro: String(msg) });
        // 10) cota diária estourou: para na hora.
        if (/daily_quota_exceeded|quota/i.test(JSON.stringify(data))) { cotaAcabou = true; break; }
      }
    } catch (e) {
      falhas++;
      await sb.from("email_envios").insert({ email, assunto, status: "erro", erro: String(e) });
    }

    await dormir(200); // 6) ~5 por segundo, o ritmo seguro do Resend.
  }

  const faltando = cotaAcabou ? (destinatarios.length - enviados - falhas - pulados) : 0;
  return json({ enviados, falhas, pulados, cotaAcabou, faltando }); // 11)
});
