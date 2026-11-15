#!/bin/bash
# 328P(Arduino Uno 타깃) 컴파일 확인용 스크립트. 차량 스케치가 플래시/RAM에 들어가는지 본다.
#
# 준비 (사용한 버전):
#   sudo apt-get update && sudo apt-get install -y gcc-avr avr-libc binutils-avr
#   mkdir -p /tmp/work && cd /tmp/work
#   git clone https://github.com/arduino/ArduinoCore-avr.git      # 11b9130371e8447920edb65a75706a6c951e51fc
#   git clone https://github.com/nRF24/RF24.git                   # 5ab63016c3b0c336004c56b5897df7a87161876e
#   git clone https://github.com/pololu/vl53l0x-arduino.git       # 9f3773cb48d4e4e844d689cfc529a06f96d1d264
#   (RC_CAR 저장소의 vehicle_mega.ino에 firmware/vehicle_328p.diff를 적용해 vehicle_328p.ino를 만든다)
#
# 사용:
#   build.sh <mcu> <variant> <ARDUINO_BOARD_DEF> <sketch.ino> <outdir>
#   328P : ./build_328p.sh atmega328p standard AVR_UNO vehicle_328p.ino /tmp/work/b/uno
#   Mega : ./build_328p.sh atmega2560 mega AVR_MEGA2560 vehicle_mega.ino /tmp/work/b/mega
#
# 결과(avr-gcc 7.3, -Os): 328P 플래시 11,130B(34.0%) / RAM 507B(24.8%)
set -e
MCU=$1; VAR=$2; BDEF=$3; INO=$4; OUT=$5
W=/tmp/work; CORE=$W/ArduinoCore-avr
rm -rf $OUT; mkdir -p $OUT
CFLAGS="-c -g -Os -w -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects -mmcu=$MCU -DF_CPU=16000000L -DARDUINO=10819 -DARDUINO_$BDEF -DARDUINO_ARCH_AVR"
CXXFLAGS="$CFLAGS -std=gnu++11 -fpermissive -fno-exceptions -fno-threadsafe-statics -Wno-error=narrowing"
INC="-I$CORE/cores/arduino -I$CORE/variants/$VAR -I$CORE/libraries/SPI/src -I$CORE/libraries/Wire/src -I$CORE/libraries/Wire/src/utility -I$W/RF24 -I$W/RF24/utility -I$W/vl53l0x-arduino"
# sketch -> cpp
{ echo '#include <Arduino.h>'; cat $INO; } > $OUT/sketch.cpp
OBJS=()
cc() { f=$1; o=$OUT/$(basename $f).o; case $f in *.c) avr-gcc $CFLAGS $INC $f -o $o;; *.S) avr-gcc -c -g -x assembler-with-cpp -flto -mmcu=$MCU -DF_CPU=16000000L -DARDUINO=10819 -DARDUINO_ARCH_AVR $INC $f -o $o;; *) avr-g++ $CXXFLAGS $INC $f -o $o;; esac; OBJS+=($o); }
for f in $OUT/sketch.cpp $CORE/cores/arduino/*.c $CORE/cores/arduino/*.cpp $CORE/cores/arduino/*.S $CORE/libraries/SPI/src/SPI.cpp $CORE/libraries/Wire/src/Wire.cpp $CORE/libraries/Wire/src/utility/twi.c $W/RF24/RF24.cpp $W/vl53l0x-arduino/VL53L0X.cpp; do cc $f; done
avr-gcc -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=$MCU -o $OUT/out.elf "${OBJS[@]}" -lm
avr-size -C --mcu=$MCU $OUT/out.elf
