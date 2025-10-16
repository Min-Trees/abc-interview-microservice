/**
 * Vue 3 Composition API for Interview Microservice
 * Ready-to-use composables for Vue.js applications
 */

import { ref, reactive, computed } from 'vue';
import { InterviewAPIClient } from './api-client';

// Initialize API client
const api = new InterviewAPIClient('http://localhost:8080');

// Authentication Composable
export function useAuth() {
    const user = ref(null);
    const loading = ref(false);
    const error = ref(null);

    const login = async (email, password) => {
        loading.value = true;
        error.value = null;
        try {
            const response = await api.login(email, password);
            user.value = response;
            return response;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const register = async (userData) => {
        loading.value = true;
        error.value = null;
        try {
            const response = await api.register(userData);
            return response;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const logout = () => {
        api.setToken(null);
        user.value = null;
    };

    const getUserInfo = async () => {
        loading.value = true;
        error.value = null;
        try {
            const userInfo = await api.getUserInfo();
            user.value = userInfo;
            return userInfo;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    return {
        user: readonly(user),
        loading: readonly(loading),
        error: readonly(error),
        login,
        register,
        logout,
        getUserInfo
    };
}

// Question Management Composable
export function useQuestions(page = 0, size = 10) {
    const questions = ref([]);
    const loading = ref(false);
    const error = ref(null);
    const totalPages = ref(0);

    const fetchQuestions = async () => {
        loading.value = true;
        error.value = null;
        try {
            const response = await api.getQuestions(page, size);
            questions.value = response.content || [];
            totalPages.value = response.totalPages || 0;
            return response;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const createQuestion = async (questionData) => {
        loading.value = true;
        error.value = null;
        try {
            const newQuestion = await api.createQuestion(questionData);
            questions.value.unshift(newQuestion);
            return newQuestion;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const updateQuestion = async (id, questionData) => {
        loading.value = true;
        error.value = null;
        try {
            const updatedQuestion = await api.updateQuestion(id, questionData);
            const index = questions.value.findIndex(q => q.id === id);
            if (index !== -1) {
                questions.value[index] = updatedQuestion;
            }
            return updatedQuestion;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const deleteQuestion = async (id) => {
        loading.value = true;
        error.value = null;
        try {
            await api.deleteQuestion(id);
            questions.value = questions.value.filter(q => q.id !== id);
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    return {
        questions: readonly(questions),
        loading: readonly(loading),
        error: readonly(error),
        totalPages: readonly(totalPages),
        fetchQuestions,
        createQuestion,
        updateQuestion,
        deleteQuestion
    };
}

// Field Management Composable
export function useFields(page = 0, size = 10) {
    const fields = ref([]);
    const loading = ref(false);
    const error = ref(null);

    const fetchFields = async () => {
        loading.value = true;
        error.value = null;
        try {
            const response = await api.getFields(page, size);
            fields.value = response.content || [];
            return response;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const createField = async (fieldData) => {
        loading.value = true;
        error.value = null;
        try {
            const newField = await api.createField(fieldData);
            fields.value.unshift(newField);
            return newField;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    return {
        fields: readonly(fields),
        loading: readonly(loading),
        error: readonly(error),
        fetchFields,
        createField
    };
}

// Topic Management Composable
export function useTopics(page = 0, size = 10) {
    const topics = ref([]);
    const loading = ref(false);
    const error = ref(null);

    const fetchTopics = async () => {
        loading.value = true;
        error.value = null;
        try {
            const response = await api.getTopics(page, size);
            topics.value = response.content || [];
            return response;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const createTopic = async (topicData) => {
        loading.value = true;
        error.value = null;
        try {
            const newTopic = await api.createTopic(topicData);
            topics.value.unshift(newTopic);
            return newTopic;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    return {
        topics: readonly(topics),
        loading: readonly(loading),
        error: readonly(error),
        fetchTopics,
        createTopic
    };
}

// Level Management Composable
export function useLevels(page = 0, size = 10) {
    const levels = ref([]);
    const loading = ref(false);
    const error = ref(null);

    const fetchLevels = async () => {
        loading.value = true;
        error.value = null;
        try {
            const response = await api.getLevels(page, size);
            levels.value = response.content || [];
            return response;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const createLevel = async (levelData) => {
        loading.value = true;
        error.value = null;
        try {
            const newLevel = await api.createLevel(levelData);
            levels.value.unshift(newLevel);
            return newLevel;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    return {
        levels: readonly(levels),
        loading: readonly(loading),
        error: readonly(error),
        fetchLevels,
        createLevel
    };
}

// Question Type Management Composable
export function useQuestionTypes(page = 0, size = 10) {
    const questionTypes = ref([]);
    const loading = ref(false);
    const error = ref(null);

    const fetchQuestionTypes = async () => {
        loading.value = true;
        error.value = null;
        try {
            const response = await api.getQuestionTypes(page, size);
            questionTypes.value = response.content || [];
            return response;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const createQuestionType = async (questionTypeData) => {
        loading.value = true;
        error.value = null;
        try {
            const newQuestionType = await api.createQuestionType(questionTypeData);
            questionTypes.value.unshift(newQuestionType);
            return newQuestionType;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    return {
        questionTypes: readonly(questionTypes),
        loading: readonly(loading),
        error: readonly(error),
        fetchQuestionTypes,
        createQuestionType
    };
}

// User Management Composable
export function useUsers(page = 0, size = 10) {
    const users = ref([]);
    const loading = ref(false);
    const error = ref(null);

    const fetchUsers = async () => {
        loading.value = true;
        error.value = null;
        try {
            const response = await api.getUsers(page, size);
            users.value = response.content || [];
            return response;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    const updateUserRole = async (id, roleId) => {
        loading.value = true;
        error.value = null;
        try {
            const updatedUser = await api.updateUserRole(id, roleId);
            const index = users.value.findIndex(u => u.id === id);
            if (index !== -1) {
                users.value[index] = updatedUser;
            }
            return updatedUser;
        } catch (err) {
            error.value = err.message;
            throw err;
        } finally {
            loading.value = false;
        }
    };

    return {
        users: readonly(users),
        loading: readonly(loading),
        error: readonly(error),
        fetchUsers,
        updateUserRole
    };
}

// Example Vue Component
export const QuestionList = {
    setup() {
        const { questions, loading, error, createQuestion } = useQuestions();
        const newQuestion = reactive({
            content: '',
            answer: '',
            topicId: 1,
            fieldId: 1,
            levelId: 1,
            questionTypeId: 1,
            language: 'en'
        });

        const handleSubmit = async () => {
            try {
                await createQuestion(newQuestion);
                Object.assign(newQuestion, {
                    content: '',
                    answer: '',
                    topicId: 1,
                    fieldId: 1,
                    levelId: 1,
                    questionTypeId: 1,
                    language: 'en'
                });
            } catch (err) {
                console.error('Failed to create question:', err);
            }
        };

        return {
            questions,
            loading,
            error,
            newQuestion,
            handleSubmit
        };
    },
    template: `
        <div>
            <h2>Questions</h2>
            <form @submit.prevent="handleSubmit">
                <input
                    v-model="newQuestion.content"
                    type="text"
                    placeholder="Question content"
                />
                <input
                    v-model="newQuestion.answer"
                    type="text"
                    placeholder="Answer"
                />
                <button type="submit">Create Question</button>
            </form>
            <div v-if="loading">Loading...</div>
            <div v-else-if="error">Error: {{ error }}</div>
            <ul v-else>
                <li v-for="question in questions" :key="question.id">
                    <h3>{{ question.questionContent }}</h3>
                    <p>Answer: {{ question.questionAnswer }}</p>
                    <p>Field: {{ question.fieldName }}</p>
                    <p>Topic: {{ question.topicName }}</p>
                    <p>Level: {{ question.levelName }}</p>
                </li>
            </ul>
        </div>
    `
};
