# วิธีการใช้งาน API: การจัดการการตั้งค่าแพลตฟอร์ม (Platform Configuration)

## ภาพรวม

ระบบการจัดการการตั้งค่าแพลตฟอร์มช่วยให้ผู้ดูแลระบบ (Admin) สามารถดูและปรับเปลี่ยนค่าการตั้งค่าหลักของระบบได้อย่างง่ายดายผ่าน API เช่น อัตราค่าคอมมิชชั่นต่างๆ ซึ่งจะถูกนำไปใช้โดยอัตโนมัติในการคำนวณของระบบ

## การยืนยันตัวตน (Authentication)

ทุก API endpoint ที่จะกล่าวถึงด้านล่างนี้ จะต้องใช้ Token ที่ยืนยันตัวตนของผู้ดูแลระบบ (Admin) ซึ่งมีสิทธิ์ `platform:manage` โดยต้องแนบไปใน `Authorization` header

---

## Admin API - สำหรับผู้ดูแลระบบ

Base URL: `/api/admin/platform-config`

### 1.1 ดูรายการการตั้งค่าทั้งหมด

*   **Endpoint:** `GET /`
*   **Method:** `GET`
*   **การตอบกลับ (Success):** `200 OK` พร้อมรายการการตั้งค่าทั้งหมดในรูปแบบ Array
    ```json
    [
        {
            "id": "pc1-uuid-...",
            "key": "default_rider_commission_rate",
            "value": "0.10",
            "description": "Default commission rate for new riders.",
            "created_at": "...",
            "updated_at": "..."
        },
        {
            "id": "pc2-uuid-...",
            "key": "promptpay_commission_rate",
            "value": "0.15",
            "description": "Commission rate for orders paid via PromptPay.",
            "created_at": "...",
            "updated_at": "..."
        }
    ]
    ```

### 1.2 อัปเดตค่าการตั้งค่า

*   **Endpoint:** `PUT /:key`
    *   `key` คือ `key` ของการตั้งค่าที่ต้องการอัปเดต (เช่น `default_rider_commission_rate`)
*   **Method:** `PUT`
*   **Body (JSON):**
    ```json
    {
        "value": "0.12", // ค่าใหม่ที่ต้องการตั้ง
        "description": "Adjusted default commission rate for new riders effective Jan 1, 2026." // Optional: อัปเดตคำอธิบาย
    }
    ```
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลของ Platform Config ที่อัปเดตแล้ว
*   **ข้อควรระวัง:** การอัปเดตค่านี้จะมีผลทันทีต่อการทำงานของระบบที่อ้างอิงถึงค่านั้น
