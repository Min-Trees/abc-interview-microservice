# 🚀 Quick Start - Frontend Integration

Hướng dẫn tích hợp nhanh API backend vào frontend trong 5 phút!

## 📋 Yêu cầu

- Backend đang chạy trên `http://localhost:8080`
- Node.js 16+ (nếu sử dụng npm/yarn)
- Trình duyệt hiện đại

## 🎯 Chọn framework của bạn

### 1. **Vanilla JavaScript/TypeScript** ⚡

```html
<!DOCTYPE html>
<html>
<head>
    <title>Interview System</title>
</head>
<body>
    <div id="app">
        <h1>Interview System</h1>
        <button onclick="login()">Login</button>
        <button onclick="createQuestion()">Create Question</button>
        <div id="questions"></div>
    </div>

    <script src="frontend-sdk/api-client.js"></script>
    <script>
        const api = new InterviewAPIClient('http://localhost:8080');

        async function login() {
            try {
                const response = await api.login('admin@example.com', '123456');
                console.log('Login successful:', response);
                alert('Login successful!');
            } catch (error) {
                console.error('Login failed:', error);
                alert('Login failed: ' + error.message);
            }
        }

        async function createQuestion() {
            try {
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
                alert('Question created successfully!');
            } catch (error) {
                console.error('Failed to create question:', error);
                alert('Failed to create question: ' + error.message);
            }
        }
    </script>
</body>
</html>
```

### 2. **React** ⚛️

```bash
# Tạo project React
npx create-react-app interview-frontend
cd interview-frontend

# Copy SDK files
cp ../frontend-sdk/*.js src/
cp ../frontend-sdk/types.ts src/
```

```jsx
// src/App.js
import React, { useState, useEffect } from 'react';
import { InterviewAPIClient } from './api-client';

const api = new InterviewAPIClient('http://localhost:8080');

function App() {
    const [user, setUser] = useState(null);
    const [questions, setQuestions] = useState([]);
    const [loading, setLoading] = useState(false);

    const login = async () => {
        try {
            const response = await api.login('admin@example.com', '123456');
            setUser(response);
            alert('Login successful!');
        } catch (error) {
            alert('Login failed: ' + error.message);
        }
    };

    const createQuestion = async () => {
        try {
            const question = await api.createQuestion({
                userId: 1,
                topicId: 1,
                fieldId: 1,
                levelId: 1,
                questionTypeId: 1,
                content: "What is React?",
                answer: "React is a JavaScript library",
                language: "en"
            });
            setQuestions(prev => [question, ...prev]);
            alert('Question created successfully!');
        } catch (error) {
            alert('Failed to create question: ' + error.message);
        }
    };

    const fetchQuestions = async () => {
        setLoading(true);
        try {
            const response = await api.getQuestions();
            setQuestions(response.content || []);
        } catch (error) {
            console.error('Failed to fetch questions:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchQuestions();
    }, []);

    return (
        <div>
            <h1>Interview System</h1>
            {user ? (
                <div>
                    <p>Welcome, {user.email}!</p>
                    <button onClick={createQuestion}>Create Question</button>
                    <button onClick={fetchQuestions}>Refresh Questions</button>
                </div>
            ) : (
                <button onClick={login}>Login</button>
            )}
            
            <h2>Questions</h2>
            {loading ? (
                <p>Loading...</p>
            ) : (
                <ul>
                    {questions.map(question => (
                        <li key={question.id}>
                            <h3>{question.questionContent}</h3>
                            <p>{question.questionAnswer}</p>
                            <p>Field: {question.fieldName}</p>
                        </li>
                    ))}
                </ul>
            )}
        </div>
    );
}

export default App;
```

### 3. **Vue.js 3** 🟢

```bash
# Tạo project Vue
npm create vue@latest interview-frontend
cd interview-frontend
npm install

# Copy SDK files
cp ../frontend-sdk/*.js src/
cp ../frontend-sdk/types.ts src/
```

```vue
<!-- src/App.vue -->
<template>
    <div>
        <h1>Interview System</h1>
        <div v-if="user">
            <p>Welcome, {{ user.email }}!</p>
            <button @click="createQuestion">Create Question</button>
            <button @click="fetchQuestions">Refresh Questions</button>
        </div>
        <div v-else>
            <button @click="login">Login</button>
        </div>
        
        <h2>Questions</h2>
        <div v-if="loading">Loading...</div>
        <ul v-else>
            <li v-for="question in questions" :key="question.id">
                <h3>{{ question.questionContent }}</h3>
                <p>{{ question.questionAnswer }}</p>
                <p>Field: {{ question.fieldName }}</p>
            </li>
        </ul>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { InterviewAPIClient } from './api-client';

const api = new InterviewAPIClient('http://localhost:8080');
const user = ref(null);
const questions = ref([]);
const loading = ref(false);

const login = async () => {
    try {
        const response = await api.login('admin@example.com', '123456');
        user.value = response;
        alert('Login successful!');
    } catch (error) {
        alert('Login failed: ' + error.message);
    }
};

const createQuestion = async () => {
    try {
        const question = await api.createQuestion({
            userId: 1,
            topicId: 1,
            fieldId: 1,
            levelId: 1,
            questionTypeId: 1,
            content: "What is Vue.js?",
            answer: "Vue.js is a JavaScript framework",
            language: "en"
        });
        questions.value.unshift(question);
        alert('Question created successfully!');
    } catch (error) {
        alert('Failed to create question: ' + error.message);
    }
};

const fetchQuestions = async () => {
    loading.value = true;
    try {
        const response = await api.getQuestions();
        questions.value = response.content || [];
    } catch (error) {
        console.error('Failed to fetch questions:', error);
    } finally {
        loading.value = false;
    }
};

onMounted(() => {
    fetchQuestions();
});
</script>
```

### 4. **Axios** 🔧

```bash
# Cài đặt axios
npm install axios
```

```javascript
// app.js
import { AuthService, QuestionService } from './axios-config';

async function init() {
    try {
        // Login
        const loginResponse = await AuthService.login('admin@example.com', '123456');
        console.log('Login successful:', loginResponse);

        // Create question
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

        // Get all questions
        const questions = await QuestionService.getQuestions();
        console.log('Questions:', questions);
    } catch (error) {
        console.error('Error:', error);
    }
}

init();
```

## 🧪 Testing với Postman

1. **Import Environment:**
   - File → Import → `frontend-sdk/Postman-Environment.json`

2. **Import Collection:**
   - File → Import → `INTERVIEW_APIS_COMPLETE_FINAL_V3.postman_collection.json`

3. **Test API:**
   - Chọn environment "Interview API Environment"
   - Chạy request "Login" để lấy token
   - Token sẽ tự động được lưu vào environment

## 🔧 Cấu hình nâng cao

### Environment Variables

```javascript
// .env
REACT_APP_API_URL=http://localhost:8080
REACT_APP_APP_NAME=Interview System
```

```javascript
// config.js
const config = {
    apiUrl: process.env.REACT_APP_API_URL || 'http://localhost:8080',
    appName: process.env.REACT_APP_APP_NAME || 'Interview System'
};

export default config;
```

### Error Handling

```javascript
// error-handler.js
export const handleAPIError = (error) => {
    if (error.status === 401) {
        // Token expired, redirect to login
        window.location.href = '/login';
    } else if (error.status === 403) {
        // Access denied
        alert('You do not have permission to perform this action');
    } else if (error.status === 404) {
        // Resource not found
        alert('Resource not found');
    } else {
        // Generic error
        alert('An error occurred: ' + error.message);
    }
};
```

### Token Management

```javascript
// token-manager.js
export class TokenManager {
    static getToken() {
        return localStorage.getItem('authToken');
    }

    static setToken(token) {
        localStorage.setItem('authToken', token);
    }

    static removeToken() {
        localStorage.removeItem('authToken');
    }

    static isTokenValid() {
        const token = this.getToken();
        if (!token) return false;
        
        try {
            const payload = JSON.parse(atob(token.split('.')[1]));
            return payload.exp * 1000 > Date.now();
        } catch {
            return false;
        }
    }
}
```

## 🚀 Deploy

### Build cho Production

```bash
# React
npm run build

# Vue
npm run build

# Copy build files to web server
cp -r build/* /var/www/html/
```

### Docker

```dockerfile
# Dockerfile
FROM nginx:alpine
COPY build/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 📞 Hỗ trợ

- **Documentation**: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
- **Postman Collection**: [INTERVIEW_APIS_COMPLETE_FINAL_V3.postman_collection.json](./INTERVIEW_APIS_COMPLETE_FINAL_V3.postman_collection.json)
- **Swagger UI**: http://localhost:8080/swagger-ui.html

## ✅ Checklist

- [ ] Backend đang chạy trên port 8080
- [ ] Copy SDK files vào project
- [ ] Cấu hình base URL đúng
- [ ] Test login thành công
- [ ] Test tạo question thành công
- [ ] Error handling hoạt động
- [ ] Token được lưu và sử dụng đúng

**Chúc bạn tích hợp thành công! 🎉**
