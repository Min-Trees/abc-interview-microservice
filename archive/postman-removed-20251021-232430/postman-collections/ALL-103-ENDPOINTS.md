# DANH SÁCH TẤT CẢ 103 ENDPOINTS - ABC Interview Platform

## 🎯 Tổng quan
- **Tổng số endpoints**: 103
- **Số services**: 8 (Auth, User, Question, Exam, Career, News, Recruitment, NLP)

---

## 1. AUTH SERVICE (5 endpoints)

| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 1 | POST | `/auth/register` | No | - | Đăng ký tài khoản mới |
| 2 | POST | `/auth/login` | No | - | Đăng nhập và lấy JWT token |
| 3 | POST | `/auth/refresh` | No | - | Làm mới access token |
| 4 | GET | `/auth/verify?token=` | No | - | Xác thực token |
| 5 | GET | `/auth/user-info` | Yes | USER | Lấy thông tin user từ token |

---

## 2. USER SERVICE (16 endpoints)

### Internal Endpoints (5)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 6 | POST | `/users/internal/create` | Yes | - | Tạo user (gọi bởi Auth Service) |
| 7 | GET | `/users/check-email/{email}` | Yes | - | Kiểm tra email tồn tại |
| 8 | GET | `/users/by-email/{email}` | Yes | - | Lấy user theo email |
| 9 | POST | `/users/validate-password` | Yes | - | Validate password |
| 10 | POST | `/users/verify-token` | Yes | - | Verify JWT token |

### User CRUD (6)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 11 | GET | `/users/{id}` | Yes | USER | Lấy user theo ID |
| 12 | PUT | `/users/{id}` | Yes | USER | Cập nhật user |
| 13 | DELETE | `/users/{id}` | Yes | ADMIN | Xóa user |
| 14 | GET | `/users?page=0&size=20` | Yes | ADMIN | Lấy tất cả users (paginated) |
| 15 | GET | `/users/role/{roleId}` | Yes | ADMIN | Lấy users theo role |
| 16 | GET | `/users/status/{status}` | Yes | ADMIN | Lấy users theo status |

### Admin Endpoints (3)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 17 | PUT | `/users/{id}/role` | Yes | ADMIN | Cập nhật role của user |
| 18 | PUT | `/users/{id}/status` | Yes | ADMIN | Cập nhật status của user |
| 19 | POST | `/users/elo` | Yes | USER | Apply Elo rating |

---

## 3. QUESTION SERVICE (26 endpoints)

### Fields (5)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 20 | GET | `/questions/fields` | No | - | Lấy tất cả fields |
| 21 | GET | `/questions/fields/{id}` | No | - | Lấy field theo ID |
| 22 | POST | `/questions/fields` | Yes | ADMIN | Tạo field mới |
| 23 | PUT | `/questions/fields/{id}` | Yes | ADMIN | Cập nhật field |
| 24 | DELETE | `/questions/fields/{id}` | Yes | ADMIN | Xóa field |

### Topics (5)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 25 | GET | `/questions/topics` | No | - | Lấy tất cả topics (với fieldName) |
| 26 | GET | `/questions/topics/{id}` | No | - | Lấy topic theo ID |
| 27 | POST | `/questions/topics` | Yes | ADMIN | Tạo topic mới |
| 28 | PUT | `/questions/topics/{id}` | Yes | ADMIN | Cập nhật topic |
| 29 | DELETE | `/questions/topics/{id}` | Yes | ADMIN | Xóa topic |

### Levels (5)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 30 | GET | `/questions/levels` | No | - | Lấy tất cả difficulty levels |
| 31 | GET | `/questions/levels/{id}` | No | - | Lấy level theo ID |
| 32 | POST | `/questions/levels` | Yes | ADMIN | Tạo level mới |
| 33 | PUT | `/questions/levels/{id}` | Yes | ADMIN | Cập nhật level |
| 34 | DELETE | `/questions/levels/{id}` | Yes | ADMIN | Xóa level |

### Question Types (5)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 35 | GET | `/questions/question-types` | No | - | Lấy tất cả question types |
| 36 | GET | `/questions/question-types/{id}` | No | - | Lấy question type theo ID |
| 37 | POST | `/questions/question-types` | Yes | ADMIN | Tạo question type mới |
| 38 | PUT | `/questions/question-types/{id}` | Yes | ADMIN | Cập nhật question type |
| 39 | DELETE | `/questions/question-types/{id}` | Yes | ADMIN | Xóa question type |

### Questions (5)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 40 | GET | `/questions?page=0&size=10` | No | - | Lấy tất cả questions (paginated) |
| 41 | GET | `/questions/{id}` | No | - | Lấy question theo ID |
| 42 | POST | `/questions` | Yes | ADMIN | Tạo question mới |
| 43 | PUT | `/questions/{id}` | Yes | ADMIN | Cập nhật question |
| 44 | DELETE | `/questions/{id}` | Yes | ADMIN | Xóa question |

### Answers (4)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 45 | GET | `/questions/{questionId}/answers` | No | - | Lấy tất cả answers của question |
| 46 | POST | `/questions/{questionId}/answers` | Yes | ADMIN | Tạo answer mới |
| 47 | PUT | `/questions/{questionId}/answers/{answerId}` | Yes | ADMIN | Cập nhật answer |
| 48 | DELETE | `/questions/{questionId}/answers/{answerId}` | Yes | ADMIN | Xóa answer |

---

## 4. EXAM SERVICE (21 endpoints)

### Exam CRUD (5)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 49 | POST | `/exams` | Yes | USER/ADMIN/RECRUITER | Tạo exam mới |
| 50 | GET | `/exams?page=0&size=20` | Yes | USER | Lấy tất cả exams (paginated) |
| 51 | GET | `/exams/{id}` | Yes | USER | Lấy exam theo ID |
| 52 | PUT | `/exams/{id}` | Yes | ADMIN/RECRUITER | Cập nhật exam |
| 53 | DELETE | `/exams/{id}` | Yes | ADMIN/RECRUITER | Xóa exam |

### Exam Lifecycle (3)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 54 | POST | `/exams/{examId}/publish?userId=` | Yes | ADMIN/RECRUITER | Publish exam |
| 55 | POST | `/exams/{examId}/start` | Yes | USER/ADMIN | Bắt đầu làm exam |
| 56 | POST | `/exams/{examId}/complete` | Yes | USER/ADMIN | Hoàn thành exam |

### Exam Queries (2)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 57 | GET | `/exams/user/{userId}?page=0&size=20` | Yes | USER/ADMIN | Lấy exams của user |
| 58 | GET | `/exams/type/{examType}?page=0&size=20` | Yes | USER | Lấy exams theo type |

### Exam Questions (2)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 59 | POST | `/exams/questions` | Yes | ADMIN/RECRUITER | Thêm câu hỏi vào exam |
| 60 | DELETE | `/exams/{examId}/questions` | Yes | ADMIN/RECRUITER | Xóa câu hỏi khỏi exam |

### Results & Answers (5)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 61 | POST | `/exams/results` | Yes | USER/ADMIN | Submit kết quả exam |
| 62 | GET | `/exams/{examId}/results?page=0&size=20` | Yes | ADMIN/RECRUITER | Lấy results của exam |
| 63 | GET | `/exams/results/user/{userId}?page=0&size=20` | Yes | USER/ADMIN | Lấy results của user |
| 64 | GET | `/exams/results/{id}` | Yes | USER/ADMIN | Lấy result theo ID |
| 65 | POST | `/exams/answers` | Yes | USER/ADMIN | Submit answer |
| 66 | GET | `/exams/{examId}/answers/{userId}?page=0&size=20` | Yes | USER/ADMIN | Lấy answers của user trong exam |
| 67 | GET | `/exams/answers/{id}` | Yes | USER/ADMIN | Lấy answer theo ID |

### Registrations (4)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 68 | POST | `/exams/registrations` | Yes | USER/ADMIN | Đăng ký làm exam |
| 69 | POST | `/exams/registrations/{registrationId}/cancel` | Yes | USER/ADMIN | Hủy đăng ký exam |
| 70 | GET | `/exams/{examId}/registrations?page=0&size=20` | Yes | ADMIN/RECRUITER | Lấy registrations của exam |
| 71 | GET | `/exams/registrations/user/{userId}?page=0&size=20` | Yes | USER/ADMIN | Lấy registrations của user |

---

## 5. CAREER SERVICE (5 endpoints)

| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 72 | POST | `/career` | Yes | USER/ADMIN | Tạo career preference |
| 73 | GET | `/career/{careerId}` | Yes | USER/ADMIN | Lấy career theo ID |
| 74 | PUT | `/career/update/{careerId}` | Yes | USER/ADMIN | Cập nhật career |
| 75 | GET | `/career/preferences/{userId}?page=0&size=20` | Yes | USER/ADMIN | Lấy careers của user (paginated) |
| 76 | DELETE | `/career/{careerId}` | Yes | USER/ADMIN | Xóa career |

---

## 6. NEWS SERVICE (17 endpoints)

### News CRUD (5)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 77 | POST | `/news` | Yes | USER/ADMIN/RECRUITER | Tạo news mới |
| 78 | GET | `/news?page=0&size=20` | No | - | Lấy tất cả news (paginated) |
| 79 | GET | `/news/{id}` | No | - | Lấy news theo ID |
| 80 | PUT | `/news/{id}` | Yes | USER/ADMIN/RECRUITER | Cập nhật news |
| 81 | DELETE | `/news/{id}` | Yes | ADMIN/RECRUITER | Xóa news |

### News Moderation (4)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 82 | POST | `/news/{newsId}/approve?adminId=` | Yes | ADMIN | Approve news |
| 83 | POST | `/news/{newsId}/reject?adminId=` | Yes | ADMIN | Reject news |
| 84 | POST | `/news/{newsId}/publish` | Yes | ADMIN | Publish news |
| 85 | GET | `/news/moderation/pending?page=0&size=20` | Yes | ADMIN | Lấy news chờ duyệt |

### News Queries (7)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 86 | GET | `/news/type/{newsType}?page=0&size=20` | No | - | Lấy news theo type |
| 87 | GET | `/news/user/{userId}?page=0&size=20` | Yes | USER/ADMIN/RECRUITER | Lấy news của user |
| 88 | GET | `/news/status/{status}?page=0&size=20` | Yes | ADMIN | Lấy news theo status |
| 89 | GET | `/news/field/{fieldId}?page=0&size=20` | No | - | Lấy news theo field |
| 90 | GET | `/news/published/{newsType}?page=0&size=20` | No | - | Lấy published news theo type |
| 91 | POST | `/news/{newsId}/vote?voteType=` | Yes | USER/ADMIN | Vote news (UP/DOWN) |

---

## 7. RECRUITMENT SERVICE (2 endpoints)

| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 92 | POST | `/recruitments` | Yes | RECRUITER/ADMIN | Tạo recruitment (news type RECRUITMENT) |
| 93 | GET | `/recruitments?page=0&size=20` | No | - | Lấy tất cả recruitments (paginated) |

---

## 8. NLP SERVICE - Python FastAPI (11 endpoints)

### Health Check (1)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 94 | GET | `/health` | No | - | Health check |

### Text Similarity (1)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 95 | POST | `/similarity/check` | Yes | USER | Kiểm tra độ tương đồng 2 texts |

### Essay Grading (1)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 96 | POST | `/grading/essay` | Yes | USER | Chấm điểm bài essay |

### Question Analysis (2)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 97 | POST | `/questions/similarity/check` | Yes | ADMIN | Kiểm tra câu hỏi trùng lặp |
| 98 | GET | `/questions/{question_id}/analytics` | Yes | ADMIN | Lấy analytics của câu hỏi |

### Exam Grading (2)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 99 | POST | `/exams/{exam_id}/questions/{question_id}/grade` | Yes | ADMIN | Chấm điểm 1 câu trong exam |
| 100 | POST | `/exams/{exam_id}/grade-all` | Yes | ADMIN | Chấm tất cả câu tự luận trong exam |

### AI Studio Integration (4)
| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 101 | POST | `/ai-studio/validate-answer` | Yes | USER | Validate câu trả lời với AI Studio |
| 102 | POST | `/ai-studio/check-plagiarism` | Yes | USER | Kiểm tra đạo văn |

---

## ✅ Tổng kết

### Phân loại theo Authentication:
- **Public (không cần auth)**: 16 endpoints
- **Authenticated**: 87 endpoints

### Phân loại theo Role:
- **PUBLIC**: 16 endpoints (GET only)
- **USER**: 45 endpoints
- **ADMIN**: 35 endpoints
- **RECRUITER**: 7 endpoints

### Phân loại theo Method:
- **GET**: 52 endpoints (50.5%)
- **POST**: 34 endpoints (33%)
- **PUT**: 11 endpoints (10.7%)
- **DELETE**: 6 endpoints (5.8%)

### Phân loại theo Service:
1. **Exam Service**: 21 endpoints (20.4%)
2. **Question Service**: 26 endpoints (25.2%)
3. **News Service**: 17 endpoints (16.5%)
4. **User Service**: 16 endpoints (15.5%)
5. **NLP Service**: 11 endpoints (10.7%)
6. **Auth Service**: 5 endpoints (4.9%)
7. **Career Service**: 5 endpoints (4.9%)
8. **Recruitment Service**: 2 endpoints (1.9%)

---

**📝 Ghi chú:**
- Tất cả endpoints qua API Gateway: `http://localhost:8080`
- Direct service URLs: 8081 (Auth), 8082 (User), 8085 (Question), 8086 (Exam), 8087 (Career), 8088 (News), 5000 (NLP)
- Pagination format: `?page=0&size=20&sort=id,desc`
- Auth header: `Authorization: Bearer {{access_token}}`
