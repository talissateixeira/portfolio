// ============================================================================
// Edge Function: avisar-comentario
//
// Chamada pela PÁGINA PÚBLICA do roteiro logo depois que a marca deixa um
// comentário. Valida o token do link (pra ninguém disparar push à toa) e manda
// uma notificação push pra todos os aparelhos inscritos (o iPhone da Talissa),
// reaproveitando a mesma tabela push_subscriptions e as chaves VAPID da push
// das tarefas do dia.
//
// Segredos (os mesmos da função enviar-notificacoes-tarefas):
//   VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY, VAPID_SUBJECT
// SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY são injetadas automaticamente.
// ============================================================================
import { createClient } from "npm:@supabase/supabase-js@2";
import webpush from "npm:web-push@3.6.7";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const VAPID_PUBLIC = Deno.env.get("VAPID_PUBLIC_KEY") ?? "";
const VAPID_PRIVATE = Deno.env.get("VAPID_PRIVATE_KEY") ?? "";
const VAPID_SUBJECT = Deno.env.get("VAPID_SUBJECT") ?? "mailto:mullertalissa@gmail.com";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...CORS, "Content-Type": "application/json" } });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ erro: "use POST" }, 405);

  let id = "", token = "", nome = "";
  try {
    const b = await req.json();
    id = (b.id ?? "").toString();
    token = (b.token ?? "").toString();
    nome = (b.nome ?? "").toString().trim();
  } catch (_e) { /* corpo inválido */ }

  if (!id || !token) return json({ erro: "faltam id/token" }, 400);

  const sb = createClient(SUPABASE_URL, SERVICE_ROLE);

  // Confere que o roteiro existe e o token bate (anti-spam de push).
  const { data: r, error } = await sb
    .from("roteiros").select("titulo, marca").eq("id", id).eq("token", token).maybeSingle();
  if (error || !r) return json({ erro: "roteiro não encontrado" }, 404);

  // Sem VAPID configurado a função não quebra o fluxo da marca — só não avisa.
  if (!VAPID_PUBLIC || !VAPID_PRIVATE) return json({ ok: true, push: false });

  webpush.setVapidDetails(VAPID_SUBJECT, VAPID_PUBLIC, VAPID_PRIVATE);

  const { data: subs } = await sb.from("push_subscriptions").select("endpoint, p256dh, auth");
  const quem = nome || "A marca";
  const payload = JSON.stringify({
    title: "💬 Novo comentário no roteiro",
    body: `${quem} comentou em "${r.titulo}". Abra o painel pra ver.`,
    url: "https://talissamuller.com/admin/#roteiros",
  });

  let enviados = 0;
  for (const s of subs ?? []) {
    try {
      await webpush.sendNotification(
        { endpoint: s.endpoint, keys: { p256dh: s.p256dh, auth: s.auth } },
        payload,
      );
      enviados++;
    } catch (e) {
      // Inscrição morta (410/404): limpa pra não tentar de novo.
      const code = (e as { statusCode?: number }).statusCode;
      if (code === 404 || code === 410) {
        await sb.from("push_subscriptions").delete().eq("endpoint", s.endpoint);
      }
    }
  }

  return json({ ok: true, push: true, enviados });
});
