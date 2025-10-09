# Postman Collections for Interview Microservice ABC

This directory contains comprehensive Postman collections for testing all APIs in the Interview Microservice ABC platform.

## Collection Overview

The main collection `Interview-Microservice-ABC.postman_collection.json` is organized by microservice:

- **Auth Service** - Authentication and user management
- **User Service** - User profiles, ELO scores, and user operations
- **Question Service** - Question management, answers, and taxonomy
- **Exam Service** - Exam creation, management, and results
- **Career Service** - Career preferences and user interests
- **News Service** - News articles and recruitment posts
- **NLP Service** - Natural language processing features

## Setup Instructions

### 1. Import Collection

1. Open Postman
2. Click "Import" button
3. Select `Interview-Microservice-ABC.postman_collection.json`
4. The collection will be imported with all folders and requests

### 2. Configure Environment Variables

The collection uses the following variables that you can set in Postman:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `baseUrl` | `http://localhost:8080` | API Gateway base URL |
| `userId` | `1` | Sample user ID for testing |
| `adminId` | `1` | Admin user ID for testing |
| `questionId` | `1` | Sample question ID |
| `answerId` | `1` | Sample answer ID |
| `examId` | `1` | Sample exam ID |
| `resultId` | `1` | Sample result ID |
| `registrationId` | `1` | Sample registration ID |
| `careerId` | `1` | Sample career preference ID |
| `newsId` | `1` | Sample news ID |
| `topicId` | `1` | Sample topic ID |
| `fieldId` | `1` | Sample field ID |
| `newsType` | `NEWS` | News type filter |
| `examType` | `TECHNICAL` | Exam type filter |
| `status` | `PENDING` | Status filter |
| `companyName` | `ABC Tech` | Company name for recruitment |
| `token` | `` | JWT token for authentication |
| `userToken` | `` | User JWT token |
| `adminToken` | `` | Admin JWT token |
| `recruiterToken` | `` | Recruiter JWT token |

### 3. Authentication Setup

Before testing most endpoints, you need to obtain authentication tokens:

1. **Get User Token**:
   - Use `Auth Service > Login` or `User Service > Login User`
   - Copy the token from response to `userToken` variable

2. **Get Admin Token**:
   - Login with admin credentials (admin@example.com / password123)
   - Copy the token to `adminToken` variable

3. **Get Recruiter Token**:
   - Login with recruiter credentials (recruiter@example.com / password123)
   - Copy the token to `recruiterToken` variable

## API Endpoints Overview

### Auth Service (`/auth/**`)
- `POST /auth/register` - Register new user
- `POST /auth/login` - User login
- `POST /auth/refresh` - Refresh JWT token
- `GET /auth/verify` - Verify JWT token
- `GET /auth/users/{id}` - Get user by ID

### User Service (`/users/**`)
- `POST /users/register` - Register user with profile
- `GET /users/{id}` - Get user by ID
- `POST /users/login` - User login
- `GET /users/verify` - Verify user email
- `PUT /users/{id}/role` - Update user role (Admin only)
- `PUT /users/{id}/status` - Update user status (Admin only)
- `POST /users/elo` - Apply ELO score changes

### Question Service (`/questions/**`, `/answers/**`, etc.)
- **Taxonomy Management**:
  - `POST /fields` - Create field (Admin only)
  - `POST /topics` - Create topic (Admin only)
  - `POST /levels` - Create level (Admin only)
  - `POST /question-types` - Create question type (Admin only)

- **Question Management**:
  - `POST /questions` - Create question
  - `GET /questions/{id}` - Get question by ID
  - `PUT /questions/{id}` - Update question
  - `DELETE /questions/{id}` - Delete question (Admin only)
  - `POST /questions/{id}/approve` - Approve question (Admin only)
  - `POST /questions/{id}/reject` - Reject question (Admin only)
  - `GET /topics/{topicId}/questions` - List questions by topic

- **Answer Management**:
  - `POST /answers` - Create answer
  - `GET /answers/{id}` - Get answer by ID
  - `PUT /answers/{id}` - Update answer
  - `DELETE /answers/{id}` - Delete answer (Admin only)
  - `POST /answers/{id}/sample` - Mark as sample answer (Admin only)
  - `GET /questions/{questionId}/answers` - List answers by question

### Exam Service (`/exams/**`)
- **Exam Management**:
  - `POST /exams` - Create exam
  - `GET /exams/{id}` - Get exam by ID
  - `PUT /exams/{id}` - Update exam
  - `DELETE /exams/{id}` - Delete exam
  - `POST /exams/{id}/publish` - Publish exam
  - `POST /exams/{id}/start` - Start exam
  - `POST /exams/{id}/complete` - Complete exam
  - `GET /exams/user/{userId}` - List exams by user
  - `GET /exams/type/{examType}` - List exams by type

- **Exam Questions**:
  - `POST /exams/questions` - Add question to exam
  - `DELETE /exams/{examId}/questions` - Remove questions from exam

- **Results & Answers**:
  - `POST /exams/results` - Submit exam result
  - `GET /exams/results/{id}` - Get result by ID
  - `GET /exams/{examId}/results` - List results by exam
  - `GET /exams/results/user/{userId}` - List results by user
  - `POST /exams/answers` - Submit user answer
  - `GET /exams/answers/{id}` - Get user answer by ID
  - `GET /exams/{examId}/answers/{userId}` - Get user answers by exam

- **Registration**:
  - `POST /exams/registrations` - Register for exam
  - `POST /exams/registrations/{id}/cancel` - Cancel registration
  - `GET /exams/registrations/{id}` - Get registration by ID
  - `GET /exams/{examId}/registrations` - List registrations by exam
  - `GET /exams/registrations/user/{userId}` - List registrations by user

### Career Service (`/career/**`)
- `POST /career` - Create career preference
- `PUT /career/update/{careerId}` - Update career preference
- `GET /career/{careerId}` - Get career by ID
- `GET /career/preferences/{userId}` - Get career preferences by user
- `DELETE /career/{careerId}` - Delete career preference

### News Service (`/news/**`, `/recruitments/**`)
- **News Management**:
  - `POST /news` - Create news article
  - `GET /news/{id}` - Get news by ID
  - `PUT /news/{id}` - Update news
  - `DELETE /news/{id}` - Delete news
  - `POST /news/{id}/approve` - Approve news (Admin only)
  - `POST /news/{id}/reject` - Reject news (Admin only)
  - `POST /news/{id}/publish` - Publish news (Admin only)
  - `POST /news/{id}/vote` - Vote on news
  - `GET /news/type/{newsType}` - List news by type
  - `GET /news/user/{userId}` - List news by user
  - `GET /news/status/{status}` - List news by status (Admin only)
  - `GET /news/field/{fieldId}` - List news by field
  - `GET /news/published/{newsType}` - List published news
  - `GET /news/moderation/pending` - List pending moderation (Admin only)

- **Recruitment Management**:
  - `POST /recruitments` - Create recruitment post
  - `GET /recruitments` - List recruitments
  - `GET /recruitments/company/{companyName}` - List recruitments by company

### NLP Service (`/health`, `/grading/**`, `/similarity/**`)
- `GET /health` - Service health check
- `POST /similarity/check` - Check text similarity
- `POST /questions/similarity/check` - Check question similarity
- `POST /grading/essay` - Grade essay answer
- `POST /exams/{examId}/questions/{questionId}/grade` - Grade exam answer
- `POST /exams/{examId}/grade-all` - Grade all exam questions
- `GET /questions/{questionId}/analytics` - Get question analytics

## Testing Workflow

### 1. Basic Setup
1. Start all microservices
2. Import sample data using database import scripts
3. Import Postman collection
4. Configure environment variables

### 2. Authentication Flow
1. Register a new user or use existing test users
2. Login to get JWT tokens
3. Set tokens in environment variables

### 3. Typical Test Scenarios

#### User Registration and Login
1. `Auth Service > Register` - Create new user
2. `Auth Service > Login` - Get authentication token
3. `User Service > Get User by ID` - Verify user data

#### Question Management
1. `Question Service > Taxonomy Management > Create Field` - Create field (Admin)
2. `Question Service > Taxonomy Management > Create Topic` - Create topic (Admin)
3. `Question Service > Question Management > Create Question` - Create question
4. `Question Service > Question Management > Approve Question` - Approve question (Admin)

#### Exam Flow
1. `Exam Service > Exam Management > Create Exam` - Create exam
2. `Exam Service > Exam Questions > Add Question to Exam` - Add questions
3. `Exam Service > Exam Management > Publish Exam` - Publish exam
4. `Exam Service > Exam Registration > Register for Exam` - Register user
5. `Exam Service > Exam Management > Start Exam` - Start exam
6. `Exam Service > User Answers > Submit Answer` - Submit answers
7. `Exam Service > Exam Management > Complete Exam` - Complete exam
8. `Exam Service > Exam Results > Submit Result` - Submit results

#### News and Recruitment
1. `News Service > News Management > Create News` - Create news article
2. `News Service > News Management > Approve News` - Approve news (Admin)
3. `News Service > Recruitment Management > Create Recruitment` - Create job posting

## Sample Data

The collection is designed to work with the sample data provided in the `database-import` directory. Key test users:

- **Admin**: admin@example.com / password123
- **Recruiter**: recruiter@example.com / password123  
- **User**: user@example.com / password123
- **Test User**: test@example.com / password123

## Error Handling

Common HTTP status codes you might encounter:

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource already exists
- `500 Internal Server Error` - Server error

## Tips for Testing

1. **Use Environment Variables**: Set up different environments for different testing scenarios
2. **Test Authentication**: Always test with proper authentication tokens
3. **Check Dependencies**: Some endpoints require existing data (e.g., questions need topics)
4. **Test Error Cases**: Try invalid data to test error handling
5. **Use Collections**: Run entire folders to test complete workflows
6. **Monitor Logs**: Check microservice logs for detailed error information

## Troubleshooting

### Common Issues

1. **401 Unauthorized**: Check if JWT token is valid and not expired
2. **403 Forbidden**: Ensure user has required role (Admin, Recruiter, etc.)
3. **404 Not Found**: Verify the resource ID exists in the database
4. **500 Internal Server Error**: Check microservice logs for detailed error information

### Debug Steps

1. Verify all microservices are running
2. Check database connections
3. Verify sample data is imported
4. Check JWT token validity
5. Review microservice logs

## Support

For issues or questions:
1. Check the microservice logs
2. Verify database data
3. Test with sample data first
4. Check API Gateway routing configuration
