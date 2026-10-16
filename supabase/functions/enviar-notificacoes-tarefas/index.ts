// ============================================================================
// Edge Function: enviar-notificacoes-tarefas
//
// Lê as tarefas do dia (calendario + tarefas_producao), monta um resumo e
// envia uma notificação push para cada dispositivo inscrito em
// push_subscriptions. É chamada todo dia de manhã pelo agendador (pg_cron).
//
// Variáveis de ambiente (segredos) que esta função usa:
//   VAPID_PUBLIC_KEY   — chave pública VAPID (a mesma que está no painel)
//   VAPID_PRIVATE_KEY  — chave privada VAPID (SEGREDO, nunca vai pro site)
//   VAPID_SUBJECT      — ex.: mailto:mullertalissa@gmail.com
//   FUNCAO_SEGREDO     — senha simples: só quem mandar este valor no header
//                        "x-funcao-segredo" consegue disparar a função
//   FUSO               — opcional, padrão America/Sao_Paulo
//
// SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY já são injetadas automaticamente.
// ============================================================================
import { createClient } from "npm:@supabase/supabase-js@2";
import webpush from "npm:web-push@3.6.7";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const VAPID_PUBLIC = Deno.env.get("VAPID_PUBLIC_KEY")!;
const VAPID_PRIVATE = Deno.env.get("VAPID_PRIVATE_KEY")!;
const VAPID_SUBJECT = Deno.env.get("VAPID_SUBJECT") ?? "mailto:mullertalissa@gmail.com";
const FUNCAO_SEGREDO = Deno.env.get("FUNCAO_SEGREDO") ?? "";
const FUSO = Deno.env.get("FUSO") ?? "America/Sao_Paulo";

webpush.setVapidDetails(VAPID_SUBJECT, VAPID_PUBLIC, VAPID_PRIVATE);

// Data de hoje (YYYY-MM-DD) no fuso certo — pg_cron roda em UTC, então aqui
// a gente garante que "hoje" é o dia no Brasil.
function hojeNoFuso(): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: FUSO, year: "numeric", month: "2-digit", day: "2-digit",
  }).format(new Date());
}

function rotuloTipo(tipo: string): string {
  if (tipo === "gravar") return "🎥 Gravar:";
  if (tipo === "editar") return "✂️ Editar:";
  if (tipo === "postar") return "📲 Postar:";
  return "•";
}

function responder(corpo: unknown, status = 200): Response {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  // Proteção: só dispara quem souber o segredo.
  if (FUNCAO_SEGREDO && req.headers.get("x-funcao-segredo") !== FUNCAO_SEGREDO) {
    return responder({ erro: "nao autorizado" }, 401);
  }

  const sb = createClient(SUPABASE_URL, SERVICE_ROLE);
  const hoje = hojeNoFuso();

  // Pega as tarefas até hoje (inclui atrasadas) que ainda não foram concluídas.
  const [calRes, prodRes] = await Promise.all([
    sb.from("calendario")
      .select("titulo,marca,tipo,data")
      .eq("status", "a_fazer")
      .lte("data", hoje)
      .order("data", { ascending: true }),
    sb.from("tarefas_producao")
      .select("titulo,prazo,coluna")
      .neq("coluna", "Concluído")
      .not("prazo", "is", null)
      .lte("prazo", hoje)
      .order("prazo", { ascending: true }),
  ]);

  const deHoje: string[] = [];
  let atrasadas = 0;

  for (const t of calRes.data ?? []) {
    const texto = `${rotuloTipo(t.tipo)} ${t.titulo}${t.marca ? " (" + t.marca + ")" : ""}`;
    if (t.data === hoje) deHoje.push(texto);
    else atrasadas++;
  }
  for (const t of prodRes.data ?? []) {
    const texto = `📦 ${t.titulo}`;
    if (t.prazo === hoje) deHoje.push(texto);
    else atrasadas++;
  }

  const total = deHoje.length + atrasadas;
  if (total === 0) {
    return responder({ enviadas: 0, motivo: "nenhuma tarefa pra hoje", hoje });
  }

  // Monta o texto da notificação.
  let corpo = deHoje.slice(0, 6).map((t) => "• " + t).join("\n");
  const sobrando = deHoje.length - 6;
  if (sobrando > 0) corpo += `\n…e mais ${sobrando}`;
  if (atrasadas > 0) corpo += (corpo ? "\n" : "") + `⏰ ${atrasadas} atrasada(s)`;

  const titulo = deHoje.length
    ? `Bom dia! ${deHoje.length} tarefa(s) hoje 🌞`
    : `${atrasadas} tarefa(s) atrasada(s) ⏰`;

  const payload = JSON.stringify({ titulo, corpo, url: "/admin/", tag: "tarefas-do-dia-" + hoje });

  // Envia pra cada dispositivo inscrito.
  const { data: inscricoes } = await sb.from("push_subscriptions").select("*");
  let enviadas = 0;
  const expiradas: string[] = [];

  await Promise.all((inscricoes ?? []).map(async (s) => {
    try {
      await webpush.sendNotification(
        { endpoint: s.endpoint, keys: { p256dh: s.p256dh, auth: s.auth } },
        payload,
      );
      enviadas++;
    } catch (e) {
      // 404/410 = inscrição morta (app desinstalado, etc.) → limpa do banco.
      const code = (e as { statusCode?: number }).statusCode;
      if (code === 404 || code === 410) expiradas.push(s.endpoint);
    }
  }));

  if (expiradas.length) {
    await sb.from("push_subscriptions").delete().in("endpoint", expiradas);
  }

  return responder({ enviadas, total, atrasadas, hoje, limpas: expiradas.length });
});
