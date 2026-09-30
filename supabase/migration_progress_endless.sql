-- =========================================================
-- HomeYoga — endless-flow progress migration
-- =========================================================
-- Supabase Dashboard → SQL Editor → yapıştır → Run.
-- Tamamı idempotent: birden fazla kez çalıştırmak güvenlidir.
--
-- NEDEN GEREKLİ
-- schema.sql'deki 'progress' tablosu endless-flow modelinden (bkz.
-- ENDLESS_PLAN.md, Faz 1) önce yazılmış. Uygulama her pratik sonunda
-- total_practices / season_number / season_day / skill_points /
-- recent_exercise_ids alanlarını yazmaya çalışıyor, kolonlar olmadığı
-- için upsert "42703: column progress.total_practices does not exist"
-- ile düşüyordu. Yerel kayıt (SharedPreferences) çalıştığı için veri
-- kaybı yoktu, ama bulut senkronu fiilen ölüydü.

-- 1. Eksik ilerleme kolonları -----------------------------------------
alter table public.progress
  add column if not exists total_practices integer not null default 0,
  add column if not exists season_number integer not null default 1,
  add column if not exists season_day integer not null default 1,
  add column if not exists skill_points jsonb not null default '{}'::jsonb,
  add column if not exists recent_exercise_ids jsonb not null default '[]'::jsonb;

-- 2. Günlük check-in kaydı (bahçe / bitki verisi) ----------------------
-- Şu an yalnızca cihazda (SharedPreferences) duruyor: uygulama silinirse
-- ya da telefon değişirse 52 haftalık bahçe sıfırlanıyor. Bu tablo o
-- veriyi buluta taşımanın önünü açar.
--
-- status: 'done' | 'off'
-- 'missed' YAZILMAZ — kaçırılmış gün, kaydı olmayan geçmiş gündür ve
-- uygulama tarafında anlık hesaplanır (bkz. computeWeekPlantLevel).
create table if not exists public.daily_log (
  user_id uuid references public.profiles(id) on delete cascade not null,
  day date not null,
  status text not null check (status in ('done', 'off')),
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (user_id, day)
);

alter table public.daily_log enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'daily_log'
      and policyname = 'Users can view own daily log.'
  ) then
    create policy "Users can view own daily log." on public.daily_log
      for select using (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'daily_log'
      and policyname = 'Users can insert own daily log.'
  ) then
    create policy "Users can insert own daily log." on public.daily_log
      for insert with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'daily_log'
      and policyname = 'Users can update own daily log.'
  ) then
    create policy "Users can update own daily log." on public.daily_log
      for update using (auth.uid() = user_id);
  end if;
end $$;

create index if not exists daily_log_user_day_idx
  on public.daily_log (user_id, day desc);

-- 3. Kontrol -----------------------------------------------------------
-- Aşağıdaki sorgu 5 satır dönmeli; dönmüyorsa 1. adım uygulanmamıştır.
-- select column_name from information_schema.columns
--  where table_schema = 'public' and table_name = 'progress'
--    and column_name in ('total_practices','season_number','season_day',
--                        'skill_points','recent_exercise_ids');
