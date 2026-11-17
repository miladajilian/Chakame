# Chakame – App Store copy

The App Store listing (en-US only). `scripts/release.sh <x.y.z>` sends it with the build;
`swift marketing/upload_listing.swift` is a dry run of the listing alone (add `--apply` to send,
`--screenshots` to include screenshots).
Keep the `## English (U.S.)` heading, the `**Field**` labels and the caption format as they are; the scripts read them.
Character counts in parentheses are only a guide; the script checks the real limits.

| Field | Limit | Where |
|---|---|---|
| Name, Subtitle | 30 each | App Information › Localizable Information (editable only while a version is being prepared) |
| Promotional Text | 170 | Version page (optional; can change any time without review, with `--promo-only`) |
| Description, Keywords, What's New | 4000 / 100 / 4000 | Version page |

**Screenshots:** nine per device in `marketing/screenshots/iphone-6.9` (1320×2868) and `ipad-13` (2064×2752),
the only sizes App Store Connect needs; it scales them down for smaller devices.
`swift marketing/screenshots/compose.swift` frames the raw captures in `marketing/screenshots/raw/{iphone,ipad}`
with the "Screenshot captions" list below.

---

## English (U.S.)

**Name** (23/30)
```
Chakame: Persian Poetry
```
**Subtitle** (28/30)
```
Hafez, Rumi, Saadi & Khayyam
```
**Keywords** (100/100; no spaces after commas, no words already in Name/Subtitle)
```
Ferdowsi,Shahnameh,poem,farsi,ghazal,rubaiyat,masnavi,شعر,حافظ,مولانا,سعدی,خیام,فردوسی,شاهنامه,چکامه
```
**Promotional Text** (137/170, optional)
```
Hafez, Rumi, Khayyam and Saadi in one beautiful, ad-free reader. Save the poems you love with a tap and read them anytime – even offline.
```
**Description** (1227/4000)
```
Read the great Persian poets in their own words – beautifully typeset, organized, and available offline.

Chakame brings the treasury of classical Persian (Farsi) poetry to your iPhone and iPad: the Divan of Hafez, the Masnavi of Rumi (Molana), the Shahnameh of Ferdowsi, the Rubaiyat of Omar Khayyam, the Golestan and Bustan of Saadi, and hundreds more poets across a thousand years of literature.

EVERY POET, EVERY BOOK
• Browse poets by century, from Rudaki to the modern era
• Each poet's complete works, sorted by collection: ghazals, rubaiyat, qasidas, masnavis and more
• Find any poet in a moment with fast search

MADE FOR READING
• Clean, distraction-free pages set in Vazirmatn, a typeface designed for Persian script
• Full right-to-left layout and Persian interface
• Prose and verse side by side, exactly as written – read Golestan's stories as Saadi wrote them
• Keep the screen awake while you read

KEEP AND SHARE
• Tap the heart to save your favorite poems
• Favorites and poems you've opened stay on your device – read them without internet
• Copy a single line or the whole poem and share it with friends

Poem texts come from the open Ganjoor project. Chakame is free, with no ads and no account required.
```
**What's New in This Version**
```
• Poem lists now show each poem's first line under its title
• New design for iPad
• New "Refresh Poems from Ganjoor" option in Settings
• Rate and review Chakame right from Settings
• The tab bar and navigation now follow your device's language direction
```
**Screenshot captions** (headline [highlighted second line] — subline, in App Store order; `compose.swift` renders them in this order)

1. دیوان شاعران پارسی [در جیب شما] — شعر کلاسیک فارسی را زیبا و آسوده بخوانید
2. سخنوران بزرگ [در یک نگاه] — فردوسی، مولانا، حافظ، خیام، سعدی و صدها شاعر دیگر
3. همهٔ آثار هر شاعر [مرتب و دسته‌بندی‌شده] — غزلیات، رباعیات، قصاید، مثنوی و…
4. ۴۹۵ غزل حافظ [تنها با یک لمس] — فهرست کامل اشعار هر دفتر
5. رباعیات خیام [خوش‌خوان و چشم‌نواز] — با قلم وزیرمتن، ساخته‌شده برای خط فارسی
6. گلستان سعدی [نثر و نظم در کنار هم] — حکایت‌ها را همان‌گونه که نوشته شده‌اند بخوانید
7. رونوشت یک مصراع [یا تمام ابیات] — بیت محبوبتان را با دوستان به اشتراک بگذارید
8. شعرهای محبوب شما [همیشه دم دست] — با یک لمس روی قلب نگهشان دارید، حتی بدون اینترنت
9. شاعر دلخواهتان را [در یک لحظه بیابید] — جستجوی سریع میان صدها سخنور پارسی‌گوی
