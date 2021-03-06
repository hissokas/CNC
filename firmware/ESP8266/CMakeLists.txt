cmake_minimum_required(VERSION 3.10)
project(ESP8266 C CXX ASM)

set(CMAKE_C_FLAGS_RELEASE "-Os")
set(CMAKE_CXX_FLAGS_RELEASE "-Os")
set(CMAKE_C_FLAGS_DEBUG "-O1")
set(CMAKE_CXX_FLAGS_DEBUG "-O1")

set(RTOS_DIR /home/paolo/esp2866/espressif/ESP8266_RTOS_SDK)
execute_process(COMMAND git describe --always --tags --dirty
        WORKING_DIRECTORY ${RTOS_DIR}
        OUTPUT_VARIABLE IDF_VER
        OUTPUT_STRIP_TRAILING_WHITESPACE)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_C_STANDARD 99)
set(COMMON_FLAGS -Os -ggdb -ffunction-sections -fdata-sections -fstrict-volatile-bitfields -mlongcalls -nostdlib -DICACHE_FLASH -DESP_PLATFORM -DIDF_VER=\"${IDF_VER}\" -MMD -MP -DMQTT_TASK -DMQTTCLIENT_PLATFORM_HEADER=MQTTFreeRTOS.h -DWOLFSSL_USER_SETTINGS)
set(WARNING_FLAGS -Wall -Werror=all -Wno-error=unused-function -Wno-error=unused-but-set-variable -Wno-error=unused-variable -Wno-error=deprecated-declarations -Wextra -Wno-unused-parameter -Wno-sign-compare -Wno-error=char-subscripts -Wno-error=unknown-pragmas -Wno-error=implicit-function-declaration -Wno-error=pointer-sign -Wno-error=switch -Wno-error=maybe-uninitialized -Wno-error=format= -Wno-error=unused-value -Wno-error=address -Wno-error=return-type -Wno-error=format-extra-args -Wno-error=format-zero-length -Wno-error=unused-label -Wno-error=sizeof-pointer-memaccess)

add_subdirectory(bootloader)
add_subdirectory(bootloaderSupport)
add_subdirectory(log)
add_subdirectory(esp8266)
add_subdirectory(util)
add_subdirectory(cjson)
add_subdirectory(espOS)
add_subdirectory(freeRTOS)
add_subdirectory(jsmn)
add_subdirectory(lwip)
add_subdirectory(mqtt)
add_subdirectory(newlib)
add_subdirectory(nvs_flash)
add_subdirectory(smartConfig)
add_subdirectory(spiFlash)
add_subdirectory(spiffs)
add_subdirectory(ssl)
add_subdirectory(tcpipAdapter)

set(HTTP_SRC  http.cpp http.h
        httpd.cpp httpd.h
        httpHeader.h httpHeader.cpp
        httpResponse.h httpResponse.cpp
        UrlMatcher.cpp UrlMatcher.h)

set(PROGRAM_SRC main.c
        SPI.cpp SPI.h
        ${HTTP_SRC}
        include/sdkconfig.h)


add_custom_target(linkerDef
        COMMAND ${CMAKE_C_COMPILER} -I ../include -C -P -x c -E ${RTOS_DIR}/components/esp8266/ld/esp8266.ld -o esp8266_out.ld
        COMMENT "create linker file")

add_custom_target(image
        COMMAND ${RTOS_DIR}/components/esptool_py/esptool/esptool.py --chip esp8266 elf2image --flash_mode "qio" --flash_freq "40m" --flash_size "4MB" --version=3 -o ./firmware.bin ./firmware
        COMMENT "create image file")

add_custom_target(flash_image
        COMMAND python ${RTOS_DIR}/components/esptool_py/esptool/esptool.py
        --chip esp8266
        --port "/dev/ttyUSB0"
        --baud "115200"
        --before "default_reset"
        --after "hard_reset"
        write_flash -z
        --flash_mode "qio"
        --flash_freq "40m"
        --flash_size "4MB"
        0x0000 ${CMAKE_BINARY_DIR}/bootloader/bootloader0x00000.bin
        0x10000 ./firmware.bin
        0x8000 ${CMAKE_BINARY_DIR}/bootloader/partitions_singleapp.bin
        COMMENT "flash image")


add_executable(firmware ${PROGRAM_SRC})
add_dependencies(firmware
        bootloader
        bootloaderSupport
        log
        esp8266
        util
        cjson
        jsmn
        espOS
        freeRTOS
        lwip
        mqtt
        newlib
        nvs_flash
        smartConfig
        spiFlash
        spiffs
        ssl
        tcpipAdapter)

add_dependencies(image firmware linkerDef)
add_dependencies(flash_image image bootloader.bin partitions_singleapp.bin)

set_target_properties(firmware PROPERTIES
        LINK_FLAGS "-nostdlib\
                    -u call_user_start_cpu0\
                    -Wl,--gc-sections\
                    -Wl,-static\
                    -T esp8266_out.ld\
                    -Wl,--no-check-sections\
                    -u call_user_start\
                    -T esp8266.common.ld\
                    -T esp8266.rom.ld\
                    -Wl,-EL\
                    -Wl,-Map=firmware.map\
                    -L ${RTOS_DIR}/components/esp8266/ld\
                    -L ${RTOS_DIR}/components/esp8266/lib")

add_dependencies(firmware linkerDef)

target_link_libraries(firmware
        -Wl,--start-group
        bootloaderSupport
        log
        esp8266
        util
        cjson
        espOS
        freeRTOS
        jsmn
        lwip
        mqtt
        newlib
        nvs_flash
        smartConfig
        spiFlash
        spiffs
        ssl
        tcpipAdapter
        airkiss
        crypto
        espnow
        gcc
        hal
        core
        net80211
        phy
        pp
        pwm
        ssc
        wpa
        wps
        ${RTOS_DIR}/components/newlib/newlib/lib/libc_nano.a
        ${RTOS_DIR}/components/newlib/newlib/lib/libm.a
        stdc++
        gcov
        -Wl,--end-group)


target_compile_options(firmware PUBLIC -DMEMLEAK_DEBUG -DICACHE_FLASH  -fno-rtti -fno-exceptions ${COMMON_FLAGS})
target_include_directories(firmware PUBLIC
        ${RTOS_DIR}/components/freertos/include
        ${RTOS_DIR}/components/freertos/include
        ${RTOS_DIR}/components/freertos/include/freertos
        ${RTOS_DIR}/components/freertos/include/freertos/private
        ${RTOS_DIR}/components/freertos/port/esp8266/include
        ${RTOS_DIR}/components/freertos/port/esp8266/include/freertos
        ${RTOS_DIR}/components/bootloader_support/include
        ${RTOS_DIR}/components/cjson/include
        ${RTOS_DIR}/components/cjson/cJSON
        ${RTOS_DIR}/components/esp8266/include
        ${RTOS_DIR}/components/esp8266/include
        ${RTOS_DIR}/components/espos/include
        ${RTOS_DIR}/components/jsmn/include
        ${RTOS_DIR}/components/log/include
        ${RTOS_DIR}/components/lwip/include
        ${RTOS_DIR}/components/lwip/include/lwip/apps
        ${RTOS_DIR}/components/lwip/lwip/src/include
        ${RTOS_DIR}/components/lwip/port/esp8266/include
        ${RTOS_DIR}/components/lwip/lwip/src/include/posix
        ${RTOS_DIR}/components/mqtt/include
        ${RTOS_DIR}/components/mqtt/paho/MQTTClient-C/src
        ${RTOS_DIR}/components/mqtt/paho/MQTTClient-C/src/FreeRTOS
        ${RTOS_DIR}/components/mqtt/paho/MQTTPacket/src
        ${RTOS_DIR}/components/newlib/include
        ${RTOS_DIR}/components/newlib/newlib/include
        ${RTOS_DIR}/components/newlib/newlib/port/include
        ${RTOS_DIR}/components/nvs_flash/include
        ${RTOS_DIR}/components/smartconfig_ack/include
        ${RTOS_DIR}/components/spi_flash/include
        ${RTOS_DIR}/components/spiffs/include
        ${RTOS_DIR}/components/spiffs/include/spiffs
        ${RTOS_DIR}/components/ssl/include
        ${RTOS_DIR}/components/ssl/mbedtls/mbedtls/include
        ${RTOS_DIR}/components/ssl/mbedtls/port/esp8266/include
        ${RTOS_DIR}/components/ssl/mbedtls/port/openssl/include
        ${RTOS_DIR}/components/tcpip_adapter/include
        ${RTOS_DIR}/components/tcpip_adapter/include
        ${RTOS_DIR}/components/util/include
        )