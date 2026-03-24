# Segway G3 Max: Модификация VCU (разгон и смена региона)

## ⚠️ Внимание
**Гарантия на самокат будет аннулирована!**  
Вы выполняете действия на свой страх и риск. Возможные последствия:
- Поломка контроллера VCU
- Нестабильная работа самоката

## 📋 Необходимые компоненты
1. **Оборудование**:
   - Программатор ST-Link v2
   - Кабели DUPON
   - Паяльник (для контакта TP13V3)

2. **Софт**:
   - [Драйвер STLink]
   - [ПО для модификации](https://github.com/Sharkboy-j/ninebot-g3-max-vcu-speed-hack/releases/latest)

Целевой MCU: `AT32F415CBT7` (Flash 128 KB).

## 🛠 Подготовка
1. Установите драйвер (`dpinst_amd64.exe`)
2. Распакуйте архив с ПО в папку **без русских символов в пути**
3. Основные файлы:
   - `dump_memory.bat` - чтение дампа
   - `fix_vcu.exe` - модификация
   - `flash_memory_patched.bat` - запись прошивки

### macOS (новые скрипты)
Для macOS добавлены аналоги:
- `dump_memory_mac.sh`
- `flash_memory_original_mac.sh`
- `flash_memory_patched_mac.sh`

Сборка OpenOCD (Artery fork) для macOS:
```bash
chmod +x build_openocd_artery_mac.sh
./build_openocd_artery_mac.sh "https://github.com/ArteryTek/openocd.git" "$(pwd)/.build" "$(pwd)/.local/openocd-artery"
```

После сборки можно запускать mac-скрипты напрямую, они автоматически используют локальный бинарник `./.local/openocd-artery/bin/openocd`.

## 🔌 Подключение ST-Link
Перед подключением внимательно посмотрите на распиновку своего ST-Link, она может различаться в зависимости от вашего экземпляра
![Распиновка](https://github.com/Sharkboy-j/ninebot-g3-max-vcu-speed-hack/raw/refs/heads/main/img/stlink.png)

**Важно!** Отключите VCU от самоката перед работой.

| Номер | ST-Link | VCU       |
|:-------:|:-------:|:----------|
| 1 | SWDIO   | DIO       |
| 2 | SWCLK   | CLK       |
| 3 | GND     | GND       |
| 4 | 3.3V    | TP13V3*   |
| 5 | GND**   | C45 (временное) |

\*Требуется пайка (контакт хрупкий!)
\*\*Используется только для замыкания на C45

![Контакты](https://github.com/Sharkboy-j/ninebot-g3-max-vcu-speed-hack/raw/refs/heads/main/img/pins.png)

## 🔄 Процесс модификации

### 1. Создание дампа
1. Замкните 5 пин (GND) на C45
2. Запустите `dump_memory.bat`
3. При появлении строки `oocd\scripts/mem_helper.tcl", line 37` разомкните контакт
4. Проверьте наличие файла `MEMORY_G3.bin` (128 КБ)
5. загрузите любой hex редактор, например, https://mh-nexus.de/en/hxd/
6. откройте hex-редактор, откройте файл `MEMORY_G3.bin`.
7. нажмите edit-> Goto (в других программах может быть go to offset)
8. введите 1F020 или 0x1F020
9. вы должны увидеть свой серийный номер два раза, если нет, то ваш дамп !!!поврежден!!!! начинайте с начала
![Serial](https://github.com/Sharkboy-j/ninebot-g3-max-vcu-speed-hack/raw/refs/heads/main/img/serial.jpeg)

### 2. Изменение параметров
Запустите `fix_vcu.exe`:
Следуйте инструкциям программы. Чтобы сменить регион самоката необходимо изменить SN

Change region? (Y/N): <u>**Y**</u>

### 3. Прошивка
1. Снова замкните GND на C45
2. Запустите `flash_memory_patched.bat`
3. Разомкните при появлении `oocd\scripts/mem_helper.tcl", line 37`
5. Процесс передачи будет завершён когда в выводе консоли можно будет увидеть строчку вида `wrote 131072 bytes from file MEMORY_G3.bin.patched.bin to flash bank 0 at offset 0x00000000 in 3.471415s (36.873 KiB/s)`

Если при прошивке есть ошибка `flash memory write protected`, сначала снимите защиту:
- Windows: `fix_option_bytes.bat`
- macOS: `./fix_option_bytes_mac.sh`

После этого отключите/подключите питание VCU и запустите прошивку снова.
Если прошивка падает с `flash write algorithm aborted by target`, добавьте в команду OpenOCD `-c "set WORKAREASIZE 0"` перед `-f .../at32.cfg` (отключает блочный алгоритм в RAM; сильно медленнее, иногда помогает).

### 4. Настройка после прошивки
1. Отвяжите самокат в приложении
2. Подключите VCU обратно к самокату предварительно отключив от STLink
3. Привяжите заново и активируйте **оба** переключателя:
![Настройки](https://github.com/Sharkboy-j/ninebot-g3-max-vcu-speed-hack/raw/refs/heads/main/img/ninebotsettings1.png)

### 5. Финал
Повторите шаги 1-3 для активации изменений.  
**Важно!** Не трогайте слайдеры после этого!

## ❌ Возможные ошибки
- `open failed` → Проверьте подключение STLink к ПК
- `init mode failed` → Ошибка подключения к VCU (проверьте контакты)

- Если вы получили ошибку, что ваш SN уже привязан к другой учетной записи:
   1. запустите change_sn_windows_amd64.exe
   2. выберите ваш файл MEMORY_G3.bin.patched.bin 
   3. введите новый SN, шаблон 1CGCC++++C++++, где + это любое число.
   4. будет создан файл с именем MEMORY_G3.bin.patched.bin.sn_changed.bin
   5. переименуйте его в MEMORY_G3.bin.patched.bin
   6. Прошейте его снова
