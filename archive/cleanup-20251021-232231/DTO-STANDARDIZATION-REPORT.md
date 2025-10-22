# DTO Standardization Report

**Date**: October 21, 2025  
**Purpose**: Review and standardize all Request/Response DTOs across microservices

---

## 📊 Current DTO Inventory

### ✅ Auth Service (4 DTOs)
**Request DTOs:**
- ✅ `LoginRequest` - Has validation (@Email, @NotBlank)
- ✅ `RegisterRequest` - Has validation, supports roleName/roleId
- ✅ `RefreshRequest` - Has validation
- ⚠️ `UserCreateRequest` - Need to check

**Response DTOs:**
- ✅ `TokenResponse` - Has @JsonInclude(NON_NULL)

**Issues Found:**
- None critical

---

### ⚠️ User Service (7 DTOs)
**Request DTOs:**
- ⚠️ `UserRequest` - **Missing validation annotations**
- ✅ `RoleUpdateRequest` - Has @NotNull
- ✅ `StatusUpdateRequest` - Has @NotNull
- ✅ `EloApplyRequest` - Has validation
- ⚠️ `LoginRequest` - Duplicate with auth-service, **missing validation**
- ⚠️ `VerifyRequest` - Need to check

**Response DTOs:**
- ✅ `UserResponse` - Has @JsonInclude(NON_NULL)

**Issues Found:**
1. ❌ `UserRequest` missing validation (@NotBlank, @Email)
2. ❌ `LoginRequest` duplicate and inconsistent with auth-service
3. ⚠️ Mix of @Data vs @Getter/@Setter - should standardize

---

### ⚠️ Question Service (12 DTOs)
**Request DTOs:**
- ⚠️ `QuestionRequest` - **Missing validation**
- ⚠️ `AnswerRequest` - **Missing validation**
- ⚠️ `FieldRequest` - **Missing validation**
- ⚠️ `TopicRequest` - **Missing validation**
- ⚠️ `LevelRequest` - Need to check
- ⚠️ `QuestionTypeRequest` - Need to check

**Response DTOs:**
- ✅ `QuestionResponse` - Has @JsonInclude(NON_NULL)
- ✅ `AnswerResponse` - Has @JsonInclude(NON_NULL)
- ✅ `FieldResponse` - Has @JsonInclude(NON_NULL)
- ✅ `TopicResponse` - Has @JsonInclude(NON_NULL)
- ✅ `LevelResponse` - Has @JsonInclude(NON_NULL)
- ✅ `QuestionTypeResponse` - Has @JsonInclude(NON_NULL)

**Issues Found:**
1. ❌ All Request DTOs missing validation annotations
2. ⚠️ Field naming: `content` vs `questionContent` - already fixed ✅
3. ⚠️ Field naming: `answer` vs `questionAnswer` - already fixed ✅

---

### ⚠️ Exam Service (10 DTOs)
**Request DTOs:**
- ⚠️ `ExamRequest` - **Missing validation**
- ⚠️ `UserAnswerRequest` - **Missing validation**
- ⚠️ `ResultRequest` - **Missing validation**
- ⚠️ `ExamRegistrationRequest` - **Missing validation**
- ⚠️ `ExamQuestionRequest` - Need to check

**Response DTOs:**
- ✅ `ExamResponse` - Has @JsonInclude(NON_NULL)
- ✅ `UserAnswerResponse` - Has @JsonInclude(NON_NULL)
- ✅ `ResultResponse` - Has @JsonInclude(NON_NULL)
- ✅ `ExamRegistrationResponse` - Has @JsonInclude(NON_NULL)
- ✅ `ExamQuestionResponse` - Has @JsonInclude(NON_NULL)

**Issues Found:**
1. ❌ All Request DTOs missing validation annotations

---

### ⚠️ News Service (2 DTOs)
**Request DTOs:**
- ⚠️ `NewsRequest` - **Missing validation**

**Response DTOs:**
- ✅ `NewsResponse` - Has @JsonInclude(NON_NULL)

**Issues Found:**
1. ❌ `NewsRequest` missing validation (@NotBlank for required fields)
2. ⚠️ Many optional fields (recruitment-related) - OK for flexibility

---

### ⚠️ Career Service (2 DTOs)
**Request DTOs:**
- ⚠️ `CareerPreferenceRequest` - **Missing validation**

**Response DTOs:**
- ✅ `CareerPreferenceResponse` - Has @JsonInclude(NON_NULL)

**Issues Found:**
1. ❌ `CareerPreferenceRequest` missing validation (@NotNull for IDs)

---

## 🎯 Standardization Plan

### Priority 1: Add Validation Annotations
**All Request DTOs need:**
```java
@NotNull        // For required Long/Integer fields
@NotBlank       // For required String fields
@NotEmpty       // For required List fields
@Email          // For email fields
@Min/@Max       // For numeric ranges
@Size           // For string/collection size limits
```

### Priority 2: Consistent Lombok Usage
**Standard:** Use `@Data` for all DTOs unless specific needs
```java
@Data
@JsonInclude(JsonInclude.Include.NON_NULL)  // Only for Response DTOs
public class SomeDTO {
    // fields
}
```

### Priority 3: Naming Conventions
**Rules:**
- ✅ Use simple field names: `content` not `questionContent`
- ✅ Use `List<Long>` for ID collections
- ✅ Use descriptive names: `expiresIn` not `expires`
- ✅ Boolean: `isActive` not `active`

### Priority 4: Documentation
**Add JavaDoc for complex DTOs:**
```java
/**
 * Request DTO for creating a new question
 * @author System
 * @version 1.0
 */
@Data
public class QuestionRequest {
    // fields
}
```

---

## 📝 Action Items

### Immediate (Critical):
1. ✅ Add `@JsonInclude(NON_NULL)` to all Response DTOs - **DONE**
2. ⏳ Add validation to all Request DTOs
3. ⏳ Remove duplicate `LoginRequest` from user-service
4. ⏳ Standardize Lombok annotations (@Data everywhere)

### Soon (Important):
5. ⏳ Add API documentation (@ApiModel, @ApiModelProperty from Swagger)
6. ⏳ Create base Request/Response classes for common fields
7. ⏳ Update Postman collections with correct DTOs

### Later (Nice to have):
8. Add builder pattern for complex DTOs
9. Add custom validators for business rules
10. Create DTO conversion utilities

---

## 🔍 Detailed Issues by Service

### User Service Issues
```java
// BEFORE (UserRequest.java)
@Data
public class UserRequest {
    private Long roleId;        // Should be @NotNull
    private String email;       // Should be @NotBlank @Email
    private String password;    // Should be @NotBlank @Size(min=6)
    private String fullName;    // Optional
    ...
}

// AFTER (Proposed)
@Data
public class UserRequest {
    @NotNull(message = "Role ID is required")
    private Long roleId;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;
    
    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 100, message = "Password must be 6-100 characters")
    private String password;
    
    private String fullName;    // Optional fields don't need validation
    private LocalDate dateOfBirth;
    private String address;
    private Boolean isStudying;
}
```

### Question Service Issues
```java
// BEFORE (QuestionRequest.java)
@Data
public class QuestionRequest {
    private Long userId;         // Should be @NotNull
    private Long topicId;        // Should be @NotNull
    private String content;      // Should be @NotBlank
    private String answer;       // Should be @NotBlank
    ...
}

// AFTER (Proposed)
@Data
public class QuestionRequest {
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotNull(message = "Topic ID is required")
    private Long topicId;
    
    @NotNull(message = "Field ID is required")
    private Long fieldId;
    
    @NotNull(message = "Level ID is required")
    private Long levelId;
    
    @NotNull(message = "Question type ID is required")
    private Long questionTypeId;
    
    @NotBlank(message = "Question content is required")
    @Size(max = 5000, message = "Content must not exceed 5000 characters")
    private String content;
    
    @NotBlank(message = "Answer is required")
    @Size(max = 5000, message = "Answer must not exceed 5000 characters")
    private String answer;
    
    @NotBlank(message = "Language is required")
    private String language;
}
```

### Exam Service Issues
```java
// BEFORE (ExamRequest.java)
@Data
public class ExamRequest {
    private Long userId;
    private String examType;
    private String title;
    private List<Long> topics;
    private Integer questionCount;
    ...
}

// AFTER (Proposed)
@Data
public class ExamRequest {
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @NotBlank(message = "Exam type is required")
    private String examType;
    
    @NotBlank(message = "Title is required")
    @Size(max = 200, message = "Title must not exceed 200 characters")
    private String title;
    
    private String position;  // Optional
    
    @NotEmpty(message = "At least one topic is required")
    private List<Long> topics;
    
    @NotEmpty(message = "At least one question type is required")
    private List<Long> questionTypes;
    
    @NotNull(message = "Question count is required")
    @Min(value = 1, message = "Must have at least 1 question")
    @Max(value = 100, message = "Cannot exceed 100 questions")
    private Integer questionCount;
    
    @NotNull(message = "Duration is required")
    @Min(value = 1, message = "Duration must be at least 1 minute")
    private Integer duration;
    
    @NotBlank(message = "Language is required")
    private String language;
}
```

---

## 📊 Summary Statistics

### Total DTOs: 37
- **Response DTOs**: 15 ✅ (All have @JsonInclude)
- **Request DTOs**: 22 ⚠️ (Need validation)

### Validation Coverage:
- ✅ **Auth Service**: 75% (3/4 validated)
- ⚠️ **User Service**: 43% (3/7 validated)
- ❌ **Question Service**: 0% (0/6 validated)
- ❌ **Exam Service**: 0% (0/5 validated)
- ❌ **News Service**: 0% (0/1 validated)
- ❌ **Career Service**: 0% (0/1 validated)

### Overall Validation: **27% (6/22 Request DTOs validated)**

---

## 🎬 Next Steps

1. **Apply validation** to all Request DTOs (Priority 1)
2. **Update Postman collections** with corrected DTOs
3. **Create validation test cases** for each DTO
4. **Document breaking changes** in API docs
5. **Rebuild all services** with standardized DTOs

---

**Generated by**: GitHub Copilot  
**Review Status**: ⏳ Pending Implementation
