# 328P용 차량 스케치 수정

원본: [shinejihun1227/RC_CAR](https://github.com/shinejihun1227/RC_CAR)의 `firmware/v4/vehicle_mega/vehicle_mega.ino` (Mega 2560용). 원본 저장소에 라이선스 표기가 없어 코드 전체는 복사하지 않고 **수정 패치만** 둔다.

## 적용

RC_CAR 저장소 루트에서:

```bash
git apply /path/to/vehicle_328p.diff
```

## 바뀌는 것 (5줄)

| 항목 | Mega 원본 | 328P |
|---|---|---|
| IN1~IN4 | D22 · 23 · 24 · 25 | D2 · D3 · D4 · D9 |
| SS 핀 출력 설정 | D53 | D10 |
| 상태 LED | D13 | A0 (328P에서 D13은 SPI SCK) |

ENA D5 · ENB D6 · CE D7 · CSN D8은 그대로다.

## 검증

`tools/build_328p.sh`로 Arduino Uno(ATmega328P) 타깃으로 컴파일해 통과를 확인했다 (플래시 11,130B = 34%, RAM 507B = 25%). **실물에서 모터 · 무선 · 거리센서가 동작하는지는 확인하지 못했다.**
