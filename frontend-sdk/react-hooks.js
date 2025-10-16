/**
 * React Hooks for Interview Microservice API
 * Custom hooks for easy integration with React components
 */

import { useState, useEffect, useCallback } from 'react';
import { InterviewAPIClient } from './api-client';

// Initialize API client
const api = new InterviewAPIClient('http://localhost:8080');

// Authentication Hooks
export const useAuth = () => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const login = useCallback(async (email, password) => {
        setLoading(true);
        setError(null);
        try {
            const response = await api.login(email, password);
            setUser(response);
            return response;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    const register = useCallback(async (userData) => {
        setLoading(true);
        setError(null);
        try {
            const response = await api.register(userData);
            return response;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    const logout = useCallback(() => {
        api.setToken(null);
        setUser(null);
    }, []);

    const getUserInfo = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const userInfo = await api.getUserInfo();
            setUser(userInfo);
            return userInfo;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    return {
        user,
        loading,
        error,
        login,
        register,
        logout,
        getUserInfo
    };
};

// Question Management Hooks
export const useQuestions = (page = 0, size = 10) => {
    const [questions, setQuestions] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [totalPages, setTotalPages] = useState(0);

    const fetchQuestions = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const response = await api.getQuestions(page, size);
            setQuestions(response.content || []);
            setTotalPages(response.totalPages || 0);
            return response;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, [page, size]);

    const createQuestion = useCallback(async (questionData) => {
        setLoading(true);
        setError(null);
        try {
            const newQuestion = await api.createQuestion(questionData);
            setQuestions(prev => [newQuestion, ...prev]);
            return newQuestion;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    const updateQuestion = useCallback(async (id, questionData) => {
        setLoading(true);
        setError(null);
        try {
            const updatedQuestion = await api.updateQuestion(id, questionData);
            setQuestions(prev => 
                prev.map(q => q.id === id ? updatedQuestion : q)
            );
            return updatedQuestion;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    const deleteQuestion = useCallback(async (id) => {
        setLoading(true);
        setError(null);
        try {
            await api.deleteQuestion(id);
            setQuestions(prev => prev.filter(q => q.id !== id));
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchQuestions();
    }, [fetchQuestions]);

    return {
        questions,
        loading,
        error,
        totalPages,
        fetchQuestions,
        createQuestion,
        updateQuestion,
        deleteQuestion
    };
};

// Field Management Hooks
export const useFields = (page = 0, size = 10) => {
    const [fields, setFields] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const fetchFields = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const response = await api.getFields(page, size);
            setFields(response.content || []);
            return response;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, [page, size]);

    const createField = useCallback(async (fieldData) => {
        setLoading(true);
        setError(null);
        try {
            const newField = await api.createField(fieldData);
            setFields(prev => [newField, ...prev]);
            return newField;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchFields();
    }, [fetchFields]);

    return {
        fields,
        loading,
        error,
        fetchFields,
        createField
    };
};

// Topic Management Hooks
export const useTopics = (page = 0, size = 10) => {
    const [topics, setTopics] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const fetchTopics = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const response = await api.getTopics(page, size);
            setTopics(response.content || []);
            return response;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, [page, size]);

    const createTopic = useCallback(async (topicData) => {
        setLoading(true);
        setError(null);
        try {
            const newTopic = await api.createTopic(topicData);
            setTopics(prev => [newTopic, ...prev]);
            return newTopic;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchTopics();
    }, [fetchTopics]);

    return {
        topics,
        loading,
        error,
        fetchTopics,
        createTopic
    };
};

// Level Management Hooks
export const useLevels = (page = 0, size = 10) => {
    const [levels, setLevels] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const fetchLevels = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const response = await api.getLevels(page, size);
            setLevels(response.content || []);
            return response;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, [page, size]);

    const createLevel = useCallback(async (levelData) => {
        setLoading(true);
        setError(null);
        try {
            const newLevel = await api.createLevel(levelData);
            setLevels(prev => [newLevel, ...prev]);
            return newLevel;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchLevels();
    }, [fetchLevels]);

    return {
        levels,
        loading,
        error,
        fetchLevels,
        createLevel
    };
};

// Question Type Management Hooks
export const useQuestionTypes = (page = 0, size = 10) => {
    const [questionTypes, setQuestionTypes] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const fetchQuestionTypes = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const response = await api.getQuestionTypes(page, size);
            setQuestionTypes(response.content || []);
            return response;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, [page, size]);

    const createQuestionType = useCallback(async (questionTypeData) => {
        setLoading(true);
        setError(null);
        try {
            const newQuestionType = await api.createQuestionType(questionTypeData);
            setQuestionTypes(prev => [newQuestionType, ...prev]);
            return newQuestionType;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchQuestionTypes();
    }, [fetchQuestionTypes]);

    return {
        questionTypes,
        loading,
        error,
        fetchQuestionTypes,
        createQuestionType
    };
};

// User Management Hooks
export const useUsers = (page = 0, size = 10) => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const fetchUsers = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const response = await api.getUsers(page, size);
            setUsers(response.content || []);
            return response;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, [page, size]);

    const updateUserRole = useCallback(async (id, roleId) => {
        setLoading(true);
        setError(null);
        try {
            const updatedUser = await api.updateUserRole(id, roleId);
            setUsers(prev => 
                prev.map(u => u.id === id ? updatedUser : u)
            );
            return updatedUser;
        } catch (err) {
            setError(err.message);
            throw err;
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchUsers();
    }, [fetchUsers]);

    return {
        users,
        loading,
        error,
        fetchUsers,
        updateUserRole
    };
};

// Example React Component
export const QuestionList = () => {
    const { questions, loading, error, createQuestion } = useQuestions();
    const [newQuestion, setNewQuestion] = useState({
        content: '',
        answer: '',
        topicId: 1,
        fieldId: 1,
        levelId: 1,
        questionTypeId: 1,
        language: 'en'
    });

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            await createQuestion(newQuestion);
            setNewQuestion({
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

    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error}</div>;

    return (
        <div>
            <h2>Questions</h2>
            <form onSubmit={handleSubmit}>
                <input
                    type="text"
                    placeholder="Question content"
                    value={newQuestion.content}
                    onChange={(e) => setNewQuestion({...newQuestion, content: e.target.value})}
                />
                <input
                    type="text"
                    placeholder="Answer"
                    value={newQuestion.answer}
                    onChange={(e) => setNewQuestion({...newQuestion, answer: e.target.value})}
                />
                <button type="submit">Create Question</button>
            </form>
            <ul>
                {questions.map(question => (
                    <li key={question.id}>
                        <h3>{question.questionContent}</h3>
                        <p>Answer: {question.questionAnswer}</p>
                        <p>Field: {question.fieldName}</p>
                        <p>Topic: {question.topicName}</p>
                        <p>Level: {question.levelName}</p>
                    </li>
                ))}
            </ul>
        </div>
    );
};
