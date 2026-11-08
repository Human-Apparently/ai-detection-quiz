-- Copy this entire file into Supabase SQL Editor, then click Run.
-- Creates a private response table and a narrow anonymous submission function.
-- Does not delete or replace existing responses.
begin;

create table if not exists public.quiz_responses (
  id uuid primary key,
  created_at timestamptz not null default now(),
  quiz_version text not null check (quiz_version = '1.0'),
  consent boolean not null check (consent = true),
  answers jsonb not null check (jsonb_typeof(answers) = 'array' and jsonb_array_length(answers) = 5),
  score smallint not null check (score between 0 and 5),
  duration_seconds integer not null check (duration_seconds between 0 and 86400)
);

alter table public.quiz_responses enable row level security;
revoke all on table public.quiz_responses from anon, authenticated;

-- Visitors can call this function but cannot read, change or delete response rows.
create or replace function public.submit_ai_quiz(p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  response_id uuid;
  clean_answers jsonb := '[]'::jsonb;
  item jsonb;
  answer_key text[] := array['human','ai','human','human','ai'];
  item_index integer := 0;
  calculated_score integer := 0;
  stored_score integer;
  total_seconds integer;
begin
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception 'Invalid response' using errcode = '22023';
  end if;
  if (p_payload->'consent') is distinct from 'true'::jsonb
     or (p_payload->>'version') is distinct from '1.0'
     or coalesce(p_payload->>'id','') !~* '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
     or jsonb_typeof(p_payload->'duration') is distinct from 'number'
     or coalesce(p_payload->>'duration','') !~ '^[0-9]{1,5}$'
     or jsonb_typeof(p_payload->'answers') is distinct from 'array' then
    raise exception 'Invalid response' using errcode = '22023';
  end if;
  if jsonb_array_length(p_payload->'answers') <> 5 then
    raise exception 'Five answers required' using errcode = '22023';
  end if;
  response_id := (p_payload->>'id')::uuid;
  total_seconds := (p_payload->>'duration')::integer;
  if total_seconds > 86400 then
    raise exception 'Invalid duration' using errcode = '22023';
  end if;

  for item in select value from jsonb_array_elements(p_payload->'answers') loop
    item_index := item_index + 1;
    if jsonb_typeof(item) is distinct from 'object'
       or jsonb_typeof(item->'choice') is distinct from 'string'
       or coalesce(item->>'choice','') not in ('human','ai')
       or jsonb_typeof(item->'confidence') is distinct from 'number'
       or coalesce(item->>'confidence','') not in ('1','2','3')
       or jsonb_typeof(item->'seconds') is distinct from 'number'
       or coalesce(item->>'seconds','') !~ '^[0-9]{1,5}$' then
      raise exception 'Invalid answer' using errcode = '22023';
    end if;
    if (item->>'seconds')::integer > 86400 then
      raise exception 'Invalid answer time' using errcode = '22023';
    end if;
    clean_answers := clean_answers || jsonb_build_array(jsonb_build_object(
      'choice',item->>'choice',
      'confidence',(item->>'confidence')::integer,
      'seconds',(item->>'seconds')::integer
    ));
    if item->>'choice' = answer_key[item_index] then
      calculated_score := calculated_score + 1;
    end if;
  end loop;

  insert into public.quiz_responses (id, quiz_version, consent, answers, score, duration_seconds)
  values (response_id, '1.0', true, clean_answers, calculated_score, total_seconds)
  on conflict (id) do nothing;

  -- Retrying a submission with the same UUID does not create another row.
  select r.score into stored_score from public.quiz_responses as r where r.id = response_id;
  return jsonb_build_object('id',response_id,'score',stored_score,'review',jsonb_build_array(
    jsonb_build_object('answer','human','explanation','A sourced photograph from Unsplash. Natural detail can look surprisingly unreal.','source','https://images.unsplash.com/photo-1472396961693-142e6e269027'),
    jsonb_build_object('answer','ai','explanation','Generated for this quiz with OpenAI image generation. The photographic style is part of the illusion.','source','https://openai.com/index/introducing-4o-image-generation/'),
    jsonb_build_object('answer','human','explanation','A sourced portrait photograph from Unsplash. Smooth lighting is not evidence of AI on its own.','source','https://images.unsplash.com/photo-1517841905240-472988babdf9'),
    jsonb_build_object('answer','human','explanation','A human narration of A Scandal in Bohemia by Arthur Conan Doyle, from LibriVox.','source','https://archive.org/details/adventures_sherlock_holmes_rg_librivox'),
    jsonb_build_object('answer','ai','explanation','Written by ChatGPT for this quiz. Evocative imagery and natural language can be generated, too.','source','https://openai.com/chatgpt/overview/')
  ));
end;
$$;

revoke all on function public.submit_ai_quiz(jsonb) from public, anon, authenticated;
grant usage on schema public to anon, authenticated;
grant execute on function public.submit_ai_quiz(jsonb) to anon, authenticated;

commit;

-- Success: run this SELECT separately if you want to check the table exists.
-- select count(*) from public.quiz_responses;
