-- Run this once in Supabase -> SQL Editor

create table if not exists posts (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  type  text not null check (type in ('text','image','video','link')),
  title text default '',
  data  text not null
);
create table if not exists settings (key text primary key, value text);

alter table posts    enable row level security;
alter table settings enable row level security;

-- everyone can READ, only the logged-in admin can WRITE
create policy "read posts"      on posts    for select using (true);
create policy "admin posts"     on posts    for all to authenticated using (true) with check (true);
create policy "read settings"   on settings for select using (true);
create policy "admin settings"  on settings for all to authenticated using (true) with check (true);

-- public bucket for images / videos
insert into storage.buckets (id, name, public) values ('board','board',true)
on conflict (id) do nothing;
create policy "admin upload" on storage.objects for insert to authenticated with check (bucket_id='board');
create policy "admin delete" on storage.objects for delete to authenticated using (bucket_id='board');
