# วิธีการใช้งานฟีเจอร์: การกำหนดสิทธิ์พนักงานอย่างละเอียด

## ภาพรวม

ฟีเจอร์นี้ช่วยให้เจ้าของร้านอาหาร (Vendor) สามารถสร้าง "บทบาท" (Roles) และกำหนด "สิทธิ์" (Permissions) การเข้าถึงส่วนต่างๆ ให้กับพนักงานในร้านได้อย่างละเอียด ทำให้สามารถจำกัดได้ว่าพนักงานแต่ละคนสามารถทำอะไรได้บ้าง เช่น พนักงานครัวอาจจะดูได้แค่รายการออเดอร์ แต่ผู้จัดการสามารถแก้ไขเมนูและจัดการพนักงานคนอื่นได้

## การยืนยันตัวตน (Authentication)

ทุก API endpoint ที่จะกล่าวถึงด้านล่างนี้ จำเป็นต้องเรียกใช้ในฐานะผู้ใช้ที่เป็นเจ้าของร้านอาหาร (Vendor) โดยต้องแนบ `Authorization` header พร้อมกับ JWT token มาด้วย

---

## 1. การจัดการบทบาทและสิทธิ์ (Staff Roles & Permissions)

Endpoint ทั้งหมดจะอยู่ภายใต้ `/api/vendor/staff-roles`

### 1.1 ดูสิทธิ์ทั้งหมดที่เป็นไปได้
ดูรายการสิทธิ์ทั้งหมดที่สามารถกำหนดให้บทบาทได้

*   **Endpoint:** `GET /api/vendor/staff-roles/permissions`
*   **Method:** `GET`
*   **การตอบกลับ (Success Response):**
    ```json
    [
        {
            "id": "f8a5c3a0-...",
            "name": "orders:view",
            "description": "View incoming and past orders"
        },
        {
            "id": "e1b2c3d4-...",
            "name": "menu:manage",
            "description": "Create, update, delete menu items and categories"
        },
        // ... and so on
    ]
    ```

### 1.2 สร้างบทบาทใหม่
สร้างบทบาทใหม่สำหรับพนักงาน เช่น "ผู้จัดการร้าน", "พนักงานครัว"

*   **Endpoint:** `POST /api/vendor/staff-roles`
*   **Method:** `POST`
*   **Body (JSON):**
    ```json
    {
        "name": "ผู้จัดการร้าน"
    }
    ```
*   **การตอบกลับ (Success Response):**
    ```json
    {
        "id": "a1b2c3d4-...",
        "name": "ผู้จัดการร้าน",
        "permissions": []
    }
    ```

### 1.3 ดูบทบาททั้งหมด
ดูรายการบทบาททั้งหมดที่สร้างไว้

*   **Endpoint:** `GET /api/vendor/staff-roles`
*   **Method:** `GET`

### 1.4 อัปเดตชื่อบทบาท

*   **Endpoint:** `PUT /api/vendor/staff-roles/{role_id}`
*   **Method:** `PUT`
*   **Body (JSON):**
    ```json
    {
        "name": "ผู้จัดการร้าน (อาวุโส)"
    }
    ```

### 1.5 กำหนดสิทธิ์ให้กับบทบาท
ระบุว่าบทบาทที่เลือกสามารถทำอะไรได้บ้าง โดยส่ง ID ของสิทธิ์ (ที่ได้จากข้อ 1.1) ไป

*   **Endpoint:** `PUT /api/vendor/staff-roles/{role_id}/permissions`
*   **Method:** `PUT`
*   **Body (JSON):**
    ```json
    {
        "permission_ids": [
            "f8a5c3a0-...", // ID ของ orders:view
            "e1b2c3d4-..."  // ID ของ menu:manage
        ]
    }
    ```

### 1.6 ลบบทบาท
*   **Endpoint:** `DELETE /api/vendor/staff-roles/{role_id}`
*   **Method:** `DELETE`

---

## 2. การจัดการพนักงาน (Staff Management)

Endpoint ทั้งหมดจะอยู่ภายใต้ `/api/vendor/staff`

### 2.1 เพิ่มพนักงานใหม่
สร้างบัญชีพนักงานใหม่และกำหนดบทบาทให้ทันที

*   **Endpoint:** `POST /api/vendor/staff`
*   **Method:** `POST`
*   **Body (JSON):**
    ```json
    {
        "name": "สมชาย พนักงาน",
        "email": "staff.member@example.com",
        "password": "password123",
        "staff_role_id": "a1b2c3d4-..." // ID ของบทบาทที่สร้างไว้
    }
    ```

### 2.2 อัปเดตพนักงาน
เปลี่ยนชื่อหรือบทบาทของพนักงานที่มีอยู่แล้ว

*   **Endpoint:** `PATCH /api/vendor/staff/{staff_id}`
*   **Method:** `PATCH`
*   **Body (JSON):**
    ```json
    {
        "name": "สมชาย ใจดี",
        "staff_role_id": "b2c3d4e5-..." // ID ของบทบาทใหม่ (ถ้าต้องการเปลี่ยน)
    }
    ```

---

## 3. การบังคับใช้สิทธิ์

หลังจากตั้งค่าทั้งหมดแล้ว ระบบจะทำการตรวจสอบสิทธิ์ของพนักงานโดยอัตโนมัติเมื่อมีการเรียกใช้งาน API ในส่วนต่างๆ ของร้านค้า เช่น:
*   พนักงานที่มีบทบาทที่ไม่มีสิทธิ์ `menu:manage` จะไม่สามารถเรียก API เพื่อสร้างหรือแก้ไขเมนูได้ และจะได้รับการตอบกลับเป็น `403 Forbidden`
*   เจ้าของร้าน (Vendor) จะมีสิทธิ์เต็มทุกอย่างโดยอัตโนัติ
