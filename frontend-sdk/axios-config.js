/**
 * Axios Configuration for Interview Microservice API
 * Ready-to-use Axios setup with interceptors
 */

import axios from 'axios';

// Create axios instance
const apiClient = axios.create({
    baseURL: 'http://localhost:8080',
    timeout: 10000,
    headers: {
        'Content-Type': 'application/json',
    }
});

// Token management
let authToken = localStorage.getItem('authToken');

export const setAuthToken = (token) => {
    authToken = token;
    if (token) {
        localStorage.setItem('authToken', token);
        apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    } else {
        localStorage.removeItem('authToken');
        delete apiClient.defaults.headers.common['Authorization'];
    }
};

// Request interceptor
apiClient.interceptors.request.use(
    (config) => {
        if (authToken) {
            config.headers.Authorization = `Bearer ${authToken}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Response interceptor
apiClient.interceptors.response.use(
    (response) => {
        return response;
    },
    (error) => {
        if (error.response?.status === 401) {
            // Token expired or invalid
            setAuthToken(null);
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

// API Service Classes
export class AuthService {
    static async register(userData) {
        const response = await apiClient.post('/auth/register', userData);
        return response.data;
    }

    static async login(email, password) {
        const response = await apiClient.post('/auth/login', { email, password });
        const { accessToken } = response.data;
        if (accessToken) {
            setAuthToken(accessToken);
        }
        return response.data;
    }

    static async getUserInfo() {
        const response = await apiClient.get('/auth/user-info');
        return response.data;
    }

    static async refreshToken(refreshToken) {
        const response = await apiClient.post('/auth/refresh', { refreshToken });
        const { accessToken } = response.data;
        if (accessToken) {
            setAuthToken(accessToken);
        }
        return response.data;
    }

    static logout() {
        setAuthToken(null);
    }
}

export class QuestionService {
    static async createField(fieldData) {
        const response = await apiClient.post('/questions/fields', fieldData);
        return response.data;
    }

    static async getFields(page = 0, size = 10) {
        const response = await apiClient.get(`/questions/fields?page=${page}&size=${size}`);
        return response.data;
    }

    static async createTopic(topicData) {
        const response = await apiClient.post('/questions/topics', topicData);
        return response.data;
    }

    static async getTopics(page = 0, size = 10) {
        const response = await apiClient.get(`/questions/topics?page=${page}&size=${size}`);
        return response.data;
    }

    static async createLevel(levelData) {
        const response = await apiClient.post('/questions/levels', levelData);
        return response.data;
    }

    static async getLevels(page = 0, size = 10) {
        const response = await apiClient.get(`/questions/levels?page=${page}&size=${size}`);
        return response.data;
    }

    static async createQuestionType(questionTypeData) {
        const response = await apiClient.post('/questions/question-types', questionTypeData);
        return response.data;
    }

    static async getQuestionTypes(page = 0, size = 10) {
        const response = await apiClient.get(`/questions/question-types?page=${page}&size=${size}`);
        return response.data;
    }

    static async createQuestion(questionData) {
        const response = await apiClient.post('/questions/questions', questionData);
        return response.data;
    }

    static async getQuestions(page = 0, size = 10) {
        const response = await apiClient.get(`/questions/questions?page=${page}&size=${size}`);
        return response.data;
    }

    static async getQuestionById(id) {
        const response = await apiClient.get(`/questions/questions/${id}`);
        return response.data;
    }

    static async updateQuestion(id, questionData) {
        const response = await apiClient.put(`/questions/questions/${id}`, questionData);
        return response.data;
    }

    static async deleteQuestion(id) {
        const response = await apiClient.delete(`/questions/questions/${id}`);
        return response.data;
    }
}

export class UserService {
    static async getUsers(page = 0, size = 10) {
        const response = await apiClient.get(`/users?page=${page}&size=${size}`);
        return response.data;
    }

    static async getUserById(id) {
        const response = await apiClient.get(`/users/${id}`);
        return response.data;
    }

    static async updateUserRole(id, roleId) {
        const response = await apiClient.put(`/users/${id}/role`, { roleId });
        return response.data;
    }

    static async updateUserStatus(id, status) {
        const response = await apiClient.put(`/users/${id}/status`, { status });
        return response.data;
    }
}

export class ExamService {
    static async createExam(examData) {
        const response = await apiClient.post('/exams', examData);
        return response.data;
    }

    static async getExams(page = 0, size = 10) {
        const response = await apiClient.get(`/exams?page=${page}&size=${size}`);
        return response.data;
    }

    static async getExamById(id) {
        const response = await apiClient.get(`/exams/${id}`);
        return response.data;
    }
}

export class NewsService {
    static async createNews(newsData) {
        const response = await apiClient.post('/news', newsData);
        return response.data;
    }

    static async getNews(page = 0, size = 10) {
        const response = await apiClient.get(`/news?page=${page}&size=${size}`);
        return response.data;
    }

    static async getNewsById(id) {
        const response = await apiClient.get(`/news/${id}`);
        return response.data;
    }
}

export class CareerService {
    static async createCareer(careerData) {
        const response = await apiClient.post('/careers', careerData);
        return response.data;
    }

    static async getCareers(page = 0, size = 10) {
        const response = await apiClient.get(`/careers?page=${page}&size=${size}`);
        return response.data;
    }

    static async getCareerById(id) {
        const response = await apiClient.get(`/careers/${id}`);
        return response.data;
    }
}

// Export the configured axios instance
export default apiClient;

// Example usage:
/*
import { AuthService, QuestionService, setAuthToken } from './axios-config';

// Login
const loginResponse = await AuthService.login('user@example.com', '123456');
console.log('Login successful:', loginResponse);

// Create a question
const question = await QuestionService.createQuestion({
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

// Get all questions
const questions = await QuestionService.getQuestions(0, 10);
console.log('Questions:', questions);
*/
