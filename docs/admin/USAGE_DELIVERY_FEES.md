# วิธีการใช้งาน API: การจัดการค่าจัดส่งแบบไดนามิก (Dynamic Delivery Fee Management)

## ภาพรวม

ระบบนี้ช่วยให้ผู้ดูแลระบบ (Admin) สามารถสร้าง, แก้ไข, ลบ, และจัดการกฎการคำนวณค่าจัดส่งแบบไดนามิกได้ ซึ่งสามารถกำหนดค่าส่งตามเงื่อนไขต่างๆ เช่น ช่วงเวลา, วันในสัปดาห์, ระยะทาง หรือยอดรวมคำสั่งซื้อ

## การยืนยันตัวตน (Authentication)

ทุก API endpoint ที่จะกล่าวถึงด้านล่างนี้ จำเป็นต้องเรียกใช้ในฐานะผู้ใช้ที่เป็นผู้ดูแลระบบ (Admin) และต้องมีสิทธิ์ `delivery-fees:manage` โดยต้องแนบ `Authorization` header พร้อมกับ JWT token มาด้วย

---

## Admin API - สำหรับผู้ดูแลระบบ

Base URL: `/api/admin/delivery-fees`

### 1.1 สร้างกฎค่าจัดส่งใหม่

*   **Endpoint:** `POST /`
*   **Method:** `POST`
*   **Body (JSON):**
    ```json
    {
        "name": "ค่าธรรมเนียมพื้นฐาน",
        "description": "ค่าจัดส่งขั้นต่ำสำหรับทุกออเดอร์",
        "rule_type": "base_fee",
        "value": 30.00,
        "priority": 10,
        "is_active": true
    }
    ```
    หรือ
    ```json
    {
        "name": "ช่วงเวลาเร่งด่วนเย็นวันศุกร์",
        "description": "เพิ่มค่าจัดส่ง 50% ทุกเย็นวันศุกร์ 17:00-20:00",
        "rule_type": "surge_multiplier",
        "value": 1.5,
        "priority": 100,
        "is_active": true,
        "start_time": "17:00:00",
        "end_time": "20:00:00",
        "days_of_week": ["friday"]
    }
    ```
    หรือ
    ```json
    {
        "name": "ค่าส่งต่อกิโลเมตร",
        "description": "คิดเพิ่ม 5 บาทต่อกิโลเมตร",
        "rule_type": "per_kilometer",
        "value": 5.00,
        "priority": 20,
        "is_active": true,
        "min_distance_km": 1.0
    }
    ```
    *   `rule_type`: (enum: `base_fee`, `per_kilometer`, `surge_multiplier`, `fixed_surcharge`)
    *   `value`: (float) ค่าตัวเลขสำหรับกฎนั้นๆ
    *   `priority`: (int) ลำดับความสำคัญในการประมวลผลกฎ (ค่าต่ำสุดถูกประมวลผลก่อน)
    *   `is_active`: (boolean) สถานะของกฎ
    *   `start_time`, `end_time`: (string, format "HH:MM:SS") ช่วงเวลาที่กฎมีผล (Optional)
    *   `days_of_week`: (array of string, enum: `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday`, `sunday`) วันในสัปดาห์ที่กฎมีผล (Optional)
    *   `min_distance_km`, `max_distance_km`: (float) ระยะทาง (กม.) ที่กฎมีผล (Optional)
    *   `min_order_subtotal`, `max_order_subtotal`: (float) ยอดรวมคำสั่งซื้อ (ไม่รวมค่าจัดส่ง) ที่กฎมีผล (Optional)
*   **การตอบกลับ (Success):** `201 Created` พร้อมข้อมูลของกฎที่สร้างขึ้น

### 1.2 ดูรายการกฎค่าจัดส่งทั้งหมด

*   **Endpoint:** `GET /`
*   **Method:** `GET`
*   **การตอบกลับ (Success):** `200 OK` พร้อมรายการกฎทั้งหมดในรูปแบบ Array โดยเรียงตาม `priority`

### 1.3 ดูรายละเอียดกฎค่าจัดส่ง

*   **Endpoint:** `GET /{id}`
*   **Method:** `GET`
*   `{id}`: ID (UUID) ของกฎ
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลของกฎนั้นๆ

### 1.4 อัปเดตกฎค่าจัดส่ง

*   **Endpoint:** `PUT /{id}`
*   **Method:** `PUT`
*   `{id}`: ID (UUID) ของกฎ
*   **Body (JSON):** เหมือนกับตอนสร้างกฎ (`POST /`) แต่ต้องมี `id` ใน URL
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลของกฎที่อัปเดตแล้ว

### 1.5 ลบกฎค่าจัดส่ง

*   **Endpoint:** `DELETE /{id}`
*   **Method:** `DELETE`
*   `{id}`: ID (UUID) ของกฎ
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อความยืนยันการลบ
