// Exemplo de lógica para uma Supabase Edge Function.
// A função real deve validar o JWT antes de registrar o evento.
// O IP deve ser obtido de um header confiável do gateway/proxy.

function anonymizeIp(ip: string): string {
  if (ip.includes(".")) {
    const parts = ip.split(".");
    return parts.length === 4 ? `${parts[0]}.${parts[1]}.${parts[2]}.0` : "unknown";
  }

  if (ip.includes(":")) {
    // Mantém somente um prefixo aproximado de IPv6.
    const parts = ip.split(":").filter(Boolean);
    return parts.slice(0, 4).join(":") + "::";
  }

  return "unknown";
}

// Exemplo de uso:
// const rawIp = req.headers.get("cf-connecting-ip") ?? "";
// const safeIp = anonymizeIp(rawIp);
// Nunca grave rawIp no banco.
