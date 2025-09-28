from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import uvicorn
import os
from dotenv import load_dotenv

from .services.nlp_service import NLPService
from .services.similarity_service import SimilarityService
from .services.grading_service import GradingService
from .services.integration_service import IntegrationService
from .models.schemas import (
    SimilarityRequest, SimilarityResponse,
    GradingRequest, GradingResponse,
    HealthResponse, QuestionSimilarityRequest, QuestionSimilarityResponse,
    ExamGradingRequest, ExamGradingResponse
)

# Load environment variables
load_dotenv()

app = FastAPI(
    title="NLP Service",
    description="Natural Language Processing service for question similarity and essay grading",
    version="1.0.0",
    docs_url="/swagger-ui.html",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security
security = HTTPBearer()

# Initialize services
nlp_service = NLPService()
similarity_service = SimilarityService()
grading_service = GradingService()
integration_service = IntegrationService()

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Simple token verification - in production, use proper JWT validation"""
    token = credentials.credentials
    # For now, accept any token - integrate with auth service later
    return token

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        service="nlp-service",
        version="1.0.0"
    )

@app.post("/similarity/check", response_model=SimilarityResponse)
async def check_similarity(
    request: SimilarityRequest,
    token: str = Depends(verify_token)
):
    """Check similarity between two texts"""
    try:
        similarity_score = await similarity_service.calculate_similarity(
            request.text1, request.text2
        )
        
        return SimilarityResponse(
            similarity_score=similarity_score,
            is_similar=similarity_score > 0.7,  # Threshold for similarity
            confidence=similarity_score
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/grading/essay", response_model=GradingResponse)
async def grade_essay(
    request: GradingRequest,
    token: str = Depends(verify_token)
):
    """Grade an essay answer"""
    try:
        grading_result = await grading_service.grade_essay(
            question=request.question,
            answer=request.answer,
            max_score=request.max_score
        )
        
        return grading_result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/questions/similarity/check", response_model=QuestionSimilarityResponse)
async def check_question_similarity(
    request: QuestionSimilarityRequest,
    token: str = Depends(verify_token)
):
    """Check if a question is similar to existing questions"""
    try:
        result = await integration_service.check_question_duplicates(
            request.question_text, request.exclude_id
        )
        
        return QuestionSimilarityResponse(
            similar_questions=result.get("similar_questions", []),
            similarity_scores=[q["similarity_score"] for q in result.get("similar_questions", [])],
            is_duplicate=result.get("is_duplicate", False)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/exams/{exam_id}/questions/{question_id}/grade", response_model=ExamGradingResponse)
async def grade_exam_answer(
    exam_id: int,
    question_id: int,
    request: ExamGradingRequest,
    token: str = Depends(verify_token)
):
    """Grade a specific exam answer"""
    try:
        result = await integration_service.grade_exam_answer(
            exam_id, question_id, request.answer_text, request.max_score
        )
        
        return ExamGradingResponse(
            exam_id=result.get("exam_id", exam_id),
            question_id=result.get("question_id", question_id),
            score=result.get("score", 0),
            max_score=result.get("max_score", request.max_score),
            feedback=result.get("feedback", "No feedback available"),
            auto_graded=result.get("auto_graded", False),
            confidence=result.get("confidence", 0.0)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/exams/{exam_id}/grade-all")
async def batch_grade_exam(
    exam_id: int,
    token: str = Depends(verify_token)
):
    """Grade all open-ended questions in an exam"""
    try:
        result = await integration_service.batch_grade_exam(exam_id)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/questions/{question_id}/analytics")
async def get_question_analytics(
    question_id: int,
    token: str = Depends(verify_token)
):
    """Get analytics for a specific question"""
    try:
        result = await integration_service.get_question_analytics(question_id)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8088)
