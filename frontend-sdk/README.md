# 🚀 Frontend SDK - Interview Microservice System

Bộ công cụ hoàn chỉnh để tích hợp nhanh API backend vào frontend.

## 📁 Cấu trúc thư mục

```
frontend-sdk/
├── api-client.js          # JavaScript/TypeScript client
├── react-hooks.js         # React hooks
├── vue-composables.js     # Vue 3 composition API
├── axios-config.js        # Axios configuration
├── Postman-Environment.json # Postman environment
└── README.md              # Hướng dẫn sử dụng
```

## 🎯 Các framework được hỗ trợ

- ✅ **Vanilla JavaScript/TypeScript**
- ✅ **React** (Hooks)
- ✅ **Vue.js 3** (Composition API)
- ✅ **Axios** (HTTP client)
- ✅ **Postman** (Testing)

## 🚀 Quick Start

### 1. Vanilla JavaScript/TypeScript

```javascript
import { InterviewAPIClient } from './api-client.js';

// Khởi tạo client
const api = new InterviewAPIClient('http://localhost:8080');

// Đăng nhập
const loginResponse = await api.login('user@example.com', '123456');
console.log('Login successful:', loginResponse);

// Tạo câu hỏi
const question = await api.createQuestion({
    userId: 1,
    topicId: 1,
    fieldId: 1,
    levelId: 1,
    questionTypeId: 1,
    content: "What is JavaScript?",
    answer: "JavaScript is a programming language",
    language: "en"
});
console.log('Question created:', question);
```

### 2. React

```jsx
import React from 'react';
import { useAuth, useQuestions } from './react-hooks.js';

function App() {
    const { user, login, logout } = useAuth();
    const { questions, createQuestion } = useQuestions();

    const handleLogin = async () => {
        try {
            await login('user@example.com', '123456');
        } catch (error) {
            console.error('Login failed:', error);
        }
    };

    const handleCreateQuestion = async () => {
        try {
            await createQuestion({
                userId: 1,
                topicId: 1,
                fieldId: 1,
                levelId: 1,
                questionTypeId: 1,
                content: "What is React?",
                answer: "React is a JavaScript library",
                language: "en"
            });
        } catch (error) {
            console.error('Failed to create question:', error);
        }
    };

    return (
        <div>
            {user ? (
                <div>
                    <h1>Welcome, {user.email}!</h1>
                    <button onClick={logout}>Logout</button>
                    <button onClick={handleCreateQuestion}>Create Question</button>
                    <ul>
                        {questions.map(question => (
                            <li key={question.id}>
                                <h3>{question.questionContent}</h3>
                                <p>{question.questionAnswer}</p>
                            </li>
                        ))}
                    </ul>
                </div>
            ) : (
                <button onClick={handleLogin}>Login</button>
            )}
        </div>
    );
}

export default App;
```

### 3. Vue.js 3

```vue
<template>
    <div>
        <div v-if="user">
            <h1>Welcome, {{ user.email }}!</h1>
            <button @click="logout">Logout</button>
            <button @click="handleCreateQuestion">Create Question</button>
            <ul>
                <li v-for="question in questions" :key="question.id">
                    <h3>{{ question.questionContent }}</h3>
                    <p>{{ question.questionAnswer }}</p>
                </li>
            </ul>
        </div>
        <div v-else>
            <button @click="handleLogin">Login</button>
        </div>
    </div>
</template>

<script setup>
import { useAuth, useQuestions } from './vue-composables.js';

const { user, login, logout } = useAuth();
const { questions, createQuestion } = useQuestions();

const handleLogin = async () => {
    try {
        await login('user@example.com', '123456');
    } catch (error) {
        console.error('Login failed:', error);
    }
};

const handleCreateQuestion = async () => {
    try {
        await createQuestion({
            userId: 1,
            topicId: 1,
            fieldId: 1,
            levelId: 1,
            questionTypeId: 1,
            content: "What is Vue.js?",
            answer: "Vue.js is a JavaScript framework",
            language: "en"
        });
    } catch (error) {
        console.error('Failed to create question:', error);
    }
};
</script>
```

### 4. Axios

```javascript
import { AuthService, QuestionService, setAuthToken } from './axios-config.js';

// Đăng nhập
const loginResponse = await AuthService.login('user@example.com', '123456');
console.log('Login successful:', loginResponse);

// Tạo câu hỏi
const question = await QuestionService.createQuestion({
    userId: 1,
    topicId: 1,
    fieldId: 1,
    levelId: 1,
    questionTypeId: 1,
    content: "What is Axios?",
    answer: "Axios is a HTTP client library",
    language: "en"
});
console.log('Question created:', question);
```

## 🔧 Cấu hình

### Environment Variables

```javascript
// Cấu hình base URL
const api = new InterviewAPIClient(process.env.REACT_APP_API_URL || 'http://localhost:8080');

// Hoặc với Axios
import axios from 'axios';
axios.defaults.baseURL = process.env.REACT_APP_API_URL || 'http://localhost:8080';
```

### Token Management

```javascript
// Lưu token vào localStorage
localStorage.setItem('authToken', token);

// Tự động thêm token vào requests
const api = new InterviewAPIClient('http://localhost:8080', localStorage.getItem('authToken'));
```

## 📋 API Endpoints

### Authentication
- `POST /auth/register` - Đăng ký user
- `POST /auth/login` - Đăng nhập
- `GET /auth/user-info` - Lấy thông tin user
- `POST /auth/refresh` - Refresh token

### Questions
- `GET /questions/questions` - Lấy danh sách câu hỏi
- `POST /questions/questions` - Tạo câu hỏi mới
- `GET /questions/questions/{id}` - Lấy câu hỏi theo ID
- `PUT /questions/questions/{id}` - Cập nhật câu hỏi
- `DELETE /questions/questions/{id}` - Xóa câu hỏi

### Fields
- `GET /questions/fields` - Lấy danh sách lĩnh vực
- `POST /questions/fields` - Tạo lĩnh vực mới

### Topics
- `GET /questions/topics` - Lấy danh sách chủ đề
- `POST /questions/topics` - Tạo chủ đề mới

### Levels
- `GET /questions/levels` - Lấy danh sách cấp độ
- `POST /questions/levels` - Tạo cấp độ mới

### Question Types
- `GET /questions/question-types` - Lấy danh sách loại câu hỏi
- `POST /questions/question-types` - Tạo loại câu hỏi mới

### Users
- `GET /users` - Lấy danh sách user (Admin only)
- `GET /users/{id}` - Lấy user theo ID
- `PUT /users/{id}/role` - Cập nhật role user (Admin only)
- `PUT /users/{id}/status` - Cập nhật status user (Admin only)

## 🔐 Authentication

Tất cả API được bảo vệ cần JWT token trong header:

```javascript
headers: {
    'Authorization': 'Bearer <your-jwt-token>'
}
```

## 📱 Error Handling

Tất cả API trả về lỗi theo chuẩn RFC 7807:

```javascript
try {
    const response = await api.createQuestion(questionData);
} catch (error) {
    if (error instanceof APIError) {
        console.error('API Error:', error.message);
        console.error('Status:', error.status);
        console.error('Data:', error.data);
    } else {
        console.error('Network Error:', error.message);
    }
}
```

## 🧪 Testing với Postman

1. Import file `Postman-Environment.json` vào Postman
2. Import file `INTERVIEW_APIS_COMPLETE_FINAL_V3.postman_collection.json`
3. Chọn environment "Interview API Environment"
4. Chạy request "Login" để lấy token
5. Token sẽ tự động được lưu vào environment variable

## 📚 Tài liệu tham khảo

- [API Documentation](../API_DOCUMENTATION.md) - Tài liệu API chi tiết
- [Postman Collection](../INTERVIEW_APIS_COMPLETE_FINAL_V3.postman_collection.json) - Collection đầy đủ
- [Swagger UI](http://localhost:8080/swagger-ui.html) - API documentation trực quan

## 🤝 Hỗ trợ

Nếu gặp vấn đề, hãy kiểm tra:

1. **Backend đang chạy** trên port 8080
2. **Token hợp lệ** và chưa hết hạn
3. **CORS** được cấu hình đúng
4. **Network** kết nối ổn định

## 📝 Changelog

### v1.0.0
- ✅ Hỗ trợ Vanilla JavaScript/TypeScript
- ✅ Hỗ trợ React Hooks
- ✅ Hỗ trợ Vue.js 3 Composition API
- ✅ Hỗ trợ Axios
- ✅ Hỗ trợ Postman
- ✅ Error handling chuẩn RFC 7807
- ✅ Token management tự động
- ✅ TypeScript definitions
