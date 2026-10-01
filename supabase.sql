-- Execute no SQL Editor do Supabase.
-- Este modelo guarda o conteúdo das páginas e uma tabela de registros.
-- O IP NÃO é guardado em formato completo.

create table if not exists public.pages (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Seu Nome',
  bio text not null default '',
  links jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.pages enable row level security;

create policy "public can read pages"
on public.pages for select
to anon, authenticated
using (true);

create policy "users can edit own page"
on public.pages for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Registro de acesso/cadastro.
create table if not exists public.access_events (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade,
  email text,
  anonymized_ip text,
  created_at timestamptz not null default now()
);

alter table public.access_events enable row level security;

-- IMPORTANTE:
-- Não dê SELECT público nessa tabela.
-- A inserção deve acontecer por uma Edge Function/server.
-- O painel admin deve ler somente via uma função/view protegida.

-- Exemplo de tabela para definir quem é administrador.
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

alter table public.admins enable row level security;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admins
    where user_id = auth.uid()
  );
$$;

create or replace view public.admin_user_view
with (security_invoker = true)
as
select email, anonymized_ip, created_at
from public.access_events;

-- Para produção, restrinja o acesso à view/tabela usando uma policy
-- que chame is_admin(), ou exponha os dados somente por uma Edge Function.
-- NÃO coloque service_role key no HTML/JS.
