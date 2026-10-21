// ============================================================================
// Edge Function: gerar-roteiro
//
// Recebe o BRIEFING da marca (e o formato desejado) e pede pro Claude montar
// um roteiro completo de vídeo UGC: objetivo, pontos importantes, legenda
// sugerida e as cenas (hook, contexto, desenvolvimento, CTA) com tempo,
// narração (fala) e cena (o que aparece). Devolve JSON pronto pra aba Roteiros
// preencher os campos. Quem edita e aprova é a Talissa — isto é só o rascunho.
//
// Segredos (configure no painel do Supabase → Edge Functions → Secrets):
//   ANTHROPIC_API_KEY  — a chave da API do Claude (sk-ant-...). SECRETA.
//   ROTEIRO_MODELO     — opcional. Padrão: claude-sonnet-5-5.
//   DONO_EMAIL         — opcional. Só este usuário logado pode gerar.
//
// SUPABASE_URL e SUPABASE_ANON_KEY são injetadas automaticamente.
// ============================================================================
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const ANON = Deno.env.get("SUPABASE_ANON_KEY")!;
const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY") ?? "";
const MODELO = Deno.env.get("ROTEIRO_MODELO") ?? "claude-sonnet-5-5";
const DONO_EMAIL = (Deno.env.get("DONO_EMAIL") ?? "mullertalissa@gmail.com").toLowerCase();

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...CORS, "Content-Type": "application/json" } });
}

const SYSTEM = `Você é roteirista de vídeos UGC (user generated content) para Instagram Reels e TikTok, escrevendo em português do Brasil, com naturalidade e tom de criadora falando com a câmera (não publicitário engessado).

A partir do BRIEFING da marca, monte um roteiro de vídeo. Responda SOMENTE com um objeto JSON válido (sem texto antes ou depois, sem markdown, sem crases), neste formato exato:

{
  "titulo": "string curto do roteiro",
  "subtitulo": "string curta opcional (ex.: nome da campanha) ou \\"\\"",
  "formato": "string ex.: \\"Reels · 60s\\"",
  "objetivo": "1 frase do objetivo do vídeo",
  "pontos_importantes": "bullets separados por quebra de linha, começando com - ",
  "sugestao_legenda": "legenda pronta pro post, com CTA, no tom da criadora",
  "cenas": [
    {
      "tag": "HOOK | CONTEXTO | DESENVOLVIMENTO | PROVA | CTA",
      "tempo": "ex.: 0-5s",
      "narracao": "a FALA da criadora nessa cena (o que ela diz)",
      "cena": "o que APARECE na tela / o que ela mostra ou faz"
    }
  ]
}

Regras:
- Entre 4 e 6 cenas. A primeira é sempre o HOOK (gancho forte nos 3 primeiros segundos). A última é sempre um CTA.
- Fala em primeira pessoa, natural, como a criadora falaria de verdade. Nada de "descubra agora" robótico.
- Respeite o que o briefing pedir (produto, diferenciais, tom, proibições, hashtags).
- Se o briefing não disser o formato, use "Reels · 60s".`;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ erro: "use POST" }, 405);

  if (!ANTHROPIC_API_KEY) {
    return json({ erro: "ANTHROPIC_API_KEY não configurada. Veja CONFIGURAR-ROTEIROS.md." }, 500);
  }

  // Só a dona (logada) pode gerar, pra ninguém mais gastar a sua cota da API.
  try {
    const jwt = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
    const sb = createClient(SUPABASE_URL, ANON);
    const { data: u } = await sb.auth.getUser(jwt);
    const email = (u?.user?.email ?? "").toLowerCase();
    if (!email || (DONO_EMAIL && email !== DONO_EMAIL)) {
      return json({ erro: "não autorizado" }, 401);
    }
  } catch (_e) {
    return json({ erro: "não autorizado" }, 401);
  }

  let briefing = "", formato = "", instrucoes = "";
  try {
    const b = await req.json();
    briefing = (b.briefing ?? "").toString().trim();
    formato = (b.formato ?? "").toString().trim();
    instrucoes = (b.instrucoes ?? "").toString().trim();
  } catch (_e) { /* corpo inválido */ }

  if (!briefing) return json({ erro: "mande o briefing da marca" }, 400);

  const userMsg =
    `BRIEFING DA MARCA:\n${briefing}` +
    (formato ? `\n\nFORMATO DESEJADO: ${formato}` : "") +
    (instrucoes ? `\n\nOBSERVAÇÕES DA CRIADORA: ${instrucoes}` : "");

  // Chama a API do Claude.
  let resp: Response;
  try {
    resp = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: MODELO,
        max_tokens: 2000,
        system: SYSTEM,
        messages: [{ role: "user", content: userMsg }],
      }),
    });
  } catch (e) {
    return json({ erro: "falha ao falar com a IA: " + (e as Error).message }, 502);
  }

  if (!resp.ok) {
    let detalhe = "";
    try { detalhe = (await resp.json())?.error?.message ?? ""; } catch (_e) { /* sem corpo */ }
    return json({ erro: "a IA recusou (status " + resp.status + "). " + detalhe }, 502);
  }

  // Extrai o texto e tenta ler o JSON do roteiro.
  let texto = "";
  try {
    const data = await resp.json();
    texto = (data?.content ?? []).filter((p: { type: string }) => p.type === "text")
      .map((p: { text: string }) => p.text).join("").trim();
  } catch (_e) { /* ignore */ }

  // Tira cercas de markdown, se vierem, e pega do primeiro { ao último }.
  texto = texto.replace(/^```(?:json)?/i, "").replace(/```$/i, "").trim();
  const ini = texto.indexOf("{"), fim = texto.lastIndexOf("}");
  if (ini >= 0 && fim > ini) texto = texto.slice(ini, fim + 1);

  let roteiro: unknown;
  try {
    roteiro = JSON.parse(texto);
  } catch (_e) {
    return json({ erro: "a IA respondeu num formato inesperado. Tente de novo." }, 502);
  }

  return json({ ok: true, roteiro });
});
