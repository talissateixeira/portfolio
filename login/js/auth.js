// ============================================================================
// js/auth.js
// Configuração e autenticação compartilhada entre index.html (login) e painel.html.
// O cliente do Supabase é criado uma única vez aqui e reaproveitado nas duas
// páginas através de window.Auth.
// ============================================================================

// EDITE AQUI se um dia precisar trocar de projeto no Supabase.
const SUPABASE_URL = "https://evafozzxhackvtlguqpq.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWZvenp4aGFja3Z0bGd1cXBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0NDY3OTMsImV4cCI6MjEwNDAyMjc5M30.VIlphy_vB4suN-0wQ93jotNgzWZGZQL3jpyq5XS8yVc";

// Cliente único do Supabase (a chave "anon" é pública por natureza, feita para
// rodar no navegador; quem protege os dados são as regras de RLS no banco).
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

window.Auth = {
  // Exposto para painel.html poder consultar as tabelas com o mesmo cliente.
  sb,

  // Faz login com e-mail e senha. Lança um erro com mensagem em português.
  async login(email, senha) {
    const { data, error } = await sb.auth.signInWithPassword({ email, password: senha });
    if (error) {
      if (error.message === "Invalid login credentials") {
        throw new Error("E-mail ou senha incorretos.");
      }
      throw new Error(error.message);
    }
    return data.user;
  },

  // Guarda de autenticação: roda no topo do painel. Sem sessão, manda de
  // volta para o login e devolve null (quem chamou deve parar a execução).
  async checkAuth() {
    const { data, error } = await sb.auth.getSession();
    if (error || !data.session) {
      window.location.href = "index.html";
      return null;
    }
    return data.session.user;
  },

  // Encerra a sessão e volta para a tela de login.
  async logout() {
    await sb.auth.signOut();
    window.location.href = "index.html";
  },

  // Dispara o e-mail de redefinição de senha do Supabase.
  async recuperarSenha(email) {
    const { error } = await sb.auth.resetPasswordForEmail(email);
    if (error) throw new Error(error.message);
  }
};
