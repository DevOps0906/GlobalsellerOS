# 08 디자인 시스템: GlobalSeller OS (globalseller-os)

작성일 2026-10-25. 이 제품의 디자인 시스템은 앱 UI 한 층이다(영상·브랜드 키트 없음). 값은 프로토타입 `prototype/index.html`의 CSS에서 그대로 뽑았고(근거 `prototype/index.html:줄`), 이름은 Tailwind CSS v4 `@theme` 토큰으로 바꿨다. 공통 규칙은 `platform-docs/products/_design-guide/DESIGN_SYSTEM.md`(정답 소스, 4단계 워크플로, 금지 사항), 앱 화면 구조는 `DASHBOARD_PATTERNS.md`를 따른다. 화면 목록과 플로우는 `03_SCREENS_UX.md`, 컴포넌트 이름의 정본은 `07_SOURCE_MIGRATION.md` 2.1절.

## 0. 정답 소스

| 대상 | 정답(코드) | 문서 | 확인 |
|---|---|---|---|
| 앱 토큰 | `apps/web/styles/tokens.css`(Tailwind CSS v4 `@theme`, 라이트/다크, 반응형 글자 크기 변수) | 이 문서 3장 | `/dev/components` 라이트/다크 × 390·1024·1440px 스크린샷 |
| 기본 컴포넌트 | `apps/web/components/ui/`(shadcn/ui 복사본을 토큰으로 재스타일) | 11.1절 | 같음 |
| 제품 컴포넌트 | `apps/web/components/<영역>/` | 11.2절, `07_SOURCE_MIGRATION.md` 2.1절 | 같음 + `/sync-design`로 프로토타입과 비교 |
| 비교 기준 화면 | `prototype/index.html`(2026-10-23판, 동결) | `docs/설계/DESIGN_STRUCTURE.md` | `tests/prototype-smoke.js` |

- 프로토타입은 "구조·값의 출발점"이고 정답은 `tokens.css`다. 토큰 값을 바꾸면 이 문서 3장을 같이 고친다. 피그마는 쓰지 않는다.
- 스택 표기: Next.js 16.x(App Router), React 19.x, Tailwind CSS v4.x, shadcn/ui(Tailwind CSS v4 지원 버전). "Tailwind"만 쓰지 않고 항상 "Tailwind CSS v4"로 쓴다(`platform-docs/products/_design-guide/DESIGN_SYSTEM.md` 6장). `tailwind.config.js` 금지.
- 컴포넌트·화면 코드에 hex·oklch 리터럴 금지(`bg-[#...]` 린트 차단, 제안). 모두 토큰 변수로.

## 1. 레퍼런스와 방향 (`DESIGN_SYSTEM.md` 4장 1단계)

| 화면 성격 | 주 레퍼런스 | 보조 | 가져올 패턴 | 가져오지 않을 것 |
|---|---|---|---|---|
| 운영 화면(동기화·주문·배송) | Primer(밀도, 상태 표시, 표) | Atlassian(필터·상태 배지) | 마켓 탭 바 + 지표 띠 + KPI 5칸 + 표(구조 문서 3장), 상태 그룹 세그먼트 | 같은 크기 카드만 늘어놓는 SaaS 카드 키트 |
| 등록·수집 편집 | Atlassian(단계 폼, 검증) | Primer | 번호 붙은 단계 카드 + 우측 고정 검증 요약(`EditLayout`) | 한 화면에 모든 입력을 펼친 긴 폼 |
| 수익 분석 | Primer | - | 단일 색상 막대 + 값 직접 표시, 비용 구조 키-값 목록 | 장식용 다색 차트, 3D 차트 |
| 계정·설정 | Primer | - | 좌측 탭 목록 + 우측 패널 | 설정을 모달 여러 개로 쪼개기 |
| 마켓 추가 마법사 | Sellbrite 채널 연결 흐름(구조만) | - | 단계 표시 + 추천 카드 + 권한 목록 | 마켓 로고를 제휴처럼 크게 쓰기 |
| 랜딩 | 03장 4절 | - | 03장 4.1절 | 대시보드 스크린숏을 실적처럼 쓰기 |

## 2. 브리프와 디자인 원칙

| 항목 | 내용 |
|---|---|
| 주제 | 국경을 넘는 상품 흐름(쿠팡 → 수집함 → 해외 마켓 → 주문 → 배송), 마켓마다 다른 규칙 |
| 대상 | 역직구 셀러와 소규모 팀. 하루에 여러 번 들어와 처리할 일을 확인한다 |
| 주된 일 | 오늘 처리할 일(발주 대기, 승인 대기, 송장 미등록)을 찾아 끝내고, 마켓별 계정 건전성을 지킨다 |
| 고유 어휘 | 원가(₩)와 판매가($)를 나란히, 마켓 고유색 점, 발송 기한, ODR·LSR 같은 마켓 지표 |
| 피할 인상 | 보라·핑크 그라디언트 AI 툴, 지구본·비행기 일러스트, 이모지 아이콘, 모든 숫자를 큰 카드로 |

| # | 원칙 | 적용 |
|---|---|---|
| 1 | 색은 의미에만 | 앱 크롬은 무채색 중립 + 브랜드 파랑 1개. 마켓 고유색은 작은 점·태그에만, 상태색은 상태 표시에만 |
| 2 | 원화와 외화를 함께 | 금액은 통화 기호와 함께 표시하고, 원가(₩)와 판매가(외화)를 같은 줄에 둔다. 숫자는 tabular-nums |
| 3 | 처리할 일이 먼저 | 운영 화면 전체 탭의 첫 줄은 "오늘 처리할 일" 지표 띠(구조 문서 3장) |
| 4 | 마켓 차이는 탭 안에서 | 마켓 전용 규칙·지표는 그 마켓 탭에서만 보인다. 전체 탭에 섞지 않는다 |
| 5 | 돈·권리·위험은 버튼 옆에 | 크레딧 비용, 리스크 검사 결과, 승인 필요 여부를 전송 버튼 바로 옆에 둔다 |

## 3. 앱 토큰

### 3.1 색

라이트가 기본. 다크는 3.5절. 값은 `prototype/index.html:12-64`(라이트), `:66-96`(다크).

| 이름 | 라이트 | 다크 | Tailwind CSS v4 토큰 | 프로토타입 변수 | 용도 |
|---|---|---|---|---|---|
| 브랜드 | oklch(0.55 0.20 255) | 같음 | `--color-brand` | `--brand` | 주 버튼, 선택 탭, 링크, 진행 막대 |
| 브랜드 호버 | oklch(0.49 0.20 255) | 같음 | `--color-brand-hover` | `--brand-h` | 주 버튼 호버 |
| 브랜드 위 글자 | #ffffff | 같음 | `--color-brand-fg` | `--brand-fg` | 주 버튼 글자 |
| 브랜드 옅은 배경 | oklch(0.96 0.04 255) | oklch(0.22 0.07 255) | `--color-brand-subtle` | `--brand-subtle` | 선택 행, 단계 번호, 칩 |
| 보조 | oklch(0.60 0.18 195) | 같음 | `--color-accent` | `--accent` | 로고 그라디언트 끝색, 보조 강조(드물게) |
| 바탕 | #f5f7fc | #080b12 | `--color-bg` | `--bg` | 페이지 바탕 |
| 표면 | #ffffff | #0f1420 | `--color-surface` | `--surface` | 카드, 입력, 모달 |
| 표면 2 | #eef1f8 | #161c2c | `--color-surface-2` | `--surface-2` | 지표 띠, 표 머리, 세그먼트 바탕 |
| 표면 3 | #e5e9f4 | #1c2338 | `--color-surface-3` | `--surface-3` | 진행 막대 바탕, 배지 바탕 |
| 글자 | #0d1117 | #e8ecf5 | `--color-fg` | `--fg` | 본문, 값 |
| 글자 2 | #3a4255 | #c0c8de | `--color-fg-2` | `--fg-2` | 라벨, 보조 본문 |
| 흐린 글자 | #6b7490 | #7480a0 | `--color-fg-muted` | `--fg-m` | 설명, 시각, 단위 |
| 테두리 | #dde2ef | #1e2638 | `--color-border` | `--border` | 카드·입력·표 구분선 |
| 강한 테두리 | #c8cedf | #2a3248 | `--color-border-strong` | `--border-2` | 드롭존 점선, 벤치마크 경계 |
| 사이드바 | #0d1117 | #060810 | `--color-sidebar` | `--sidebar` | 좌측 GNB 바탕(라이트에서도 어두움) |
| 사이드바 글자 | rgba(255,255,255,0.88) | 같음 | `--color-sidebar-fg` | `--sidebar-fg` | GNB 메뉴 |
| 사이드바 흐린 글자 | rgba(255,255,255,0.42) | 같음 | `--color-sidebar-muted` | `--sidebar-m` | GNB 섹션 제목 |
| 사이드바 활성 | rgba(255,255,255,0.10) | 같음 | `--color-sidebar-active` | `--sidebar-act` | 호버·선택 바탕 |
| 사이드바 브랜드 | oklch(0.72 0.18 255) | 같음 | `--color-sidebar-brand` | `--sidebar-brand` | 선택 메뉴 아이콘 |

상태색(`prototype/index.html:36-39`). 상태는 색만으로 전달하지 않고 점·아이콘·글자를 함께 쓴다.

| 상태 | 값 | 토큰 | 쓰는 곳 |
|---|---|---|---|
| 성공 | oklch(0.56 0.18 145) | `--color-success` | `live`, `applied`, `delivered`, 지표 양호 |
| 경고 | oklch(0.68 0.18 75) | `--color-warning` | `held`, `purchase_pending`, 리스크 WARN, 지표 주의 |
| 위험 | oklch(0.56 0.22 25) | `--color-danger` | `error`, `failed`, `delayed`, 리스크 FAIL, 계정 삭제 |
| 정보 | oklch(0.58 0.16 240) | `--color-info` | 진행 중, `queued`, `submitting` |

`StatusPill` 배경은 상태색을 `color-mix(in oklab, <상태색> 13%, transparent)`로 섞어 쓴다(`prototype/index.html:372-376`). 회색 배지는 `--color-surface-3` + `--color-fg-muted`.

차트색(`prototype/index.html:41-45`). MVP 차트는 단일 계열이라 `--color-chart-1`만 쓰고, 계열이 둘 이상인 차트는 순서대로 쓴다.

| 순서 | 값 | 토큰 |
|---|---|---|
| 1 | oklch(0.55 0.20 255) | `--color-chart-1` |
| 2 | oklch(0.60 0.18 195) | `--color-chart-2` |
| 3 | oklch(0.62 0.16 135) | `--color-chart-3` |
| 4 | oklch(0.65 0.18 45) | `--color-chart-4` |
| 5 | oklch(0.58 0.20 315) | `--color-chart-5` |

마켓 고유색(`prototype/index.html:29-34`, 태그 `:386-400`). 점(`MarketChip`, `MarketScope` 탭)과 `MarketTag`에만 쓴다. 버튼·배경에 쓰지 않는다.

| 마켓 | 점 색 | 태그 라이트(배경 / 글자) | 태그 다크(배경 / 글자) | 토큰 |
|---|---|---|---|---|
| Amazon | #ff9900 | #fff3e0 / #e65c00 | #2a1800 / #ffb74d | `--color-market-amazon`, `--color-market-amazon-tag-bg`, `-tag-fg` |
| eBay | #e53238 | #ffebee / #c62828 | #2a0808 / #ef9a9a | `--color-market-ebay` … |
| Shopee | #ee4d2d | #fff3e0 / #bf360c | #2a1000 / #ff8a65 | `--color-market-shopee` … |
| Lazada | #f57224 | #fff3e0 / #e64a19 | #2a1200 / #ffcc80 | `--color-market-lazada` … |
| TikTok Shop | #010101 (다크 점 #888) | `--color-surface-3` / `--color-fg-muted` | #1e2638 / #9e9e9e | `--color-market-tiktok` … |
| 쿠팡(원본) | #c0392b | #fce4e4 / #c0392b | #2a0808 / #ef9a9a | `--color-market-coupang` … |

Qoo10·Etsy 점 색은 마법사 카드 로고색(`prototype/index.html:4492` 마켓 카탈로그)에서 가져와 Phase 2에 토큰으로 추가한다(제안).

### 3.2 서체

| 역할 | 서체 | 토큰 | 근거 |
|---|---|---|---|
| 본문·제목 | Pretendard, 대체 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif | `--font-sans` | `prototype/index.html:58` |
| 숫자·코드·주문번호 | JetBrains Mono, 대체 'Fira Code', monospace | `--font-mono` | `:59` |

- Pretendard는 `next/font/local`로 자체 호스팅한다(프로토타입의 Google Fonts 요청은 폐기, `07_SOURCE_MIGRATION.md` 3절 10번).
- 금액·KPI 값은 `font-variant-numeric: tabular-nums`. 주문번호·송장·상품 id는 `--font-mono`.

### 3.3 서체 스케일과 반응형 3구간

반응형 3구간 글자 크기는 이 표가 정본이다(`prototype/index.html:610-612`, 구조 문서 2장). Tailwind CSS v4 `@theme` 값은 미디어 쿼리로 바꿀 수 없으므로 `:root`에 `--fs-*` 변수를 두고 구간별 미디어 쿼리에서 덮어쓴 뒤, 유틸리티 `text-(length:--fs-page-title)`로 쓴다(제안).

| 역할 | 토큰 | 모바일 ~767px | 태블릿 768~1199px | 데스크탑 1200px~ | 굵기 |
|---|---|---|---|---|---|
| 페이지 제목 | `--fs-page-title` | 16px | 18px | 20px | 800, 자간 -0.3px |
| KPI 값 | `--fs-kpi-value` | 19px | 21px | 24px | 800, tabular-nums |
| 본문 | `--fs-body` | 13px | 14px | 14px | 400 |
| 모달 제목 | `--fs-modal-title` | 15px | 16px | 16px | 800 |
| 카드 제목 | `--fs-card-title` | 13px | 13px | 13px | 700 |
| 지표 띠 값 | `--fs-metric` | 14px | 14px | 14px | 800 |
| 보조 글자(카드 설명, 필드 라벨) | `--fs-small` | 11.5px | 11.5px | 11.5px | 500~600 |
| 라벨(KPI 라벨, 표 머리) | `--fs-label` | 10.5px | 10.5px | 10.5px | 700, 대문자 영문은 자간 0.07em |
| 배지·태그 | `--fs-badge` | 10.5px | 10.5px | 10.5px | 700 |

값 근거: 카드 제목 `prototype/index.html:299`, 보조 `:300`, KPI 라벨 `:323-327`, 배지 `:367-371`, 지표 띠 값 `:840`, 모달 제목 `:858`.

### 3.4 간격·반경·그림자·모션·밀도

| 토큰 | 값 | 용도 | 근거 |
|---|---|---|---|
| `--spacing` | 4px 기준(Tailwind CSS v4 기본) | 카드 안쪽 16·18px, 카드 사이 14·20px | 프로토타입 `.card-body`(`:307`), `.view.active` gap |
| `--radius-sm` | 6px | 버튼 xs, 세그먼트 버튼, 코드 박스 | `:53` |
| `--radius-md` | 8px | 버튼, 입력, 아이콘 버튼, GNB 항목 | `:54` |
| `--radius-lg` | 12px | 카드, KPI, 선택 카드, 지표 띠 카드 | `:55` |
| `--radius-xl` | 16px | 모달 | `:56` |
| `--radius-pill` | 9999px | 배지, 칩, 진행 막대 | 프로토타입 `.pill` |
| `--shadow-sm` | 0 1px 2px rgba(0,0,0,.05) | 세그먼트 선택 버튼 | `:61` |
| `--shadow-md` | 0 1px 3px rgba(0,0,0,.07), 0 4px 12px rgba(0,0,0,.05) (다크: 0 1px 3px rgba(0,0,0,.3), 0 4px 12px rgba(0,0,0,.25)) | 카드, KPI | `:62`, `:79` |
| `--shadow-lg` | 0 4px 6px rgba(0,0,0,.07), 0 10px 30px rgba(0,0,0,.09) | 모달, 드롭다운 | `:63` |
| `--motion-fast` | 120~140ms ease | 호버·선택 전환 | 프로토타입 `transition:all .14s` |
| `--row-compact` / `--row-default` | 36px / 44px | 표 행 높이(제안, 프로토타입 셀 패딩 10px 기준) | 제안 |

모든 요소에 같은 반경·그림자를 쓰지 않는다. 카드(lg·md 그림자) < 모달(xl·lg 그림자). 섹션 등장 애니메이션, 카드 호버 들림 효과는 쓰지 않는다.

### 3.5 다크 모드

| 규칙 | 내용 |
|---|---|
| 전환 | 시스템 설정을 따르고, 사용자가 고르면 `data-theme="dark"`·`"light"`가 우선(`prototype/index.html:66-96`과 같은 구조). Tailwind CSS v4 `@custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *))` |
| 바뀌는 토큰 | 3.1절 "다크" 열이 있는 색, `--shadow-md`. 브랜드·상태·차트·마켓 점 색은 그대로 |
| 사이드바 | 라이트에서도 어둡다. 다크에서는 #060810으로 더 어둡게 |
| 마켓 태그 | 다크 전용 배경·글자 쌍(3.1절 마켓 표) |
| `color-scheme` | 다크에서 `color-scheme: dark`로 폼 컨트롤·스크롤바도 따라가게 |
| 대비 | 본문 4.5:1 이상, 큰 값(KPI) 3:1 이상. 흐린 글자(#7480a0 on #0f1420)는 보조 정보에만 |

### 3.6 아이콘

Lucide만 쓴다. 프로토타입의 이모지 아이콘(GNB, KPI 라벨, 규칙 행, 수집 방식 카드)은 모두 Lucide로 바꾼다(`07_SOURCE_MIGRATION.md` 3절 7번). 고정 매핑(제안): 대시보드 `LayoutDashboard`, 상품 수집 `Search`, 해외 등록 `Upload`, 동기화 `RefreshCw`, 주문 `Package`, 배송 `Truck`, 수익 `BarChart3`, 연동 설정 `Plug`, 알림 `Bell`, 리스크 경고 `TriangleAlert`.

### 3.7 DESIGN.md 초기값

| 항목 | 값 |
|---|---|
| 주 레퍼런스 | 운영 화면 Primer, 편집·검증 Atlassian, 마법사 Sellbrite 흐름 |
| 가져올 패턴 | 마켓 탭 바 + 지표 띠 + KPI + 표, 번호 단계 카드 + 우측 고정 검증, 단일 색상 막대 차트 |
| 가져오지 않을 것 | SaaS 카드 키트, 보라 그라디언트, 이모지 아이콘, 지구본 일러스트, 다색 장식 차트 |
| 색 | 3.1절 표 그대로 |
| `--font-sans` / `--font-mono` | Pretendard / JetBrains Mono |
| 서체 스케일 | 3.3절 표(반응형 3구간) |
| 반경 | 6 / 8 / 12 / 16px + pill |
| 그림자 | sm / md / lg(3.4절) |
| 다크 모드 | 시스템 + `data-theme` 우선 |
| 포커스 | 테두리 `--color-brand` + 3px `color-mix(in oklab, var(--color-brand) 14%, transparent)` 바깥 그림자(`prototype/index.html:719`). 버튼·탭은 같은 그림자를 `:focus-visible`에만 |

## 4. 브랜드 키트

해당 없음. 사용자별 브랜드 키트가 없는 운영 도구다.

## 5. 영상 캔버스

해당 없음. 영상을 만들지 않는다.

## 6. 장르 문법

해당 없음.

## 7. 모션 시스템

| 대상 | 동작 | 시간 |
|---|---|---|
| 탭·세그먼트·선택 카드 | 배경·테두리 색 전환 | `--motion-fast` |
| 모달(마법사) | 페이드 + 4px 위로 | 160ms ease-out(제안) |
| 진행 막대(수집·일괄 등록) | 폭 전환 | 300ms linear(Realtime 갱신 사이) |
| `prefers-reduced-motion` | 모든 전환 0ms | - |

## 8. 이미지 스타일 시스템

해당 없음(이미지 생성 없음). 상품 썸네일 규칙만 둔다: 정사각 자르기, 56·72px 두 크기(`prototype/index.html:728` `.thumb`), 대표 이미지는 브랜드 2px 테두리, 이미지 없음은 회색 자리표시 + `ImageOff` 아이콘.

## 9. 장면 컴포넌트 명세

해당 없음.

## 10. 변주 규칙

해당 없음.

## 11. 앱 컴포넌트

### 11.1 기본 컴포넌트 (shadcn/ui 재스타일)

Button, IconButton, Input, Textarea, Select, Checkbox, RadioGroup, Switch, Tabs, Dialog, Sheet(모바일 필터), DropdownMenu, Tooltip, Toast, Badge(→ `StatusPill`), Table(→ `DataTable`), Skeleton, Progress, Breadcrumb, EmptyState.

### 11.2 제품 컴포넌트

이름은 `07_SOURCE_MIGRATION.md` 2.1절과 같다.

| 컴포넌트 | 위치 | 역할 | 배리언트 | 상태 |
|---|---|---|---|---|
| `AppTopbar`, `TopTabs`, `Breadcrumb` | `components/shell/` | 상단 바와 주요 탭 5개 | - | 선택, 알림 배지 |
| `AppSidebar`, `NavItem`, `MarketChip`, `SidebarUserCard` | `components/shell/` | 좌측 GNB 9개, 마켓 연결 칩, 사용자 카드 | 220px(데스크탑) / 200px(태블릿) | 선택, 배지(경고·정보), 마켓 연결됨·미연결·예정 |
| `MobileNav` | `components/shell/` | 767px 이하 가로 스크롤 메뉴 10개 | - | 선택(브랜드 바탕) |
| `PageHeader` | `components/layout/` | 제목·설명·우측 행동 버튼 | - | - |
| `KpiGrid`, `KpiCard` | `components/kpi/` | KPI 5칸(데스크탑 5열, 태블릿 3열, 모바일 2열) | 막대 있음/없음 | 상승(success)·하락(danger)·중립, 로딩 스켈레톤 |
| `StatusPill` | `components/ui/` | 상태 배지 | ok, warn, err, info, gray / 점 있음·없음 | - |
| `MarketTag` | `components/market/` | 마켓 이름 태그 | 마켓 코드별 | - |
| `SegmentTabs` | `components/ui/` | 하위 탭, 주문 상태 그룹 | 기본, 작게(마법사 언어 전환) | 선택, 숫자 배지 |
| `MarketScope` | `components/market-scope/` | 마켓 탭 바(전체 + 계정 + 마켓 추가) | - | 선택, 숫자, 경고 배지(토큰 만료), NEW 배지 |
| `MarketHealthStrip` | `components/market-scope/` | 전체 탭·마켓 탭 지표 띠 | 전체 / 마켓별 | 양호·주의·실패 배지, 행동 버튼 |
| `Stepper` | `components/ui/` | 단계 표시 | - | 완료(성공 + 체크), 현재(브랜드), 대기 |
| `FormSection` | `components/form/` | 번호 붙은 단계 카드 | - | - |
| `SelectCard` | `components/ui/` | 선택 카드 | checkbox(마켓·항목), radio(수집 방식) | 선택, 비활성 |
| `ChoiceChip` | `components/ui/` | 진단 문항 선택 칩 | radio, checkbox | 선택, 포커스 링 |
| `MarketRecommendCard` | `components/markets/` | 추천 마켓 카드 | 추천(브랜드 테두리)/일반 | 바로 연결 가능·준비 후 연결·목표 지역 외·초청·승인제·연결됨 |
| `WizardDialog` | `components/markets/` | 마켓 추가 마법사 | - | 단계 1~5, 승인 전 다음 비활성 |
| `FileDropzone` | `components/form/` | CSV·XLSX 업로드 | - | 끌어다 놓는 중, 업로드 중, 오류(행 번호) |
| `TokenInput` | `components/form/` | 키워드·제외어 칩 입력 | 포함(브랜드), 제외(위험색) | 한글 조합 중 Enter 무시 |
| `EditLayout` | `components/layout/` | 본문 + 우측 고정 요약 300px | - | 1199px 이하에서 요약이 아래로 |
| `SourceProductSummary`, `Thumbnail` | `components/collect/` | 원본 상품 요약, 썸네일 | 56 / 72px | 대표(브랜드 테두리), 이미지 없음 |
| `ValidationChecklist` | `components/listing/` | 등록 전 검증, 리스크 검사 | - | OK·WARN·FAIL 아이콘 + 글자 |
| `KeyValueList` | `components/ui/` | 가격 계산·요약 | 합계 행 | - |
| `RuleRow` | `components/sync/` | 동기화 규칙 행(아이콘·제목·설명·Switch/Select) | 기본 / 마켓 전용 배지 | 켜짐·꺼짐 |
| `ProgressRow`, `UsageBar`, `QuotaMeter` | `components/ui/` | 진행률, 플랜 사용량, API 한도 | - | 정상(브랜드)·경고(70% 이상, warning)·초과(danger) |
| `HBarChart`, `VBarChart` | `components/charts/` | 단일 색상 막대, 값 직접 표시, 호버 툴팁 | 가로 / 세로(현재 달 강조) | 빈 데이터 |
| `ShipmentTimeline` | `components/shipping/` | 배송 구간 타임라인 | - | 완료·현재·대기 |
| `PipelineSteps` | `components/orders/` | 주문 5단계 건수 | - | - |
| `ActivityItem` | `components/dashboard/` | 최근 활동 | 정보·성공·경고·위험 아이콘 | - |
| `Callout` | `components/ui/` | 안내 상자 | 정보 / 경고 | - |
| `DataTable`, `TableToolbar`, `SearchInput` | `components/table/` | 목록 표, 필터 줄 | 컴팩트 / 기본 행 | 빈 상태, 로딩, 오류, 카드 안 가로 스크롤 |
| `AccountLayout`, `AccountTabNav` | `components/account/` | 계정 좌측 프로필 카드 + 탭 8개 | - | 선택, 경고 배지(보안) |
| `PlanCard`, `MarketAccountCard`, `SecretField`, `BillingRow`, `MemberRow`, `LoginHistoryRow` | `components/account/` | 계정 탭 구성요소 | `PlanCard` 현재 플랜 강조 | `MarketAccountCard` 연결됨·만료 임박·만료·미연결·예정, `SecretField` 마스킹 값만 |
| `IntegrationCard` | `components/settings/` | 연동 상태 카드(쿠팡 파트너스, 확장, 운송사) | - | 연결됨·미설정·오류 |

### 11.3 COMPONENTS.md 초기값

| 컴포넌트 | 크기 배리언트 | 종류 배리언트 | 상태 | 토큰 |
|---|---|---|---|---|
| Button | xs(높이 26) / md(32) / icon(32×32) | primary / ghost / danger | 기본·호버·포커스·비활성·로딩 | `--radius-sm`(xs)·`--radius-md`, `--color-brand`, `--color-brand-hover` |
| Input, Select, Textarea | md(36px) | 기본 | 기본·포커스·오류·비활성 | `--color-border`, `--color-surface`, 포커스 링 3.7절 |
| Dialog | md(880px 최대) | 기본, 마법사 | 열림 | `--radius-xl`, `--shadow-lg` |
| DataTable | 컴팩트 36 / 기본 44 | 기본 | 빈 상태·로딩·오류 | `--row-*`, 표 머리 `--color-surface-2` + `--fs-label` |
| StatusPill | sm | ok/warn/err/info/gray | 점 + 글자 필수 | 상태색 13% 섞음 |
| SegmentTabs | md | 기본 | 선택·숫자 | `--color-surface-2`, `--shadow-sm` |
| MarketScope | md | - | 선택 밑줄 2px 브랜드 | `--color-border`, `--color-brand` |
| KpiCard | 반응형(3.3절) | 막대 유무 | 로딩 | `--radius-lg`, `--shadow-md`, `--fs-kpi-value` |
