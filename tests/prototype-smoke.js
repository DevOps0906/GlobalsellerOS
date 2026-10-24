// GlobalSeller OS 프로토타입 동작 확인
// 사용: npm test   (설치된 Chromium 사용 시 CHROMIUM_PATH=/path/to/chromium npm test)
const path = require('path');
const { chromium } = require('playwright');

const FILE = 'file://' + path.resolve(__dirname, '../prototype/index.html');
let failures = 0;
const check = (ok, label) => {
  console.log(`${ok ? '✓' : '✗'} ${label}`);
  if (!ok) failures++;
};

(async () => {
  const browser = await chromium.launch(process.env.CHROMIUM_PATH ? { executablePath: process.env.CHROMIUM_PATH } : {});
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  await page.goto(FILE);
  const ev = (fn, arg) => page.evaluate(fn, arg);

  // 1. 좌측 메뉴 → 각 화면
  const views = await page.$$eval('.sidebar .nav-item', els => els.map(e => e.dataset.view));
  for (const v of views) {
    await page.click(`.sidebar .nav-item[data-view="${v}"]`);
    check(await ev(v => document.getElementById('view-' + v).classList.contains('active'), v), `메뉴 → ${v} 화면`);
  }

  // 2. 마켓별 탭 (동기화·주문·배송)
  for (const scope of ['sync', 'orders', 'shipping']) {
    await page.click(`.sidebar .nav-item[data-view="${scope}"]`);
    for (const mk of ['amzus', 'amzjp', 'ebay', 'shopee', 'all']) {
      await page.click(`#view-${scope} .mtab[data-mk="${mk}"]`);
      const ok = await ev(([s, mk]) => {
        const v = document.getElementById('view-' + s);
        const rows = [...v.querySelectorAll('table[data-mfilter] tbody tr[data-market]')].filter(t => !t.hidden);
        const rowsOk = mk === 'all' || rows.every(t => t.dataset.market.split(' ').includes(mk));
        const strip = [...v.querySelectorAll('.mstrip')].filter(x => !x.hidden).map(x => x.dataset.only);
        return rowsOk && strip.length === 1 && strip[0].split(' ').includes(mk);
      }, [scope, mk]);
      check(ok, `${scope} · ${mk} 탭 필터·지표`);
    }
  }

  // 3. 주문: 마켓 탭 × 상태 필터
  await page.click('.sidebar .nav-item[data-view="orders"]');
  await page.click('#view-orders .mtab[data-mk="shopee"]');
  await page.click('#view-orders .seg-btn[data-st="cs"]');
  check(await ev(() => !document.querySelector('#order-table .empty-row').hidden), '주문 · Shopee + 취소 → 빈 상태 표시');
  await page.click('#view-orders .seg-btn[data-st="all"]');
  await page.click('#view-orders .mtab[data-mk="all"]');

  // 4. 상품 수집 하위 탭
  await page.click('.sidebar .nav-item[data-view="products"]');
  await page.click('#view-products .hd-actions .btn-ghost');
  check(await ev(() => document.getElementById('col-single').offsetHeight > 0), '상품 수집 · 개별 등록');
  await page.click('#view-products .hd-actions .btn-primary');
  check(await ev(() => document.getElementById('col-bulk').offsetHeight > 0), '상품 수집 · 대량 수집');

  // 5. 마켓 추가 마법사 전 과정
  await page.click('.sidebar .nav-item[data-view="orders"]');
  await page.click('#view-orders .mtab-add');
  await page.click('#mk-next');                       // 추천
  check(await ev(() => document.querySelectorAll('#mk-rec .rec').length === 8), '마법사 · 추천 마켓 8곳');
  await page.click('#mk-next');                       // 1순위 선택 → 연결
  check(await ev(() => document.getElementById('mk-next').disabled), '마법사 · 권한 승인 전 다음 비활성');
  await page.click('#mk-c-btn');
  await page.click('#mk-next');                       // 초기 설정
  await page.click('#mk-next');                       // 완료
  const added = await ev(() => MK.added[0]);
  await page.click('#mk-next');                       // 닫기
  check(await ev(id => ['sync', 'orders', 'shipping'].every(s => document.querySelector(`#view-${s} .mtab[data-mk="${id}"]`)), added),
    `마법사 · ${added} 탭이 세 메뉴에 생성`);

  // 6. 모바일 폭 가로 넘침
  await page.setViewportSize({ width: 390, height: 844 });
  for (const v of ['dashboard', 'products', 'listing', 'sync', 'orders', 'shipping', 'profit', 'account']) {
    await ev(v => switchView(v), v);
    check(await ev(() => { const m = document.querySelector('.main'); return m.scrollWidth <= m.clientWidth; }), `모바일 · ${v} 가로 넘침 없음`);
  }

  check(errors.length === 0, '스크립트 오류 없음' + (errors.length ? ': ' + errors.join(' | ') : ''));
  await browser.close();
  console.log(failures ? `\n${failures}건 실패` : '\n모두 통과');
  process.exit(failures ? 1 : 0);
})();
