-- =========================================
-- HomeYoga Supabase Database Schema v2
-- =========================================
-- Run this entire script in your Supabase SQL Editor

-- 1. Create Profiles Table (Linked to Supabase Auth)
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  first_name text,
  last_name text,
  age integer,
  height_cm numeric,
  weight_kg numeric,
  fitness_level text default 'Beginner',
  goals text[] default '{}',
  workout_frequency_per_week integer default 3,
  preferred_duration_minutes integer default 15,
  preferred_time text default 'Morning',
  available_equipment text[] default '{}',
  physical_limitations text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Turn on Row Level Security for profiles
alter table public.profiles enable row level security;
create policy "Public profiles are viewable by everyone." on profiles for select using (true);
create policy "Users can insert their own profile." on profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile." on profiles for update using (auth.uid() = id);

-- 2. Create Progress Table (XP, Level, Streaks)
create table public.progress (
  user_id uuid references public.profiles(id) on delete cascade not null primary key,
  xp integer default 0 not null,
  level integer default 1 not null,
  current_streak integer default 0 not null,
  longest_streak integer default 0 not null,
  total_workouts integer default 0 not null,
  total_minutes integer default 0 not null,
  last_workout_date timestamp with time zone
);

alter table public.progress enable row level security;
create policy "Users can view own progress." on progress for select using (auth.uid() = user_id);
create policy "Users can update own progress." on progress for update using (auth.uid() = user_id);
create policy "Users can insert own progress." on progress for insert with check (auth.uid() = user_id);

-- Trigger to create progress row when profile is created
create or replace function public.handle_new_user_progress()
returns trigger as $$
begin
  insert into public.progress (user_id) values (new.id);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_profile_created on public.profiles;
create trigger on_profile_created
  after insert on public.profiles
  for each row execute procedure public.handle_new_user_progress();

-- 3. Create Exercises Table (The global exercise library)
create table public.exercises (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text,
  instructions text,
  video_url text,
  duration_seconds integer not null default 60,
  rest_seconds integer not null default 10,
  difficulty text not null, -- Beginner, Intermediate, Advanced
  category text not null,   -- Yoga, Pilates, Stretching, Breathing
  muscle_groups text[],
  xp_reward integer not null default 10
);

alter table public.exercises enable row level security;
create policy "Exercises are viewable by everyone." on exercises for select using (true);

-- 4. Create Workouts Table (Curated combinations of exercises)
create table public.workouts (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text,
  estimated_minutes integer not null,
  difficulty text not null,
  category text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.workouts enable row level security;
create policy "Workouts are viewable by everyone." on workouts for select using (true);

-- 5. Create Workout_Exercises Table (Many-to-Many linking with order)
create table public.workout_exercises (
  id uuid default gen_random_uuid() primary key,
  workout_id uuid references public.workouts(id) on delete cascade not null,
  exercise_id uuid references public.exercises(id) on delete cascade not null,
  order_index integer not null,
  override_duration integer, -- if this specific workout wants a longer/shorter duration
  override_rest integer
);

alter table public.workout_exercises enable row level security;
create policy "Workout exercises are viewable by everyone." on workout_exercises for select using (true);

-- Insert Some Seed Data for Exercises
insert into public.exercises (name, description, instructions, duration_seconds, rest_seconds, difficulty, category, xp_reward) values
('Child''s Pose (Balasana)', 'A resting pose that stretches the back and calms the mind.', 'Kneel on the floor, touch your big toes together, sit on your heels, and walk your hands forward.', 60, 10, 'Beginner', 'Yoga', 10),
('Downward-Facing Dog', 'An inversion that builds strength and stretches the entire body.', 'From hands and knees, tuck your toes, lift your hips back and up.', 60, 15, 'Beginner', 'Yoga', 15),
('Plank Pose', 'Core-strengthening pose.', 'Step back from downward dog until your shoulders are over your wrists.', 45, 20, 'Intermediate', 'Pilates', 20),
('Cobra Pose (Bhujangasana)', 'A backbend that stretches the chest and abs.', 'Lie on your stomach, place hands under shoulders, lift your chest.', 30, 15, 'Beginner', 'Yoga', 15);
