#!/bin/bash

# Test API Script for Interview Microservice ABC
# This script tests all services and APIs using curl

BASE_URL="http://localhost:8080"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TOTAL=0
PASSED=0
FAILED=0

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to test API endpoint
test_api() {
    local name=$1
    local method=$2
    local url=$3
    local data=$4
    local expected_status=$5
    
    TOTAL=$((TOTAL + 1))
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method -H "Content-Type: application/json" -d "$data" "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$url")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq "$expected_status" ]; then
        print_color $GREEN "✅ $name"
        PASSED=$((PASSED + 1))
    else
        print_color $RED "❌ $name - HTTP $http_code"
        FAILED=$((FAILED + 1))
    fi
}

# Test health checks
print_color $BLUE "🔍 Testing Health Checks..."
test_api "Gateway Health" "GET" "http://localhost:8080/actuator/health" "" 200
test_api "Auth Service Health" "GET" "http://localhost:8081/actuator/health" "" 200
test_api "User Service Health" "GET" "http://localhost:8082/actuator/health" "" 200
test_api "Career Service Health" "GET" "http://localhost:8084/actuator/health" "" 200
test_api "Question Service Health" "GET" "http://localhost:8085/actuator/health" "" 200
test_api "Exam Service Health" "GET" "http://localhost:8086/actuator/health" "" 200
test_api "News Service Health" "GET" "http://localhost:8087/actuator/health" "" 200
test_api "NLP Service Health" "GET" "http://localhost:8088/health" "" 200

# Test authentication
print_color $BLUE "🔐 Testing Authentication..."
test_api "User Login" "POST" "$BASE_URL/auth/login" '{"email":"test@example.com","password":"password123"}' 200

# Test user service
print_color $BLUE "👤 Testing User Service..."
test_api "User Registration" "POST" "$BASE_URL/users/register" '{"email":"testuser@example.com","password":"password123","firstName":"Test","lastName":"User","role":"USER"}' 200

# Test question service
print_color $BLUE "❓ Testing Question Service..."
test_api "Create Field" "POST" "$BASE_URL/fields" '{"name":"Computer Science","description":"Computer Science field"}' 200
test_api "Create Topic" "POST" "$BASE_URL/topics" '{"name":"Data Structures","description":"Data Structures and Algorithms","fieldId":1}' 200

# Test exam service
print_color $BLUE "📝 Testing Exam Service..."
test_api "Create Exam" "POST" "$BASE_URL/exams" '{"title":"Java Programming Test","description":"Test your Java programming skills","examType":"TECHNICAL","duration":60,"maxAttempts":3,"isActive":true,"createdBy":1}' 200

# Test career service
print_color $BLUE "🎯 Testing Career Service..."
test_api "Create Career Preference" "POST" "$BASE_URL/career" '{"userId":1,"preferredFields":["Software Engineering","Data Science"],"experienceLevel":"INTERMEDIATE","salaryExpectation":50000,"locationPreference":"Ho Chi Minh City","workType":"FULL_TIME","skills":["Java","Spring Boot"],"interests":["Web Development"]}' 200

# Test news service
print_color $BLUE "📰 Testing News Service..."
test_api "Create News" "POST" "$BASE_URL/news" '{"title":"New Job Opportunities","content":"Exciting new job opportunities...","newsType":"JOB_OPPORTUNITY","fieldId":1,"createdBy":1,"tags":["tech","jobs"]}' 200

# Test NLP service
print_color $BLUE "🤖 Testing NLP Service..."
test_api "Check Similarity" "POST" "$BASE_URL/questions/similarity/check" '{"question_text":"What is machine learning?","exclude_id":1}' 200
test_api "Grade Essay" "POST" "$BASE_URL/grading/essay" '{"question":"Explain machine learning","answer":"Machine learning is a subset of AI...","max_score":100}' 200

# Show results
print_color $BLUE "📊 Test Results Summary:"
print_color $YELLOW "Total Tests: $TOTAL"
print_color $GREEN "Passed: $PASSED"
print_color $RED "Failed: $FAILED"

if [ $FAILED -eq 0 ]; then
    print_color $GREEN "🎉 All tests passed! System is working correctly."
    exit 0
else
    print_color $YELLOW "⚠️  Some tests failed. Please check the services."
    exit 1
fi
