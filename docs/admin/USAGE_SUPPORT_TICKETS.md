# วิธีการใช้งาน API: ระบบจัดการตั๋วซัพพอร์ต (สำหรับ Admin)

## ภาพรวม

ระบบนี้ช่วยให้ผู้ดูแลระบบ (Admin) สามารถดู, จัดการ, และตอบกลับตั๋วซัพพอร์ต (Support Tickets) ที่ผู้ใช้ (Users) และไรเดอร์ (Riders) ส่งเข้ามาในระบบได้

## การยืนยันตัวตน (Authentication)

ทุก API endpoint ที่จะกล่าวถึงด้านล่างนี้ จำเป็นต้องเรียกใช้ในฐานะผู้ใช้ที่เป็นผู้ดูแลระบบ (Admin) และต้องมีสิทธิ์ `support:manage` โดยต้องแนบ `Authorization` header พร้อมกับ JWT token มาด้วย

---

## Admin API - สำหรับผู้ดูแลระบบ

Base URL: `/api/admin/support`

### 1.1 ดูรายการตั๋วซัพพอร์ตทั้งหมด

*   **Endpoint:** `GET /tickets`
*   **Method:** `GET`
*   **Query Parameters (Optional):**
    *   `status`: กรองตามสถานะ (e.g., `?status=open`)
    *   `page`: ระบุหน้า (e.g., `?page=1`)
    *   `limit`: ระบุจำนวนรายการต่อหน้า (e.g., `?limit=20`)
*   **การตอบกลับ (Success):** `200 OK` พร้อมรายการตั๋วทั้งหมดในรูปแบบ Array และข้อมูล pagination

### 1.2 ดูรายละเอียดตั๋วและประวัติการตอบกลับ

*   **Endpoint:** `GET /tickets/{ticket_id}`
*   **Method:** `GET`
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลของตั๋วและรายการตอบกลับ (replies) ทั้งหมด
    ```json
    {
        "ticket": {
            "id": "...",
            "subject": "...",
            "description": "...",
            // ... other ticket fields
        },
        "replies": [
            {
                "id": "...",
                "message": "นี่คือข้อความจากผู้ใช้",
                "is_admin_reply": false,
                "created_at": "..."
            },
            {
                "id": "...",
                "message": "นี่คือการตอบกลับจากแอดมิน",
                "is_admin_reply": true,
                "created_at": "..."
            }
        ]
    }
    ```

### 1.3 ตอบกลับตั๋วซัพพอร์ต

*   **Endpoint:** `POST /tickets/{ticket_id}/replies`
*   **Method:** `POST`
*   **Body (JSON):**
    ```json
    {
        "message": "สวัสดีครับ แอดมินได้รับเรื่องแล้วและกำลังดำเนินการตรวจสอบให้ครับ"
    }
    ```
*   **การตอบกลับ (Success):** `201 Created` พร้อมข้อมูลของ Reply ที่ถูกสร้าง

### 1.4 มอบหมายตั๋วให้เจ้าหน้าที่

*   **Endpoint:** `POST /tickets/{ticket_id}/assign`
*   **Method:** `POST`
*   **Body (JSON):**
    ```json
    {
        "agent_id": "c4a7e3a0-..." // UUID ของ Admin ที่จะมอบหมายให้ดูแล
    }
    ```
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลตั๋วที่อัปเดตแล้ว

### 1.5 อัปเดตสถานะตั๋ว

*   **Endpoint:** `PATCH /tickets/{ticket_id}/status`
*   **Method:** `PATCH`
*   **Body (JSON):**
    ```json
    {
        "status": "in_progress" // สถานะที่เป็นไปได้: "open", "in_progress", "resolved", "closed"
    }
    ```
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลตั๋วที่อัปเดตแล้ว
