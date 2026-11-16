# RCcar_PCB

RC카 차량 보드 통합 설계 기록. 미제연 11월 미니프로젝트 PCB 특강에서 쓸 **모델 보드**(정답 예시)를 설계하는 저장소다.

**상태: 초안.** 사양서 v0.4까지 작성했고(2026-11-16 부품 확인 반영, 11-17 L298N 입력 풀다운 · 레이아웃 규칙 추가), 실물 제작·동작 검증은 하지 않았다.

## 무엇을 설계하나

기존 구성(Arduino Mega + L298N 모듈 + 점퍼선)을 **한 장의 PCB**로 통합한다.

| | |
|---|---|
| PCB 위 | ATmega328P(TQFP-32), 16MHz 클록, 리셋, 12V → 5V → 3.3V 전원, L298N IC + 보호 회로, 커넥터 |
| PCB 밖 | nRF24L01+ PA/LNA 모듈, VL53L0X 거리센서, 모터 2개, 12V 어댑터선(+/−) |
| 설계 기준 | 모터 1개 stall 5.5A 가정, 어댑터 12V 5A |

## 구성

| 경로 | 내용 |
|---|---|
| [`docs/spec-v0.4.md`](docs/spec-v0.4.md) | **현재 기준.** 통합 설계 사양서 (전원 트리, 핀맵, BOM, 선폭·전류 제한 계산, 확인 필요 항목). v0.3 대비 변경 요약이 맨 앞에 있다 |
| [`docs/parts-confirmed.md`](docs/parts-confirmed.md) | 부품 확정표: EasyEDA 검색용 LCSC 번호, 학생이 틀리기 쉬운 지점, 이번에 해소한 ⚠ |
| [`docs/handson-checklist.md`](docs/handson-checklist.md) | 강사가 EasyEDA로 정답 보드를 직접 만들 때 쓰는 촬영 · 확인표 (덱 실습 1~17 구간 기준) |
| [`docs/lecture-notice-draft.md`](docs/lecture-notice-draft.md) | 사전 공지문 초안 (날짜 · 장소 · EasyEDA 버전은 빈칸) |
| [`docs/spec-v0.3.md`](docs/spec-v0.3.md) | 이전 버전 (이력용) |
| [`docs/decision-log.md`](docs/decision-log.md) | 설계 결정과 근거, 정정 이력, 남은 작업 |
| [`docs/deck-outline.md`](docs/deck-outline.md) | 특강 슬라이드(486장) 제목 목차 |
| [`sim/`](sim/) | 전류 제한 회로 ngspice 간이 시뮬레이션 |
| [`firmware/`](firmware/) | Mega → ATmega328P 스케치 수정 패치 (5줄) |
| [`tools/build_328p.sh`](tools/build_328p.sh) | avr-gcc로 328P 컴파일을 확인한 스크립트 |

특강 덱은 [`slides/`](slides/)에 있다 (486장, 9.6MB, 파일명에 공백이 있다). 실습 스크린샷 슬라이드는 강사가 EasyEDA를 직접 돌린 뒤에 채운다. 어느 버전인지는 [`slides/README.md`](slides/README.md) 참고.

## 검증 수준 (읽을 때 주의)

| 항목 | 상태 |
|---|---|
| 328P에 차량 코드가 들어가는가 | **컴파일로 확인** (플래시 34%, RAM 25%) |
| 전류 제한 회로(Rs + NPN) | **간이 시뮬레이션만** (이상 스위치, 모터 L=2mH 가정). 실물 미검증 |
| 모터 stall 5.5A | **가정, 실측 안 함** (찾은 37mm 12V 기어모터 중 최대값. 발주하지 않으므로 이 값으로 고정) |
| 데이터시트 수치 | 웹에서 찾은 사본 기준. 제조사 원본과 대조 필요 |
| 핀 번호 | EasyEDA / KiCad 심볼과 대조 전 |
| L298N 입력 풀다운 10kΩ ×6 | 설계에 추가함(11-17). 떠 있는 입력의 실제 읽힘은 데이터시트로 미확인이지만, 풀다운은 확인과 무관하게 안전한 쪽이라 유지 |
| 보드 크기 · 높이 · 장착홀 | **차체 실측 없이 진행** (차가 커서 들어간다고 가정, 발주 없음). 높이 여유는 확인한 적 없음 (벌크 캡 25mm, L298N 방열판) |
| 부품 LCSC 번호 | 11개는 부품 페이지에서 재확인(✔), 나머지 소형 부품 7개는 EasyEDA에서 눈으로 확인 필요(△). [`parts-confirmed.md`](docs/parts-confirmed.md) |
| 모터 · 무선 · 거리센서 실제 동작 | 확인 못 함 |

사양서에서 ⚠ 표시는 직접 확인하지 못한 값이나 가정이다. 확정은 사양서 11장의 열린 항목이 해소된 뒤에 한다.

## 기반 자료

- 차량 펌웨어 · 핀맵: [shinejihun1227/RC_CAR](https://github.com/shinejihun1227/RC_CAR). 라이선스 표기가 없어 코드는 복사하지 않고 **수정 패치(diff)만** 수록했다.
- 이 저장소에는 라이선스를 지정하지 않았다. 열람은 가능하지만 재사용 조건은 저장소 주인이 따로 정한다.

## 갱신 방식

Claude와 작업하는 세션에서 내용이 바뀔 때마다 변경된 파일을 이 저장소에 커밋한다. 백그라운드 자동 동기화가 아니라, 세션 중 작업 단위로 반영하는 방식이다. 최신 상태는 커밋 기록을 보면 된다.

## 남은 작업

- 강사가 EasyEDA로 정답 보드를 직접 설계 → 핀 번호 대조 · 스크린샷 촬영 ([`handson-checklist.md`](docs/handson-checklist.md)) → 덱 실습 1~17 구간 채우기
- 사전 공지문의 날짜 · 장소 · EasyEDA 버전 채우기
- KiCad 프로젝트 파일 (회로도, 보드) — 미착수
