# วิธีการใช้งาน API: การจัดการข้อพิพาท (Dispute Management)

## ภาพรวม
ระบบนี้ช่วยให้ผู้ดูแลระบบ (Admin) สามารถจัดการข้อพิพาทที่เกิดขึ้นระหว่างผู้ใช้และร้านค้า/ไรเดอร์ได้ เช่น การตรวจสอบข้อเท็จจริง และตัดสินผลสรุปของข้อพิพาท

## การยืนยันตัวตน (Authentication)
ต้องใช้ JWT Token ของ Admin ที่มีสิทธิ์ `disputes:manage` ใน Header: `Authorization: Bearer <TOKEN>`

---

## Admin API

Base URL: `/api/admin/disputes`

### 1. ดูรายการข้อพิพาททั้งหมด
*   **Endpoint:** `GET /`
*   **Example:** `curl -X GET "http://localhost:8080/api/admin/disputes" -H "Authorization: Bearer <TOKEN>"`

### 2. ดูรายละเอียดข้อพิพาทตาม ID
*   **Endpoint:** `GET /:id`
*   **Example:** `curl -X GET "http://localhost:8080/api/admin/disputes/<id>" -H "Authorization: Bearer <TOKEN>"`

### 3. อัปเดตสถานะข้อพิพาท
*   **Endpoint:** `PATCH /:id/status`
*   **Example:**
```bash
curl -X PATCH "http://localhost:8080/api/admin/disputes/<id>/status" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'
```

### 4. ตัดสินข้อพิพาท
*   **Endpoint:** `POST /:id/resolve`
*   **Example:** `curl -X POST "http://localhost:8080/api/admin/disputes/<id>/resolve" -H "Authorization: Bearer <TOKEN>"`

### 5. ปิดข้อพิพาท
*   **Endpoint:** `POST /:id/close`
*   **Example:** `curl -X POST "http://localhost:8080/api/admin/disputes/<id>/close" -H "Authorization: Bearer <TOKEN>"`
