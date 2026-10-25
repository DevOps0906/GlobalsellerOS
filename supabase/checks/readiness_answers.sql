-- 실행: platform-docs products/_tools-sqlcheck 에서
--   node check.mjs --vector mono <0001> <0002> <0003> ../../GlobalsellerOS/supabase/seed.sql <이 파일>
-- GS-06-009(supabase/tests/ pgTAP)가 시작되면 이 검사를 pgTAP 로 옮긴다.
-- 마법사 답변 제약 테스트: 올바른 값 통과, 틀린 값 거부
do $$
declare uid uuid := gen_random_uuid(); oid uuid := gen_random_uuid(); bad int := 0; v jsonb;
begin
  insert into auth.users (id) values (uid);
  insert into public.organizations (id, name, slug, owner_id) values (oid, '테스트', 'rd-test', uid);
  -- 올바른 값
  insert into globalseller.readiness_answers (org_id, answers) values
    (oid, '{"biz":"ind","tel":"yes","pay":"global","card":"yes","region":["na","jp","sea"],"cat":["beauty","food"],"budget":"50"}');
  -- 틀린 값 6종: 각각 거부돼야 한다
  foreach v in array array[
    '{"biz":"x","tel":"yes","pay":"global","card":"yes","region":["na"],"cat":["beauty"],"budget":"50"}'::jsonb,
    '{"biz":"ind","tel":"yes","pay":"global","card":"yes","region":[],"cat":["beauty"],"budget":"50"}'::jsonb,
    '{"biz":"ind","tel":"yes","pay":"global","card":"yes","region":["mars"],"cat":["beauty"],"budget":"50"}'::jsonb,
    '{"biz":"ind","tel":"yes","pay":"global","card":"yes","region":["na"],"cat":["toys"],"budget":"50"}'::jsonb,
    '{"biz":"ind","tel":"yes","pay":"global","card":"yes","region":["na"],"cat":["beauty"],"budget":"100"}'::jsonb,
    '{"biz":"ind","tel":"yes","pay":"global","card":"yes","region":"na","cat":["beauty"],"budget":"50"}'::jsonb
  ] loop
    begin
      insert into globalseller.readiness_answers (org_id, answers) values (oid, v);
      raise exception 'SHOULD_FAIL %', v;
    exception when check_violation then bad := bad + 1;
    end;
  end loop;
  if bad <> 6 then raise exception 'expected 6 rejections, got %', bad; end if;
  raise notice 'readiness constraint OK: 1 accepted, % rejected', bad;
end $$;
