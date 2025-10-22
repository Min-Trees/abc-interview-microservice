# ABC Interview Platform - Complete API Documentation

**Tổng số:** 100+ endpoints | **Services:** 7 | **Updated:** 2025-10-21

---

## 📋 TABLE OF CONTENTS
1. [Auth Service](#1-auth-service) - 5 endpoints
2. [User Service](#2-user-service) - 15 endpoints  
3. [Question Service](#3-question-service) - 43 endpoints
4. [Exam Service](#4-exam-service) - 26 endpoints
5. [News Service](#5-news-service) - 16 endpoints
6. [Recruitment Service](#6-recruitment-service) - 3 endpoints
7. [Career Service](#7-career-service) - 5 endpoints

---

## 1. AUTH SERVICE

**Base URL:** `http://localhost:8080/auth`  
**Total:** 5 endpoints

| # | Method | Endpoint | Auth | Description | Request Body Example |
|---|--------|----------|:----:|-------------|---------------------|
| 1 | POST | `/register` | ❌ | Register new account | `{"email":"user@ex.com","password":"pass123","fullName":"John"}` |
| 2 | POST | `/login` | ❌ | Login | `{"email":"admin@example.com","password":"admin123"}` |
| 3 | POST | `/refresh` | ❌ | Refresh token | `{"refreshToken":"xxx"}` |
| 4 | GET | `/verify?token=xxx` | ❌ | Verify token | - |
| 5 | GET | `/user-info` | ✅ | Get current user info | - |

---

## 2. USER SERVICE

**Base URL:** `http://localhost:8080/users`  
**Total:** 15 endpoints

### Public Endpoints
| # | Method | Endpoint | Auth | Description |
|---|--------|----------|:----:|-------------|
| 1 | GET | `/roles` | ❌ | Get all roles |
| 2 | GET | `/check-email/{email}` | ❌ | Check email exists |

### Internal Endpoints
| # | Method | Endpoint | Description | Request Body |
|---|--------|----------|-------------|--------------|
| 3 | POST | `/internal/create` | Create user (internal) | `{"email":"...","password":"...","fullName":"...","roleId":1}` |
| 4 | GET | `/by-email/{email}` | Get user by email | - |
| 5 | POST | `/validate-password` | Validate password | `{"email":"...","password":"..."}` |
| 6 | POST | `/verify-token` | Verify JWT | `{"token":"..."}` |

### Protected Endpoints (require auth)
| # | Method | Endpoint | Roles | Description | Request Body |
|---|--------|----------|-------|-------------|--------------|
| 7 | GET | `/{id}` | ALL | Get user by ID | - |
| 8 | PUT | `/{id}` | ADMIN | Update user | `{"fullName":"...","phone":"..."}` |
| 9 | DELETE | `/{id}` | ADMIN | Delete user | - |
| 10 | PUT | `/{id}/role` | ADMIN | Change role | `{"roleId":2}` |
| 11 | PUT | `/{id}/status` | ADMIN | Change status | `{"status":"ACTIVE"}` |
| 12 | POST | `/elo` | USER/ADMIN | Apply ELO rating | `{"userId":1,"eloChange":10}` |
| 13 | GET | `` | ADMIN | List all users (paginated) | - |
| 14 | GET | `/role/{roleId}` | ADMIN | List users by role | - |
| 15 | GET | `/status/{status}` | ADMIN | List users by status | - |

---

## 3. QUESTION SERVICE

**Base URL:** `http://localhost:8080/questions`  
**Total:** 43 endpoints

### A. Fields (5 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 1 | POST | `/fields` | ✅ | ADMIN | Create field | `{"name":"Mobile Dev","description":"..."}` |
| 2 | GET | `/fields` | ❌ | - | List fields (paginated) | - |
| 3 | GET | `/fields/{id}` | ❌ | - | Get field by ID | - |
| 4 | PUT | `/fields/{id}` | ✅ | ADMIN | Update field | `{"name":"...","description":"..."}` |
| 5 | DELETE | `/fields/{id}` | ✅ | ADMIN | Delete field | - |

### B. Topics (5 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 6 | POST | `/topics` | ✅ | ADMIN | Create topic | `{"name":"Flutter","description":"...","fieldId":1}` |
| 7 | GET | `/topics` | ❌ | - | List topics | - |
| 8 | GET | `/topics/{id}` | ❌ | - | Get topic by ID | - |
| 9 | PUT | `/topics/{id}` | ✅ | ADMIN | Update topic | `{"name":"...","description":"...","fieldId":1}` |
| 10 | DELETE | `/topics/{id}` | ✅ | ADMIN | Delete topic | - |

### C. Levels (5 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 11 | POST | `/levels` | ✅ | ADMIN | Create level | `{"name":"Expert","description":"..."}` |
| 12 | GET | `/levels` | ❌ | - | List levels | - |
| 13 | GET | `/levels/{id}` | ❌ | - | Get level by ID | - |
| 14 | PUT | `/levels/{id}` | ✅ | ADMIN | Update level | `{"name":"...","description":"..."}` |
| 15 | DELETE | `/levels/{id}` | ✅ | ADMIN | Delete level | - |

### D. Question Types (5 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 16 | POST | `/question-types` | ✅ | ADMIN | Create type | `{"name":"Coding","description":"..."}` |
| 17 | GET | `/question-types` | ❌ | - | List types | - |
| 18 | GET | `/question-types/{id}` | ❌ | - | Get type by ID | - |
| 19 | PUT | `/question-types/{id}` | ✅ | ADMIN | Update type | `{"name":"...","description":"..."}` |
| 20 | DELETE | `/question-types/{id}` | ✅ | ADMIN | Delete type | - |

### E. Questions (8 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 21 | POST | `` | ✅ | USER/ADMIN | Create question | `{"userId":1,"topicId":1,"fieldId":1,"levelId":1,"questionTypeId":1,"content":"Q?","answer":"A","language":"Vietnamese"}` |
| 22 | GET | `` | ❌ | - | List all questions | - |
| 23 | GET | `/{id}` | ❌ | - | Get question by ID | - |
| 24 | PUT | `/{id}` | ✅ | ADMIN | Update question | Same as #21 |
| 25 | DELETE | `/{id}` | ✅ | ADMIN | Delete question | - |
| 26 | POST | `/{id}/approve` | ✅ | ADMIN | Approve question | Query: `?adminId=1` |
| 27 | POST | `/{id}/reject` | ✅ | ADMIN | Reject question | Query: `?adminId=1` |
| 28 | GET | `/topics/{topicId}/questions` | ❌ | - | List by topic | - |

### F. Answers (7 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 29 | POST | `/answers` | ✅ | USER/ADMIN | Create answer | `{"questionId":1,"userId":1,"content":"...","language":"Vietnamese"}` |
| 30 | GET | `/answers` | ❌ | - | List all answers | - |
| 31 | GET | `/answers/{id}` | ❌ | - | Get answer by ID | - |
| 32 | PUT | `/answers/{id}` | ✅ | USER/ADMIN | Update answer | Same as #29 |
| 33 | DELETE | `/answers/{id}` | ✅ | ADMIN | Delete answer | - |
| 34 | POST | `/answers/{id}/sample` | ✅ | ADMIN | Mark as sample | Query: `?isSample=true` |
| 35 | GET | `/{questionId}/answers` | ❌ | - | List by question | - |

---

## 4. EXAM SERVICE

**Base URL:** `http://localhost:8080/exams`  
**Total:** 26 endpoints

### A. Exams (11 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 1 | POST | `` | ✅ | USER/ADMIN/RECRUITER | Create exam | `{"userId":1,"examType":"VIRTUAL","title":"...","position":"...","topics":[1,2],"questionTypes":[1],"questionCount":10,"duration":30,"language":"Vietnamese"}` |
| 2 | GET | `` | ❌ | - | List all exams | - |
| 3 | GET | `/{id}` | ❌ | - | Get exam by ID | - |
| 4 | PUT | `/{id}` | ✅ | ADMIN/RECRUITER | Update exam | Same as #1 |
| 5 | DELETE | `/{id}` | ✅ | ADMIN/RECRUITER | Delete exam | - |
| 6 | POST | `/{examId}/publish` | ✅ | ADMIN/RECRUITER | Publish exam | Query: `?userId=1` |
| 7 | POST | `/{examId}/start` | ✅ | USER/ADMIN | Start exam | - |
| 8 | POST | `/{examId}/complete` | ✅ | USER/ADMIN | Complete exam | - |
| 9 | GET | `/user/{userId}` | ✅ | USER/ADMIN | List by user | - |
| 10 | GET | `/type?type=VIRTUAL` | ❌ | - | List by type | - |
| 11 | GET | `/types` | ❌ | - | Get exam types | - |

### B. Exam Questions (2 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 12 | POST | `/questions` | ✅ | ADMIN/RECRUITER | Add question to exam | `{"examId":1,"questionId":2,"order":1}` |
| 13 | DELETE | `/{examId}/questions` | ✅ | ADMIN/RECRUITER | Remove all questions | - |

### C. Registrations (5 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 14 | POST | `/registrations` | ✅ | USER/ADMIN | Register for exam | `{"examId":1,"userId":1}` |
| 15 | GET | `/registrations/{id}` | ✅ | USER/ADMIN | Get registration | - |
| 16 | POST | `/registrations/{id}/cancel` | ✅ | USER/ADMIN | Cancel registration | - |
| 17 | GET | `/{examId}/registrations` | ✅ | ADMIN/RECRUITER | List by exam | - |
| 18 | GET | `/registrations/user/{userId}` | ✅ | USER/ADMIN | List by user | - |

### D. Results (4 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 19 | POST | `/results` | ✅ | USER/ADMIN | Submit result | `{"examId":1,"userId":1,"score":85,"totalQuestions":10,"correctAnswers":8}` |
| 20 | GET | `/results/{id}` | ✅ | USER/ADMIN | Get result | - |
| 21 | GET | `/{examId}/results` | ✅ | ADMIN/RECRUITER | List by exam | - |
| 22 | GET | `/results/user/{userId}` | ✅ | USER/ADMIN | List by user | - |

### E. Answers (4 endpoints)
| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 23 | POST | `/answers` | ✅ | USER/ADMIN | Submit answer | `{"examId":1,"questionId":2,"userId":1,"content":"..."}` |
| 24 | GET | `/answers/{id}` | ✅ | USER/ADMIN | Get answer | - |
| 25 | GET | `/{examId}/answers/{userId}` | ✅ | USER/ADMIN | List user answers | - |

---

## 5. NEWS SERVICE

**Base URL:** `http://localhost:8080/news`  
**Total:** 16 endpoints

| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 1 | POST | `` | ✅ | USER/ADMIN/RECRUITER | Create news | `{"userId":1,"title":"...","content":"...","fieldId":1,"newsType":"NEWS"}` |
| 2 | GET | `` | ❌ | - | List all news | - |
| 3 | GET | `/{id}` | ❌ | - | Get news by ID | - |
| 4 | PUT | `/{id}` | ✅ | USER/ADMIN/RECRUITER | Update news | Same as #1 |
| 5 | DELETE | `/{id}` | ✅ | ADMIN/RECRUITER | Delete news | - |
| 6 | POST | `/{newsId}/approve` | ✅ | ADMIN | Approve news | Query: `?adminId=1` |
| 7 | POST | `/{newsId}/reject` | ✅ | ADMIN | Reject news | Query: `?adminId=1` |
| 8 | POST | `/{newsId}/publish` | ✅ | ADMIN | Publish news | - |
| 9 | POST | `/{newsId}/vote` | ✅ | USER/ADMIN | Vote news | Query: `?voteType=UPVOTE` |
| 10 | GET | `/type?type=NEWS` | ❌ | - | List by type | - |
| 11 | GET | `/user/{userId}` | ✅ | USER/ADMIN/RECRUITER | List by user | - |
| 12 | GET | `/status/{status}` | ✅ | ADMIN | List by status | - |
| 13 | GET | `/field/{fieldId}` | ❌ | - | List by field | - |
| 14 | GET | `/published/{newsType}` | ❌ | - | List published | - |
| 15 | GET | `/moderation/pending` | ✅ | ADMIN | List pending moderation | - |
| 16 | GET | `/types` | ❌ | - | Get news types | - |

---

## 6. RECRUITMENT SERVICE

**Base URL:** `http://localhost:8080/recruitments`  
**Total:** 3 endpoints

| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 1 | POST | `` | ✅ | RECRUITER/ADMIN | Create recruitment | `{"userId":1,"title":"Job","content":"...","fieldId":1,"newsType":"RECRUITMENT","companyName":"ABC","location":"HN","salary":"1000","experience":"2y","position":"Dev"}` |
| 2 | GET | `` | ❌ | - | List recruitments | - |
| 3 | GET | `/company/{name}` | ❌ | - | List by company | - |

---

## 7. CAREER SERVICE

**Base URL:** `http://localhost:8080/career`  
**Total:** 5 endpoints

| # | Method | Endpoint | Auth | Roles | Description | Request Body |
|---|--------|----------|:----:|-------|-------------|--------------|
| 1 | POST | `` | ✅ | USER/ADMIN | Create preference | `{"userId":1,"fieldId":1,"levelId":2,"desiredPosition":"Dev","desiredSalary":"1500","desiredLocation":"HN"}` |
| 2 | GET | `/{careerId}` | ✅ | USER/ADMIN | Get by ID | - |
| 3 | PUT | `/update/{careerId}` | ✅ | USER/ADMIN | Update preference | Same as #1 |
| 4 | DELETE | `/{careerId}` | ✅ | USER/ADMIN | Delete preference | - |
| 5 | GET | `/preferences/{userId}` | ✅ | USER/ADMIN | List by user | - |

---

## 📊 SUMMARY

| Service | Public | Protected | Total |
|---------|:------:|:---------:|:-----:|
| Auth | 4 | 1 | 5 |
| User | 2 | 13 | 15 |
| Question | 20 | 23 | 43 |
| Exam | 3 | 23 | 26 |
| News | 7 | 9 | 16 |
| Recruitment | 2 | 1 | 3 |
| Career | 0 | 5 | 5 |
| **TOTAL** | **38** | **75** | **113** |

---

## 🔑 AUTHENTICATION

All protected endpoints (✅) require Bearer token in header:
```
Authorization: Bearer <token>
```

Get token via `/auth/login`:
```json
POST /auth/login
{
  "email": "admin@example.com",
  "password": "admin123"
}
```

---

## ⚠️ KNOWN ISSUES

1. **Auth Service - `/user-info`**: Returns 403 because user-service blocks internal calls
2. **Question/Exam POST**: Requires complete DTO with all required fields (see Request Body examples)
3. **Pagination**: Default is page=0, size=10. Use query params: `?page=0&size=20`

---

## 📝 NOTES

- **VIRTUAL** vs **RECRUITER**: Exam types for self-practice vs recruitment
- **NEWS** vs **RECRUITMENT**: News types for articles vs job postings
- **ELO Rating**: Applied after completing exams to track user skill level
- **Sample Answers**: Marked answers used as reference for grading

