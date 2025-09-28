# NLP Service

Natural Language Processing service for the Interview Microservice ABC platform.

## Features

- **Question Similarity Detection**: Check for duplicate or similar questions
- **Essay Grading**: Automated grading of open-ended questions
- **Text Analysis**: Sentiment analysis, keyword extraction, and complexity analysis
- **Integration**: Seamless integration with Question Service and Exam Service

## API Endpoints

### Health Check
- `GET /health` - Service health status

### Similarity Detection
- `POST /similarity/check` - Check similarity between two texts
- `POST /questions/similarity/check` - Check if a question is similar to existing questions

### Essay Grading
- `POST /grading/essay` - Grade an essay answer
- `POST /exams/{exam_id}/questions/{question_id}/grade` - Grade a specific exam answer
- `POST /exams/{exam_id}/grade-all` - Grade all open-ended questions in an exam

### Analytics
- `GET /questions/{question_id}/analytics` - Get analytics for a specific question

## Usage

### Check Question Similarity
```bash
curl -X POST "http://localhost:8088/questions/similarity/check" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question_text": "What is machine learning?",
    "exclude_id": 123
  }'
```

### Grade Essay
```bash
curl -X POST "http://localhost:8088/grading/essay" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "Explain the concept of machine learning",
    "answer": "Machine learning is a subset of artificial intelligence...",
    "max_score": 100
  }'
```

### Grade Exam Answer
```bash
curl -X POST "http://localhost:8088/exams/1/questions/5/grade" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "exam_id": 1,
    "question_id": 5,
    "answer_text": "Student answer here...",
    "max_score": 100
  }'
```

## Grading Criteria

The service evaluates essays based on four main criteria:

1. **Content (40%)**: Relevance and completeness of the answer
2. **Structure (20%)**: Organization and flow of ideas
3. **Language (20%)**: Vocabulary and sentence complexity
4. **Relevance (20%)**: How well the answer addresses the question

## Configuration

Environment variables can be set in the `.env` file:

```env
NLP_SERVICE_PORT=8088
QUESTION_SERVICE_URL=http://question-service:8085
EXAM_SERVICE_URL=http://exam-service:8086
JWT_SECRET=your_jwt_secret
SIMILARITY_THRESHOLD=0.7
GRADING_CONFIDENCE_THRESHOLD=0.6
```

## Docker

Build and run with Docker:

```bash
docker build -t nlp-service .
docker run -p 8088:8088 nlp-service
```

## Dependencies

- FastAPI for the web framework
- Sentence Transformers for semantic similarity
- spaCy for NLP processing
- scikit-learn for machine learning utilities
- NLTK for natural language processing
- Transformers for pre-trained models

## Development

Install dependencies:

```bash
pip install -r requirements.txt
```

Run locally:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8088 --reload
```

## Integration

This service integrates with:
- **Question Service**: For fetching question details and checking duplicates
- **Exam Service**: For grading exam answers and saving results
- **Auth Service**: For JWT token validation (planned)
