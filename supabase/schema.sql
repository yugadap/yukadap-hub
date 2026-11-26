-- say의 이유식: Supabase 테이블과 보안 정책
-- Supabase 대시보드 > SQL Editor 에 붙여넣고 Run.

create table if not exists public.meal_entries (
  user_id    uuid        not null default auth.uid() references auth.users (id) on delete cascade,
  id         text        not null,
  meal_date  date        not null,
  meal_time  text        not null,
  menu       text        not null default '',
  ings       text[]      not null default '{}',
  amount     integer     not null default 0 check (amount between 0 and 1000),
  liked      smallint    not null default 2 check (liked between 1 and 3),
  reacts     text[]      not null default '{}',
  memo       text        not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);
create index if not exists meal_entries_user_date on public.meal_entries (user_id, meal_date desc);

create table if not exists public.baby_profiles (
  user_id    uuid        primary key default auth.uid() references auth.users (id) on delete cascade,
  name       text        not null default '',
  birth      date,
  start_date date,
  updated_at timestamptz not null default now()
);

-- 본인 기록만 읽고 쓰기
alter table public.meal_entries  enable row level security;
alter table public.baby_profiles enable row level security;

drop policy if exists "own entries" on public.meal_entries;
create policy "own entries" on public.meal_entries
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "own profile" on public.baby_profiles;
create policy "own profile" on public.baby_profiles
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
