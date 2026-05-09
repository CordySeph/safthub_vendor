# วิธีการใช้งาน API: การจัดการการคืนเงิน (Refund Management)

## ภาพรวม
ระบบนี้ช่วยให้ผู้ดูแลระบบ (Admin) สามารถอนุมัติหรือจัดการคำขอคืนเงินจากผู้ใช้ได้

## การยืนยันตัวตน (Authentication)
ต้องใช้ JWT Token ของ Admin ที่มีสิทธิ์ `refunds:manage` ใน Header: `Authorization: Bearer <TOKEN>`

---

## Admin API

Base URL: `/api/admin/refunds`

### 1. สร้างคำขอคืนเงิน
*   **Endpoint:** `POST /`
*   **Example:**
```bash
curl -X POST "http://localhost:8080/api/admin/refunds" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"order_id": "<order_id>", "amount": 100.00, "reason": "damaged_goods"}'
```

### 2. ดูรายการคำขอคืนเงินทั้งหมด
*   **Endpoint:** `GET /`
*   **Example:** `curl -X GET "http://localhost:8080/api/admin/refunds" -H "Authorization: Bearer <TOKEN>"`

### 3. ดูรายละเอียดคำขอคืนเงิน
*   **Endpoint:** `GET /:id`
*   **Example:** `curl -X GET "http://localhost:8080/api/admin/refunds/<id>" -H "Authorization: Bearer <TOKEN>"`

### 4. อัปเดตสถานะคำขอคืนเงิน
*   **Endpoint:** `PATCH /:id/status`
*   **Example:** `curl -X PATCH "http://localhost:8080/api/admin/refunds/<id>/status" -H "Authorization: Bearer <TOKEN>" -d '{"status": "approved"}'`

### 5. ดำเนินการคืนเงิน
*   **Endpoint:** `POST /:id/process`
*   **Example:** `curl -X POST "http://localhost:8080/api/admin/refunds/<id>/process" -H "Authorization: Bearer <TOKEN>"`
