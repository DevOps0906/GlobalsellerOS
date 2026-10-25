-- =====================================================================
-- 20261025000003_readiness_values_and_metric_keys.sql
-- 작성일 2026-10-25. 기존 마이그레이션(0001, 0002)은 고치지 않고 이 파일로 덧붙인다(CLAUDE.md 5장).
--
-- 1. 마켓 추가 마법사 여건 진단 답변(readiness_answers.answers)의 허용 값을 고정한다.
--    값 목록 정본: docs/설계/DESIGN_STRUCTURE.md 4.1절, 원본 prototype/index.html 마법사 1단계.
--    0002 의 readiness_answers_check(키 7개 존재만 확인)를 값까지 확인하는 제약으로 바꾼다.
-- 2. market_health_snapshots.metrics, market_accounts.settings 의 키 설명을 S-05·S-06 마켓 지표 띠에 맞춰 갱신한다.
--    (설명만 바꾼다. 키 제약은 두지 않는다: 마켓 지표는 마켓 정책에 따라 늘어나며, 쓰는 쪽은 워커 health 크론 하나다.)
-- 2번 실행해도 같은 결과가 나온다(drop if exists → add).
-- =====================================================================

-- 1. 여건 진단 답변 값 ------------------------------------------------------
alter table globalseller.readiness_answers
  drop constraint if exists readiness_answers_check;
alter table globalseller.readiness_answers
  drop constraint if exists readiness_answers_values_check;

alter table globalseller.readiness_answers
  add constraint readiness_answers_values_check check (
    jsonb_typeof(answers) = 'object'
    -- 단일 선택 5문항
    and answers->>'biz'    in ('ind', 'corp', 'none')          -- 사업자 형태: 개인사업자 · 법인사업자 · 아직 없음
    and answers->>'tel'    in ('yes', 'no')                    -- 통신판매업 신고: 완료 · 아직
    and answers->>'pay'    in ('global', 'fx', 'none')         -- 해외 수취 계좌: 글로벌 수취 계좌 · 국내 은행 외화 계좌 · 아직 없음
    and answers->>'card'   in ('yes', 'no')                    -- 해외 결제 카드: 있음 · 없음
    and answers->>'budget' in ('0', '50', 'any')               -- 월 고정비 예산: 0원 · 월 $50 이하 · 상관없음
    -- 복수 선택 2문항: 1개 이상, 허용 값만
    and jsonb_typeof(answers->'region') = 'array'
    and jsonb_array_length(answers->'region') between 1 and 4
    and (answers->'region') <@ '["na", "jp", "sea", "eu"]'::jsonb          -- 북미 · 일본 · 동남아 · 유럽
    and jsonb_typeof(answers->'cat') = 'array'
    and jsonb_array_length(answers->'cat') between 1 and 5
    and (answers->'cat') <@ '["beauty", "food", "living", "elec", "craft"]'::jsonb  -- 뷰티 · 식품 · 리빙·주방 · 전자기기 · 공예·전통
  );

comment on column globalseller.readiness_answers.answers is
  '여건 진단 7문항. biz(ind|corp|none), tel(yes|no), pay(global|fx|none), card(yes|no), budget(0|50|any), '
  'region[](na|jp|sea|eu, 1~4개), cat[](beauty|food|living|elec|craft, 1~5개). 정본 DESIGN_STRUCTURE.md 4.1절';

-- 2. 마켓 지표·설정 키 설명 --------------------------------------------------
comment on column globalseller.market_health_snapshots.metrics is
  '마켓별 지표 키(정본 DESIGN_STRUCTURE.md 3.1절). '
  '주문(S-05): odr, late_shipment_rate, pre_fulfillment_cancel_rate, response_24h_rate, seller_level, defect_rate, late_delivery_rate, unanswered_messages, lsr, nfr, chat_response_rate. '
  '배송(S-06): valid_tracking_rate, on_time_delivery_rate, tracking_upload_rate, delayed_shipments. '
  '동기화(S-04): api_usage_pct, last_sync_at';

comment on column globalseller.market_accounts.settings is
  '마켓 계정 설정(비밀 값 금지, 정본 DESIGN_STRUCTURE.md 3.1절). '
  'order_import_interval_min, price_rule_id, shipping_template_id, currency, stock_buffer, import_existing_listings, add_ops_tabs, '
  'handling_days(eBay·Amazon US), lead_time_days(Amazon JP), dts_days(Shopee), shipping_service(eBay), logistics(Shopee: sls), '
  'seller_center_url(판매자센터 바로가기)';
