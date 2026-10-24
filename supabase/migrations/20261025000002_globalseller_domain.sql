-- =====================================================================
-- 20261025000002_globalseller_domain.sql  (GlobalSeller OS 도메인, 스키마 globalseller)
-- 선행: 20261025000001_core_lite.sql (코어는 public 스키마). 뒤: seed.sql
-- 정본 문서: docs/기획서/05_DATA_MODEL.md, 이름 기준: docs/설계/DESIGN_STRUCTURE.md 5.1·8·9·11장
--
-- 규칙
--   (a) 모든 도메인 표는 org_id 를 가진다(예외: fx_rates 는 전 조직 공용 참조 표).
--   (b) 사용자(authenticated)에게는 SELECT 만 준다. 쓰기는 Route Handler·워커(service_role) 또는
--       이 파일의 SECURITY DEFINER RPC 만 한다(코어 SECURITY_BASELINE 규칙, core_lite 머리 주석).
--   (c) 상태 값과 허용 전이는 globalseller.transition_allowed 한 곳에 둔다. service_role 쓰기에도 적용된다.
--   (d) 원화는 *_krw bigint(원), 외화는 *_minor bigint(통화 최소 단위) + currency 3자리. 실수 금지.
--   (e) 오류 코드는 GS001~GS099 (04_API.md 7장).
-- 이 파일을 고치지 않는다. 변경은 새 번호 파일로 추가한다(supabase/README.md).
-- =====================================================================

create schema if not exists globalseller;
revoke all on schema globalseller from public, anon;
grant usage on schema globalseller to authenticated, service_role;


-- =====================================================================
-- 1. 헬퍼: 플랜 기능 플래그, 한도, 상태 전이 표, 공용 트리거
-- =====================================================================

-- 조직의 globalseller 엔타이틀먼트 플랜 features. 엔타이틀먼트가 없으면 '{}'.
create or replace function globalseller.features(p_org_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select p.features
    from public.app_entitlements e
    join public.plans p on p.id = e.plan_id
    where e.org_id = p_org_id and e.app_id = 'globalseller' and e.status = 'active'
      and (e.expires_at is null or e.expires_at > now())
  ), '{}'::jsonb);
$$;

-- 숫자 한도. 키가 없으면 p_default, -1 은 무제한.
create or replace function globalseller.plan_limit(p_org_id uuid, p_key text, p_default integer)
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(nullif(globalseller.features(p_org_id) ->> p_key, '')::integer, p_default);
$$;

-- 상태 전이 표. 초기 상태는 from = '' 로 표현한다. DESIGN_STRUCTURE.md 5.1, 05_DATA_MODEL.md 3장과 같다.
create or replace function globalseller.transition_allowed(p_table text, p_from text, p_to text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select (coalesce(p_from, '') || '>' || coalesce(p_to, '')) = any (
    case p_table
      when 'source_products' then array[
        '>collected', 'collected>reviewing', 'collected>ready', 'collected>excluded',
        'reviewing>ready', 'reviewing>excluded', 'ready>reviewing', 'ready>listed', 'ready>excluded',
        'listed>ready', 'excluded>collected']
      when 'listings' then array[
        '>draft', '>live',
        'draft>validating', 'validating>ready', 'validating>draft', 'ready>draft', 'ready>queued',
        'queued>submitting', 'queued>draft', 'submitting>live', 'submitting>error',
        'error>draft', 'error>queued', 'live>error', 'live>paused', 'paused>live', 'live>ended', 'paused>ended']
      when 'sync_events' then array[
        '>detected', 'detected>applied', 'detected>held', 'detected>skipped', 'detected>failed',
        'held>applied', 'held>skipped', 'failed>detected', 'failed>applied']
      when 'orders' then array[
        '>received', '>purchase_pending', '>shipped', '>delivered',
        'received>purchase_pending', 'received>cancelled', 'purchase_pending>purchased',
        'purchased>at_warehouse', 'at_warehouse>shipped', 'purchased>shipped', 'shipped>delivered',
        'received>cancel_requested', 'purchase_pending>cancel_requested', 'purchased>cancel_requested',
        'at_warehouse>cancel_requested', 'cancel_requested>cancelled', 'cancel_requested>purchase_pending',
        'shipped>return_requested', 'delivered>return_requested', 'return_requested>returned',
        'return_requested>delivered']
      when 'shipments' then array[
        '>pending', 'pending>at_warehouse', 'pending>departed', 'at_warehouse>departed',
        'departed>customs', 'departed>out_for_delivery', 'customs>out_for_delivery', 'out_for_delivery>delivered',
        'departed>delayed', 'customs>delayed', 'out_for_delivery>delayed',
        'delayed>customs', 'delayed>out_for_delivery', 'delayed>delivered',
        'pending>exception', 'at_warehouse>exception', 'departed>exception', 'customs>exception',
        'out_for_delivery>exception', 'delayed>exception',
        'exception>departed', 'exception>customs', 'exception>out_for_delivery', 'exception>delivered']
      when 'market_accounts' then array[
        '>connecting', 'connecting>active', 'connecting>error', 'connecting>disconnected',
        'active>token_expired', 'active>error', 'active>disconnected',
        'token_expired>active', 'token_expired>disconnected', 'error>active', 'error>disconnected',
        'disconnected>connecting']
      when 'collect_jobs' then array[
        '>queued', 'queued>running', 'queued>cancelled', 'running>completed', 'running>failed',
        'running>cancelled', 'failed>queued']
      when 'listing_batches' then array[
        '>queued', 'queued>running', 'queued>cancelled', 'running>completed', 'running>failed',
        'running>cancelled', 'failed>queued']
      else array[]::text[]
    end
  );
$$;

-- 범용 상태 전이 트리거.
create or replace function globalseller.status_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if not globalseller.transition_allowed(tg_table_name, '', new.status) then
      raise exception '%: invalid initial status %', tg_table_name, new.status using errcode = 'GS001';
    end if;
  elsif new.status is distinct from old.status then
    if not globalseller.transition_allowed(tg_table_name, old.status, new.status) then
      raise exception '%: invalid transition % -> %', tg_table_name, old.status, new.status using errcode = 'GS001';
    end if;
  end if;
  return new;
end;
$$;

-- 통화 코드 검사용 도메인 규칙: ISO 4217 세 글자 대문자.
-- (도메인 타입 대신 check 로 둔다. 표마다 같은 식을 쓴다)


-- =====================================================================
-- 2. 수집: collect_groups, source_products, source_product_options, collect_presets, collect_jobs
-- =====================================================================
create table if not exists globalseller.collect_groups (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references public.organizations(id) on delete cascade,
  name        text not null constraint collect_groups_name_check check (char_length(name) between 1 and 60),
  sort_order  integer not null default 0,
  created_by  uuid,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (org_id, name),
  unique (org_id, id)
);

create table if not exists globalseller.collect_presets (
  id               uuid primary key default gen_random_uuid(),
  org_id           uuid not null references public.organizations(id) on delete cascade,
  name             text not null constraint collect_presets_name_check check (char_length(name) between 1 and 60),
  filters          jsonb not null default '{}'::jsonb constraint collect_presets_filters_check check (jsonb_typeof(filters) = 'object'),
  post_actions     jsonb not null default '{}'::jsonb constraint collect_presets_post_actions_check check (jsonb_typeof(post_actions) = 'object'),
  schedule_cron    text,
  schedule_enabled boolean not null default false,
  last_run_at      timestamptz,
  created_by       uuid,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (org_id, name),
  unique (org_id, id),
  constraint collect_presets_schedule_check check (not schedule_enabled or schedule_cron is not null)
);

create table if not exists globalseller.collect_jobs (
  id                uuid primary key default gen_random_uuid(),
  org_id            uuid not null references public.organizations(id) on delete cascade,
  method            text not null
                    constraint collect_jobs_method_check check (method in ('url', 'url_list', 'extension', 'keyword', 'schedule')),
  params            jsonb not null default '{}'::jsonb constraint collect_jobs_params_check check (jsonb_typeof(params) = 'object'),
  preset_id         uuid,
  group_id          uuid,
  status            text not null default 'queued'
                    constraint collect_jobs_status_check check (status in ('queued', 'running', 'completed', 'failed', 'cancelled')),
  total_count       integer not null default 0 constraint collect_jobs_total_check check (total_count >= 0),
  collected_count   integer not null default 0 constraint collect_jobs_collected_check check (collected_count >= 0),
  passed_count      integer not null default 0 constraint collect_jobs_passed_check check (passed_count >= 0),
  excluded_count    integer not null default 0 constraint collect_jobs_excluded_check check (excluded_count >= 0),
  exclusion_reasons jsonb not null default '{}'::jsonb,
  last_error        text,
  job_id            uuid references public.jobs(id) on delete set null,
  request_id        text,
  created_by        uuid,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  started_at        timestamptz,
  finished_at       timestamptz,
  unique (org_id, id),
  constraint collect_jobs_preset_fk foreign key (org_id, preset_id)
    references globalseller.collect_presets (org_id, id) on delete set null (preset_id),
  constraint collect_jobs_group_fk foreign key (org_id, group_id)
    references globalseller.collect_groups (org_id, id) on delete set null (group_id)
);
create unique index if not exists collect_jobs_request_uniq on globalseller.collect_jobs (org_id, request_id) where request_id is not null;

create table if not exists globalseller.source_products (
  id                     uuid primary key default gen_random_uuid(),
  org_id                 uuid not null references public.organizations(id) on delete cascade,
  group_id               uuid,
  collect_job_id         uuid,
  collect_method         text not null
                         constraint source_products_method_check check (collect_method in ('url', 'url_list', 'extension', 'keyword', 'schedule')),
  coupang_product_id     text not null constraint source_products_pid_check check (coupang_product_id ~ '^[0-9]{1,20}$'),
  coupang_item_id        text not null default '',
  coupang_vendor_item_id text,
  source_url             text not null constraint source_products_url_check check (source_url ~ '^https://(www\.|m\.)?coupang\.com/'),
  title_ko               text not null constraint source_products_title_check check (char_length(title_ko) between 1 and 300),
  brand                  text,
  seller_name            text,
  category_path          text,
  delivery_type          text not null default 'unknown'
                         constraint source_products_delivery_check check (delivery_type in ('rocket', 'rocket_growth', 'seller', 'unknown')),
  price_krw              bigint constraint source_products_price_check check (price_krw is null or price_krw >= 0),
  list_price_krw         bigint constraint source_products_list_price_check check (list_price_krw is null or list_price_krw >= 0),
  stock_status           text not null default 'unknown'
                         constraint source_products_stock_check check (stock_status in ('in_stock', 'low', 'out_of_stock', 'unknown')),
  rating                 numeric(2, 1) constraint source_products_rating_check check (rating is null or rating between 0 and 5),
  review_count           integer not null default 0 constraint source_products_reviews_check check (review_count >= 0),
  images                 jsonb not null default '[]'::jsonb constraint source_products_images_check check (jsonb_typeof(images) = 'array'),
  notice                 jsonb not null default '{}'::jsonb constraint source_products_notice_check check (jsonb_typeof(notice) = 'object'),
  review_summary         jsonb,
  estimated_weight_g     integer constraint source_products_weight_check check (estimated_weight_g is null or estimated_weight_g > 0),
  risk_level             text not null default 'ok'
                         constraint source_products_risk_check check (risk_level in ('ok', 'warn', 'block')),
  risk_flags             jsonb not null default '[]'::jsonb constraint source_products_risk_flags_check check (jsonb_typeof(risk_flags) = 'array'),
  status                 text not null default 'collected'
                         constraint source_products_status_check
                         check (status in ('collected', 'reviewing', 'ready', 'listed', 'excluded')),
  exclusion_reason       text,
  memo                   text constraint source_products_memo_check check (memo is null or char_length(memo) <= 500),
  last_checked_at        timestamptz,
  created_by             uuid,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  deleted_at             timestamptz,
  unique (org_id, id),
  constraint source_products_group_fk foreign key (org_id, group_id)
    references globalseller.collect_groups (org_id, id) on delete set null (group_id),
  constraint source_products_job_fk foreign key (org_id, collect_job_id)
    references globalseller.collect_jobs (org_id, id) on delete set null (collect_job_id)
);
create unique index if not exists source_products_coupang_uniq
  on globalseller.source_products (org_id, coupang_product_id, coupang_item_id) where deleted_at is null;
create index if not exists source_products_org_status_idx
  on globalseller.source_products (org_id, status, created_at desc) where deleted_at is null;
create index if not exists source_products_recheck_idx
  on globalseller.source_products (last_checked_at nulls first) where status = 'listed' and deleted_at is null;

create table if not exists globalseller.source_product_options (
  id                uuid primary key default gen_random_uuid(),
  org_id            uuid not null references public.organizations(id) on delete cascade,
  source_product_id uuid not null,
  option_name       text not null constraint source_product_options_name_check check (char_length(option_name) between 1 and 200),
  coupang_item_id   text,
  price_krw         bigint constraint source_product_options_price_check check (price_krw is null or price_krw >= 0),
  stock_status      text not null default 'unknown'
                    constraint source_product_options_stock_check check (stock_status in ('in_stock', 'low', 'out_of_stock', 'unknown')),
  selected          boolean not null default true,
  sort_order        integer not null default 0,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  constraint source_product_options_product_fk foreign key (org_id, source_product_id)
    references globalseller.source_products (org_id, id) on delete cascade
);
create index if not exists source_product_options_product_idx on globalseller.source_product_options (source_product_id, sort_order);


-- =====================================================================
-- 3. 마켓 계정과 템플릿: market_accounts, price_rules, shipping_templates
-- =====================================================================
create table if not exists globalseller.market_accounts (
  id                  uuid primary key default gen_random_uuid(),
  org_id              uuid not null references public.organizations(id) on delete cascade,
  market_code         text not null
                      constraint market_accounts_code_check check (market_code ~ '^[a-z][a-z0-9]{1,15}(_[a-z]{2})?$'),
  site                text constraint market_accounts_site_check check (site is null or site ~ '^[A-Z]{2}$'),
  nickname            text not null constraint market_accounts_nickname_check check (char_length(nickname) between 1 and 60),
  external_account_id text not null default '',
  auth_type           text not null
                      constraint market_accounts_auth_check check (auth_type in ('oauth', 'api_key')),
  credential_id       uuid references public.encrypted_credentials(id) on delete set null,
  scopes              text[] not null default '{}',
  token_expires_at    timestamptz,
  status              text not null default 'connecting'
                      constraint market_accounts_status_check
                      check (status in ('connecting', 'active', 'token_expired', 'error', 'disconnected')),
  currency            text not null constraint market_accounts_currency_check check (currency ~ '^[A-Z]{3}$'),
  settings            jsonb not null default '{}'::jsonb constraint market_accounts_settings_check check (jsonb_typeof(settings) = 'object'),
  sort_order          integer not null default 0,
  last_sync_at        timestamptz,
  last_error          text,
  connected_by        uuid,
  connected_at        timestamptz,
  disconnected_at     timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (org_id, id),
  unique (org_id, market_code, external_account_id)
);
comment on column globalseller.market_accounts.market_code is
  '마켓 카탈로그 코드(packages/domain/markets.ts). 예: ebay_us, amazon_us, amazon_jp, shopee_sg, shopee_th, lazada_sg, qoo10_jp, etsy';
create index if not exists market_accounts_org_idx on globalseller.market_accounts (org_id, sort_order) where status <> 'disconnected';
create index if not exists market_accounts_token_idx on globalseller.market_accounts (token_expires_at) where status = 'active';

create table if not exists globalseller.price_rules (
  id                uuid primary key default gen_random_uuid(),
  org_id            uuid not null references public.organizations(id) on delete cascade,
  name              text not null constraint price_rules_name_check check (char_length(name) between 1 and 60),
  target_margin_pct numeric(5, 2) not null default 30 constraint price_rules_target_check check (target_margin_pct between 0 and 90),
  min_margin_pct    numeric(5, 2) not null default 20 constraint price_rules_min_check check (min_margin_pct between 0 and 90),
  rounding          text not null default 'end_99'
                    constraint price_rules_rounding_check check (rounding in ('none', 'end_99', 'end_90', 'integer', 'jpy_10')),
  fx_buffer_pct     numeric(5, 2) not null default 0 constraint price_rules_fx_buffer_check check (fx_buffer_pct between 0 and 20),
  is_default        boolean not null default false,
  created_by        uuid,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (org_id, name),
  unique (org_id, id),
  constraint price_rules_margin_order_check check (min_margin_pct <= target_margin_pct)
);
create unique index if not exists price_rules_one_default_idx on globalseller.price_rules (org_id) where is_default;

create table if not exists globalseller.shipping_templates (
  id             uuid primary key default gen_random_uuid(),
  org_id         uuid not null references public.organizations(id) on delete cascade,
  name           text not null constraint shipping_templates_name_check check (char_length(name) between 1 and 60),
  carrier        text not null
                 constraint shipping_templates_carrier_check
                 check (carrier in ('epost_ems', 'k_packet', 'dhl_ecommerce', 'shopee_sls', 'other')),
  min_days       integer not null constraint shipping_templates_min_days_check check (min_days between 1 and 60),
  max_days       integer not null constraint shipping_templates_max_days_check check (max_days between 1 and 90),
  handling_days  integer not null default 2 constraint shipping_templates_handling_check check (handling_days between 0 and 30),
  cost_krw       bigint not null default 0 constraint shipping_templates_cost_check check (cost_krw >= 0),
  weight_limit_g integer constraint shipping_templates_weight_check check (weight_limit_g is null or weight_limit_g > 0),
  is_default     boolean not null default false,
  created_by     uuid,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (org_id, name),
  unique (org_id, id),
  constraint shipping_templates_days_order_check check (min_days <= max_days)
);
create unique index if not exists shipping_templates_one_default_idx on globalseller.shipping_templates (org_id) where is_default;


-- =====================================================================
-- 4. 등록: listings, listing_batches, listing_batch_items
-- =====================================================================
create table if not exists globalseller.listing_batches (
  id                   uuid primary key default gen_random_uuid(),
  org_id               uuid not null references public.organizations(id) on delete cascade,
  name                 text,
  market_account_ids   uuid[] not null constraint listing_batches_markets_check check (cardinality(market_account_ids) between 1 and 10),
  price_rule_id        uuid,
  shipping_template_id uuid,
  options              jsonb not null default '{}'::jsonb constraint listing_batches_options_check check (jsonb_typeof(options) = 'object'),
  status               text not null default 'queued'
                       constraint listing_batches_status_check check (status in ('queued', 'running', 'completed', 'failed', 'cancelled')),
  total_items          integer not null default 0 constraint listing_batches_total_check check (total_items >= 0),
  passed_items         integer not null default 0,
  warned_items         integer not null default 0,
  blocked_items        integer not null default 0,
  submitted_items      integer not null default 0,
  failed_items         integer not null default 0,
  request_id           text,
  created_by           uuid,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  started_at           timestamptz,
  finished_at          timestamptz,
  unique (org_id, id),
  constraint listing_batches_rule_fk foreign key (org_id, price_rule_id)
    references globalseller.price_rules (org_id, id) on delete set null (price_rule_id),
  constraint listing_batches_shipping_fk foreign key (org_id, shipping_template_id)
    references globalseller.shipping_templates (org_id, id) on delete set null (shipping_template_id)
);
create unique index if not exists listing_batches_request_uniq on globalseller.listing_batches (org_id, request_id) where request_id is not null;

create table if not exists globalseller.listings (
  id                   uuid primary key default gen_random_uuid(),
  org_id               uuid not null references public.organizations(id) on delete cascade,
  source_product_id    uuid,
  market_account_id    uuid not null,
  market_code          text not null,
  batch_id             uuid,
  sku                  text not null constraint listings_sku_check check (sku ~ '^[A-Za-z0-9._-]{1,50}$'),
  external_id          text,
  language             text not null default 'en'
                       constraint listings_language_check check (language in ('en', 'ja', 'th', 'zh', 'ms', 'vi', 'id', 'ko')),
  title                text not null constraint listings_title_check check (char_length(title) between 1 and 200),
  bullets              text[] not null default '{}' constraint listings_bullets_check check (cardinality(bullets) <= 10),
  description          text,
  keywords             text[] not null default '{}',
  category_id          text,
  category_path        text,
  attributes           jsonb not null default '{}'::jsonb constraint listings_attributes_check check (jsonb_typeof(attributes) = 'object'),
  images               jsonb not null default '[]'::jsonb constraint listings_images_check check (jsonb_typeof(images) = 'array'),
  currency             text not null constraint listings_currency_check check (currency ~ '^[A-Z]{3}$'),
  price_minor          bigint constraint listings_price_check check (price_minor is null or price_minor > 0),
  quantity             integer not null default 0 constraint listings_quantity_check check (quantity >= 0),
  cost_krw             bigint constraint listings_cost_check check (cost_krw is null or cost_krw >= 0),
  shipping_cost_krw    bigint constraint listings_shipping_check check (shipping_cost_krw is null or shipping_cost_krw >= 0),
  fx_rate              numeric(18, 6) constraint listings_fx_check check (fx_rate is null or fx_rate > 0),
  fee_pct              numeric(5, 2) constraint listings_fee_check check (fee_pct is null or fee_pct between 0 and 50),
  expected_margin_pct  numeric(5, 2),
  price_rule_id        uuid,
  shipping_template_id uuid,
  validation           jsonb not null default '[]'::jsonb constraint listings_validation_check check (jsonb_typeof(validation) = 'array'),
  risk_level           text not null default 'ok' constraint listings_risk_check check (risk_level in ('ok', 'warn', 'block')),
  status               text not null default 'draft'
                       constraint listings_status_check
                       check (status in ('draft', 'validating', 'ready', 'queued', 'submitting', 'live', 'error', 'paused', 'ended')),
  last_error           text,
  imported             boolean not null default false,
  submitted_at         timestamptz,
  live_at              timestamptz,
  ended_at             timestamptz,
  last_synced_at       timestamptz,
  created_by           uuid,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  unique (org_id, id),
  unique (market_account_id, sku),
  constraint listings_source_fk foreign key (org_id, source_product_id)
    references globalseller.source_products (org_id, id) on delete set null (source_product_id),
  constraint listings_account_fk foreign key (org_id, market_account_id)
    references globalseller.market_accounts (org_id, id) on delete cascade,
  constraint listings_batch_fk foreign key (org_id, batch_id)
    references globalseller.listing_batches (org_id, id) on delete set null (batch_id),
  constraint listings_rule_fk foreign key (org_id, price_rule_id)
    references globalseller.price_rules (org_id, id) on delete set null (price_rule_id),
  constraint listings_shipping_fk foreign key (org_id, shipping_template_id)
    references globalseller.shipping_templates (org_id, id) on delete set null (shipping_template_id),
  constraint listings_submit_ready_check check (status not in ('queued', 'submitting', 'live') or price_minor is not null),
  constraint listings_no_block_submit_check check (risk_level <> 'block' or status not in ('ready', 'queued', 'submitting'))
);
create index if not exists listings_org_status_idx on globalseller.listings (org_id, status, updated_at desc);
create index if not exists listings_account_status_idx on globalseller.listings (market_account_id, status);
create index if not exists listings_source_idx on globalseller.listings (source_product_id) where source_product_id is not null;
create unique index if not exists listings_external_uniq on globalseller.listings (market_account_id, external_id) where external_id is not null;

create table if not exists globalseller.listing_batch_items (
  id                uuid primary key default gen_random_uuid(),
  org_id            uuid not null references public.organizations(id) on delete cascade,
  batch_id          uuid not null,
  source_product_id uuid not null,
  market_account_id uuid not null,
  listing_id        uuid,
  verdict           text not null default 'pass' constraint listing_batch_items_verdict_check check (verdict in ('pass', 'warn', 'block')),
  reasons           jsonb not null default '[]'::jsonb constraint listing_batch_items_reasons_check check (jsonb_typeof(reasons) = 'array'),
  status            text not null default 'pending'
                    constraint listing_batch_items_status_check check (status in ('pending', 'queued', 'submitted', 'failed', 'skipped')),
  last_error        text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (batch_id, source_product_id, market_account_id),
  constraint listing_batch_items_batch_fk foreign key (org_id, batch_id)
    references globalseller.listing_batches (org_id, id) on delete cascade,
  constraint listing_batch_items_source_fk foreign key (org_id, source_product_id)
    references globalseller.source_products (org_id, id) on delete cascade,
  constraint listing_batch_items_account_fk foreign key (org_id, market_account_id)
    references globalseller.market_accounts (org_id, id) on delete cascade,
  constraint listing_batch_items_listing_fk foreign key (org_id, listing_id)
    references globalseller.listings (org_id, id) on delete set null (listing_id)
);
create index if not exists listing_batch_items_batch_idx on globalseller.listing_batch_items (batch_id, status);


-- =====================================================================
-- 5. 동기화: sync_rules, sync_events, fx_rates
-- =====================================================================
create table if not exists globalseller.sync_rules (
  id                uuid primary key default gen_random_uuid(),
  org_id            uuid not null references public.organizations(id) on delete cascade,
  market_account_id uuid,
  rule_key          text not null
                    constraint sync_rules_key_check check (rule_key in (
                      'interval_min', 'oos_zero_stock', 'cost_up_recalc', 'fx_recalc', 'min_margin_hold',
                      'price_guard', 'buybox_watch', 'jpy_round_10', 'keep_listing_oos',
                      'token_auto_refresh', 'per_country_pricing')),
  enabled           boolean not null default true,
  params            jsonb not null default '{}'::jsonb constraint sync_rules_params_check check (jsonb_typeof(params) = 'object'),
  updated_by        uuid,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  constraint sync_rules_account_fk foreign key (org_id, market_account_id)
    references globalseller.market_accounts (org_id, id) on delete cascade
);
comment on column globalseller.sync_rules.market_account_id is 'null = 조직 기본 규칙, 값 = 그 마켓 계정의 덮어쓰기';
create unique index if not exists sync_rules_scope_uniq
  on globalseller.sync_rules (org_id, coalesce(market_account_id, '00000000-0000-0000-0000-000000000000'::uuid), rule_key);

create table if not exists globalseller.sync_events (
  id                 uuid primary key default gen_random_uuid(),
  org_id             uuid not null references public.organizations(id) on delete cascade,
  source_product_id  uuid not null,
  listing_id         uuid,
  market_account_id  uuid,
  change_type        text not null
                     constraint sync_events_change_check check (change_type in ('price_up', 'price_down', 'out_of_stock', 'restock', 'fx_change')),
  before_price_krw   bigint,
  after_price_krw    bigint,
  before_stock       text,
  after_stock        text,
  currency           text constraint sync_events_currency_check check (currency is null or currency ~ '^[A-Z]{3}$'),
  before_price_minor bigint,
  after_price_minor  bigint,
  margin_after_pct   numeric(5, 2),
  status             text not null default 'detected'
                     constraint sync_events_status_check check (status in ('detected', 'applied', 'held', 'skipped', 'failed')),
  reason             text,
  job_id             uuid references public.jobs(id) on delete set null,
  approved_by        uuid,
  detected_at        timestamptz not null default now(),
  applied_at         timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  unique (org_id, id),
  constraint sync_events_source_fk foreign key (org_id, source_product_id)
    references globalseller.source_products (org_id, id) on delete cascade,
  constraint sync_events_listing_fk foreign key (org_id, listing_id)
    references globalseller.listings (org_id, id) on delete set null (listing_id),
  constraint sync_events_account_fk foreign key (org_id, market_account_id)
    references globalseller.market_accounts (org_id, id) on delete set null (market_account_id)
);
create index if not exists sync_events_org_detected_idx on globalseller.sync_events (org_id, detected_at desc);
create index if not exists sync_events_account_idx on globalseller.sync_events (market_account_id, detected_at desc);
create index if not exists sync_events_held_idx on globalseller.sync_events (org_id) where status = 'held';

-- 전 조직 공용 참조 표(org_id 없음, 규칙 (a) 예외). 쓰기는 워커 fx 크론만.
create table if not exists globalseller.fx_rates (
  id         bigint generated always as identity primary key,
  currency   text not null constraint fx_rates_currency_check check (currency ~ '^[A-Z]{3}$' and currency <> 'KRW'),
  rate_krw   numeric(18, 6) not null constraint fx_rates_rate_check check (rate_krw > 0),
  source     text not null,
  fetched_at timestamptz not null default now()
);
comment on column globalseller.fx_rates.rate_krw is '외화 1단위당 원화. 예: USD 1385.000000';
create index if not exists fx_rates_latest_idx on globalseller.fx_rates (currency, fetched_at desc);


-- =====================================================================
-- 6. 주문·발주·배송: orders, order_items, purchases, shipments, shipment_events
-- =====================================================================
create table if not exists globalseller.orders (
  id                     uuid primary key default gen_random_uuid(),
  org_id                 uuid not null references public.organizations(id) on delete cascade,
  market_account_id      uuid not null,
  market_code            text not null,
  external_order_id      text not null constraint orders_external_check check (char_length(external_order_id) between 1 and 80),
  status                 text not null default 'received'
                         constraint orders_status_check check (status in (
                           'received', 'purchase_pending', 'purchased', 'at_warehouse', 'shipped', 'delivered',
                           'cancel_requested', 'cancelled', 'return_requested', 'returned')),
  buyer_country          text constraint orders_country_check check (buyer_country is null or buyer_country ~ '^[A-Z]{2}$'),
  ship_to                jsonb,
  currency               text not null constraint orders_currency_check check (currency ~ '^[A-Z]{3}$'),
  total_minor            bigint not null constraint orders_total_check check (total_minor >= 0),
  fee_minor              bigint not null default 0 constraint orders_fee_check check (fee_minor >= 0),
  fx_rate                numeric(18, 6) constraint orders_fx_check check (fx_rate is null or fx_rate > 0),
  total_krw              bigint,
  fee_krw                bigint,
  ordered_at             timestamptz not null,
  ship_by_at             timestamptz,
  claim_reason           text,
  pii_purged_at          timestamptz,
  last_synced_at         timestamptz,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  unique (org_id, id),
  unique (market_account_id, external_order_id),
  constraint orders_account_fk foreign key (org_id, market_account_id)
    references globalseller.market_accounts (org_id, id) on delete cascade
);
comment on column globalseller.orders.ship_to is '배송지(이름·주소·전화). 배송 완료 90일 뒤 워커가 지우고 pii_purged_at 기록(제안, 01_PRD 6장)';
create index if not exists orders_org_status_idx on globalseller.orders (org_id, status, ordered_at desc);
create index if not exists orders_account_status_idx on globalseller.orders (market_account_id, status);
create index if not exists orders_ship_by_idx on globalseller.orders (ship_by_at) where status in ('received', 'purchase_pending', 'purchased', 'at_warehouse');
create index if not exists orders_profit_idx on globalseller.orders (org_id, ordered_at) where status in ('shipped', 'delivered', 'returned');

create table if not exists globalseller.order_items (
  id                uuid primary key default gen_random_uuid(),
  org_id            uuid not null references public.organizations(id) on delete cascade,
  order_id          uuid not null,
  listing_id        uuid,
  source_product_id uuid,
  external_item_id  text,
  sku               text,
  title             text not null,
  quantity          integer not null constraint order_items_qty_check check (quantity > 0),
  currency          text not null constraint order_items_currency_check check (currency ~ '^[A-Z]{3}$'),
  unit_price_minor  bigint not null constraint order_items_price_check check (unit_price_minor >= 0),
  created_at        timestamptz not null default now(),
  constraint order_items_order_fk foreign key (org_id, order_id)
    references globalseller.orders (org_id, id) on delete cascade,
  constraint order_items_listing_fk foreign key (org_id, listing_id)
    references globalseller.listings (org_id, id) on delete set null (listing_id),
  constraint order_items_source_fk foreign key (org_id, source_product_id)
    references globalseller.source_products (org_id, id) on delete set null (source_product_id)
);
create index if not exists order_items_order_idx on globalseller.order_items (order_id);

create table if not exists globalseller.purchases (
  id               uuid primary key default gen_random_uuid(),
  org_id           uuid not null references public.organizations(id) on delete cascade,
  order_id         uuid not null,
  coupang_order_no text constraint purchases_order_no_check check (coupang_order_no is null or coupang_order_no ~ '^[0-9-]{4,30}$'),
  cost_krw         bigint not null constraint purchases_cost_check check (cost_krw >= 0),
  domestic_ship_krw bigint not null default 0 constraint purchases_ship_check check (domestic_ship_krw >= 0),
  status           text not null default 'ordered'
                   constraint purchases_status_check check (status in ('ordered', 'delivered_to_warehouse', 'cancelled', 'refunded')),
  purchased_by     uuid,
  purchased_at     timestamptz not null default now(),
  memo             text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (org_id, id),
  constraint purchases_order_fk foreign key (org_id, order_id)
    references globalseller.orders (org_id, id) on delete cascade
);
create index if not exists purchases_order_idx on globalseller.purchases (order_id);

create table if not exists globalseller.shipments (
  id                    uuid primary key default gen_random_uuid(),
  org_id                uuid not null references public.organizations(id) on delete cascade,
  order_id              uuid not null,
  market_account_id     uuid not null,
  carrier               text not null
                        constraint shipments_carrier_check check (carrier in ('epost_ems', 'k_packet', 'dhl_ecommerce', 'shopee_sls', 'other')),
  tracking_no           text not null constraint shipments_tracking_check check (tracking_no ~ '^[A-Za-z0-9-]{6,40}$'),
  status                text not null default 'pending'
                        constraint shipments_status_check check (status in (
                          'pending', 'at_warehouse', 'departed', 'customs', 'out_for_delivery', 'delivered', 'delayed', 'exception')),
  cost_krw              bigint constraint shipments_cost_check check (cost_krw is null or cost_krw >= 0),
  weight_g              integer constraint shipments_weight_check check (weight_g is null or weight_g > 0),
  eta_date              date,
  warehouse_received_at timestamptz,
  departed_at           timestamptz,
  delivered_at          timestamptz,
  uploaded_to_market_at timestamptz,
  last_event_at         timestamptz,
  last_error            text,
  created_by            uuid,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (org_id, id),
  unique (carrier, tracking_no),
  constraint shipments_order_fk foreign key (org_id, order_id)
    references globalseller.orders (org_id, id) on delete cascade,
  constraint shipments_account_fk foreign key (org_id, market_account_id)
    references globalseller.market_accounts (org_id, id) on delete cascade
);
create index if not exists shipments_org_status_idx on globalseller.shipments (org_id, status, updated_at desc);
create index if not exists shipments_tracking_poll_idx on globalseller.shipments (last_event_at nulls first) where status not in ('delivered');
create index if not exists shipments_upload_pending_idx on globalseller.shipments (market_account_id) where uploaded_to_market_at is null;

create table if not exists globalseller.shipment_events (
  id          bigint generated always as identity primary key,
  org_id      uuid not null references public.organizations(id) on delete cascade,
  shipment_id uuid not null,
  occurred_at timestamptz not null,
  status      text not null
              constraint shipment_events_status_check check (status in (
                'pending', 'at_warehouse', 'departed', 'customs', 'out_for_delivery', 'delivered', 'delayed', 'exception')),
  location    text,
  description text not null default '',
  raw         jsonb,
  created_at  timestamptz not null default now(),
  unique (shipment_id, occurred_at, description),
  constraint shipment_events_shipment_fk foreign key (org_id, shipment_id)
    references globalseller.shipments (org_id, id) on delete cascade
);
create index if not exists shipment_events_shipment_idx on globalseller.shipment_events (shipment_id, occurred_at desc);


-- =====================================================================
-- 7. 건전성·마법사·알림: market_health_snapshots, readiness_answers, notification_prefs
-- =====================================================================
create table if not exists globalseller.market_health_snapshots (
  id                uuid primary key default gen_random_uuid(),
  org_id            uuid not null references public.organizations(id) on delete cascade,
  market_account_id uuid not null,
  snapshot_date     date not null,
  metrics           jsonb not null default '{}'::jsonb constraint market_health_metrics_check check (jsonb_typeof(metrics) = 'object'),
  created_at        timestamptz not null default now(),
  unique (market_account_id, snapshot_date),
  constraint market_health_account_fk foreign key (org_id, market_account_id)
    references globalseller.market_accounts (org_id, id) on delete cascade
);
comment on column globalseller.market_health_snapshots.metrics is
  '마켓별 지표 키: odr, late_shipment_rate, pre_fulfillment_cancel_rate, valid_tracking_rate, on_time_delivery_rate, seller_level, defect_rate, lsr, nfr, chat_response_rate, api_usage_pct';

create table if not exists globalseller.readiness_answers (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references public.organizations(id) on delete cascade,
  answers     jsonb not null constraint readiness_answers_check check (
                jsonb_typeof(answers) = 'object'
                and answers ? 'biz' and answers ? 'tel' and answers ? 'pay' and answers ? 'card'
                and answers ? 'region' and answers ? 'cat' and answers ? 'budget'),
  answered_by uuid,
  created_at  timestamptz not null default now()
);
create index if not exists readiness_answers_latest_idx on globalseller.readiness_answers (org_id, created_at desc);

create table if not exists globalseller.notification_prefs (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references public.organizations(id) on delete cascade,
  user_id    uuid,
  channel    text not null constraint notification_prefs_channel_check check (channel in ('email', 'slack')),
  event_key  text not null
             constraint notification_prefs_event_check check (event_key in (
               'order_received', 'api_error', 'daily_sales', 'weekly_report', 'price_anomaly', 'renewal_notice')),
  enabled    boolean not null default true,
  settings   jsonb not null default '{}'::jsonb constraint notification_prefs_settings_check check (jsonb_typeof(settings) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on column globalseller.notification_prefs.settings is 'Slack 채널 이름 등 비밀이 아닌 값만. Slack 웹훅 URL 은 encrypted_credentials(provider slack)';
create unique index if not exists notification_prefs_uniq
  on globalseller.notification_prefs (org_id, coalesce(user_id, '00000000-0000-0000-0000-000000000000'::uuid), channel, event_key);


-- =====================================================================
-- 8. 트리거: updated_at, 상태 전이, 쓰기 잠금(service_role/DEFINER 만), 상품 수 한도
-- =====================================================================
do $$
declare t text;
begin
  foreach t in array array[
    'collect_groups', 'collect_presets', 'collect_jobs', 'source_products', 'source_product_options',
    'market_accounts', 'price_rules', 'shipping_templates', 'listing_batches', 'listings', 'listing_batch_items',
    'sync_rules', 'sync_events', 'orders', 'purchases', 'shipments', 'notification_prefs']
  loop
    execute format('drop trigger if exists %I on globalseller.%I', t || '_set_updated_at', t);
    execute format('create trigger %I before update on globalseller.%I for each row execute function public.set_updated_at()',
                   t || '_set_updated_at', t);
  end loop;

  foreach t in array array[
    'source_products', 'listings', 'sync_events', 'orders', 'shipments', 'market_accounts', 'collect_jobs', 'listing_batches']
  loop
    execute format('drop trigger if exists %I on globalseller.%I', t || '_status_guard', t);
    execute format('create trigger %I before insert or update of status on globalseller.%I for each row execute function globalseller.status_guard()',
                   t || '_status_guard', t);
  end loop;

  foreach t in array array[
    'collect_groups', 'collect_presets', 'collect_jobs', 'source_products', 'source_product_options',
    'market_accounts', 'price_rules', 'shipping_templates', 'listing_batches', 'listings', 'listing_batch_items',
    'sync_rules', 'sync_events', 'fx_rates', 'orders', 'order_items', 'purchases', 'shipments', 'shipment_events',
    'market_health_snapshots', 'readiness_answers', 'notification_prefs']
  loop
    execute format('drop trigger if exists %I on globalseller.%I', t || '_guard_write', t);
    execute format('create trigger %I before insert or update or delete on globalseller.%I for each row execute function public.guard_privileged_write()',
                   t || '_guard_write', t);
  end loop;
end $$;

-- 상품 수 한도(features.gs_products_max). 동시 INSERT 경쟁은 조직 단위 advisory lock 으로 직렬화한다.
create or replace function globalseller.source_products_enforce_quota()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_limit integer;
  v_count integer;
begin
  v_limit := globalseller.plan_limit(new.org_id, 'gs_products_max', 0);
  if v_limit = -1 then
    return new;
  end if;
  perform pg_advisory_xact_lock(hashtext('globalseller:products:' || new.org_id::text));
  select count(*) into v_count from globalseller.source_products s
   where s.org_id = new.org_id and s.deleted_at is null and s.status <> 'excluded';
  if v_count >= v_limit then
    raise exception 'source_products: plan limit % reached', v_limit using errcode = 'GS003';
  end if;
  return new;
end;
$$;
drop trigger if exists source_products_quota on globalseller.source_products;
create trigger source_products_quota before insert on globalseller.source_products
  for each row execute function globalseller.source_products_enforce_quota();

-- 마켓 계정 수 한도(features.gs_markets_max). disconnected 는 세지 않는다.
create or replace function globalseller.market_accounts_enforce_quota()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_limit integer;
  v_count integer;
begin
  if tg_op = 'UPDATE' and not (old.status = 'disconnected' and new.status <> 'disconnected') then
    return new;
  end if;
  v_limit := globalseller.plan_limit(new.org_id, 'gs_markets_max', 0);
  if v_limit = -1 then
    return new;
  end if;
  perform pg_advisory_xact_lock(hashtext('globalseller:markets:' || new.org_id::text));
  select count(*) into v_count from globalseller.market_accounts m
   where m.org_id = new.org_id and m.status <> 'disconnected' and m.id <> new.id;
  if v_count >= v_limit then
    raise exception 'market_accounts: plan limit % reached', v_limit using errcode = 'GS003';
  end if;
  return new;
end;
$$;
drop trigger if exists market_accounts_quota on globalseller.market_accounts;
create trigger market_accounts_quota before insert or update of status on globalseller.market_accounts
  for each row execute function globalseller.market_accounts_enforce_quota();


-- =====================================================================
-- 9. 뷰: v_profit_monthly, v_market_tab_counts (security_invoker: 호출자 RLS 적용)
-- =====================================================================
create or replace view globalseller.v_profit_monthly
with (security_invoker = true)
as
with o as (
  select o.org_id, o.market_account_id, o.market_code,
         date_trunc('month', o.ordered_at at time zone 'Asia/Seoul')::date as month,
         o.id, coalesce(o.total_krw, 0) as revenue_krw, coalesce(o.fee_krw, 0) as fee_krw, o.status
  from globalseller.orders o
  where o.status in ('shipped', 'delivered', 'return_requested', 'returned')
), p as (
  select pu.order_id, sum(pu.cost_krw + pu.domestic_ship_krw) as purchase_krw
  from globalseller.purchases pu
  where pu.status in ('ordered', 'delivered_to_warehouse')
  group by pu.order_id
), s as (
  select sh.order_id, sum(coalesce(sh.cost_krw, 0)) as shipping_krw
  from globalseller.shipments sh
  group by sh.order_id
)
select o.org_id, o.month, o.market_account_id, o.market_code,
       count(*)                                                   as order_count,
       count(*) filter (where o.status = 'returned')              as returned_count,
       sum(o.revenue_krw) filter (where o.status <> 'returned')   as revenue_krw,
       sum(o.fee_krw) filter (where o.status <> 'returned')       as fee_krw,
       sum(coalesce(p.purchase_krw, 0))                           as purchase_krw,
       sum(coalesce(s.shipping_krw, 0))                           as shipping_krw,
       sum(case when o.status = 'returned' then -coalesce(p.purchase_krw, 0) - coalesce(s.shipping_krw, 0)
                else o.revenue_krw - o.fee_krw - coalesce(p.purchase_krw, 0) - coalesce(s.shipping_krw, 0) end)
                                                                  as net_profit_krw
from o
left join p on p.order_id = o.id
left join s on s.order_id = o.id
group by o.org_id, o.month, o.market_account_id, o.market_code;

create or replace view globalseller.v_market_tab_counts
with (security_invoker = true)
as
select m.org_id, m.id as market_account_id, m.market_code, m.nickname, m.sort_order,
       (select count(*) from globalseller.listings l
         where l.market_account_id = m.id and l.status in ('live', 'paused'))                               as sync_count,
       (select count(*) from globalseller.orders o
         where o.market_account_id = m.id
           and o.status in ('received', 'purchase_pending', 'purchased', 'at_warehouse', 'cancel_requested', 'return_requested')) as orders_count,
       (select count(*) from globalseller.shipments s
         where s.market_account_id = m.id
           and s.status in ('pending', 'at_warehouse', 'departed', 'customs', 'out_for_delivery', 'delayed', 'exception')) as shipping_count,
       (select count(*) from globalseller.sync_events e
         where e.market_account_id = m.id and e.status in ('held', 'failed'))                               as sync_alert_count
from globalseller.market_accounts m
where m.status <> 'disconnected';


-- =====================================================================
-- 10. RPC (SECURITY DEFINER) — DESIGN_STRUCTURE.md 11.2
-- =====================================================================

-- 수집 잡 생성. Route Handler(service_role)만 부른다. 수집은 무료, 플랜 엔타이틀먼트와 상품 한도만 확인.
create or replace function globalseller.enqueue_collect_job(
  p_org_id     uuid,
  p_method     text,
  p_params     jsonb,
  p_request_id text,
  p_preset_id  uuid default null,
  p_group_id   uuid default null,
  p_actor_id   uuid default null
)
returns globalseller.collect_jobs
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row   globalseller.collect_jobs;
  v_job   public.jobs;
  v_limit integer;
  v_count integer;
begin
  if not public.is_service_caller() then
    raise exception 'enqueue_collect_job: service_role only' using errcode = '42501';
  end if;
  if not public.has_entitlement(p_org_id, 'globalseller') then
    raise exception 'enqueue_collect_job: no entitlement' using errcode = 'GS002';
  end if;
  if p_request_id is null or char_length(p_request_id) not between 8 and 80 then
    raise exception 'enqueue_collect_job: request_id required' using errcode = '22023';
  end if;
  if p_method = 'schedule'
     and coalesce((globalseller.features(p_org_id) ->> 'gs_scheduled_collect')::boolean, false) is not true then
    raise exception 'enqueue_collect_job: % not in plan', p_method using errcode = 'GS004';
  end if;
  select * into v_row from globalseller.collect_jobs c where c.org_id = p_org_id and c.request_id = p_request_id;
  if found then
    return v_row;
  end if;
  v_limit := globalseller.plan_limit(p_org_id, 'gs_products_max', 0);
  if v_limit <> -1 then
    select count(*) into v_count from globalseller.source_products s
     where s.org_id = p_org_id and s.deleted_at is null and s.status <> 'excluded';
    if v_count >= v_limit then
      raise exception 'enqueue_collect_job: plan limit % reached', v_limit using errcode = 'GS003';
    end if;
  end if;
  insert into globalseller.collect_jobs (org_id, method, params, preset_id, group_id, request_id, created_by)
  values (p_org_id, p_method, coalesce(p_params, '{}'::jsonb), p_preset_id, p_group_id, p_request_id, p_actor_id)
  returning * into v_row;
  v_job := public.enqueue_job(
    p_org_id, 'globalseller', 'globalseller.collect', 'collect.' || p_method,
    jsonb_build_object('collect_job_id', v_row.id, 'method', p_method),
    100, now(), 3, null, 'job:globalseller:collect:' || p_request_id, null, p_actor_id, false);
  update globalseller.collect_jobs set job_id = v_job.id where id = v_row.id returning * into v_row;
  return v_row;
end;
$$;

-- 승인 대기(held) 변동을 반영 대기열로. owner·admin·member 가 부른다.
create or replace function globalseller.approve_sync_event(p_event_id uuid)
returns globalseller.sync_events
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row globalseller.sync_events;
  v_job public.jobs;
begin
  select * into v_row from globalseller.sync_events e where e.id = p_event_id for update;
  if not found then
    raise exception 'approve_sync_event: not found' using errcode = 'P0002';
  end if;
  if not public.is_service_caller()
     and not public.has_org_role(v_row.org_id, array['owner', 'admin', 'member']) then
    raise exception 'approve_sync_event: not allowed' using errcode = '42501';
  end if;
  if not public.has_entitlement(v_row.org_id, 'globalseller') then
    raise exception 'approve_sync_event: no entitlement' using errcode = 'GS002';
  end if;
  if v_row.status <> 'held' then
    raise exception 'approve_sync_event: status is %', v_row.status using errcode = 'GS005';
  end if;
  v_job := public.enqueue_job(
    v_row.org_id, 'globalseller', 'globalseller.sync', 'sync.apply_event',
    jsonb_build_object('sync_event_id', v_row.id), 50, now(), 3, null,
    'job:globalseller:sync_approve:' || v_row.id::text, null, auth.uid(), false);
  update globalseller.sync_events
     set approved_by = auth.uid(), job_id = v_job.id
   where id = p_event_id
  returning * into v_row;
  perform public.write_audit(v_row.org_id, 'globalseller.sync_event.approved', 'sync_event', p_event_id::text,
                             null, null, jsonb_build_object('change_type', v_row.change_type, 'margin_after_pct', v_row.margin_after_pct));
  return v_row;
end;
$$;

-- 쿠팡 발주 기록. 주문을 purchased 로 바꾸고 원가를 남긴다. owner·admin·member.
create or replace function globalseller.record_purchase(
  p_order_id          uuid,
  p_coupang_order_no  text,
  p_cost_krw          bigint,
  p_domestic_ship_krw bigint default 0,
  p_memo              text default null
)
returns globalseller.purchases
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_order globalseller.orders;
  v_row   globalseller.purchases;
begin
  select * into v_order from globalseller.orders o where o.id = p_order_id for update;
  if not found then
    raise exception 'record_purchase: order not found' using errcode = 'P0002';
  end if;
  if not public.is_service_caller()
     and not public.has_org_role(v_order.org_id, array['owner', 'admin', 'member']) then
    raise exception 'record_purchase: not allowed' using errcode = '42501';
  end if;
  if not public.has_entitlement(v_order.org_id, 'globalseller') then
    raise exception 'record_purchase: no entitlement' using errcode = 'GS002';
  end if;
  if v_order.status not in ('received', 'purchase_pending') then
    raise exception 'record_purchase: order status is %', v_order.status using errcode = 'GS006';
  end if;
  if p_cost_krw is null or p_cost_krw < 0 or coalesce(p_domestic_ship_krw, 0) < 0 then
    raise exception 'record_purchase: invalid amount' using errcode = '22023';
  end if;
  insert into globalseller.purchases (org_id, order_id, coupang_order_no, cost_krw, domestic_ship_krw, purchased_by, memo)
  values (v_order.org_id, p_order_id, nullif(btrim(p_coupang_order_no), ''), p_cost_krw, coalesce(p_domestic_ship_krw, 0),
          auth.uid(), left(p_memo, 500))
  returning * into v_row;
  if v_order.status = 'received' then
    update globalseller.orders set status = 'purchase_pending' where id = p_order_id;
  end if;
  update globalseller.orders set status = 'purchased' where id = p_order_id;
  perform public.write_audit(v_order.org_id, 'globalseller.order.purchased', 'order', p_order_id::text,
                             null, null, jsonb_build_object('cost_krw', p_cost_krw));
  return v_row;
end;
$$;

-- 마켓 탭 배지 숫자. p_screen: sync | orders | shipping. 조직 멤버만(뷰가 RLS 를 따른다).
create or replace function globalseller.market_tab_counts(p_org_id uuid, p_screen text)
returns table (market_account_id uuid, market_code text, nickname text, sort_order integer, badge bigint, alert bigint)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_service_caller() and not public.is_org_member(p_org_id) then
    raise exception 'market_tab_counts: not a member' using errcode = '42501';
  end if;
  if p_screen not in ('sync', 'orders', 'shipping') then
    raise exception 'market_tab_counts: unknown screen %', p_screen using errcode = '22023';
  end if;
  return query
  select v.market_account_id, v.market_code, v.nickname, v.sort_order,
         case p_screen when 'sync' then v.sync_count when 'orders' then v.orders_count else v.shipping_count end,
         case p_screen when 'sync' then v.sync_alert_count else 0::bigint end
  from globalseller.v_market_tab_counts v
  where v.org_id = p_org_id
  order by v.sort_order, v.market_account_id;
end;
$$;

-- 플랜 한도 대비 사용량(계정 > 구독 플랜 탭). 조직 멤버만.
create or replace function globalseller.plan_usage(p_org_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_features jsonb;
  v_month    timestamptz := date_trunc('month', now() at time zone 'Asia/Seoul') at time zone 'Asia/Seoul';
begin
  if not public.is_service_caller() and not public.is_org_member(p_org_id) then
    raise exception 'plan_usage: not a member' using errcode = '42501';
  end if;
  v_features := globalseller.features(p_org_id);
  return jsonb_build_object(
    'products', jsonb_build_object(
      'used', (select count(*) from globalseller.source_products s
                where s.org_id = p_org_id and s.deleted_at is null and s.status <> 'excluded'),
      'limit', coalesce((v_features ->> 'gs_products_max')::integer, 0)),
    'markets', jsonb_build_object(
      'used', (select count(*) from globalseller.market_accounts m where m.org_id = p_org_id and m.status <> 'disconnected'),
      'limit', coalesce((v_features ->> 'gs_markets_max')::integer, 0)),
    'ai_translations', jsonb_build_object(
      'used', (select greatest(coalesce(sum(-l.amount), 0), 0) from public.credit_ledger l
                where l.org_id = p_org_id and l.app_id = 'globalseller'
                  and l.entry_type in ('consume', 'refund') and l.created_at >= v_month),
      'limit', coalesce((v_features ->> 'gs_ai_translations_month')::integer, 0)),
    'members', jsonb_build_object(
      'used', (select count(*) from public.org_members om where om.org_id = p_org_id and om.status in ('active', 'invited')),
      'limit', coalesce((v_features ->> 'gs_members_max')::integer, 0))
  );
end;
$$;


-- =====================================================================
-- 11. RLS 와 GRANT — 사용자는 SELECT 만(조직 멤버). 쓰기는 service_role 과 위 RPC.
-- =====================================================================
do $$
declare t text;
begin
  foreach t in array array[
    'collect_groups', 'collect_presets', 'collect_jobs', 'source_products', 'source_product_options',
    'market_accounts', 'price_rules', 'shipping_templates', 'listing_batches', 'listings', 'listing_batch_items',
    'sync_rules', 'sync_events', 'orders', 'order_items', 'purchases', 'shipments', 'shipment_events',
    'market_health_snapshots', 'readiness_answers', 'notification_prefs']
  loop
    execute format('alter table globalseller.%I enable row level security', t);
    execute format('revoke all on table globalseller.%I from public, anon, authenticated', t);
    execute format('grant all on table globalseller.%I to service_role', t);
    execute format('grant select on table globalseller.%I to authenticated', t);
    execute format('drop policy if exists %I on globalseller.%I', t || '_select', t);
    execute format('create policy %I on globalseller.%I for select to authenticated using (public.is_org_member(org_id))',
                   t || '_select', t);
  end loop;
end $$;

-- 배송지(ship_to)는 viewer 에게 보이지 않게 컬럼 권한을 뺀다(주문 화면은 서버가 마스킹해 내려준다).
revoke select on table globalseller.orders from authenticated;
grant select (id, org_id, market_account_id, market_code, external_order_id, status, buyer_country, currency,
              total_minor, fee_minor, fx_rate, total_krw, fee_krw, ordered_at, ship_by_at, claim_reason,
              pii_purged_at, last_synced_at, created_at, updated_at)
  on table globalseller.orders to authenticated;

-- 알림 설정: 다른 사용자의 개인 행은 숨긴다(조직 기본 행 user_id null 은 모두에게 보임).
drop policy if exists notification_prefs_select on globalseller.notification_prefs;
create policy notification_prefs_select on globalseller.notification_prefs for select to authenticated
  using (public.is_org_member(org_id) and (user_id is null or user_id = auth.uid()));

-- fx_rates: 로그인 사용자 누구나 읽기(공용 참조), 쓰기는 service_role.
alter table globalseller.fx_rates enable row level security;
revoke all on table globalseller.fx_rates from public, anon, authenticated;
grant all on table globalseller.fx_rates to service_role;
grant select on table globalseller.fx_rates to authenticated;
drop policy if exists fx_rates_select on globalseller.fx_rates;
create policy fx_rates_select on globalseller.fx_rates for select to authenticated using (true);

-- 뷰
revoke all on table globalseller.v_profit_monthly, globalseller.v_market_tab_counts from public, anon, authenticated;
grant select on table globalseller.v_profit_monthly, globalseller.v_market_tab_counts to authenticated, service_role;

-- 시퀀스(identity)
grant usage, select on all sequences in schema globalseller to service_role;

-- 함수: 기본 회수 후 필요한 것만
revoke execute on all functions in schema globalseller from public, anon, authenticated;
grant execute on all functions in schema globalseller to service_role;
grant execute on function globalseller.approve_sync_event(uuid) to authenticated;
grant execute on function globalseller.record_purchase(uuid, text, bigint, bigint, text) to authenticated;
grant execute on function globalseller.market_tab_counts(uuid, text) to authenticated;
grant execute on function globalseller.plan_usage(uuid) to authenticated;
-- 트리거·뷰 내부에서 쓰는 헬퍼(RLS 정책 평가는 호출자 권한)
grant execute on function globalseller.transition_allowed(text, text, text) to authenticated;
grant execute on function globalseller.features(uuid) to authenticated;
grant execute on function globalseller.plan_limit(uuid, text, integer) to authenticated;


-- =====================================================================
-- 12. Realtime: 진행률·목록 갱신 구독(RLS 하에서)
-- =====================================================================
do $$
declare t text;
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach t in array array['collect_jobs', 'listing_batches', 'listings', 'sync_events', 'orders', 'shipments']
    loop
      if not exists (select 1 from pg_publication_tables
                     where pubname = 'supabase_realtime' and schemaname = 'globalseller' and tablename = t) then
        execute format('alter publication supabase_realtime add table globalseller.%I', t);
      end if;
    end loop;
  end if;
end $$;
