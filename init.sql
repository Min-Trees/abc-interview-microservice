-- 🗄️ INITIALIZE ALL DATABASES FOR INTERVIEW SYSTEM
-- This script creates all required databases for microservices

-- Create databases
CREATE DATABASE authdb;
CREATE DATABASE userdb;
CREATE DATABASE careerdb;
CREATE DATABASE questiondb;
CREATE DATABASE examdb;
CREATE DATABASE newsdb;

-- Grant permissions to postgres user
GRANT ALL PRIVILEGES ON DATABASE authdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE userdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE careerdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE questiondb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE examdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE newsdb TO postgres;

-- Connect to each database and create initial data
\c authdb;

-- Create roles table for auth service
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Insert default roles
INSERT INTO roles(role_name, description) VALUES 
('USER', 'Role cho sinh viên/người tìm việc'),
('RECRUITER', 'Role cho nhà tuyển dụng'),
('ADMIN', 'Role cho quản trị viên')
ON CONFLICT (role_name) DO NOTHING;

\c userdb;

-- Create roles table for user service
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Insert default roles
INSERT INTO roles(role_name, description) VALUES 
('USER', 'Role cho sinh viên/người tìm việc'),
('RECRUITER', 'Role cho nhà tuyển dụng'),
('ADMIN', 'Role cho quản trị viên')
ON CONFLICT (role_name) DO NOTHING;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    role_id BIGINT REFERENCES roles(id),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    date_of_birth DATE,
    address VARCHAR(255),
    status VARCHAR(50) DEFAULT 'PENDING',
    is_studying BOOLEAN,
    elo_score INTEGER DEFAULT 0,
    elo_rank VARCHAR(50) DEFAULT 'NEWBIE',
    verify_token VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create elo_history table
CREATE TABLE IF NOT EXISTS elo_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    points INTEGER NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

\c careerdb;

-- Create career_preferences table
CREATE TABLE IF NOT EXISTS career_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    field_id BIGINT NOT NULL,
    topic_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

\c questiondb;

-- Create fields table
CREATE TABLE IF NOT EXISTS fields (
    id BIGSERIAL PRIMARY KEY,
    field_name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Create topics table
CREATE TABLE IF NOT EXISTS topics (
    id BIGSERIAL PRIMARY KEY,
    field_id BIGINT REFERENCES fields(id),
    topic_name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Create levels table
CREATE TABLE IF NOT EXISTS levels (
    id BIGSERIAL PRIMARY KEY,
    level_name VARCHAR(50) NOT NULL,
    description TEXT
);

-- Create question_types table
CREATE TABLE IF NOT EXISTS question_types (
    id BIGSERIAL PRIMARY KEY,
    question_type_name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Create questions table
CREATE TABLE IF NOT EXISTS questions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    topic_id BIGINT REFERENCES topics(id),
    field_id BIGINT REFERENCES fields(id),
    level_id BIGINT REFERENCES levels(id),
    question_type_id BIGINT REFERENCES question_types(id),
    question_content TEXT NOT NULL,
    question_answer TEXT,
    similarity_score DOUBLE PRECISION,
    status VARCHAR(50) DEFAULT 'PENDING',
    language VARCHAR(10) DEFAULT 'vi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by BIGINT,
    useful_vote INTEGER DEFAULT 0,
    unuseful_vote INTEGER DEFAULT 0
);

-- Create answers table
CREATE TABLE IF NOT EXISTS answers (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    question_id BIGINT REFERENCES questions(id),
    question_type_id BIGINT REFERENCES question_types(id),
    answer_content TEXT NOT NULL,
    is_correct BOOLEAN,
    similarity_score DOUBLE PRECISION,
    useful_vote INTEGER DEFAULT 0,
    unuseful_vote INTEGER DEFAULT 0,
    is_sample_answer BOOLEAN DEFAULT FALSE,
    order_number INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

\c examdb;

-- Create exams table
CREATE TABLE IF NOT EXISTS exams (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    exam_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    position VARCHAR(100),
    topics TEXT, -- JSON array of topic IDs
    question_types TEXT, -- JSON array of question type IDs
    question_count INTEGER,
    duration INTEGER, -- minutes
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(50) DEFAULT 'DRAFT',
    language VARCHAR(10) DEFAULT 'vi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT
);

-- Create exam_questions table
CREATE TABLE IF NOT EXISTS exam_questions (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT REFERENCES exams(id),
    question_id BIGINT NOT NULL,
    order_number INTEGER
);

-- Create results table
CREATE TABLE IF NOT EXISTS results (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT REFERENCES exams(id),
    user_id BIGINT NOT NULL,
    score DOUBLE PRECISION,
    pass_status BOOLEAN,
    feedback TEXT,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create user_answers table
CREATE TABLE IF NOT EXISTS user_answers (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT REFERENCES exams(id),
    question_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    answer_content TEXT,
    is_correct BOOLEAN,
    similarity_score DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create exam_registrations table
CREATE TABLE IF NOT EXISTS exam_registrations (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT REFERENCES exams(id),
    user_id BIGINT NOT NULL,
    registration_status VARCHAR(50) DEFAULT 'REGISTERED',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

\c newsdb;

-- Create news table
CREATE TABLE IF NOT EXISTS news (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    field_id BIGINT,
    exam_id BIGINT,
    news_type VARCHAR(50) NOT NULL, -- NEWS, RECRUITMENT
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    expired_at TIMESTAMP,
    approved_by BIGINT,
    useful_vote INTEGER DEFAULT 0,
    interest_vote INTEGER DEFAULT 0,
    company_name VARCHAR(255),
    location VARCHAR(255),
    salary VARCHAR(100),
    experience VARCHAR(100),
    position VARCHAR(100),
    working_hours VARCHAR(100),
    deadline VARCHAR(100),
    application_method TEXT
);

-- Insert sample data for testing
\c questiondb;

-- Insert sample fields
INSERT INTO fields(field_name, description) VALUES 
('Lập trình viên', 'Ngành lập trình phần mềm'),
('Business Analyst', 'Phân tích nghiệp vụ'),
('Tester', 'Kiểm thử phần mềm'),
('DevOps', 'Vận hành và triển khai')
ON CONFLICT DO NOTHING;

-- Insert sample topics
INSERT INTO topics(field_id, topic_name, description) VALUES 
(1, 'ReactJS', 'Thư viện JavaScript cho UI'),
(1, 'VueJS', 'Framework JavaScript cho UI'),
(1, 'Angular', 'Framework TypeScript cho UI'),
(1, 'Spring Boot', 'Framework Java cho backend'),
(1, 'Node.js', 'Runtime JavaScript cho backend'),
(2, 'Requirements Analysis', 'Phân tích yêu cầu'),
(2, 'Process Modeling', 'Mô hình hóa quy trình'),
(3, 'Manual Testing', 'Kiểm thử thủ công'),
(3, 'Automated Testing', 'Kiểm thử tự động'),
(4, 'Docker', 'Containerization'),
(4, 'Kubernetes', 'Container orchestration')
ON CONFLICT DO NOTHING;

-- Insert sample levels
INSERT INTO levels(level_name, description) VALUES 
('Fresher', 'Mới ra trường, 0-1 năm kinh nghiệm'),
('Junior', '1-2 năm kinh nghiệm'),
('Middle', '2-4 năm kinh nghiệm'),
('Senior', '4+ năm kinh nghiệm'),
('Lead', '5+ năm kinh nghiệm, có khả năng dẫn dắt team')
ON CONFLICT DO NOTHING;

-- Insert sample question types
INSERT INTO question_types(question_type_name, description) VALUES 
('Multiple Choice', 'Câu hỏi trắc nghiệm'),
('Open Ended', 'Câu hỏi tự luận'),
('True/False', 'Câu hỏi đúng/sai'),
('Fill in the Blank', 'Câu hỏi điền vào chỗ trống'),
('Code Review', 'Review code'),
('System Design', 'Thiết kế hệ thống')
ON CONFLICT DO NOTHING;

-- Success message
\c postgres;
SELECT 'All databases and tables created successfully!' as message;



