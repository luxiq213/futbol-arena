-- =============================================================================
-- FUTBOL PARTY - SUPABASE FREE TIER SQL SCHEMA
-- Supabase Dashboard -> SQL Editor ekranına bu kodu yapıştırıp "Run" tuşuna bas.
-- =============================================================================

-- 1. KULLANICI PROFİLLERİ VE SIRALAMA TABLOSU (public.profiles)
create table if not exists public.profiles (
  id uuid primary key,
  username text not null default 'Kaptan',
  email text not null default '',
  avatar text not null default 'goat_10',
  favorite_team text not null default 'Galatasaray',
  points integer not null default 500,
  matches_played integer not null default 0,
  matches_won integer not null default 0,
  current_streak integer not null default 0,
  is_ad_free boolean not null default false,
  updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_points on public.profiles (points desc);

alter table public.profiles enable row level security;

-- Herkes genel liderlik tablosunu okuyabilir
create policy "Profiles are viewable by everyone"
  on public.profiles for select
  using (true);

-- Kullanıcı kendi profilini oluşturabilir ve güncelleyebilir
create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Apple App Store Hesap Silme Zorunluluğu (Guideline 5.1.1(v)) için silme izni
create policy "Users can delete their own profile"
  on public.profiles for delete
  using (auth.uid() = id);

-- 2. CANLI ONLINE DAVET ODALARI TABLOSU (public.online_rooms)
create table if not exists public.online_rooms (
  code text primary key,
  host_id text not null,
  game_title text not null,
  target_game text not null default 'commonPlayer',
  status text not null default 'waiting',
  participants jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.online_rooms enable row level security;

create policy "Online rooms are viewable by everyone"
  on public.online_rooms for select
  using (true);

create policy "Anyone can create an online room"
  on public.online_rooms for insert
  with check (true);

create policy "Participants can update online rooms"
  on public.online_rooms for update
  using (true);

-- 3. SUPABASE REALTIME YAYININA ONLINE ODALARI EKLE
alter publication supabase_realtime add table public.online_rooms;
