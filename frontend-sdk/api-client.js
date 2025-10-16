/**
 * Interview Microservice API Client
 * A simple JavaScript/TypeScript client for the Interview System APIs
 */

class InterviewAPIClient {
    constructor(baseURL = 'http://localhost:8080', token = null) {
        this.baseURL = baseURL;
        this.token = token;
    }

    // Set authentication token
    setToken(token) {
        this.token = token;
    }

    // Get headers with authentication
    getHeaders() {
        const headers = {
            'Content-Type': 'application/json',
        };
        
        if (this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }
        
        return headers;
    }

    // Generic request method
    async request(endpoint, options = {}) {
        const url = `${this.baseURL}${endpoint}`;
        const config = {
            headers: this.getHeaders(),
            ...options
        };

        try {
            const response = await fetch(url, config);
            
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new APIError(
                    errorData.detail || `HTTP ${response.status}`,
                    response.status,
                    errorData
                );
            }

            return await response.json();
        } catch (error) {
            if (error instanceof APIError) {
                throw error;
            }
            throw new APIError(`Network error: ${error.message}`, 0);
        }
    }

    // Authentication APIs
    async register(userData) {
        return this.request('/auth/register', {
            method: 'POST',
            body: JSON.stringify(userData)
        });
    }

    async login(email, password) {
        const response = await this.request('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ email, password })
        });
        
        // Auto-set token after login
        if (response.accessToken) {
            this.setToken(response.accessToken);
        }
        
        return response;
    }

    async getUserInfo() {
        return this.request('/auth/user-info');
    }

    // Question Management APIs
    async createField(fieldData) {
        return this.request('/questions/fields', {
            method: 'POST',
            body: JSON.stringify(fieldData)
        });
    }

    async getFields(page = 0, size = 10) {
        return this.request(`/questions/fields?page=${page}&size=${size}`);
    }

    async createTopic(topicData) {
        return this.request('/questions/topics', {
            method: 'POST',
            body: JSON.stringify(topicData)
        });
    }

    async getTopics(page = 0, size = 10) {
        return this.request(`/questions/topics?page=${page}&size=${size}`);
    }

    async createLevel(levelData) {
        return this.request('/questions/levels', {
            method: 'POST',
            body: JSON.stringify(levelData)
        });
    }

    async getLevels(page = 0, size = 10) {
        return this.request(`/questions/levels?page=${page}&size=${size}`);
    }

    async createQuestionType(questionTypeData) {
        return this.request('/questions/question-types', {
            method: 'POST',
            body: JSON.stringify(questionTypeData)
        });
    }

    async getQuestionTypes(page = 0, size = 10) {
        return this.request(`/questions/question-types?page=${page}&size=${size}`);
    }

    async createQuestion(questionData) {
        return this.request('/questions/questions', {
            method: 'POST',
            body: JSON.stringify(questionData)
        });
    }

    async getQuestions(page = 0, size = 10) {
        return this.request(`/questions/questions?page=${page}&size=${size}`);
    }

    async getQuestionById(id) {
        return this.request(`/questions/questions/${id}`);
    }

    async updateQuestion(id, questionData) {
        return this.request(`/questions/questions/${id}`, {
            method: 'PUT',
            body: JSON.stringify(questionData)
        });
    }

    async deleteQuestion(id) {
        return this.request(`/questions/questions/${id}`, {
            method: 'DELETE'
        });
    }

    // User Management APIs
    async getUsers(page = 0, size = 10) {
        return this.request(`/users?page=${page}&size=${size}`);
    }

    async getUserById(id) {
        return this.request(`/users/${id}`);
    }

    async updateUserRole(id, roleId) {
        return this.request(`/users/${id}/role`, {
            method: 'PUT',
            body: JSON.stringify({ roleId })
        });
    }

    async updateUserStatus(id, status) {
        return this.request(`/users/${id}/status`, {
            method: 'PUT',
            body: JSON.stringify({ status })
        });
    }

    // Exam Management APIs
    async createExam(examData) {
        return this.request('/exams', {
            method: 'POST',
            body: JSON.stringify(examData)
        });
    }

    async getExams(page = 0, size = 10) {
        return this.request(`/exams?page=${page}&size=${size}`);
    }

    async getExamById(id) {
        return this.request(`/exams/${id}`);
    }

    // News Management APIs
    async createNews(newsData) {
        return this.request('/news', {
            method: 'POST',
            body: JSON.stringify(newsData)
        });
    }

    async getNews(page = 0, size = 10) {
        return this.request(`/news?page=${page}&size=${size}`);
    }

    async getNewsById(id) {
        return this.request(`/news/${id}`);
    }

    // Career Management APIs
    async createCareer(careerData) {
        return this.request('/careers', {
            method: 'POST',
            body: JSON.stringify(careerData)
        });
    }

    async getCareers(page = 0, size = 10) {
        return this.request(`/careers?page=${page}&size=${size}`);
    }

    async getCareerById(id) {
        return this.request(`/careers/${id}`);
    }
}

// Custom Error Class
class APIError extends Error {
    constructor(message, status, data = {}) {
        super(message);
        this.name = 'APIError';
        this.status = status;
        this.data = data;
    }
}

// Export for different module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { InterviewAPIClient, APIError };
} else if (typeof window !== 'undefined') {
    window.InterviewAPIClient = InterviewAPIClient;
    window.APIError = APIError;
}

// Example usage:
/*
// Initialize client
const api = new InterviewAPIClient('http://localhost:8080');

// Login and get token
try {
    const loginResponse = await api.login('user@example.com', '123456');
    console.log('Login successful:', loginResponse);
} catch (error) {
    console.error('Login failed:', error.message);
}

// Create a question
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
} catch (error) {
    console.error('Failed to create question:', error.message);
}

// Get all questions
try {
    const questions = await api.getQuestions(0, 10);
    console.log('Questions:', questions);
} catch (error) {
    console.error('Failed to get questions:', error.message);
}
*/
