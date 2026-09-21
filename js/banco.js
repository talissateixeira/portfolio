// ============================================================================
// js/banco.js
// Conexão com o Supabase, usada por TODAS as páginas do projeto: o portfólio
// (portfolio-v2.html), a tela de login (login/index.html) e o painel
// (admin/index.html). É o único lugar onde a URL e a chave pública do
// Supabase ficam escritas — se um dia precisar trocar de projeto, troque só
// aqui.
//
// Esta página precisa carregar o Supabase por CDN ANTES deste arquivo:
//   <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js"></script>
//   <script src="js/banco.js"></script>  (ou "../js/banco.js" de dentro de login/ ou admin/)
//
// A chave abaixo é a chave pública ("anon"), feita pra rodar no navegador de
// qualquer visitante — ela não é segredo. Quem protege os dados de verdade
// são as regras de RLS configuradas no banco.sql. NUNCA coloque aqui a
// chave secreta ("service_role") do Supabase.
// ============================================================================
const SUPABASE_URL = "https://evafozzxhackvtlguqpq.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWZvenp4aGFja3Z0bGd1cXBxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0NDY3OTMsImV4cCI6MjEwNDAyMjc5M30.VIlphy_vB4suN-0wQ93jotNgzWZGZQL3jpyq5XS8yVc";

// Cliente único do Supabase, reaproveitado em todas as páginas.
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

window.Banco = {
  sb,

  // ---- Autenticação (usada por login/index.html e admin/index.html) ----

  // Faz login com e-mail e senha. Lança um erro com mensagem em português.
  async entrar(email, senha) {
    const { data, error } = await sb.auth.signInWithPassword({ email, password: senha });
    if (error) {
      if (error.message === "Invalid login credentials") {
        throw new Error("E-mail ou senha incorretos.");
      }
      throw new Error(error.message);
    }
    return data.user;
  },

  // Guarda de autenticação: roda no topo do admin, antes de mostrar qualquer
  // coisa na tela. Sem sessão, manda de volta pro login. Quem chamar deve
  // parar a execução quando isto devolver null.
  async exigirSessao(caminhoLogin) {
    const { data, error } = await sb.auth.getSession();
    if (error || !data.session) {
      window.location.href = caminhoLogin;
      return null;
    }
    return data.session.user;
  },

  // Se já tiver sessão aberta, usado pela tela de login pra pular direto
  // pro admin sem pedir e-mail/senha de novo.
  async jaTemSessao() {
    const { data } = await sb.auth.getSession();
    return !!data.session;
  },

  // Encerra a sessão e volta para a tela de login.
  async sair(caminhoLogin) {
    await sb.auth.signOut();
    window.location.href = caminhoLogin;
  },

  // Dispara o e-mail de redefinição de senha do Supabase.
  async recuperarSenha(email) {
    const { error } = await sb.auth.resetPasswordForEmail(email);
    if (error) throw new Error(error.message);
  }
};
