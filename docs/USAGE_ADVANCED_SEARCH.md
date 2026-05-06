# วิธีการใช้งาน API: การค้นหาและกรองขั้นสูง (Advanced Search)

## ภาพรวม

Endpoint นี้ช่วยให้ผู้ใช้สามารถค้นหาและกรองร้านอาหารได้ตามเงื่อนไขต่างๆ ที่ซับซ้อนขึ้น เพื่อผลลัพธ์ที่ตรงกับความต้องการมากที่สุด

## Endpoint

`GET /api/search/restaurants`

## Query Parameters

คุณสามารถผสมผสานพารามิเตอร์ต่างๆ เข้าด้วยกันเพื่อการค้นหาที่ละเอียดขึ้น

| Parameter    | Type    | รายละเอียด                                                                                                 | ตัวอย่าง                               |
| :----------- | :------ | :--------------------------------------------------------------------------------------------------------- | :------------------------------------- |
| `q`          | string  | ค้นหาตามชื่อร้าน (ค้นหาบางส่วนของคำ, ไม่สนตัวพิมพ์เล็ก/ใหญ่)                                                      | `?q=Pizza`                             |
| `category`   | string  | **(ใหม่)** กรองตามประเภทอาหาร (ค้นหาบางส่วนของคำ, ไม่สนตัวพิมพ์เล็ก/ใหญ่)                                        | `?category=Thai`                       |
| `tags`       | string  | กรองตามแท็ก (ใส่ได้หลายค่า คั่นด้วย `,`) ร้านอาหารต้องมีครบทุกแท็กที่ระบุ                                       | `?tags=Thai,Healthy`                   |
| `rating`     | float   | กรองตามคะแนนรีวิวขั้นต่ำ                                                                                    | `?rating=4.5`                          |
| `price_range`| string  | กรองตามระดับราคา                                                                                           | `?price_range=$$`                      |
| `promotions` | boolean | **(ใหม่)** กรองร้านที่มีโปรโมชั่น (`true`) หรือไม่มี (`false`)                                               | `?promotions=true`                     |
| `sort_by`    | string  | จัดเรียงผลลัพธ์ (`rating_desc` หรือ `distance_asc`)                                                        | `?sort_by=rating_desc`                 |
| `lat`        | float   | Latitude ของผู้ใช้ (จำเป็นสำหรับ `sort_by=distance_asc`)                                                   | `?lat=13.7563`                         |
| `lon`        | float   | Longitude ของผู้ใช้ (จำเป็นสำหรับ `sort_by=distance_asc`)                                                  | `?lon=100.5018`                        |
| `page`       | integer | หมายเลขหน้าสำหรับ Pagination (ค่าเริ่มต้นคือ `1`)                                                           | `?page=2`                              |
| `limit`      | integer | จำนวนรายการต่อหน้า (ค่าเริ่มต้นคือ `10`)                                                                    | `?limit=5`                             |

---

## ตัวอย่างการใช้งาน

#### 1. ค้นหาร้านอาหารญี่ปุ่นที่เรตติ้ง 4 ดาวขึ้นไป
```bash
curl "http://localhost:8080/api/search/restaurants?category=Japanese&rating=4"
```

#### 2. ค้นหาร้านที่มีโปรโมชั่นและเรียงตามเรตติ้งจากสูงไปต่ำ
```bash
curl "http://localhost:8080/api/search/restaurants?promotions=true&sort_by=rating_desc"
```

#### 3. ค้นหาร้านอาหารอีสานที่อยู่ใกล้ฉันที่สุดและมีโปรโมชั่น
```bash
curl "http://localhost:8080/api/search/restaurants?category=อีสาน&promotions=true&sort_by=distance_asc&lat=13.7563&lon=100.5018"
```
