# 개발서 — GlobalSeller OS

쿠팡에서 수집한 상품을 Amazon · eBay · Shopee 등 해외 마켓에 등록하고, 재고·가격 동기화부터 주문·발주·배송·수익까지 한 화면에서 운영하는 역직구 멀티채널 SaaS의 개발 방법입니다. platform-docs `develop/<제품>/` 형식을 따르되, 이 저장소가 곧 개발 폴더이므로 setup 스크립트와 별도 묶음 폴더는 없습니다.

| 항목 | 내용 |
|---|---|
| 주 사용자 | 쿠팡 상품으로 해외 판매를 하는 1인·소규모 역직구 셀러 |
| DB 스키마 | `globalseller` (모듈러로 합칠 때 번호 2700, 제안) |
| 개발 작업 | `docs/기획서/06_AGENT_PLAN.md` 2장, 진행 상태는 `tasks/README.md` |
| 개발 방식 | 멀티에이전트: 팀장(주 세션) Opus 5.5 + 팀원(부에이전트) Sonnet 5.5 — `docs/MULTI_AGENT.md` |
| 로그인 | 인증 단계: Mock(Stage A) → Google + 이메일(Stage B) → 카카오·네이버(Stage C). 안내서 16장 |
| 기획서 | [`../기획서/`](../기획서/README.md) · 디자인 구조 [`../설계/DESIGN_STRUCTURE.md`](../설계/DESIGN_STRUCTURE.md) |

## 이 폴더의 파일

| 파일 | 내용 |
|---|---|
| [`globalseller-os_develop.md`](globalseller-os_develop.md) | 개발 방법 안내서. 0장부터 순서대로 따라간다 |

## 시작하기

```bash
git clone https://github.com/DevOps0906/GlobalsellerOS.git
git clone https://github.com/DevOps0906/platform-docs.git   # 공용 코어 문서(같은 상위 폴더에 나란히)
cd GlobalsellerOS
claude --add-dir ../platform-docs                            # 팀장 세션(Opus 5.5) 시작
# 세션 안에서: /next-task
```
