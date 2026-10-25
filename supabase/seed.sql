-- =====================================================================
-- seed.sql (GlobalSeller OS 모놀리스)
-- 선행: migrations/20261025000001_core_lite.sql, migrations/20261025000002_globalseller_domain.sql
-- 정본: docs/기획서/01_PRD.md 4장(요금과 크레딧). 플랜 한도는 prototype/index.html 계정 > 구독 플랜 탭 값.
--   플랜 4종(free 기본, starter, pro, enterprise). 1 크레딧 = AI 번역 1회(상품 1개 × 언어 1개, 01_PRD 4.2).
-- 반복 실행 가능(upsert). 개발용 시드 계정은 scripts/dev/seed-users.mjs 가 만든다(05_DATA_MODEL 10장).
-- =====================================================================

-- 앱 1행. apps 가 정확히 1행이면 signup_app 메타데이터가 없어도 가입 시 이 앱으로 부트스트랩된다(core_lite SECTION 1).
insert into public.apps (id, name, schema_name, signup_policy, status) values
  ('globalseller', 'GlobalSeller OS', 'globalseller', 'open', 'active')
on conflict (id) do update
  set name = excluded.name, schema_name = excluded.schema_name, signup_policy = excluded.signup_policy, status = excluded.status;

-- features 키(서버만 읽음, 01_PRD 4.4절. 이름 그대로 쓴다):
--   gs_products_max          수집함 + 리스팅 원본 상품 수(제외 상태 빼고). -1 무제한
--   gs_markets_max           연결 마켓 계정 수(disconnected 빼고). -1 무제한
--   gs_ai_translations_month 월 지급 크레딧(= AI 번역 수, monthly_credits 와 같은 값)
--   gs_members_max           조직 멤버 수(초대 중 포함). -1 무제한
--   gs_bulk_listing_max      일괄 등록 1회 항목 수 상한(Route Handler 가 검사)
--   gs_profit_insights       수익 인사이트 문장(S-07)
--   gs_scheduled_collect     정기 수집 허용(P1, enqueue_collect_job 이 검사)
-- 가격(원)은 01_PRD D-01 (a) 확정(2026-10-25, 권고안 채택), 금액 자체는 제안값. 프로토타입 USD(Starter $29 / Pro $79 / Enterprise $199)를 원화로 다시 정했다.
-- Enterprise "무제한"은 01_PRD 4.1 시스템 상한(상품 50,000, 마켓 30, 번역 100,000) 제안값을 넣는다. 멤버만 -1.
insert into public.plans (app_id, code, name, price_krw, billing_interval, monthly_credits, signup_credits, carry_over, features, is_default, is_active, sort_order) values
  ('globalseller', 'free', 'Free', 0, 'month', 50, 0, false,
   '{"gs_products_max": 20, "gs_markets_max": 1, "gs_ai_translations_month": 50, "gs_members_max": 1, "gs_bulk_listing_max": 10, "gs_profit_insights": false, "gs_scheduled_collect": false}',
   true, true, 0),
  ('globalseller', 'starter', 'Starter', 39000, 'month', 1000, 0, false,
   '{"gs_products_max": 200, "gs_markets_max": 2, "gs_ai_translations_month": 1000, "gs_members_max": 2, "gs_bulk_listing_max": 500, "gs_profit_insights": false, "gs_scheduled_collect": true}',
   false, true, 1),
  ('globalseller', 'pro', 'Pro', 99000, 'month', 10000, 0, false,
   '{"gs_products_max": 2000, "gs_markets_max": 5, "gs_ai_translations_month": 10000, "gs_members_max": 10, "gs_bulk_listing_max": 500, "gs_profit_insights": true, "gs_scheduled_collect": true}',
   false, true, 2),
  ('globalseller', 'enterprise', 'Enterprise', 249000, 'month', 100000, 0, false,
   '{"gs_products_max": 50000, "gs_markets_max": 30, "gs_ai_translations_month": 100000, "gs_members_max": -1, "gs_bulk_listing_max": 500, "gs_profit_insights": true, "gs_scheduled_collect": true}',
   false, true, 3)
on conflict (app_id, code) do update
  set name = excluded.name, price_krw = excluded.price_krw, billing_interval = excluded.billing_interval,
      monthly_credits = excluded.monthly_credits, signup_credits = excluded.signup_credits, carry_over = excluded.carry_over,
      features = excluded.features, is_default = excluded.is_default, is_active = excluded.is_active, sort_order = excluded.sort_order;

insert into public.credit_packs (app_id, code, name, credits, price_krw, is_active, sort_order) values
  ('globalseller', 'pack_1000', 'AI 번역 1,000회', 1000, 9900, true, 1),
  ('globalseller', 'pack_5000', 'AI 번역 5,000회', 5000, 39000, true, 2)
on conflict (app_id, code) do update
  set name = excluded.name, credits = excluded.credits, price_krw = excluded.price_krw, is_active = excluded.is_active, sort_order = excluded.sort_order;

-- ---------------------------------------------------------------------
-- AI 기능별 라우팅 기본값(org null, app globalseller). 워커가 resolve_ai_route 로 체인을 받는다(02_ARCHITECTURE 5장).
-- 제공자·단가 행은 core_lite SECTION 11 이 넣는다. 모든 값은 제안이다.
-- ---------------------------------------------------------------------
insert into public.ai_routing_settings (org_id, app_id, feature, kind, mode, chain, force_open_source) values
  (null, 'globalseller', 'globalseller.translate',      'llm', 'auto', '[{"provider":"openai","model":"*"},{"provider":"google","model":"*"},{"provider":"anthropic","model":"*"},{"provider":"oss-llm","model":"*"}]', false),
  (null, 'globalseller', 'globalseller.title',          'llm', 'auto', '[{"provider":"anthropic","model":"*"},{"provider":"openai","model":"*"},{"provider":"oss-llm","model":"*"}]', false),
  (null, 'globalseller', 'globalseller.category_map',   'llm', 'auto', '[{"provider":"google","model":"*"},{"provider":"openai","model":"*"},{"provider":"oss-llm","model":"*"}]', false),
  (null, 'globalseller', 'globalseller.review_summary', 'llm', 'auto', '[{"provider":"oss-llm","model":"*"},{"provider":"google","model":"*"}]', false)
on conflict ((coalesce(org_id::text, '')), (coalesce(app_id, '')), feature, kind) do update
  set mode = excluded.mode, chain = excluded.chain, force_open_source = excluded.force_open_source;

-- 체인 검사: 존재하지 않거나 종류가 다른 제공자가 있으면 실패한다.
do $$
declare v_bad text;
begin
  select string_agg(s.feature || '/' || s.kind || ':' || coalesce(e.item ->> 'provider', '?'), ', ') into v_bad
  from public.ai_routing_settings s
  cross join lateral jsonb_array_elements(s.chain) as e(item)
  left join public.ai_providers p on p.id = e.item ->> 'provider'
  where s.org_id is null and s.app_id = 'globalseller'
    and (p.id is null or not (s.kind = any (p.kinds))
         or ((s.mode = 'open_source' or s.force_open_source) and p.source <> 'open_source'));
  if v_bad is not null then
    raise exception 'globalseller routing defaults: invalid chain providers %', v_bad;
  end if;
end $$;

-- 기준 환율 초기값(개발용, fx 크론이 1시간마다 덮어쓴다). 값은 프로토타입 표시값(제안).
insert into globalseller.fx_rates (currency, rate_krw, source)
select v.currency, v.rate_krw, 'seed'
from (values ('USD', 1385.000000::numeric), ('JPY', 9.240000::numeric), ('SGD', 1072.000000::numeric), ('THB', 38.500000::numeric)) as v(currency, rate_krw)
where not exists (select 1 from globalseller.fx_rates f where f.currency = v.currency);
