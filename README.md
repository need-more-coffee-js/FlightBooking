# FlightBooking

<img src="Screenshots/logo.PNG" width="120" />

**FlightBooking** — учебное iOS-приложение на Swift для поиска авиабилетов и хранения истории QR-сканов билетов.  
Проект сделан на стеке **UIKit + SnapKit + CoreData + GCD**, с кастомной вёрсткой в card-стиле.

---

## Возможности
-  **Список рейсов** — загрузка по API [Travelpayouts](https://travelpayouts.com)  
-  **Фильтры** — выбор направления (откуда/куда), даты, swap-кнопка  
-  **Цветовая индикация** — цена подсвечивается по диапазонам  
-  **Детали рейса** — модальное окно с подробной информацией  
-  **QR-сканер** — считывание билетов и сохранение в CoreData  
-  **История сканов** — просмотр и удаление старых билетов

---

##  Технологии
- **Swift 5**, UIKit, AutoLayout через **SnapKit**
- **CoreData** — для локального хранения сканов
- **GCD** — для фоновой загрузки API и работы с камерой
- **AVFoundation** — для QR-сканирования
- **NSFetchedResultsController** — live-обновления таблицы истории

---

##  Видео

[Смотреть видео](https://youtube.com/shorts/Mz63XlNTW_s?si=LzfCs_HpLCeluK5Z)

---

##  Скриншоты

| Главный экран | Поиск | Детали |
|---------------|-------|--------|
| <img src="Screenshots/main.PNG" width="250"/> | <img src="Screenshots/search.PNG" width="250"/> | <img src="Screenshots/detail.PNG" width="250"/> |

| История | Удаление |
|--------|----------|
| <img src="Screenshots/history.PNG" width="250"/> | <img src="Screenshots/delete.PNG" width="250"/> |

---

##  Демонстрация сканирования

<p align="center">
  <img src="Screenshots/scan.gif" width="300"/>
</p>

---

##  Пример QR-кода для теста

<a href="http://qrcoder.ru" target="_blank">
  <img src="http://qrcoder.ru/code/?%7B%22origin%22%3A%22MOW%22%2C%22destination%22%3A%22KZN%22%2C%22price%22%3A180%2C%22currency%22%3A%22USD%22%2C%22departure_at%22%3A%222025-11-25T11%3A00%3A00Z%22%2C%22return_at%22%3A%222025-12-18T10%3A05%3A00Z%22%2C%22airline%22%3A%22SU%22%2C%22flight_number%22%3A6131%7D&4&0" 
       width="244" height="244" title="QR код для теста">
</a>

QR-код содержит JSON следующего вида:

```json
{
  "origin": "MOW",
  "destination": "KZN",
  "price": 180,
  "currency": "USD",
  "departure_at": "2025-11-25T11:00:00Z",
  "return_at": "2025-12-18T10:05:00Z",
  "airline": "SU",
  "flight_number": 6131
}

---
##  Установка
1. Клонируйте проект  
   ```bash
   git clone https://github.com/yourusername/FlightBooking.git
   
   TOKEN -> Token.plist 
   
<dict>
<key>TRAVELPAYOUTS_TOKEN</key>
<string>ВАШ_ТОКЕН</string>
</dict>

