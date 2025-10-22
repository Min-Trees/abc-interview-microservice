# 🔧 Postman Troubleshooting - Socket Hang Up

## ❌ Lỗi "Socket Hang Up"

Lỗi này thường xảy ra khi:
- Timeout quá ngắn
- Request quá lớn
- Cấu hình Postman không đúng
- Backend không phản hồi kịp thời

## ✅ Giải pháp

### 1. **Cấu hình Timeout trong Postman**

1. Mở Postman Settings (⚙️)
2. Vào tab **General**
3. Tăng các giá trị timeout:
   - **Request timeout in ms**: `300000` (5 phút)
   - **Request timeout in ms (Socket)**: `300000` (5 phút)

### 2. **Kiểm tra Environment Variables**

Đảm bảo các biến môi trường đúng:
```json
{
  "base_url": "http://localhost:8080",
  "auth_url": "http://localhost:8081", 
  "user_url": "http://localhost:8082",
  "question_url": "http://localhost:8085"
}
```

### 3. **Kiểm tra Headers**

Đảm bảo có đầy đủ headers:
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer <token> (nếu cần)
```

### 4. **Kiểm tra Request Body**

- JSON phải valid
- Không có ký tự đặc biệt
- Size không quá lớn

### 5. **Test từng bước**

1. **Test Gateway Health:**
   ```
   GET http://localhost:8080/actuator/health
   ```

2. **Test Auth Service:**
   ```
   POST http://localhost:8080/auth/login
   Body: {"email": "admin@example.com", "password": "123456"}
   ```

3. **Test Question Service:**
   ```
   GET http://localhost:8080/questions/fields
   ```

### 6. **Cấu hình Proxy (nếu cần)**

Nếu dùng proxy:
1. Settings → Proxy
2. Tắt "Use the system proxy"
3. Hoặc cấu hình proxy đúng

### 7. **Kiểm tra Firewall/Antivirus**

- Tắt tạm thời Windows Firewall
- Tắt tạm thời Antivirus
- Kiểm tra xem có chặn port 8080 không

### 8. **Restart Services**

```bash
# Restart Gateway
docker restart interview-gateway-service

# Restart tất cả services
docker-compose restart
```

### 9. **Kiểm tra Logs**

```bash
# Gateway logs
docker logs interview-gateway-service -f

# Question Service logs  
docker logs interview-question-service -f

# User Service logs
docker logs interview-user-service -f
```

### 10. **Test với cURL**

```bash
# Test login
curl -X POST "http://localhost:8080/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "123456"}'

# Test get fields
curl -X GET "http://localhost:8080/questions/fields"
```

## 🚨 Lỗi thường gặp

### 1. **"Connection refused"**
- Services chưa start
- Port bị chặn
- Docker container down

### 2. **"Timeout"**
- Request quá lâu
- Database chậm
- Network lag

### 3. **"Invalid JSON"**
- Body không đúng format
- Ký tự đặc biệt
- Encoding issues

### 4. **"Unauthorized"**
- Token hết hạn
- Token không đúng format
- Role không đủ quyền

## 📞 Hỗ trợ

Nếu vẫn gặp lỗi:
1. Chụp screenshot lỗi
2. Copy logs từ console
3. Mô tả steps tái tạo lỗi
4. Kiểm tra network connectivity
