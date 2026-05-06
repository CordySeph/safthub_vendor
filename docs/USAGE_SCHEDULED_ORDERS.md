# วิธีการใช้งาน API: การตั้งเวลาสั่งอาหารล่วงหน้า (Scheduled Orders)

## ภาพรวม

ฟีเจอร์นี้ช่วยให้ผู้ใช้สามารถสั่งอาหารและเลือกเวลาจัดส่งในอนาคตได้ โดยระบบจะจัดเก็บเวลาที่กำหนดไว้ และประมวลผลคำสั่งซื้อเมื่อถึงเวลาที่ใกล้เคียงกับการจัดส่งที่กำหนด

## การยืนยันตัวตน (Authentication)

API Endpoint ที่เกี่ยวข้องกับการสร้างคำสั่งซื้อทั่วไป จะยังคงใช้การยืนยันตัวตนแบบเดิม (เช่น JWT token ของผู้ใช้)

---

## API Endpoint ที่แก้ไข

### 1.1 สร้างคำสั่งซื้อ (Checkout Order)

*   **Endpoint:** `POST /api/orders/checkout` (Endpoint เดิม)
*   **Method:** `POST`
*   **Body (JSON):**
    ```json
    {
        "paymentMethod": "wallet",       // หรือ "cash_on_delivery"
        "addressId": "uuid-ของ-ที่อยู่",
        "scheduledDeliveryTime": "2024-03-10T19:00:00Z" // Optional: เวลาที่ต้องการให้จัดส่ง (ISO 8601 format)
    }
    ```
    *   `scheduledDeliveryTime`: (Optional) ระบุเวลาที่ต้องการให้จัดส่งในอนาคต หากระบุ ระบบจะตั้งสถานะคำสั่งซื้อเป็น `scheduled` จนกว่าจะถึงเวลาใกล้จัดส่ง
    *   **ข้อกำหนด:** `scheduledDeliveryTime` จะต้องเป็นเวลาในอนาคตเท่านั้น หากระบุเวลาในอดีต จะถูกปฏิเสธ

*   **การประมวลผล:**
    *   หาก `scheduledDeliveryTime` ถูกระบุและถูกต้อง คำสั่งซื้อจะถูกสร้างขึ้นในสถานะ `scheduled`
    *   หากไม่ระบุ `scheduledDeliveryTime` หรือระบุเป็น `null` คำสั่งซื้อจะเข้าสู่กระบวนการปกติทันที (สถานะ `pending` หรือ `awaiting_payment`)

*   **การตอบกลับ (Success):** `201 Created` พร้อมข้อความยืนยันและ `orderId`
    ```json
    {
        "message": "Order placed successfully",
        "orderId": "uuid-ของ-order"
    }
    ```
