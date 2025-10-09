# Database Import Files for Interview Microservice ABC

This directory contains SQL scripts to populate all microservice databases with sample data for testing and development purposes.

## Database Structure

The microservice architecture uses separate databases for each service:

- **authdb** - Authentication service database
- **userdb** - User management service database  
- **careerdb** - Career preferences service database
- **questiondb** - Question management service database
- **examdb** - Exam service database
- **newsdb** - News and recruitment service database

## Import Instructions

### Prerequisites

1. Ensure PostgreSQL is running
2. All databases should be created using `init.sql`
3. All microservices should be stopped before importing data

### Import Order

Import the files in the following order to maintain referential integrity:

```bash
# 1. Import authentication data
psql -h localhost -U postgres -d authdb -f authdb-sample-data.sql

# 2. Import user data
psql -h localhost -U postgres -d userdb -f userdb-sample-data.sql

# 3. Import question data (needed for career references)
psql -h localhost -U postgres -d questiondb -f questiondb-sample-data.sql

# 4. Import career data
psql -h localhost -U postgres -d careerdb -f careerdb-sample-data.sql

# 5. Import exam data
psql -h localhost -U postgres -d examdb -f examdb-sample-data.sql

# 6. Import news data
psql -h localhost -U postgres -d newsdb -f newsdb-sample-data.sql
```

### Quick Import Script

You can also use the provided PowerShell script for Windows:

```powershell
# Run the quick import script
.\quick-import-data.ps1
```

## Sample Data Overview

### Auth Database (authdb)
- **Roles**: USER, RECRUITER, ADMIN
- **Users**: 4 sample users with different roles
- **Passwords**: All users have password 'password123' (BCrypt hashed)

### User Database (userdb)
- **Users**: 6 detailed user profiles with different ELO scores and ranks
- **ELO History**: Sample ELO score changes and activities
- **User Status**: Mix of ACTIVE and PENDING users

### Career Database (careerdb)
- **Career Preferences**: 15 sample career preferences linking users to fields and topics
- **References**: Links to questiondb for field and topic data

### Question Database (questiondb)
- **Fields**: 6 programming and tech fields
- **Topics**: 25 topics across different fields
- **Levels**: 6 experience levels from Fresher to Architect
- **Question Types**: 8 different question types
- **Questions**: 10 sample questions with various statuses
- **Answers**: 10 sample answers with voting data

### Exam Database (examdb)
- **Exams**: 6 sample exams (TECHNICAL, BEHAVIORAL types)
- **Exam Questions**: Links between exams and questions
- **Results**: 8 sample exam results with scores and feedback
- **User Answers**: 10 sample user answers
- **Registrations**: 10 exam registrations (including 1 cancelled)

### News Database (newsdb)
- **News Articles**: 6 technical news articles
- **Recruitment Posts**: 7 job postings across different fields
- **Status Mix**: PUBLISHED, PENDING, APPROVED statuses
- **Voting Data**: Sample useful and interest votes

## Test Users

### Admin User
- **Email**: admin@example.com
- **Password**: password123
- **Role**: ADMIN
- **Status**: ACTIVE

### Recruiter User
- **Email**: recruiter@example.com
- **Password**: password123
- **Role**: RECRUITER
- **Status**: ACTIVE

### Regular Users
- **Email**: user@example.com
- **Password**: password123
- **Role**: USER
- **Status**: ACTIVE
- **ELO Score**: 1200 (BRONZE)

- **Email**: test@example.com
- **Password**: password123
- **Role**: USER
- **Status**: PENDING
- **ELO Score**: 800 (NEWBIE)

## Data Relationships

The sample data maintains proper relationships:

- Users have ELO scores and history
- Career preferences link users to fields and topics
- Questions belong to topics, fields, levels, and question types
- Exams contain questions and have results
- News articles can be linked to fields and exams
- All foreign key relationships are maintained

## Notes

- All timestamps are relative to the current time
- Passwords are properly hashed using BCrypt
- Sample data includes realistic content in both English and Vietnamese
- Voting and scoring data provides realistic test scenarios
- Some data has PENDING status for testing approval workflows

## Troubleshooting

If you encounter foreign key constraint errors:

1. Ensure all databases are created first
2. Import in the correct order as specified above
3. Check that questiondb data is imported before careerdb
4. Verify that all referenced IDs exist in the respective tables

## Cleanup

To remove all sample data:

```sql
-- Connect to each database and truncate tables
\c authdb;
TRUNCATE TABLE users CASCADE;
TRUNCATE TABLE roles CASCADE;

\c userdb;
TRUNCATE TABLE elo_history CASCADE;
TRUNCATE TABLE users CASCADE;
TRUNCATE TABLE roles CASCADE;

\c careerdb;
TRUNCATE TABLE career_preferences CASCADE;

\c questiondb;
TRUNCATE TABLE answers CASCADE;
TRUNCATE TABLE questions CASCADE;
TRUNCATE TABLE question_types CASCADE;
TRUNCATE TABLE levels CASCADE;
TRUNCATE TABLE topics CASCADE;
TRUNCATE TABLE fields CASCADE;

\c examdb;
TRUNCATE TABLE user_answers CASCADE;
TRUNCATE TABLE exam_registrations CASCADE;
TRUNCATE TABLE results CASCADE;
TRUNCATE TABLE exam_questions CASCADE;
TRUNCATE TABLE exams CASCADE;

\c newsdb;
TRUNCATE TABLE news CASCADE;
```
