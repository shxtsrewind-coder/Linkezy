-- Shared stats for Linkezy (daily solver counts and "faster than X%").
-- Run once in the Supabase SQL editor. The game calls these functions with the
-- public anon key; the table stays locked behind row level security.

-- ---------- Linkezy: daily solver counts ----------
create table if not exists public.link_solves (
  puzzle_id  text        not null check (char_length(puzzle_id) <= 40),
  client_id  uuid        not null,
  time_ms    integer     not null check (time_ms between 1000 and 86400000),
  moves      integer     not null check (moves between 0 and 1000),
  hints      integer     not null default 0 check (hints between 0 and 100),
  created_at timestamptz not null default now(),
  primary key (puzzle_id, client_id)
);
alter table public.link_solves enable row level security;
create index if not exists link_solves_puzzle_time on public.link_solves (puzzle_id, time_ms);

-- Record a solve (first solve per device counts) and return the crowd picture.
create or replace function public.link_record_solve(
  p_puzzle text, p_client uuid, p_time_ms integer, p_moves integer, p_hints integer
) returns table (solvers bigint, faster_pct numeric)
language plpgsql security definer set search_path = public as $$
declare my_time integer;
begin
  if p_puzzle !~ '^daily:\d{4}-\d{2}-\d{2}$' then raise exception 'bad puzzle id'; end if;
  insert into link_solves (puzzle_id, client_id, time_ms, moves, hints)
  values (p_puzzle, p_client, greatest(1000, least(p_time_ms, 86400000)), least(p_moves, 1000), least(p_hints, 100))
  on conflict (puzzle_id, client_id) do nothing;
  select s.time_ms into my_time from link_solves s where s.puzzle_id = p_puzzle and s.client_id = p_client;
  return query
    select count(*)::bigint,
           case when count(*) <= 1 then 0::numeric
                else round(100.0 * count(*) filter (where s.time_ms > my_time) / (count(*) - 1), 1) end
    from link_solves s where s.puzzle_id = p_puzzle;
end $$;

create or replace function public.link_solver_count(p_puzzle text)
returns bigint language sql stable security definer set search_path = public as $$
  select count(*)::bigint from link_solves where puzzle_id = p_puzzle;
$$;

-- Only the anon/authenticated roles may call the functions; the table stays private.
revoke all on public.link_solves from anon, authenticated;
grant execute on function public.link_record_solve(text, uuid, integer, integer, integer) to anon, authenticated;
grant execute on function public.link_solver_count(text) to anon, authenticated;
