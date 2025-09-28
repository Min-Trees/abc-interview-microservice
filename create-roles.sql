-- Script to create roles in the database
-- This will create the necessary roles for the Interview Microservice ABC system

-- Create roles table if not exists
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default roles
INSERT INTO roles (name, description) VALUES 
('USER', 'Regular user with basic permissions'),
('ADMIN', 'Administrator with full system access'),
('RECRUITER', 'Recruiter with hiring and management permissions')
ON CONFLICT (name) DO NOTHING;

-- Create users table if not exists
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role_id BIGINT REFERENCES roles(id),
    date_of_birth DATE,
    address TEXT,
    is_studying BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    elo_score INTEGER DEFAULT 1000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create test users
INSERT INTO users (email, password, full_name, role_id, date_of_birth, address, is_studying, status, elo_score) VALUES 
('testuser1@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Test User 1', 1, '1995-01-15', '123 Main Street, Ho Chi Minh City', false, 'ACTIVE', 1000),
('admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Admin User', 2, '1990-05-20', '456 Admin Street, Ho Chi Minh City', false, 'ACTIVE', 1500),
('recruiter@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Recruiter User', 3, '1988-12-10', '789 Recruiter Street, Ho Chi Minh City', false, 'ACTIVE', 1200)
ON CONFLICT (email) DO NOTHING;

-- Create career_preferences table
CREATE TABLE IF NOT EXISTS career_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    preferred_fields TEXT[],
    experience_level VARCHAR(20),
    salary_expectation INTEGER,
    location_preference VARCHAR(255),
    work_type VARCHAR(20),
    skills TEXT[],
    interests TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create fields table
CREATE TABLE IF NOT EXISTS fields (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create topics table
CREATE TABLE IF NOT EXISTS topics (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    field_id BIGINT REFERENCES fields(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create levels table
CREATE TABLE IF NOT EXISTS levels (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    min_score INTEGER DEFAULT 0,
    max_score INTEGER DEFAULT 1000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create question_types table
CREATE TABLE IF NOT EXISTS question_types (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_multiple_choice BOOLEAN DEFAULT FALSE,
    is_open_ended BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create questions table
CREATE TABLE IF NOT EXISTS questions (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    difficulty VARCHAR(20),
    topic_id BIGINT REFERENCES topics(id),
    level_id BIGINT REFERENCES levels(id),
    question_type_id BIGINT REFERENCES question_types(id),
    created_by BIGINT REFERENCES users(id),
    is_multiple_choice BOOLEAN DEFAULT FALSE,
    is_open_ended BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'PENDING',
    approved_by BIGINT REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create question_options table
CREATE TABLE IF NOT EXISTS question_options (
    id BIGSERIAL PRIMARY KEY,
    question_id BIGINT REFERENCES questions(id),
    content TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create answers table
CREATE TABLE IF NOT EXISTS answers (
    id BIGSERIAL PRIMARY KEY,
    question_id BIGINT REFERENCES questions(id),
    content TEXT NOT NULL,
    is_sample BOOLEAN DEFAULT FALSE,
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create exams table
CREATE TABLE IF NOT EXISTS exams (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    exam_type VARCHAR(20),
    duration INTEGER,
    max_attempts INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_by BIGINT REFERENCES users(id),
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create exam_questions table
CREATE TABLE IF NOT EXISTS exam_questions (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT REFERENCES exams(id),
    question_id BIGINT REFERENCES questions(id),
    order_index INTEGER DEFAULT 0,
    points INTEGER DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create exam_registrations table
CREATE TABLE IF NOT EXISTS exam_registrations (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT REFERENCES exams(id),
    user_id BIGINT REFERENCES users(id),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'REGISTERED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create exam_answers table
CREATE TABLE IF NOT EXISTS exam_answers (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT REFERENCES exams(id),
    question_id BIGINT REFERENCES questions(id),
    user_id BIGINT REFERENCES users(id),
    answer_text TEXT,
    is_correct BOOLEAN,
    time_spent INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create exam_results table
CREATE TABLE IF NOT EXISTS exam_results (
    id BIGSERIAL PRIMARY KEY,
    exam_id BIGINT REFERENCES exams(id),
    user_id BIGINT REFERENCES users(id),
    score INTEGER DEFAULT 0,
    total_score INTEGER DEFAULT 0,
    time_spent INTEGER DEFAULT 0,
    is_passed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create news table
CREATE TABLE IF NOT EXISTS news (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    news_type VARCHAR(20),
    field_id BIGINT REFERENCES fields(id),
    created_by BIGINT REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'PENDING',
    approved_by BIGINT REFERENCES users(id),
    approved_at TIMESTAMP,
    published_at TIMESTAMP,
    tags TEXT[],
    votes_up INTEGER DEFAULT 0,
    votes_down INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create recruitments table
CREATE TABLE IF NOT EXISTS recruitments (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    news_type VARCHAR(20) DEFAULT 'RECRUITMENT',
    field_id BIGINT REFERENCES fields(id),
    created_by BIGINT REFERENCES users(id),
    company_name VARCHAR(255),
    location VARCHAR(255),
    salary VARCHAR(100),
    requirements TEXT[],
    status VARCHAR(20) DEFAULT 'PENDING',
    approved_by BIGINT REFERENCES users(id),
    approved_at TIMESTAMP,
    published_at TIMESTAMP,
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO fields (name, description) VALUES 
('Computer Science', 'Computer Science and Information Technology'),
('Data Science', 'Data Science and Analytics'),
('Software Engineering', 'Software Development and Engineering')
ON CONFLICT DO NOTHING;

INSERT INTO topics (name, description, field_id) VALUES 
('Data Structures and Algorithms', 'Fundamental data structures and algorithmic problem solving', 1),
('Machine Learning', 'Machine learning algorithms and applications', 2),
('Web Development', 'Frontend and backend web development', 3)
ON CONFLICT DO NOTHING;

INSERT INTO levels (name, description, min_score, max_score) VALUES 
('Beginner', 'Entry level questions', 0, 500),
('Intermediate', 'Intermediate level questions', 500, 1000),
('Advanced', 'Advanced level questions', 1000, 2000)
ON CONFLICT DO NOTHING;

INSERT INTO question_types (name, description, is_multiple_choice, is_open_ended) VALUES 
('Multiple Choice', 'Multiple choice questions', true, false),
('Open Ended', 'Open ended questions', false, true),
('True/False', 'True or false questions', true, false)
ON CONFLICT DO NOTHING;

-- Display created data
SELECT 'Roles created:' as info;
SELECT * FROM roles;

SELECT 'Users created:' as info;
SELECT id, email, full_name, role_id, status FROM users;

SELECT 'Fields created:' as info;
SELECT * FROM fields;

SELECT 'Topics created:' as info;
SELECT * FROM topics;

SELECT 'Levels created:' as info;
SELECT * FROM levels;

SELECT 'Question Types created:' as info;
SELECT * FROM question_types;
