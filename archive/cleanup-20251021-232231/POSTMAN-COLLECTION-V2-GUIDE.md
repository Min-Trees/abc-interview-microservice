# 📮 Postman Collection v2 - Complete Guide

## 🎯 Overview

File `INTERVIEW_APIS_COMPLETE_V2.postman_collection.json` đã được cập nhật với:

- ✅ **RegisterRequest mới** - Support cả `roleId` và `roleName`
- ✅ **Gateway URL đúng** - `http://localhost:8222`
- ✅ **RFC 7807 error testing** - Test tất cả error scenarios
- ✅ **Comprehensive test scripts** - Auto-verify responses
- ✅ **Token management** - Auto-save và reuse tokens

---

## 🚀 Quick Start

### 1. Import Collection
1. Mở Postman
2. Click **Import**
3. Chọn file: `INTERVIEW_APIS_COMPLETE_V2.postman_collection.json`
4. Click **Import**

### 2. Set Environment Variables
Collection đã có sẵn variables:
- `base_url`: `http://localhost:8222`
- `access_token`: (auto-filled)
- `refresh_token`: (auto-filled)
- `user_id`: `3`

### 3. Run Authentication Flow
1. **1.1 Register User (with roleName)** - Test register với roleName
2. **1.2 Register User (with roleId)** - Test register với roleId
3. **1.4 Login** - Login với existing user
4. **1.5 Refresh Token** - Test token refresh

---

## 📋 Collection Structure

### **1. Authentication Flow**
- ✅ **1.1 Register User (with roleName)** - Dùng `roleName: "USER"`
- ✅ **1.2 Register User (with roleId)** - Dùng `roleId: 1`
- ✅ **1.3 Register Admin** - Dùng `roleName: "ADMIN"`
- ✅ **1.4 Login** - Login với existing user
- ✅ **1.5 Refresh Token** - Refresh expired token
- ✅ **1.6 Verify Email** - Verify email với token

### **2. Error Testing**
- ✅ **2.1 Register - Invalid Role Name** → 404 + RFC 7807
- ✅ **2.2 Register - Invalid Role ID** → 404 + RFC 7807
- ✅ **2.3 Register - Duplicate Email** → 409 + RFC 7807
- ✅ **2.4 Register - Validation Error** → 400 + RFC 7807 + details
- ✅ **2.5 Login - Invalid Credentials** → 401 + RFC 7807
- ✅ **2.6 Get User - Not Found** → 404 + RFC 7807

### **3. User Management**
- ✅ **3.1 Get User by ID** - Get user profile
- ✅ **3.2 Update User Role** - Admin only
- ✅ **3.3 Update User Status** - Admin only
- ✅ **3.4 Apply ELO Points** - Update ELO score

### **4. Questions**
- ✅ **4.1 Get All Questions** - List questions
- ✅ **4.2 Get Question by ID** - Get specific question
- ✅ **4.3 Create Question** - Create new question

### **5. Exams**
- ✅ **5.1 Get All Exams** - List exams
- ✅ **5.2 Create Exam** - Create new exam
- ✅ **5.3 Submit Exam Answer** - Submit answers

### **6. Careers**
- ✅ **6.1 Get All Careers** - List job postings
- ✅ **6.2 Create Career** - Create job posting

### **7. News**
- ✅ **7.1 Get All News** - List news articles
- ✅ **7.2 Create News** - Create news article

### **8. Health Checks**
- ✅ **8.1 Gateway Health** - Check gateway status
- ✅ **8.2 Auth Service Health** - Check auth service
- ✅ **8.3 User Service Health** - Check user service

---

## 🔧 Request Examples

### **Register với roleName**
```json
POST {{base_url}}/auth/register
Content-Type: application/json

{
  "roleName": "USER",
  "email": "newuser@example.com",
  "password": "password123",
  "fullName": "New User",
  "dateOfBirth": "1995-06-10",
  "address": "123 User Street, Ho Chi Minh City",
  "isStudying": true
}
```

### **Register với roleId**
```json
POST {{base_url}}/auth/register
Content-Type: application/json

{
  "roleId": 1,
  "email": "newuser2@example.com",
  "password": "password123",
  "fullName": "New User 2",
  "dateOfBirth": "1998-05-15",
  "address": "456 User Avenue, Hanoi",
  "isStudying": false
}
```

### **Login**
```json
POST {{base_url}}/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### **Error Response Example**
```json
{
  "type": "https://errors.abc.com/ROLE_NOT_FOUND",
  "title": "Role Not Found",
  "status": 404,
  "detail": "Role 'INVALID_ROLE' not found",
  "instance": "/auth/register",
  "errorCode": "ROLE_NOT_FOUND",
  "traceId": "c0bcf071-d2bb-41e0-9026-e8b61c07a5b4",
  "timestamp": "2025-10-10T05:34:56.242929427Z"
}
```

---

## ✅ Test Scripts

Mỗi request đều có test scripts để verify:

### **Success Response Tests**
```javascript
pm.test('Status code is 201', function () {
    pm.response.to.have.status(201);
});

pm.test('Response has access token', function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('accessToken');
    pm.expect(jsonData).to.have.property('tokenType', 'Bearer');
    pm.expect(jsonData).to.have.property('refreshToken');
    pm.expect(jsonData).to.have.property('expiresIn');
});

pm.test('Save tokens', function () {
    const jsonData = pm.response.json();
    pm.collectionVariables.set('access_token', jsonData.accessToken);
    pm.collectionVariables.set('refresh_token', jsonData.refreshToken);
});
```

### **Error Response Tests**
```javascript
pm.test('Status code is 404', function () {
    pm.response.to.have.status(404);
});

pm.test('RFC 7807 error format', function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('type');
    pm.expect(jsonData).to.have.property('title');
    pm.expect(jsonData).to.have.property('status');
    pm.expect(jsonData).to.have.property('detail');
    pm.expect(jsonData).to.have.property('instance');
    pm.expect(jsonData).to.have.property('errorCode');
    pm.expect(jsonData).to.have.property('traceId');
    pm.expect(jsonData).to.have.property('timestamp');
});

pm.test('Error code is ROLE_NOT_FOUND', function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData.errorCode).to.equal('ROLE_NOT_FOUND');
});
```

---

## 🎯 Testing Workflow

### **Step 1: Test Authentication**
1. Run **1.1 Register User (with roleName)**
2. Run **1.2 Register User (with roleId)**
3. Run **1.4 Login** (với existing user)
4. Verify tokens được save vào variables

### **Step 2: Test Error Scenarios**
1. Run **2.1 Register - Invalid Role Name**
2. Run **2.2 Register - Invalid Role ID**
3. Run **2.3 Register - Duplicate Email**
4. Run **2.4 Register - Validation Error**
5. Run **2.5 Login - Invalid Credentials**
6. Run **2.6 Get User - Not Found**

**Expected:** Tất cả đều return RFC 7807 error format

### **Step 3: Test Business Logic**
1. Run **3.1 Get User by ID** (với token)
2. Run **4.1 Get All Questions**
3. Run **5.1 Get All Exams**
4. Run **6.1 Get All Careers**
5. Run **7.1 Get All News**

### **Step 4: Test Health Checks**
1. Run **8.1 Gateway Health**
2. Run **8.2 Auth Service Health**
3. Run **8.3 User Service Health**

**Expected:** Tất cả return `{"status": "UP"}`

---

## 🔑 Test Credentials

| Email | Password | Role | Status |
|-------|----------|------|--------|
| admin@example.com | password123 | ADMIN | ACTIVE |
| recruiter@example.com | password123 | RECRUITER | ACTIVE |
| user@example.com | password123 | USER | ACTIVE |
| test@example.com | password123 | USER | PENDING |

---

## 📊 Collection Runner

### **Run All Tests**
1. Click **Collection Runner**
2. Select **Interview Microservice ABC - Complete v2**
3. Click **Start Test**
4. Xem results trong **Test Results** tab

### **Run Specific Folder**
1. Click **Collection Runner**
2. Select folder (ví dụ: "1. Authentication Flow")
3. Click **Start Test**

### **Run Individual Request**
1. Select request
2. Click **Send**
3. Xem **Test Results** tab

---

## 🐛 Troubleshooting

### **Error: "base_url not found"**
- Check collection variables
- Ensure `base_url` = `http://localhost:8222`

### **Error: "401 Unauthorized"**
- Run login request trước
- Check `access_token` variable được set

### **Error: "Connection refused"**
- Ensure services đang chạy: `docker-compose ps`
- Check Gateway port: `http://localhost:8222`

### **Error: "500 Internal Server Error"**
- Check service logs: `docker-compose logs auth-service`
- Rebuild services: `docker-compose build --no-cache`

---

## 📈 Performance Testing

### **Load Testing với Postman**
1. Tạo **Newman** script
2. Run multiple iterations
3. Monitor response times

### **Example Newman Command**
```bash
newman run INTERVIEW_APIS_COMPLETE_V2.postman_collection.json \
  --environment local \
  --iteration-count 10 \
  --delay-request 1000
```

---

## 🎉 Success Criteria

✅ **All authentication requests return 201/200**  
✅ **All error requests return proper RFC 7807 format**  
✅ **Tokens are automatically saved and reused**  
✅ **All test scripts pass**  
✅ **Health checks return "UP"**  
✅ **Business logic requests work with authentication**  

---

## 📞 Support

**Collection Issues:**
- Check `base_url` variable
- Verify services are running
- Check authentication flow

**Service Issues:**
- Read `SYSTEM-CHECK-COMPLETE.md`
- Check `REBUILD-AND-TEST.md`
- Verify `docker-compose ps`

**Error Format Issues:**
- Read `ERROR-CODES.md`
- Check `GLOBAL-EXCEPTION-HANDLING.md`

---

**Ready to test!** 🚀

Import `INTERVIEW_APIS_COMPLETE_V2.postman_collection.json` và bắt đầu testing!



