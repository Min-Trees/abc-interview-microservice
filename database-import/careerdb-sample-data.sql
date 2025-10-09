-- =============================================
-- CAREER SERVICE DATABASE - SAMPLE DATA
-- =============================================

-- Connect to careerdb
\c careerdb;

-- Sample career preferences
-- Note: field_id and topic_id reference data from questiondb
INSERT INTO career_preferences(user_id, field_id, topic_id, created_at, updated_at) VALUES 
(3, 1, 1, NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days'),  -- User 3 interested in Programming - ReactJS
(3, 1, 2, NOW() - INTERVAL '25 days', NOW() - INTERVAL '3 days'),  -- User 3 interested in Programming - VueJS
(3, 2, 6, NOW() - INTERVAL '20 days', NOW() - INTERVAL '1 day'),   -- User 3 interested in Business Analysis - Requirements Analysis
(4, 1, 1, NOW() - INTERVAL '15 days', NOW() - INTERVAL '2 days'),  -- User 4 interested in Programming - ReactJS
(4, 1, 3, NOW() - INTERVAL '10 days', NOW() - INTERVAL '1 day'),   -- User 4 interested in Programming - Angular
(5, 1, 4, NOW() - INTERVAL '20 days', NOW() - INTERVAL '3 days'),  -- User 5 interested in Programming - Spring Boot
(5, 1, 5, NOW() - INTERVAL '18 days', NOW() - INTERVAL '2 days'),  -- User 5 interested in Programming - Node.js
(5, 3, 8, NOW() - INTERVAL '12 days', NOW() - INTERVAL '1 day'),   -- User 5 interested in Testing - Manual Testing
(6, 1, 1, NOW() - INTERVAL '25 days', NOW() - INTERVAL '4 days'),  -- User 6 interested in Programming - ReactJS
(6, 1, 4, NOW() - INTERVAL '22 days', NOW() - INTERVAL '3 days'),  -- User 6 interested in Programming - Spring Boot
(6, 4, 10, NOW() - INTERVAL '18 days', NOW() - INTERVAL '2 days'), -- User 6 interested in DevOps - Docker
(6, 4, 11, NOW() - INTERVAL '15 days', NOW() - INTERVAL '1 day'),  -- User 6 interested in DevOps - Kubernetes
(2, 1, 1, NOW() - INTERVAL '40 days', NOW() - INTERVAL '10 days'), -- Recruiter interested in Programming - ReactJS
(2, 1, 2, NOW() - INTERVAL '35 days', NOW() - INTERVAL '8 days'),  -- Recruiter interested in Programming - VueJS
(2, 2, 6, NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days');  -- Recruiter interested in Business Analysis - Requirements Analysis

-- Success message
SELECT 'Career database sample data inserted successfully!' as message;
