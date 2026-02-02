-- Fix pets table

alter table public.pets
drop column if exists owner;

alter table public.pets
add column owner_id uuid not null references auth.users(id) on delete cascade;

-- Optional improvements
alter table public.pets
alter column age type int using age::int;
