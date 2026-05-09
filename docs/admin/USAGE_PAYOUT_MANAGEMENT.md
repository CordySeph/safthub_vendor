# วิธีการใช้งาน API: การจัดการการจ่ายเงิน (Payout Management)

## ภาพรวม

ระบบนี้ช่วยให้ผู้ดูแลระบบ (Admin) สามารถตรวจสอบ, อนุมัติ, หรือปฏิเสธคำขอเบิกเงิน (Payout Requests) ที่ส่งมาจากทั้งร้านค้า (Restaurants) และไรเดอร์ (Riders) ได้จากศูนย์กลาง

## การยืนยันตัวตน (Authentication)

ทุก API endpoint ที่จะกล่าวถึงด้านล่างนี้ จำเป็นต้องเรียกใช้ในฐานะผู้ใช้ที่เป็นผู้ดูแลระบบ (Admin) และต้องมีสิทธิ์ `payouts:manage` โดยต้องแนบ `Authorization` header พร้อมกับ JWT token มาด้วย

---

## Admin API - สำหรับผู้ดูแลระบบ

Base URL: `/api/admin/payouts`

### 1.1 ดูรายการคำขอเบิกเงินทั้งหมด

Endpoint นี้จะรวบรวมคำขอเบิกเงินจากทั้งร้านค้าและไรเดอร์มาแสดงในที่เดียว

*   **Endpoint:** `GET /requests`
*   **Method:** `GET`
*   **Query Parameters (Optional):**
    *   `status`: กรองตามสถานะ (e.g., `?status=pending`) สถานะที่เป็นไปได้คือ `pending`, `approved`, `rejected`
*   **การตอบกลับ (Success):** `200 OK` พร้อมรายการคำขอทั้งหมดในรูปแบบ Array
    ```json
    [
        {
            "id": "a1b2c3d4-...",
            "type": "rider", // ประเภทของคำขอ
            "requestor_id": "r1-uuid-...",
            "requestor_name": "สมชาย ไรเดอร์",
            "amount": 1500.50,
            "status": "pending",
            "requested_at": "2025-11-21T10:00:00Z"
        },
        {
            "id": "e5f6g7h8-...",
            "type": "restaurant",
            "requestor_id": "resto-uuid-...",
            "requestor_name": "ร้านอาหารอร่อยดี",
            "amount": 12500.00,
            "status": "pending",
            "requested_at": "2025-11-21T09:30:00Z"
        }
    ]
    ```

### 1.2 อนุมัติ/ปฏิเสธ คำขอเบิกเงินของไรเดอร์

*   **Endpoint:** `PATCH /requests/rider/{id}`
    *   `{id}` คือ ID ของคำขอเบิกเงิน
*   **Method:** `PATCH`
*   **Body (JSON):**
    ```json
    {
        "status": "approved", // "approved" หรือ "rejected"
        "notes": "โอนเงินเรียบร้อย" // Optional: บันทึกของแอดมิน
    }
    ```
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลของ Payout Request ที่อัปเดตแล้ว

### 1.3 อนุมัติ/ปฏิเสธ คำขอเบิกเงินของร้านค้า

*   **Endpoint:** `PATCH /requests/restaurant/{id}`
    *   `{id}` คือ ID ของคำขอเบิกเงิน
*   **Method:** `PATCH`
*   **Body (JSON):**
    ```json
    {
        "status": "rejected", // "approved" หรือ "rejected"
        "notes": "ข้อมูลบัญชีไม่ถูกต้อง กรุณาติดต่อซัพพอร์ต" // Optional: บันทึกของแอดมิน
    }
    ```
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลของ Restaurant Payout Request ที่อัปเดตแล้ว
