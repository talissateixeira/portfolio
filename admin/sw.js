// ============================================================================
// admin/sw.js — Service Worker do painel (só para notificações push).
//
// Este Service Worker NÃO faz cache de nada de propósito: ele existe só para
// receber as notificações push (tarefas do dia) e abrir o painel quando você
// toca na notificação. Assim o painel nunca fica "preso" numa versão antiga.
// ============================================================================

// Recebe o push enviado pela Edge Function e mostra a notificação.
self.addEventListener("push", (event) => {
  let dados = {};
  try {
    dados = event.data ? event.data.json() : {};
  } catch (erro) {
    dados = { corpo: event.data ? event.data.text() : "" };
  }

  const titulo = dados.titulo || "Tarefas de hoje";
  const opcoes = {
    body: dados.corpo || "",
    icon: "/admin/icon-192.png",
    badge: "/admin/icon-192.png",
    tag: dados.tag || "tarefas-do-dia",
    renotify: true,
    data: { url: dados.url || "/admin/" }
  };

  event.waitUntil(self.registration.showNotification(titulo, opcoes));
});

// Ao tocar na notificação, foca o painel se já estiver aberto, senão abre.
self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const destino = (event.notification.data && event.notification.data.url) || "/admin/";
  event.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true }).then((janelas) => {
      for (const janela of janelas) {
        if (janela.url.includes("/admin") && "focus" in janela) return janela.focus();
      }
      if (self.clients.openWindow) return self.clients.openWindow(destino);
    })
  );
});

// Assume o controle assim que uma versão nova é instalada.
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));
