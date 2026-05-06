# วิธีการใช้งาน API: การส่งออกรายงาน (Admin)

## ภาพรวม

ระบบส่งออกรายงานช่วยให้ผู้ดูแลระบบสามารถสร้างและดาวน์โหลดข้อมูลรายงานเกี่ยวกับคำสั่งซื้อ (Orders) ในรูปแบบไฟล์ CSV ได้ โดยสามารถระบุช่วงวันที่, สถานะของคำสั่งซื้อ, และคอลัมน์ที่ต้องการได้

## การยืนยันตัวตน (Authentication)

ทุก API endpoint ที่จะกล่าวถึงด้านล่างนี้ จำเป็นต้องเรียกใช้ในฐานะผู้ใช้ที่เป็นผู้ดูแลระบบ (Admin) และต้องมีสิทธิ์ `reports:manage` โดยต้องแนบ `Authorization` header พร้อมกับ JWT token มาด้วย

---

## Admin API - สำหรับผู้ดูแลระบบ

Base URL: `/api/admin/reports`

### 1.1 ส่งออกรายงานคำสั่งซื้อ (Orders Export)

*   **Endpoint:** `POST /export/orders`
*   **Method:** `POST`
*   **Body (JSON):**
    ```json
    {
        "start_date": "2025-01-01T00:00:00Z", // วันที่เริ่มต้น (Required)
        "end_date": "2025-01-31T23:59:59Z",   // วันที่สิ้นสุด (Required)
        "status": ["completed", "delivered"],// Optional: กรองตามสถานะ (e.g., "pending", "completed", "cancelled")
        "columns": [                         // Optional: คอลัมน์ที่ต้องการในรายงาน
            "id",                            // รหัสคำสั่งซื้อ
            "total_price",                   // ราคารวม
            "status",                        // สถานะคำสั่งซื้อ
            "created_at",                    // วันที่สร้างคำสั่งซื้อ
            "user_name",                     // ชื่อผู้ใช้ (จากตาราง User)
            "user_email",                    // อีเมลผู้ใช้ (จากตาราง User)
            "restaurant_name"                // ชื่อร้านอาหาร (จากตาราง Restaurant)
        ]
    }
    ```
    *   หากไม่ระบุ `columns` ระบบจะใช้คอลัมน์เริ่มต้นให้: `id`, `total_price`, `status`, `created_at`, `user_name`, `restaurant_name`
*   **Query Parameters (Optional):**
    *   `filename`: ชื่อไฟล์ CSV ที่ต้องการ (e.g., `?filename=my_order_report`) - *ยังไม่ได้รองรับในเวอร์ชันนี้*
*   **การตอบกลับ (Success):** `200 OK` พร้อมไฟล์ CSV ที่ดาวน์โหลด
    *   `Content-Disposition`: `attachment; filename="orders_export_YYYY-MM-DD.csv"`
    *   `Content-Type`: `text/csv`
*   **ข้อผิดพลาด (Error):**
    *   `400 Bad Request`: หาก `start_date` หรือ `end_date` ไม่ถูกต้อง
    *   `500 Internal Server Error`: หากเกิดข้อผิดพลาดในการสร้างรายงาน
