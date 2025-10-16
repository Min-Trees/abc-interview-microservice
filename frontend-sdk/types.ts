/**
 * TypeScript Definitions for Interview Microservice API
 * Type definitions for better development experience
 */

// Base API Response
export interface ApiResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
  first: boolean;
  last: boolean;
  numberOfElements: number;
}

// Authentication Types
export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  roleName: string;
  fullName: string;
  dateOfBirth: string;
  address: string;
  isStudying: boolean;
}

export interface TokenResponse {
  accessToken: string;
  tokenType: string;
  refreshToken: string;
  expiresIn: number;
  verifyToken?: string;
}

export interface UserInfo {
  id: number;
  email: string;
  fullName: string;
  roleName: string;
  status: string;
  eloScore: number;
  eloRank: string;
  createdAt: string;
}

// Question Types
export interface Question {
  id: number;
  userId: number;
  topicId: number;
  fieldId: number;
  levelId: number;
  questionTypeId: number;
  questionContent: string;
  questionAnswer: string;
  similarityScore?: number;
  status: string;
  language: string;
  createdAt: string;
  approvedAt?: string;
  approvedBy?: number;
  usefulVote: number;
  unusefulVote: number;
  fieldName: string;
  topicName: string;
  levelName: string;
  questionTypeName: string;
}

export interface QuestionRequest {
  userId: number;
  topicId: number;
  fieldId: number;
  levelId: number;
  questionTypeId: number;
  content: string;
  answer: string;
  language: string;
}

// Field Types
export interface Field {
  id: number;
  name: string;
  description: string;
}

export interface FieldRequest {
  name: string;
  description: string;
}

// Topic Types
export interface Topic {
  id: number;
  fieldId: number;
  name: string;
  description: string;
}

export interface TopicRequest {
  fieldId: number;
  name: string;
  description: string;
}

// Level Types
export interface Level {
  id: number;
  name: string;
  description: string;
  minScore: number;
  maxScore: number;
}

export interface LevelRequest {
  name: string;
  description: string;
  minScore: number;
  maxScore: number;
}

// Question Type Types
export interface QuestionType {
  id: number;
  name: string;
  description: string;
}

export interface QuestionTypeRequest {
  name: string;
  description: string;
}

// User Types
export interface User {
  id: number;
  roleId: number;
  roleName: string;
  email: string;
  fullName: string;
  dateOfBirth: string;
  address: string;
  status: string;
  isStudying: boolean;
  eloScore: number;
  eloRank: string;
  createdAt: string;
  verifyToken?: string;
}

export interface RoleUpdateRequest {
  roleId: number;
}

export interface StatusUpdateRequest {
  status: string;
}

// Exam Types
export interface Exam {
  id: number;
  title: string;
  description: string;
  duration: number;
  maxScore: number;
  questionIds: number[];
  createdAt: string;
  updatedAt: string;
}

export interface ExamRequest {
  title: string;
  description: string;
  duration: number;
  maxScore: number;
  questionIds: number[];
}

// News Types
export interface News {
  id: number;
  title: string;
  content: string;
  author: string;
  category: string;
  createdAt: string;
  updatedAt: string;
}

export interface NewsRequest {
  title: string;
  content: string;
  author: string;
  category: string;
}

// Career Types
export interface Career {
  id: number;
  title: string;
  description: string;
  requirements: string;
  salary: string;
  location: string;
  createdAt: string;
  updatedAt: string;
}

export interface CareerRequest {
  title: string;
  description: string;
  requirements: string;
  salary: string;
  location: string;
}

// Error Types
export interface ErrorResponse {
  type: string;
  title: string;
  status: number;
  detail: string;
  instance: string;
  errorCode: string;
  traceId: string;
  timestamp: string;
  details?: Record<string, string>;
}

// API Client Types
export interface APIClientConfig {
  baseURL: string;
  token?: string;
  timeout?: number;
}

export interface RequestConfig {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  headers?: Record<string, string>;
  body?: any;
}

// React Hooks Types
export interface UseAuthReturn {
  user: UserInfo | null;
  loading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<TokenResponse>;
  register: (userData: RegisterRequest) => Promise<TokenResponse>;
  logout: () => void;
  getUserInfo: () => Promise<UserInfo>;
}

export interface UseQuestionsReturn {
  questions: Question[];
  loading: boolean;
  error: string | null;
  totalPages: number;
  fetchQuestions: () => Promise<ApiResponse<Question>>;
  createQuestion: (questionData: QuestionRequest) => Promise<Question>;
  updateQuestion: (id: number, questionData: QuestionRequest) => Promise<Question>;
  deleteQuestion: (id: number) => Promise<void>;
}

export interface UseFieldsReturn {
  fields: Field[];
  loading: boolean;
  error: string | null;
  fetchFields: () => Promise<ApiResponse<Field>>;
  createField: (fieldData: FieldRequest) => Promise<Field>;
}

export interface UseTopicsReturn {
  topics: Topic[];
  loading: boolean;
  error: string | null;
  fetchTopics: () => Promise<ApiResponse<Topic>>;
  createTopic: (topicData: TopicRequest) => Promise<Topic>;
}

export interface UseLevelsReturn {
  levels: Level[];
  loading: boolean;
  error: string | null;
  fetchLevels: () => Promise<ApiResponse<Level>>;
  createLevel: (levelData: LevelRequest) => Promise<Level>;
}

export interface UseQuestionTypesReturn {
  questionTypes: QuestionType[];
  loading: boolean;
  error: string | null;
  fetchQuestionTypes: () => Promise<ApiResponse<QuestionType>>;
  createQuestionType: (questionTypeData: QuestionTypeRequest) => Promise<QuestionType>;
}

export interface UseUsersReturn {
  users: User[];
  loading: boolean;
  error: string | null;
  fetchUsers: () => Promise<ApiResponse<User>>;
  updateUserRole: (id: number, roleId: number) => Promise<User>;
}

// Vue Composables Types
export interface UseAuthComposable {
  user: Readonly<Ref<UserInfo | null>>;
  loading: Readonly<Ref<boolean>>;
  error: Readonly<Ref<string | null>>;
  login: (email: string, password: string) => Promise<TokenResponse>;
  register: (userData: RegisterRequest) => Promise<TokenResponse>;
  logout: () => void;
  getUserInfo: () => Promise<UserInfo>;
}

export interface UseQuestionsComposable {
  questions: Readonly<Ref<Question[]>>;
  loading: Readonly<Ref<boolean>>;
  error: Readonly<Ref<string | null>>;
  totalPages: Readonly<Ref<number>>;
  fetchQuestions: () => Promise<ApiResponse<Question>>;
  createQuestion: (questionData: QuestionRequest) => Promise<Question>;
  updateQuestion: (id: number, questionData: QuestionRequest) => Promise<Question>;
  deleteQuestion: (id: number) => Promise<void>;
}

// Utility Types
export type APIError = Error & {
  status: number;
  data: ErrorResponse;
};

export type PaginationParams = {
  page?: number;
  size?: number;
};

export type SortParams = {
  sort?: string;
  direction?: 'asc' | 'desc';
};

// Service Types
export interface AuthService {
  register(userData: RegisterRequest): Promise<TokenResponse>;
  login(email: string, password: string): Promise<TokenResponse>;
  getUserInfo(): Promise<UserInfo>;
  refreshToken(refreshToken: string): Promise<TokenResponse>;
  logout(): void;
}

export interface QuestionService {
  createField(fieldData: FieldRequest): Promise<Field>;
  getFields(page?: number, size?: number): Promise<ApiResponse<Field>>;
  createTopic(topicData: TopicRequest): Promise<Topic>;
  getTopics(page?: number, size?: number): Promise<ApiResponse<Topic>>;
  createLevel(levelData: LevelRequest): Promise<Level>;
  getLevels(page?: number, size?: number): Promise<ApiResponse<Level>>;
  createQuestionType(questionTypeData: QuestionTypeRequest): Promise<QuestionType>;
  getQuestionTypes(page?: number, size?: number): Promise<ApiResponse<QuestionType>>;
  createQuestion(questionData: QuestionRequest): Promise<Question>;
  getQuestions(page?: number, size?: number): Promise<ApiResponse<Question>>;
  getQuestionById(id: number): Promise<Question>;
  updateQuestion(id: number, questionData: QuestionRequest): Promise<Question>;
  deleteQuestion(id: number): Promise<void>;
}

export interface UserService {
  getUsers(page?: number, size?: number): Promise<ApiResponse<User>>;
  getUserById(id: number): Promise<User>;
  updateUserRole(id: number, roleId: number): Promise<User>;
  updateUserStatus(id: number, status: string): Promise<User>;
}

export interface ExamService {
  createExam(examData: ExamRequest): Promise<Exam>;
  getExams(page?: number, size?: number): Promise<ApiResponse<Exam>>;
  getExamById(id: number): Promise<Exam>;
}

export interface NewsService {
  createNews(newsData: NewsRequest): Promise<News>;
  getNews(page?: number, size?: number): Promise<ApiResponse<News>>;
  getNewsById(id: number): Promise<News>;
}

export interface CareerService {
  createCareer(careerData: CareerRequest): Promise<Career>;
  getCareers(page?: number, size?: number): Promise<ApiResponse<Career>>;
  getCareerById(id: number): Promise<Career>;
}
