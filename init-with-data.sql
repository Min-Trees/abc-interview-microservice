-- 🗄️ INITIALIZE ALL DATABASES WITH FULL SAMPLE DATA
-- Interview Microservice ABC - Complete Database Setup
-- This script creates databases, tables, and inserts comprehensive sample data

-- =============================================
-- CREATE DATABASES
-- =============================================
CREATE DATABASE authdb;
CREATE DATABASE userdb;
CREATE DATABASE careerdb;
CREATE DATABASE questiondb;
CREATE DATABASE examdb;
CREATE DATABASE newsdb;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE authdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE userdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE careerdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE questiondb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE examdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE newsdb TO postgres;

-- =============================================
-- AUTH SERVICE DATABASE
-- =============================================
\c authdb;

-- Create roles table
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Insert roles
INSERT INTO roles(role_name, description) VALUES 
('USER', 'Role cho sinh viên/người tìm việc'),
('RECRUITER', 'Role cho nhà tuyển dụng'),
('ADMIN', 'Role cho quản trị viên')
ON CONFLICT (role_name) DO NOTHING;

-- =============================================
-- USER SERVICE DATABASE
-- =============================================
\c userdb;

-- Create roles table
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

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

-- Insert roles
INSERT INTO roles(role_name, description) VALUES 
('USER', 'Role cho sinh viên/người tìm việc'),
('RECRUITER', 'Role cho nhà tuyển dụng'),
('ADMIN', 'Role cho quản trị viên')
ON CONFLICT (role_name) DO NOTHING;

-- Insert sample users (password is 'password123' hashed with BCrypt)
INSERT INTO users(role_id, email, password, full_name, date_of_birth, address, status, is_studying, elo_score, elo_rank, verify_token, created_at) VALUES 
(3, 'admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Admin User', '1985-01-15', '123 Admin Street, Ho Chi Minh City', 'ACTIVE', false, 0, 'NEWBIE', NULL, NOW()),
(2, 'recruiter@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Recruiter User', '1988-03-20', '456 Recruiter Avenue, Hanoi', 'ACTIVE', false, 0, 'NEWBIE', NULL, NOW()),
(1, 'user@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Nguyễn Văn A', '1995-06-10', '789 User Lane, Da Nang', 'ACTIVE', true, 1200, 'BRONZE', NULL, NOW()),
(1, 'test@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Test User', '1998-12-05', '321 Test Road, Can Tho', 'PENDING', true, 800, 'NEWBIE', 'sample-verify-token-123', NOW()),
(1, 'student@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Trần Thị B', '2000-08-15', '654 Student Street, Hue', 'ACTIVE', true, 950, 'NEWBIE', NULL, NOW()),
(1, 'developer@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Lê Văn C', '1992-04-22', '987 Developer Boulevard, Hai Phong', 'ACTIVE', false, 1500, 'SILVER', NULL, NOW()),
(1, 'newbie@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Phạm Thị D', '1999-11-30', '147 Newbie Street, Nha Trang', 'ACTIVE', true, 500, 'NEWBIE', NULL, NOW()),
(1, 'expert@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', 'Hoàng Văn E', '1990-02-14', '258 Expert Avenue, Vung Tau', 'ACTIVE', false, 2100, 'GOLD', NULL, NOW())
ON CONFLICT (email) DO NOTHING;

-- Insert ELO history
INSERT INTO elo_history(user_id, action, points, description, created_at) VALUES 
(3, 'EXAM_COMPLETED', 50, 'Hoàn thành bài thi ReactJS', NOW() - INTERVAL '2 days'),
(3, 'QUESTION_APPROVED', 20, 'Câu hỏi được admin duyệt', NOW() - INTERVAL '1 day'),
(3, 'ANSWER_VOTED_UP', 5, 'Câu trả lời nhận vote tích cực', NOW() - INTERVAL '12 hours'),
(5, 'EXAM_COMPLETED', 30, 'Hoàn thành bài thi cơ bản', NOW() - INTERVAL '3 days'),
(5, 'QUESTION_CREATED', 10, 'Tạo câu hỏi mới', NOW() - INTERVAL '1 day'),
(6, 'EXAM_COMPLETED', 100, 'Hoàn thành bài thi nâng cao', NOW() - INTERVAL '5 days'),
(6, 'QUESTION_APPROVED', 25, 'Câu hỏi chất lượng cao được duyệt', NOW() - INTERVAL '2 days'),
(6, 'ANSWER_MARKED_SAMPLE', 15, 'Câu trả lời được đánh dấu mẫu', NOW() - INTERVAL '1 day'),
(7, 'ACCOUNT_CREATED', 50, 'Tạo tài khoản mới', NOW() - INTERVAL '1 day'),
(8, 'EXAM_COMPLETED', 150, 'Hoàn thành bài thi khó', NOW() - INTERVAL '4 days'),
(8, 'QUESTION_APPROVED', 30, 'Nhiều câu hỏi được duyệt', NOW() - INTERVAL '3 days');

-- =============================================
-- QUESTION SERVICE DATABASE
-- =============================================
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

-- Insert fields
INSERT INTO fields(field_name, description) VALUES 
('Lập trình viên', 'Ngành lập trình phần mềm'),
('Business Analyst', 'Phân tích nghiệp vụ'),
('Tester', 'Kiểm thử phần mềm'),
('DevOps', 'Vận hành và triển khai'),
('Data Science', 'Khoa học dữ liệu'),
('UI/UX Design', 'Thiết kế giao diện người dùng')
ON CONFLICT DO NOTHING;

-- Insert topics
INSERT INTO topics(field_id, topic_name, description) VALUES 
(1, 'ReactJS', 'Thư viện JavaScript cho UI'),
(1, 'VueJS', 'Framework JavaScript cho UI'),
(1, 'Angular', 'Framework TypeScript cho UI'),
(1, 'Spring Boot', 'Framework Java cho backend'),
(1, 'Node.js', 'Runtime JavaScript cho backend'),
(1, 'Python', 'Ngôn ngữ lập trình Python'),
(1, 'Java', 'Ngôn ngữ lập trình Java'),
(1, 'JavaScript', 'Ngôn ngữ lập trình JavaScript'),
(2, 'Requirements Analysis', 'Phân tích yêu cầu'),
(2, 'Process Modeling', 'Mô hình hóa quy trình'),
(2, 'Stakeholder Management', 'Quản lý các bên liên quan'),
(3, 'Manual Testing', 'Kiểm thử thủ công'),
(3, 'Automated Testing', 'Kiểm thử tự động'),
(3, 'Performance Testing', 'Kiểm thử hiệu suất'),
(3, 'Security Testing', 'Kiểm thử bảo mật'),
(4, 'Docker', 'Containerization'),
(4, 'Kubernetes', 'Container orchestration'),
(4, 'AWS', 'Amazon Web Services'),
(4, 'CI/CD', 'Continuous Integration/Deployment'),
(5, 'Machine Learning', 'Học máy'),
(5, 'Data Analysis', 'Phân tích dữ liệu'),
(5, 'Big Data', 'Dữ liệu lớn'),
(6, 'UI Design', 'Thiết kế giao diện'),
(6, 'UX Research', 'Nghiên cứu trải nghiệm người dùng'),
(6, 'Prototyping', 'Tạo mẫu thử nghiệm')
ON CONFLICT DO NOTHING;

-- Insert levels
INSERT INTO levels(level_name, description) VALUES 
('Fresher', 'Mới ra trường, 0-1 năm kinh nghiệm'),
('Junior', '1-2 năm kinh nghiệm'),
('Middle', '2-4 năm kinh nghiệm'),
('Senior', '4+ năm kinh nghiệm'),
('Lead', '5+ năm kinh nghiệm, có khả năng dẫn dắt team'),
('Architect', '7+ năm kinh nghiệm, thiết kế hệ thống')
ON CONFLICT DO NOTHING;

-- Insert question types
INSERT INTO question_types(question_type_name, description) VALUES 
('Multiple Choice', 'Câu hỏi trắc nghiệm'),
('Open Ended', 'Câu hỏi tự luận'),
('True/False', 'Câu hỏi đúng/sai'),
('Fill in the Blank', 'Câu hỏi điền vào chỗ trống'),
('Code Review', 'Review code'),
('System Design', 'Thiết kế hệ thống'),
('Algorithm', 'Thuật toán'),
('Database Design', 'Thiết kế cơ sở dữ liệu')
ON CONFLICT DO NOTHING;

-- Insert questions
INSERT INTO questions(user_id, topic_id, field_id, level_id, question_type_id, question_content, question_answer, similarity_score, status, language, created_at, approved_at, approved_by, useful_vote, unuseful_vote) VALUES 
(3, 1, 1, 2, 1, 'ReactJS là gì và các tính năng chính của nó?', 'ReactJS là thư viện JavaScript để xây dựng giao diện người dùng. Các tính năng: Virtual DOM, Component-based, JSX, One-way data binding, React Hooks.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days', 1, 15, 2),
(3, 1, 1, 2, 2, 'Giải thích khái niệm Virtual DOM trong ReactJS', 'Virtual DOM là bản sao JavaScript của DOM thật. React tạo virtual copy, thực hiện thay đổi trên đó, sau đó cập nhật hiệu quả vào DOM thật chỉ ở những chỗ thay đổi.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '8 days', NOW() - INTERVAL '7 days', 1, 12, 1),
(4, 2, 1, 1, 1, 'VueJS là gì và khác gì so với ReactJS?', 'VueJS là framework JavaScript tiến bộ. Khác biệt chính: Vue dùng templates vs JSX, Vue có two-way binding vs React one-way, Vue dễ học hơn, React có ecosystem lớn hơn.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', 1, 8, 0),
(5, 4, 1, 3, 2, 'Mô tả tính năng auto-configuration của Spring Boot', 'Spring Boot auto-configuration tự động cấu hình ứng dụng Spring dựa trên dependencies. Sử dụng @EnableAutoConfiguration và có thể tùy chỉnh qua application.properties.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', 1, 20, 1),
(6, 1, 1, 4, 6, 'Thiết kế kiến trúc hệ thống e-commerce có khả năng mở rộng', 'Hệ thống e-commerce có khả năng mở rộng cần: Load balancers, CDN, Kiến trúc Microservices, Database sharding, Caching layers (Redis), Message queues, API Gateway, và hệ thống giám sát.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', 1, 25, 0),
(3, 9, 2, 2, 2, 'Requirements Analysis là gì và tại sao quan trọng?', 'Requirements Analysis là quá trình xác định kỳ vọng của người dùng cho sản phẩm mới. Quan trọng vì giúp đảm bảo sản phẩm cuối đáp ứng nhu cầu và giảm chi phí phát triển.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', 1, 10, 1),
(4, 13, 3, 1, 1, 'Phân biệt unit testing và integration testing?', 'Unit testing kiểm tra từng component riêng lẻ, integration testing kiểm tra các component làm việc cùng nhau. Unit test nhanh và tập trung hơn, integration test phát hiện lỗi giao tiếp.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', 1, 6, 0),
(5, 16, 4, 2, 2, 'Giải thích Docker containers và lợi ích của chúng', 'Docker containers là đơn vị nhẹ, di động đóng gói ứng dụng và dependencies. Lợi ích: Tính nhất quán giữa các môi trường, hiệu quả tài nguyên, dễ mở rộng, triển khai đơn giản.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '1 day', NOW() - INTERVAL '12 hours', 1, 18, 2),
(6, 20, 5, 3, 2, 'Machine Learning là gì và cho ví dụ ứng dụng', 'Machine Learning là nhánh của AI cho phép máy tính học từ dữ liệu. Ứng dụng: Nhận dạng hình ảnh, hệ thống gợi ý, phát hiện gian lận, xử lý ngôn ngữ tự nhiên.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '12 hours', NOW() - INTERVAL '6 hours', 1, 14, 1),
(3, 1, 1, 2, 1, 'React Hooks là gì và kể tên một số hooks thường dùng?', 'React Hooks là các functions cho phép sử dụng state và tính năng React trong functional components. Hooks phổ biến: useState, useEffect, useContext, useReducer, useCallback.', 0.0, 'PENDING', 'vi', NOW() - INTERVAL '2 hours', NULL, NULL, 0, 0),
(7, 8, 1, 1, 1, 'JavaScript là ngôn ngữ gì? Synchronous hay Asynchronous?', 'JavaScript là ngôn ngữ lập trình high-level, interpreted. Về bản chất là synchronous và single-threaded nhưng có khả năng xử lý asynchronous thông qua callbacks, promises, async/await.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', 1, 9, 1),
(8, 7, 1, 4, 7, 'Giải thích thuật toán Binary Search và độ phức tạp', 'Binary Search là thuật toán tìm kiếm trên mảng đã sắp xếp bằng cách chia đôi không gian tìm kiếm. Độ phức tạp: O(log n) thời gian, O(1) không gian.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', 1, 22, 0),
(3, 4, 1, 3, 2, 'Dependency Injection trong Spring Boot hoạt động như thế nào?', 'DI trong Spring Boot cho phép container quản lý và inject dependencies vào objects. Sử dụng @Autowired, @Component, @Service. Spring tự động tạo và inject beans theo cấu hình.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', 1, 17, 1),
(6, 19, 4, 4, 6, 'Thiết kế CI/CD pipeline cho ứng dụng microservices', 'CI/CD pipeline cho microservices: Source control (Git), Build (Maven/Gradle), Unit tests, Integration tests, Docker image build, Push to registry, Deploy to K8s, Monitoring & Rollback.', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', 1, 28, 2),
(5, 14, 3, 2, 2, 'Performance Testing là gì? Các loại performance test?', 'Performance Testing kiểm tra hiệu suất hệ thống. Các loại: Load Testing (kiểm tra tải), Stress Testing (kiểm tra giới hạn), Spike Testing (tăng đột ngột), Endurance Testing (chạy lâu dài).', 0.0, 'APPROVED', 'vi', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', 1, 11, 0);

-- Insert answers
INSERT INTO answers(user_id, question_id, question_type_id, answer_content, is_correct, similarity_score, useful_vote, unuseful_vote, is_sample_answer, order_number, created_at) VALUES 
(3, 1, 1, 'ReactJS là thư viện JavaScript để xây dựng giao diện. Tính năng: Virtual DOM, Component-based, JSX, One-way binding, Hooks.', true, 0.0, 8, 1, true, 1, NOW() - INTERVAL '9 days'),
(4, 1, 1, 'ReactJS là thư viện frontend giúp tạo UI tương tác. Tính năng chính: Virtual DOM cho hiệu suất, components tái sử dụng, lập trình declarative.', true, 0.0, 5, 0, false, 2, NOW() - INTERVAL '8 days'),
(5, 1, 1, 'React là thư viện xây dựng web app. Dùng JSX syntax và có state management, component lifecycle.', true, 0.0, 3, 1, false, 3, NOW() - INTERVAL '7 days'),
(3, 2, 2, 'Virtual DOM là bản sao JavaScript của DOM thật. React tạo virtual copy, thay đổi trên đó, sau đó update hiệu quả vào DOM thật.', true, 0.0, 10, 0, true, 1, NOW() - INTERVAL '6 days'),
(4, 2, 2, 'Virtual DOM như bản copy nhẹ của DOM thật mà React dùng để tối ưu updates và cải thiện rendering performance.', true, 0.0, 4, 0, false, 2, NOW() - INTERVAL '5 days'),
(6, 3, 1, 'VueJS là progressive framework JavaScript. Khác biệt: Vue dùng templates vs JSX, two-way binding vs one-way, dễ học hơn, React có ecosystem lớn.', true, 0.0, 6, 0, true, 1, NOW() - INTERVAL '4 days'),
(3, 4, 2, 'Spring Boot auto-configuration tự động cấu hình ứng dụng dựa trên dependencies. Dùng @EnableAutoConfiguration, tùy chỉnh qua application.properties.', true, 0.0, 12, 1, true, 1, NOW() - INTERVAL '3 days'),
(5, 4, 2, 'Auto-configuration trong Spring Boot giảm boilerplate code bằng cách tự động setup beans dựa trên classpath dependencies và properties.', true, 0.0, 7, 0, false, 2, NOW() - INTERVAL '2 days'),
(6, 5, 6, 'Hệ thống e-commerce mở rộng cần: Load balancers, CDN, Microservices, Database sharding, Caching (Redis), Message queues, API Gateway, monitoring.', true, 0.0, 15, 0, true, 1, NOW() - INTERVAL '1 day'),
(3, 6, 2, 'Requirements Analysis xác định kỳ vọng người dùng. Quan trọng vì đảm bảo sản phẩm đáp ứng nhu cầu và giảm chi phí phát triển.', true, 0.0, 8, 0, true, 1, NOW() - INTERVAL '12 hours'),
(7, 11, 1, 'JavaScript vừa synchronous vừa asynchronous. Single-threaded nhưng có Event Loop, callbacks, promises để xử lý async.', true, 0.0, 7, 0, true, 1, NOW() - INTERVAL '2 days'),
(8, 12, 7, 'Binary Search: Chia đôi mảng sắp xếp, so sánh giá trị giữa. O(log n) time complexity, hiệu quả cho dữ liệu lớn.', true, 0.0, 16, 1, true, 1, NOW() - INTERVAL '3 days'),
(6, 13, 2, 'DI trong Spring Boot: Container tự động tạo và inject beans. Dùng @Autowired, @Component. Giảm coupling, dễ test.', true, 0.0, 13, 0, true, 1, NOW() - INTERVAL '4 days'),
(8, 14, 6, 'CI/CD pipeline: Git → Build → Test → Docker → Registry → K8s Deploy → Monitor. Tự động hóa toàn bộ quy trình release.', true, 0.0, 20, 1, true, 1, NOW() - INTERVAL '5 days'),
(5, 15, 2, 'Performance Testing: Load (tải thường), Stress (quá tải), Spike (tăng đột ngột), Endurance (chạy lâu). Đảm bảo hệ thống ổn định.', true, 0.0, 9, 0, true, 1, NOW() - INTERVAL '2 days');

-- =============================================
-- CAREER SERVICE DATABASE
-- =============================================
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

-- Insert career preferences
INSERT INTO career_preferences(user_id, field_id, topic_id, created_at, updated_at) VALUES 
(3, 1, 1, NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days'),
(3, 1, 2, NOW() - INTERVAL '25 days', NOW() - INTERVAL '3 days'),
(3, 2, 9, NOW() - INTERVAL '20 days', NOW() - INTERVAL '1 day'),
(4, 1, 1, NOW() - INTERVAL '15 days', NOW() - INTERVAL '2 days'),
(4, 1, 3, NOW() - INTERVAL '10 days', NOW() - INTERVAL '1 day'),
(5, 1, 4, NOW() - INTERVAL '20 days', NOW() - INTERVAL '3 days'),
(5, 1, 5, NOW() - INTERVAL '18 days', NOW() - INTERVAL '2 days'),
(5, 3, 12, NOW() - INTERVAL '12 days', NOW() - INTERVAL '1 day'),
(6, 1, 1, NOW() - INTERVAL '25 days', NOW() - INTERVAL '4 days'),
(6, 1, 4, NOW() - INTERVAL '22 days', NOW() - INTERVAL '3 days'),
(6, 4, 16, NOW() - INTERVAL '18 days', NOW() - INTERVAL '2 days'),
(6, 4, 17, NOW() - INTERVAL '15 days', NOW() - INTERVAL '1 day'),
(2, 1, 1, NOW() - INTERVAL '40 days', NOW() - INTERVAL '10 days'),
(2, 1, 2, NOW() - INTERVAL '35 days', NOW() - INTERVAL '8 days'),
(2, 2, 9, NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days'),
(7, 1, 8, NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
(7, 6, 23, NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
(8, 5, 20, NOW() - INTERVAL '10 days', NOW() - INTERVAL '3 days'),
(8, 5, 21, NOW() - INTERVAL '10 days', NOW() - INTERVAL '3 days'),
(8, 1, 6, NOW() - INTERVAL '8 days', NOW() - INTERVAL '2 days');

-- =============================================
-- EXAM SERVICE DATABASE
-- =============================================
\c examdb;

-- Create exams table
CREATE TABLE IF NOT EXISTS exams (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    exam_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    position VARCHAR(100),
    topics TEXT,
    question_types TEXT,
    question_count INTEGER,
    duration INTEGER,
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

-- Insert exams
INSERT INTO exams(user_id, exam_type, title, position, topics, question_types, question_count, duration, start_time, end_time, status, language, created_at, created_by) VALUES 
(1, 'TECHNICAL', 'Đánh giá ReactJS Developer', 'Frontend Developer', '[1,2,3]', '[1,2]', 20, 60, NOW() + INTERVAL '7 days', NOW() + INTERVAL '7 days 1 hour', 'PUBLISHED', 'vi', NOW() - INTERVAL '5 days', 1),
(1, 'TECHNICAL', 'Phỏng vấn Java Spring Boot', 'Backend Developer', '[4,7]', '[1,2,6]', 25, 90, NOW() + INTERVAL '10 days', NOW() + INTERVAL '10 days 1.5 hours', 'PUBLISHED', 'vi', NOW() - INTERVAL '4 days', 1),
(2, 'TECHNICAL', 'Kiểm tra Full Stack Developer', 'Full Stack Developer', '[1,2,4,5]', '[1,2,6]', 30, 120, NOW() + INTERVAL '14 days', NOW() + INTERVAL '14 days 2 hours', 'PUBLISHED', 'vi', NOW() - INTERVAL '3 days', 2),
(1, 'BEHAVIORAL', 'Đánh giá Kỹ năng Mềm', 'Any Position', '[]', '[2]', 10, 30, NOW() + INTERVAL '5 days', NOW() + INTERVAL '5 days 30 minutes', 'DRAFT', 'vi', NOW() - INTERVAL '2 days', 1),
(2, 'TECHNICAL', 'Phỏng vấn DevOps Engineer', 'DevOps Engineer', '[16,17,18,19]', '[1,2,6]', 20, 75, NOW() + INTERVAL '12 days', NOW() + INTERVAL '12 days 1.25 hours', 'PUBLISHED', 'vi', NOW() - INTERVAL '1 day', 2),
(1, 'TECHNICAL', 'Đánh giá Data Science', 'Data Scientist', '[20,21,22]', '[1,2,7]', 25, 90, NOW() + INTERVAL '8 days', NOW() + INTERVAL '8 days 1.5 hours', 'PUBLISHED', 'vi', NOW() - INTERVAL '6 hours', 1),
(2, 'TECHNICAL', 'Test JavaScript Fundamentals', 'Junior Developer', '[8]', '[1,3]', 15, 45, NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days 45 minutes', 'PUBLISHED', 'vi', NOW() - INTERVAL '1 day', 2),
(1, 'TECHNICAL', 'Kiểm tra Python Developer', 'Python Developer', '[6]', '[1,2,7]', 20, 60, NOW() + INTERVAL '9 days', NOW() + INTERVAL '9 days 1 hour', 'PUBLISHED', 'vi', NOW() - INTERVAL '2 days', 1);

-- Insert exam questions
INSERT INTO exam_questions(exam_id, question_id, order_number) VALUES 
(1, 1, 1), (1, 2, 2), (1, 3, 3), (1, 10, 4),
(2, 4, 1), (2, 5, 2), (2, 13, 3),
(3, 1, 1), (3, 4, 2), (3, 5, 3),
(5, 8, 1), (5, 14, 2),
(6, 9, 1), (6, 12, 2),
(7, 11, 1),
(8, 9, 1), (8, 12, 2);

-- Insert results
INSERT INTO results(exam_id, user_id, score, pass_status, feedback, completed_at) VALUES 
(1, 3, 85.5, true, 'Hiểu rõ về ReactJS. Thành thạo component lifecycle và state management.', NOW() - INTERVAL '2 days'),
(1, 4, 72.0, true, 'Nắm vững cơ bản ReactJS. Cần cải thiện về hooks và performance optimization.', NOW() - INTERVAL '1 day'),
(1, 5, 45.0, false, 'Cần học thêm về ReactJS cơ bản. Tập trung vào component architecture và JSX syntax.', NOW() - INTERVAL '12 hours'),
(2, 3, 92.0, true, 'Xuất sắc về Spring Boot. Hiểu sâu auto-configuration và dependency injection.', NOW() - INTERVAL '1 day'),
(2, 6, 78.5, true, 'Tốt về Spring Boot. Hiểu khái niệm core nhưng cần cải thiện tính năng nâng cao.', NOW() - INTERVAL '6 hours'),
(3, 3, 88.0, true, 'Khả năng full-stack tốt. Hiểu rõ cả frontend và backend technologies.', NOW() - INTERVAL '3 days'),
(5, 6, 95.0, true, 'Kiến thức DevOps xuất sắc. Thành thạo containerization và orchestration.', NOW() - INTERVAL '2 days'),
(6, 3, 67.5, true, 'Hiểu tốt về data science. Cần cải thiện về chi tiết implementation.', NOW() - INTERVAL '1 day'),
(7, 7, 58.0, true, 'Nắm được JavaScript cơ bản. Cần practice thêm về async programming.', NOW() - INTERVAL '1 day'),
(2, 8, 96.5, true, 'Kiến thức Spring Boot vượt trội. Architect level understanding.', NOW() - INTERVAL '8 hours');

-- Insert user answers
INSERT INTO user_answers(exam_id, question_id, user_id, answer_content, is_correct, similarity_score, created_at) VALUES 
(1, 1, 3, 'ReactJS là thư viện JavaScript để xây dựng UI với Virtual DOM, components, và JSX.', true, 0.95, NOW() - INTERVAL '2 days'),
(1, 2, 3, 'Virtual DOM là bản sao JavaScript của DOM thật giúp React tối ưu updates và cải thiện performance.', true, 0.92, NOW() - INTERVAL '2 days'),
(1, 3, 3, 'VueJS dùng templates và two-way binding, React dùng JSX và one-way binding.', true, 0.88, NOW() - INTERVAL '2 days'),
(1, 1, 4, 'ReactJS là thư viện frontend tạo interactive UI với components và state management.', true, 0.85, NOW() - INTERVAL '1 day'),
(1, 2, 4, 'Virtual DOM giúp React update browser DOM hiệu quả bằng cách so sánh virtual và real DOM.', true, 0.78, NOW() - INTERVAL '1 day'),
(1, 3, 4, 'VueJS dễ học hơn React và có two-way data binding.', true, 0.82, NOW() - INTERVAL '1 day'),
(1, 1, 5, 'React là thư viện JavaScript cho web development.', false, 0.45, NOW() - INTERVAL '12 hours'),
(1, 2, 5, 'Virtual DOM dùng để styling trong React.', false, 0.30, NOW() - INTERVAL '12 hours'),
(2, 4, 3, 'Spring Boot auto-configuration tự động setup beans dựa trên classpath dependencies và properties.', true, 0.94, NOW() - INTERVAL '1 day'),
(2, 5, 3, 'Hệ thống e-commerce mở rộng cần load balancers, microservices, database sharding, caching, monitoring.', true, 0.91, NOW() - INTERVAL '1 day'),
(7, 11, 7, 'JavaScript là synchronous nhưng có async capabilities với callbacks, promises, async/await.', true, 0.87, NOW() - INTERVAL '1 day'),
(2, 4, 8, 'Spring Boot DI container quản lý lifecycle và inject dependencies tự động. Loose coupling, testable code.', true, 0.97, NOW() - INTERVAL '8 hours'),
(2, 13, 8, 'DI pattern cho phép inversion of control. Spring container tạo và wire beans theo configuration.', true, 0.96, NOW() - INTERVAL '8 hours');

-- Insert exam registrations
INSERT INTO exam_registrations(exam_id, user_id, registration_status, registered_at) VALUES 
(1, 3, 'REGISTERED', NOW() - INTERVAL '3 days'),
(1, 4, 'REGISTERED', NOW() - INTERVAL '2 days'),
(1, 5, 'REGISTERED', NOW() - INTERVAL '1 day'),
(2, 3, 'REGISTERED', NOW() - INTERVAL '2 days'),
(2, 6, 'REGISTERED', NOW() - INTERVAL '1 day'),
(3, 3, 'REGISTERED', NOW() - INTERVAL '4 days'),
(5, 6, 'REGISTERED', NOW() - INTERVAL '3 days'),
(6, 3, 'REGISTERED', NOW() - INTERVAL '2 days'),
(1, 6, 'CANCELLED', NOW() - INTERVAL '2 days'),
(2, 4, 'REGISTERED', NOW() - INTERVAL '1 day'),
(7, 7, 'REGISTERED', NOW() - INTERVAL '2 days'),
(2, 8, 'REGISTERED', NOW() - INTERVAL '1 day'),
(8, 3, 'REGISTERED', NOW() - INTERVAL '3 days'),
(8, 7, 'REGISTERED', NOW() - INTERVAL '2 days'),
(6, 8, 'REGISTERED', NOW() - INTERVAL '1 day');

-- =============================================
-- NEWS SERVICE DATABASE
-- =============================================
\c newsdb;

-- Create news table
CREATE TABLE IF NOT EXISTS news (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    field_id BIGINT,
    exam_id BIGINT,
    news_type VARCHAR(50) NOT NULL,
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

-- Insert news articles
INSERT INTO news(user_id, title, content, field_id, exam_id, news_type, status, created_at, published_at, expired_at, approved_by, useful_vote, interest_vote, company_name, location, salary, experience, position, working_hours, deadline, application_method) VALUES 
(1, 'ReactJS 18 - Các Tính Năng Mới Được Phát Hành', 'ReactJS 18 giới thiệu nhiều tính năng thú vị bao gồm concurrent rendering, automatic batching, và cải thiện performance. Những tính năng này giúp ứng dụng React nhanh hơn và hiệu quả hơn.', 1, NULL, 'NEWS', 'PUBLISHED', NOW() - INTERVAL '5 days', NOW() - INTERVAL '4 days', NULL, 1, 25, 18, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'Spring Boot 3.0 - Cập Nhật Quan Trọng', 'Spring Boot 3.0 mang đến cải tiến đáng kể bao gồm native compilation support, enhanced observability, và tích hợp tốt hơn với Jakarta EE. Release này tập trung vào performance và developer experience.', 1, NULL, 'NEWS', 'PUBLISHED', NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NULL, 1, 20, 15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(1, 'Docker Best Practices cho Production', 'Học các Docker best practices thiết yếu cho production deployments bao gồm security considerations, resource management, và monitoring strategies.', 4, NULL, 'NEWS', 'PUBLISHED', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NULL, 1, 15, 12, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'Machine Learning Trends 2024', 'Khám phá xu hướng machine learning mới nhất bao gồm large language models, computer vision advances, và ethical AI considerations cho năm 2024.', 5, NULL, 'NEWS', 'PUBLISHED', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', NULL, 1, 30, 25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(1, 'API Gateway Design Patterns', 'Hiểu các API Gateway design patterns khác nhau và chiến lược implementation cho kiến trúc microservices.', 1, NULL, 'NEWS', 'PENDING', NOW() - INTERVAL '1 day', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'Database Sharding Strategies', 'Hướng dẫn toàn diện về database sharding strategies để xử lý ứng dụng quy mô lớn và cải thiện performance.', 1, NULL, 'NEWS', 'APPROVED', NOW() - INTERVAL '12 hours', NULL, NULL, 1, 8, 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(1, 'Kubernetes trong Thực Tế', 'Chia sẻ kinh nghiệm triển khai Kubernetes trong môi trường production, từ setup đến scaling và troubleshooting.', 4, NULL, 'NEWS', 'PUBLISHED', NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', NULL, 1, 22, 19, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'Tips Học ReactJS Hiệu Quả', 'Những tips và tricks giúp học ReactJS nhanh và hiệu quả dành cho beginners. Bao gồm resources, learning path, và common pitfalls.', 1, NULL, 'NEWS', 'PUBLISHED', NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NULL, 1, 18, 14, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Insert recruitment posts
INSERT INTO news(user_id, title, content, field_id, exam_id, news_type, status, created_at, published_at, expired_at, approved_by, useful_vote, interest_vote, company_name, location, salary, experience, position, working_hours, deadline, application_method) VALUES 
(2, 'Senior ReactJS Developer - ABC Tech', 'Chúng tôi đang tìm kiếm Senior ReactJS Developer để gia nhập đội ngũ đang phát triển. Bạn sẽ chịu trách nhiệm phát triển và bảo trì các ứng dụng web sử dụng ReactJS, Redux, và công nghệ frontend hiện đại.', 1, 1, 'RECRUITMENT', 'PUBLISHED', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NOW() + INTERVAL '30 days', 1, 12, 35, 'ABC Tech', 'TP. Hồ Chí Minh', '2000-3000 USD', '3-5 năm', 'Senior ReactJS Developer', '9h-18h', '2024-12-31', 'Gửi CV về hr@abctech.com'),
(2, 'Java Spring Boot Developer - XYZ Corp', 'Tham gia đội backend development với vai trò Java Spring Boot Developer. Bạn sẽ làm việc với microservices và RESTful APIs sử dụng Spring Boot, Spring Security và các công nghệ liên quan.', 1, 2, 'RECRUITMENT', 'PUBLISHED', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', NOW() + INTERVAL '25 days', 1, 18, 28, 'XYZ Corp', 'Hà Nội', '1800-2500 USD', '2-4 năm', 'Java Spring Boot Developer', '8h-17h', '2024-12-25', 'Apply qua website: xyzcorp.com/careers'),
(2, 'Full Stack Developer - TechStart', 'Cần Full Stack Developer có thể làm việc với cả frontend và backend. Kinh nghiệm với ReactJS, Node.js, và cloud platforms là bắt buộc.', 1, 3, 'RECRUITMENT', 'PUBLISHED', NOW() - INTERVAL '1 day', NOW() - INTERVAL '12 hours', NOW() + INTERVAL '20 days', 1, 15, 22, 'TechStart', 'Đà Nẵng', '1500-2200 USD', '2-3 năm', 'Full Stack Developer', 'Linh hoạt', '2024-12-20', 'Email: jobs@techstart.vn'),
(2, 'DevOps Engineer - CloudTech', 'Tìm kiếm DevOps Engineer để quản lý cloud infrastructure và CI/CD pipelines. Kinh nghiệm với Docker, Kubernetes, và AWS là thiết yếu.', 4, 5, 'RECRUITMENT', 'PUBLISHED', NOW() - INTERVAL '12 hours', NOW() - INTERVAL '6 hours', NOW() + INTERVAL '15 days', 1, 20, 30, 'CloudTech', 'TP. Hồ Chí Minh', '2200-3000 USD', '3-5 năm', 'DevOps Engineer', '9h-18h', '2024-12-15', 'LinkedIn: CloudTech Careers'),
(2, 'Data Scientist - DataCorp', 'Tham gia đội data science để làm việc trên các dự án machine learning và phân tích dữ liệu. Yêu cầu background mạnh về Python, ML algorithms, và statistical analysis.', 5, 6, 'RECRUITMENT', 'PUBLISHED', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '3 hours', NOW() + INTERVAL '18 days', 1, 25, 40, 'DataCorp', 'Hà Nội', '2500-3500 USD', '4-6 năm', 'Senior Data Scientist', '9h-18h', '2024-12-18', 'Apply tại: datacorp.vn/careers'),
(2, 'UI/UX Designer - DesignStudio', 'Tìm kiếm UI/UX Designer sáng tạo để thiết kế giao diện cho ứng dụng web và mobile. Thành thạo Figma, Adobe Creative Suite, và user research.', 6, NULL, 'RECRUITMENT', 'PENDING', NOW() - INTERVAL '2 hours', NULL, NOW() + INTERVAL '10 days', NULL, 0, 0, 'DesignStudio', 'TP. Hồ Chí Minh', '1200-1800 USD', '2-4 năm', 'UI/UX Designer', '9h-18h', '2024-12-10', 'Portfolio gửi về: design@designstudio.vn'),
(2, 'Business Analyst - FinanceTech', 'Tìm Business Analyst để phân tích yêu cầu nghiệp vụ và làm việc với development teams. Ưu tiên kinh nghiệm trong lĩnh vực tài chính và agile methodologies.', 2, NULL, 'RECRUITMENT', 'APPROVED', NOW() - INTERVAL '1 hour', NULL, NOW() + INTERVAL '12 days', 1, 5, 8, 'FinanceTech', 'TP. Hồ Chí Minh', '1500-2000 USD', '2-3 năm', 'Business Analyst', '8h-17h', '2024-12-12', 'Email: ba@financetech.vn'),
(2, 'Junior Python Developer - AIStart', 'Tuyển Junior Python Developer cho các dự án AI và automation. Cơ hội học hỏi và phát triển trong môi trường startup năng động.', 1, NULL, 'RECRUITMENT', 'PUBLISHED', NOW() - INTERVAL '1 day', NOW() - INTERVAL '20 hours', NOW() + INTERVAL '22 days', 1, 10, 15, 'AIStart', 'Hà Nội', '800-1200 USD', '0-1 năm', 'Junior Python Developer', '9h-18h', '2024-12-28', 'Apply: aistart.vn/careers'),
(2, 'Mobile Developer (Flutter) - MobileHub', 'Cần Mobile Developer chuyên Flutter để phát triển ứng dụng iOS và Android. Kinh nghiệm với state management và native integration.', 1, NULL, 'RECRUITMENT', 'PUBLISHED', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day', NOW() + INTERVAL '20 days', 1, 14, 20, 'MobileHub', 'TP. Hồ Chí Minh', '1600-2400 USD', '2-4 năm', 'Flutter Developer', '9h-18h', '2024-12-22', 'Email: mobile@mobilehub.vn'),
(2, 'QA Automation Engineer - TestPro', 'Tuyển QA Automation Engineer để xây dựng và maintain test automation framework. Selenium, Cypress, hoặc Playwright experience.', 3, NULL, 'RECRUITMENT', 'PUBLISHED', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days', NOW() + INTERVAL '15 days', 1, 8, 12, 'TestPro', 'Đà Nẵng', '1400-2000 USD', '2-3 năm', 'QA Automation Engineer', '8h30-17h30', '2024-12-15', 'LinkedIn: TestPro Company');

-- =============================================
-- SUCCESS MESSAGE
-- =============================================
\c postgres;
SELECT '✅ TẤT CẢ DATABASES VÀ DỮ LIỆU MẪU ĐÃ ĐƯỢC TẠO THÀNH CÔNG!' as message;
SELECT '📊 THỐNG KÊ DỮ LIỆU:' as summary;

\c userdb;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_elo_history FROM elo_history;

\c questiondb;
SELECT COUNT(*) as total_fields FROM fields;
SELECT COUNT(*) as total_topics FROM topics;
SELECT COUNT(*) as total_questions FROM questions;
SELECT COUNT(*) as total_answers FROM answers;

\c careerdb;
SELECT COUNT(*) as total_career_preferences FROM career_preferences;

\c examdb;
SELECT COUNT(*) as total_exams FROM exams;
SELECT COUNT(*) as total_results FROM results;
SELECT COUNT(*) as total_registrations FROM exam_registrations;

\c newsdb;
SELECT COUNT(*) as total_news FROM news WHERE news_type = 'NEWS';
SELECT COUNT(*) as total_recruitments FROM news WHERE news_type = 'RECRUITMENT';

\c postgres;
SELECT '🎉 HỆ THỐNG SẴN SÀNG SỬ DỤNG!' as status;
