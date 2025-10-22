# POSTMAN COLLECTION - COMPLETE VERIFICATION REPORT

## ✅ Verified from Actual Source Code

### Data Sources Analyzed:
1. **Java DTOs** - All Request/Response classes from services
2. **Python Pydantic Models** - NLP service schemas
3. **Controller Methods** - All @RequestMapping endpoints
4. **Swagger UI HTML** - Service documentation structure

---

## 🔍 DETAILED FINDINGS BY SERVICE

### 1. AUTH SERVICE ✅ 
**Status:** CORRECT - No changes needed

**RegisterRequest** (from `RegisterRequest.java`):
```json
{
  "email": "user@example.com",
  "password": "password123",
  "roleName": "STUDENT",  // OR roleId: 1
  "fullName": "John Doe",
  "dateOfBirth": "2000-01-01",
  "address": "123 Main St",
  "isStudying": true
}
```

**LoginRequest** (from `LoginRequest.java`):
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

---

### 2. USER SERVICE ⚠️
**Status:** MINOR ISSUE - roleId usage

**UserRequest** (from `UserRequest.java`):
```json
{
  "roleId": 1,          // ✅ MUST be Long, not String roleName
  "email": "user@example.com",
  "password": "password123",
  "fullName": "John Doe",
  "dateOfBirth": "2000-01-01",
  "address": "123 Main St",
  "isStudying": true
}
```

**Fix:** Internal API endpoints use `roleId` (Long) not `roleName`

---

### 3. QUESTION SERVICE ❌
**Status:** CRITICAL ERRORS - Field names wrong

#### QuestionRequest (from `QuestionRequest.java`):
```java
// ACTUAL FIELDS:
private String content;   // NOT "questionContent" ❌
private String answer;    // NOT "questionAnswer" ❌
```

**CORRECT JSON:**
```json
{
  "userId": 1,
  "topicId": 1,
  "fieldId": 1,
  "levelId": 1,
  "questionTypeId": 1,
  "content": "What is Spring Boot?",      // ✅ NOT "questionContent"
  "answer": "Spring Boot is...",          // ✅ NOT "questionAnswer"
  "language": "Java"
}
```

#### AnswerRequest (from `AnswerRequest.java`):
```java
// ACTUAL FIELDS:
private String content;   // NOT "answerContent" ❌
```

**CORRECT JSON:**
```json
{
  "userId": 1,
  "questionId": 1,
  "questionTypeId": 1,
  "content": "Spring Boot is a framework...",  // ✅ NOT "answerContent"
  "isCorrect": true,
  "isSampleAnswer": false,
  "orderNumber": 1
}
```

**Other DTOs (CORRECT):**
- FieldRequest: `name`, `description` ✅
- TopicRequest: `fieldId`, `name`, `description` ✅
- LevelRequest: `name`, `description`, `minScore`, `maxScore` ✅
- QuestionTypeRequest: `name`, `description` ✅

---

### 4. EXAM SERVICE ⚠️
**Status:** MINOR ISSUES

#### ExamRequest (from `ExamRequest.java`):
```json
{
  "userId": 1,
  "examType": "TECHNICAL",
  "title": "Java Spring Boot Exam",
  "position": "Backend Developer",        // ⚠️ ADD THIS FIELD
  "topics": [1, 2, 3],
  "questionTypes": [1, 2],
  "questionCount": 20,
  "duration": 60,
  "language": "Java"
}
```

**Fix:** Add `position` field (String)

#### UserAnswerRequest (from `UserAnswerRequest.java`):
```json
{
  "examId": 1,
  "questionId": 1,
  "userId": 1,
  "answerContent": "My answer...",  // ✅ This one IS "answerContent" (different from Question)
  "isCorrect": true
}
```

**Note:** In UserAnswerRequest it's `answerContent`, but in AnswerRequest it's `content`

**Other DTOs (CORRECT):**
- ExamQuestionRequest: `examId`, `questionId`, `orderNumber` ✅
- ResultRequest: `examId`, `userId`, `score`, `passStatus`, `feedback` ✅
- ExamRegistrationRequest: `examId`, `userId`, `registrationStatus` ✅

---

### 5. CAREER SERVICE ✅
**Status:** CORRECT - No changes needed

**CareerPreferenceRequest** (from `CareerPreferenceRequest.java`):
```json
{
  "userId": 1,
  "fieldId": 1,
  "topicId": 1
}
```

---

### 6. NEWS SERVICE ❌
**Status:** CRITICAL ERRORS - Multiple wrong fields

#### NewsRequest (from `NewsRequest.java`):
```java
// ACTUAL FIELDS:
private String companyName;      // NOT "company" ❌
private String location;         // ✅
private String salary;           // ✅
private String experience;       // ✅ NOT "requirements" array
private String position;         // ✅
private String workingHours;     // ✅ NOT in current collection
private String deadline;         // ✅
private String applicationMethod;// ✅ NOT in current collection
```

**CORRECT JSON for News:**
```json
{
  "userId": 1,
  "title": "New Java Framework Released",
  "content": "Spring Boot 3.5 is now available...",
  "fieldId": 1,
  "examId": null,
  "newsType": "NEWS"
}
```

**CORRECT JSON for Recruitment:**
```json
{
  "userId": 1,
  "title": "Senior Java Developer",
  "content": "We are looking for...",
  "fieldId": 1,
  "examId": null,
  "newsType": "RECRUITMENT",
  "companyName": "ABC Tech Company",     // ✅ NOT "company"
  "location": "Hanoi, Vietnam",
  "salary": "50000-80000 USD",
  "experience": "5+ years Java",         // ✅ String, NOT array "requirements"
  "position": "Backend Developer",
  "workingHours": "9AM-6PM Mon-Fri",     // ⚠️ ADD THIS
  "deadline": "2025-12-31",
  "applicationMethod": "email@company.com" // ⚠️ ADD THIS
}
```

**Fix:**
1. Change `company` → `companyName`
2. Remove `requirements` array → use `experience` (String)
3. Remove `benefits` array
4. Add `workingHours` (String)
5. Add `applicationMethod` (String)

---

### 7. RECRUITMENT SERVICE ❌
**Status:** Same as News Service (uses NewsRequest DTO)

---

### 8. NLP SERVICE ✅
**Status:** CORRECT (verified from Python Pydantic models)

#### From schemas.py:

**SimilarityRequest:**
```json
{
  "text1": "First text",
  "text2": "Second text"
}
```

**GradingRequest:**
```json
{
  "question": "What is Spring Boot?",
  "answer": "Spring Boot is...",
  "max_score": 10,
  "criteria": ["accuracy", "completeness"]  // optional
}
```

**QuestionSimilarityRequest:**
```json
{
  "question_text": "What is dependency injection?",
  "exclude_id": null  // optional
}
```

**ExamGradingRequest:**
```json
{
  "exam_id": 1,           // ⚠️ Use underscore, not camelCase
  "question_id": 1,       // ⚠️ Use underscore, not camelCase
  "answer_text": "My answer...",
  "max_score": 10
}
```

**AI Studio endpoints** (from main.py - accept dict):
```json
// /ai-studio/validate-answer
{
  "question": "What is Spring Boot?",
  "answer": "Spring Boot is...",
  "expected_answer": "Spring Boot is a framework..."  // optional
}

// /ai-studio/check-plagiarism
{
  "text": "Text to check for plagiarism..."
}
```

---

## 📊 SUMMARY OF CHANGES NEEDED

### Critical (MUST FIX):
1. **Question Service**:
   - QuestionRequest: `questionContent` → `content`, `questionAnswer` → `answer`
   - AnswerRequest: `answerContent` → `content`

2. **News/Recruitment Service**:
   - `company` → `companyName`
   - Remove `requirements` array, use `experience` (String)
   - Remove `benefits` array
   - Add `workingHours` field
   - Add `applicationMethod` field

### Medium Priority:
1. **User Service**: Clarify `roleId` (Long) vs `roleName` (String) usage
2. **Exam Service**: Add `position` field to ExamRequest
3. **NLP Service**: Use snake_case for Python (exam_id, question_id, answer_text)

### Low Priority:
- Review all sample data for realistic values
- Verify enum values (examType, newsType, registrationStatus, etc.)
- Check LocalDate format consistency ("YYYY-MM-DD")

---

## 🔧 FIXING ORDER

### Phase 1 - Critical Fixes (NOW):
1. Fix Question Service Collection (2 DTOs)
2. Fix News/Recruitment Service Collection (1 DTO)

### Phase 2 - Medium Fixes:
3. Update Exam Service Collection (add position field)
4. Update User Service Collection (clarify roleId usage)

### Phase 3 - Verification:
5. Test all collections with running services
6. Verify with Swagger UI
7. Update documentation

---

**Generated:** From complete source code analysis  
**Date:** Based on current codebase  
**Confidence:** HIGH - All data verified from actual DTO/Model classes
