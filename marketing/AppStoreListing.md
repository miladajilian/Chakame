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

**Name** (7/30)
```
Chakame
```
**Subtitle** (13/30)
```
Persian poems
```
**Keywords** (78/100)
```
poem, poetry, shahname, chakame, شعر, شاعر, شاهنامه, حافظ, سعدی, فردوسی, چکامه
```
**Promotional Text** (0/170, optional)
```
```
**Description** (177/4000)
```
Chakame is an iOS app that provides access to a collection of Persian poems. Enjoy reading numerous Persian poems with the convenience of locally stored data after the download.
```
**What's New in This Version**
```
Migration to a new database
Update to the liquid glass interface
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
