# supabase-expert — pitfalls (리뷰 1순위 체크리스트)

| # | 함정 | 증상 · 위험 | 확인 방법 |
|---|---|---|---|
| 1 | 테이블에 RLS 미설정 | 공개 키로 전 조직 데이터 접근 | `enable row level security` 유무 |
| 2 | 정책이 `true`로 열려 있음 (`USING(true)`, `FOR ALL`) | 사실상 무방비 | 정책 using/with check |
| 3 | 조직 판정을 사용자 수정 가능 값으로 | 다른 조직 데이터 접근 | 정책이 코어 헬퍼를 쓰는가 |
| 4 | update 정책에 with check 누락 | 행을 다른 조직으로 옮김 | update 정책 |
| 5 | 뷰어 역할에 쓰기 허용 | 권한 우회 | insert/update/delete 정책의 역할 |
| 6 | 정책 컬럼 인덱스 없음 | 전 쿼리 지연 | `org_id` 인덱스 |
| 7 | 기존 마이그레이션 · 코어 lite 사본 수정 | 환경 간 스키마 불일치 | git 이력의 기존 파일 변경 |
| 8 | 금액 컬럼을 `numeric`/`float`로, 외화에 `currency` 누락 | 실수 오차 · 통화 혼동 | 컬럼 타입 |
| 9 | 주문 · 발주 · 리스팅 외부 id 고유 제약 누락 | 같은 주문 두 번 발주, 중복 리스팅 | 제약 유무 |
| 10 | 평문 토큰 · API 키 컬럼 | 마켓 계정 탈취 | 컬럼 이름 · 타입, `encrypted_credentials` 참조 여부 |
| 11 | service role 키 노출 | 전권 노출 | Grep `service_role`, 환경 변수 |
| 12 | `security definer` 함수의 `search_path` 미고정 · 권한 미확인 | 권한 상승 | 함수 정의 |
| 13 | 뷰가 RLS 를 우회 (`security_invoker` 없음) | 수익 집계에서 다른 조직 노출 | 뷰 옵션 |
| 14 | 상태 check 값이 `DESIGN_STRUCTURE.md` 5.1절과 다름 | 화면 상태 그룹 누락 | check 제약 |
| 15 | 생성 타입을 직접 수정 | 재생성 시 소실 | 타입 파일 diff |
| 16 | 시드에 실데이터 · 키 · 실제 주소 | 정보 유출 | seed 파일 |
| 17 | 구매자 개인정보에 보존 기간 · 파기 경로 없음 | 개인정보 과다 보관 | 컬럼 분리 · 파기 함수 |
