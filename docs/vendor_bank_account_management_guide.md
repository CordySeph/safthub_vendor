### **ภาพรวม API การจัดการบัญชีธนาคาร**

*   **Base Path:** `/api/vendor/bank-accounts`
*   **Authentication:** ทุก endpoint ในส่วนนี้จำเป็นต้องใช้ JWT token ของ `vendor` ที่ร้านค้าได้รับการอนุมัติแล้ว

---

#### **1. เพิ่มบัญชีธนาคารใหม่**

*   **Endpoint:** `POST /`
*   **คำอธิบาย:** เพิ่มบัญชีธนาคารใหม่สำหรับร้านค้าของคุณ
*   **Request Body:**
    ```json
    {
        "bank_name": "Kasikorn Bank",
        "account_number": "1234567890",
        "account_holder_name": "Mr. Vendor Name",
        "is_default": true
    }
    ```
    *   `is_default` (optional): หากตั้งเป็น `true` บัญชีนี้จะถูกใช้เป็นบัญชีหลักในการรับเงิน

*   **Example `curl`:**
    ```bash
    curl -L -X POST http://localhost:8080/api/vendor/bank-accounts \
      -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
      -H "Content-Type: application/json" \
      -d '{"bank_name": "Kasikorn Bank", "account_number": "1234567890", "account_holder_name": "Mr. Vendor Name", "is_default": true}'
    ```

*   **Success Response (201 Created):**
    ```json
    {
        "id": "a1b2c3d4-e5f6-...",
        "restaurant_id": "...",
        "bank_name": "Kasikorn Bank",
        "account_number_mask": "********7890",
        "account_holder_name": "Mr. Vendor Name",
        "is_default": true
    }
    ```
    *(**หมายเหตุ:** เลขบัญชีจะถูกปิดไว้เพื่อความปลอดภัย)*

---

#### **2. ดูรายการบัญชีธนาคารทั้งหมด**

*   **Endpoint:** `GET /`
*   **คำอธิบาย:** ดูรายการบัญชีธนาคารทั้งหมดที่ได้เพิ่มไว้สำหรับร้านค้าของคุณ

*   **Example `curl`:**
    ```bash
    curl -L -X GET http://localhost:8080/api/vendor/bank-accounts \
      -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
    ```

*   **Success Response (200 OK):**
    (จะแสดงผลเป็น Array ของ Object บัญชีธนาคาร เหมือนในข้อ 1)

---

#### **3. ตั้งค่าบัญชีหลัก**

*   **Endpoint:** `POST /:id/set-default`
*   **คำอธิบาย:** ตั้งค่าให้บัญชีธนาคารที่ระบุเป็นบัญชีหลักสำหรับการรับเงิน

*   **Example `curl`:**
    ```bash
    # แทนที่ :id ด้วย ID ของบัญชีธนาคารที่ต้องการ
    curl -L -X POST http://localhost:8080/api/vendor/bank-accounts/a1b2c3d4-e5f6-.../set-default \
      -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
    ```

*   **Success Response (200 OK):**
    ```json
    {
        "message": "Default bank account set successfully"
    }
    ```

---

#### **4. แก้ไขข้อมูลบัญชีธนาคาร**

*   **Endpoint:** `PATCH /:id`
*   **คำอธิบาย:** แก้ไขชื่อธนาคาร หรือ ชื่อเจ้าของบัญชี (ไม่สามารถแก้ไขเลขบัญชีได้)
*   **Request Body:**
    ```json
    {
        "bank_name": "Siam Commercial Bank",
        "account_holder_name": "Mr. Vendor Newname"
    }
    ```

*   **Example `curl`:**
    ```bash
    # แทนที่ :id ด้วย ID ของบัญชีธนาคารที่ต้องการ
    curl -L -X PATCH http://localhost:8080/api/vendor/bank-accounts/a1b2c3d4-e5f6-... \
      -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
      -H "Content-Type: application/json" \
      -d '{"account_holder_name": "Mr. Vendor Newname"}'
    ```

*   **Success Response (200 OK):**
    (จะแสดงผลเป็น Object บัญชีธนาคารที่ถูกแก้ไข)

---

#### **5. ลบบัญชีธนาคาร**

*   **Endpoint:** `DELETE /:id`
*   **คำอธิบาย:** ลบบัญชีธนาคารที่ไม่ต้องการใช้งานแล้ว

*   **Example `curl`:**
    ```bash
    # แทนที่ :id ด้วย ID ของบัญชีธนาคารที่ต้องการ
    curl -L -X DELETE http://localhost:8080/api/vendor/bank-accounts/a1b2c3d4-e5f6-... \
      -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
    ```

*   **Success Response (204 No Content):**
    (จะไม่มี Response Body กลับมา)
