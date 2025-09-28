from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from enum import Enum

class SimilarityRequest(BaseModel):
    text1: str = Field(..., description="First text to compare")
    text2: str = Field(..., description="Second text to compare")

class SimilarityResponse(BaseModel):
    similarity_score: float = Field(..., description="Similarity score between 0 and 1")
    is_similar: bool = Field(..., description="Whether texts are considered similar")
    confidence: float = Field(..., description="Confidence level of the similarity")

class GradingRequest(BaseModel):
    question: str = Field(..., description="The question being answered")
    answer: str = Field(..., description="The student's answer")
    max_score: int = Field(default=100, description="Maximum possible score")
    criteria: Optional[List[str]] = Field(default=None, description="Grading criteria")

class GradingResponse(BaseModel):
    score: float = Field(..., description="Assigned score")
    max_score: int = Field(..., description="Maximum possible score")
    percentage: float = Field(..., description="Score as percentage")
    feedback: List[str] = Field(..., description="Detailed feedback")
    strengths: List[str] = Field(..., description="Identified strengths")
    weaknesses: List[str] = Field(..., description="Areas for improvement")
    suggestions: List[str] = Field(..., description="Suggestions for improvement")
    confidence: float = Field(..., description="Confidence in the grading")

class HealthResponse(BaseModel):
    status: str = Field(..., description="Service status")
    service: str = Field(..., description="Service name")
    version: str = Field(..., description="Service version")

class QuestionSimilarityRequest(BaseModel):
    question_text: str = Field(..., description="Question text to check")
    exclude_id: Optional[int] = Field(default=None, description="Question ID to exclude from comparison")

class QuestionSimilarityResponse(BaseModel):
    similar_questions: List[Dict[str, Any]] = Field(..., description="List of similar questions")
    similarity_scores: List[float] = Field(..., description="Similarity scores for each question")
    is_duplicate: bool = Field(..., description="Whether the question is a duplicate")

class ExamGradingRequest(BaseModel):
    exam_id: int = Field(..., description="Exam ID")
    question_id: int = Field(..., description="Question ID")
    answer_text: str = Field(..., description="Student's answer text")
    max_score: int = Field(..., description="Maximum score for this question")

class ExamGradingResponse(BaseModel):
    exam_id: int = Field(..., description="Exam ID")
    question_id: int = Field(..., description="Question ID")
    score: float = Field(..., description="Assigned score")
    max_score: int = Field(..., description="Maximum possible score")
    feedback: str = Field(..., description="Detailed feedback")
    auto_graded: bool = Field(..., description="Whether this was auto-graded")
    confidence: float = Field(..., description="Confidence in the grading")
