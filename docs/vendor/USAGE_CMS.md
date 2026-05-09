# วิธีการใช้งาน API: ระบบจัดการเนื้อหา (CMS)

## ภาพรวม

ระบบจัดการเนื้อหา (CMS) ช่วยให้ผู้ดูแลระบบสามารถสร้างและจัดการเนื้อหาแบบไดนามิกได้ เช่น หน้าคำถามที่พบบ่อย (FAQ), ประกาศ, หรือแบนเนอร์โปรโมชัน โดยไม่ต้องแก้ไขโค้ดของแอปพลิเคชัน

## การยืนยันตัวตน (Authentication)

*   **Admin API:** ทุก Endpoint ที่อยู่ภายใต้ `/api/admin/content` จำเป็นต้องใช้ Token สำหรับยืนยันตัวตนของผู้ดูแลระบบ (ผู้ใช้ที่มีสิทธิ์ `content:manage`) โดยแนบไปใน `Authorization` header
*   **Public API:** Endpoint ภายใต้ `/api/public/content` ไม่ต้องการการยืนยันตัวตน

---

## 1. Admin API - สำหรับผู้ดูแลระบบ

Base URL: `/api/admin/content`

### 1.1 สร้างเนื้อหาใหม่

*   **Endpoint:** `POST /`
*   **Method:** `POST`
*   **Body (JSON):**
    ```json
    {
        "title": "คำถามที่พบบ่อยเกี่ยวกับการคืนเงิน",
        "slug": "faq-refund-policy",
        "content": "<h1>นโยบายการคืนเงิน</h1><p>คุณสามารถขอคืนเงินได้ภายใน 24 ชั่วโมง...</p>",
        "type": "faq", // ประเภทของเนื้อหา: "faq", "banner", "page"
        "status": "published" // สถานะ: "draft", "published", "archived"
    }
    ```
*   **การตอบกลับ (Success):** `201 Created` พร้อมข้อมูลของเนื้อหาที่ถูกสร้าง

### 1.2 ดูรายการเนื้อหาทั้งหมด

*   **Endpoint:** `GET /`
*   **Method:** `GET`
*   **Query Parameters (Optional):**
    *   `type`: กรองตามประเภท (e.g., `?type=faq`)
    *   `status`: กรองตามสถานะ (e.g., `?status=published`)
*   **การตอบกลับ (Success):** `200 OK` พร้อมรายการเนื้อหาทั้งหมดในรูปแบบ Array

### 1.3 ดูเนื้อหาตาม ID

*   **Endpoint:** `GET /{id}`
*   **Method:** `GET`
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลของเนื้อหาชิ้นนั้นๆ

### 1.4 อัปเดตเนื้อหา

*   **Endpoint:** `PATCH /{id}`
*   **Method:** `PATCH`
*   **Body (JSON):** สามารถส่งเฉพาะฟิลด์ที่ต้องการอัปเดตได้
    ```json
    {
        "title": "นโยบายการคืนเงิน (ฉบับปรับปรุง)",
        "status": "published"
    }
    ```
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลเนื้อหาที่อัปเดตแล้ว

### 1.5 ลบเนื้อหา

*   **Endpoint:** `DELETE /{id}`
*   **Method:** `DELETE`
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อความยืนยัน

---

## 2. Public API - สำหรับสาธารณะ

Base URL: `/api/public/content`

### 2.1 ดูเนื้อหาด้วย Slug

Endpoint นี้ใช้สำหรับดึงข้อมูลเนื้อหาที่ต้องการนำไปแสดงผลในหน้าแอปพลิเคชัน โดยจะแสดงเฉพาะเนื้อหาที่มีสถานะเป็น `published` เท่านั้น

*   **Endpoint:** `GET /{slug}`
    *   ตัวอย่าง: `GET /api/public/content/faq-refund-policy`
*   **Method:** `GET`
*   **การตอบกลับ (Success):** `200 OK` พร้อมข้อมูลของเนื้อหา
*   **การตอบกลับ (Error):** `404 Not Found` หากไม่พบ `slug` หรือสถานะไม่ใช่ `published`
