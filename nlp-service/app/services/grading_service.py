import re
import asyncio
from typing import List, Dict, Any
from .nlp_service import NLPService
from .similarity_service import SimilarityService
from .ai_studio_service import AIStudioService

class GradingService:
    def __init__(self):
        self.nlp_service = NLPService()
        self.similarity_service = SimilarityService()
        self.ai_studio_service = AIStudioService()
        
    async def grade_essay(self, question: str, answer: str, max_score: int = 100) -> Dict[str, Any]:
        """Grade an essay answer comprehensively using AI Studio"""
        try:
            # Use AI Studio for primary grading
            ai_result = await self.ai_studio_service.grade_essay(question, answer, max_score)
            
            # Fallback to traditional NLP grading if AI Studio fails
            if ai_result.get("score", 0) == 0 and "Error" in ai_result.get("feedback", ""):
                return await self._grade_essay_traditional(question, answer, max_score)
            
            # Enhance AI Studio result with additional analysis
            processed_question = await self.nlp_service.preprocess_text(question)
            processed_answer = await self.nlp_service.preprocess_text(answer)
            
            # Add plagiarism check
            plagiarism_result = await self.ai_studio_service.check_plagiarism(answer)
            
            # Combine AI Studio result with additional metrics
            return {
                "score": ai_result.get("score", 0),
                "max_score": max_score,
                "percentage": round((ai_result.get("score", 0) / max_score) * 100, 2),
                "feedback": ai_result.get("feedback", ""),
                "strengths": ai_result.get("strengths", []),
                "weaknesses": ai_result.get("weaknesses", []),
                "suggestions": ai_result.get("suggestions", []),
                "confidence": 0.9,  # High confidence for AI Studio
                "criteria_scores": ai_result.get("criteria_scores", {}),
                "plagiarism_check": {
                    "is_original": plagiarism_result.get("is_original", True),
                    "confidence": plagiarism_result.get("confidence", 0.8),
                    "similarity_score": plagiarism_result.get("similarity_score", 0.1),
                    "concerns": plagiarism_result.get("concerns", [])
                },
                "grading_method": "ai_studio"
            }
            
        except Exception as e:
            print(f"Error in AI Studio essay grading: {e}")
            # Fallback to traditional grading
            return await self._grade_essay_traditional(question, answer, max_score)
    
    async def _grade_essay_traditional(self, question: str, answer: str, max_score: int = 100) -> Dict[str, Any]:
        """Fallback traditional grading method"""
        try:
            # Preprocess texts
            processed_question = await self.nlp_service.preprocess_text(question)
            processed_answer = await self.nlp_service.preprocess_text(answer)
            
            # Calculate different aspects of the answer
            content_score = await self._grade_content(processed_question, processed_answer, max_score * 0.4)
            structure_score = await self._grade_structure(processed_answer, max_score * 0.2)
            language_score = await self._grade_language(processed_answer, max_score * 0.2)
            relevance_score = await self._grade_relevance(processed_question, processed_answer, max_score * 0.2)
            
            # Calculate total score
            total_score = content_score + structure_score + language_score + relevance_score
            
            # Generate feedback
            feedback = await self._generate_feedback(
                content_score, structure_score, language_score, relevance_score,
                processed_question, processed_answer, max_score
            )
            
            # Identify strengths and weaknesses
            strengths = await self._identify_strengths(
                content_score, structure_score, language_score, relevance_score
            )
            
            weaknesses = await self._identify_weaknesses(
                content_score, structure_score, language_score, relevance_score
            )
            
            # Generate suggestions
            suggestions = await self._generate_suggestions(weaknesses, processed_answer)
            
            # Calculate confidence based on consistency of scores
            confidence = await self._calculate_confidence(
                content_score, structure_score, language_score, relevance_score
            )
            
            return {
                "score": round(total_score, 2),
                "max_score": max_score,
                "percentage": round((total_score / max_score) * 100, 2),
                "feedback": feedback,
                "strengths": strengths,
                "weaknesses": weaknesses,
                "suggestions": suggestions,
                "confidence": confidence,
                "grading_method": "traditional_nlp"
            }
            
        except Exception as e:
            print(f"Error in traditional essay grading: {e}")
            return {
                "score": 0,
                "max_score": max_score,
                "percentage": 0,
                "feedback": [f"Error in grading: {str(e)}"],
                "strengths": [],
                "weaknesses": ["Technical error occurred"],
                "suggestions": ["Please try again"],
                "confidence": 0.0,
                "grading_method": "error"
            }
    
    async def _grade_content(self, question: str, answer: str, max_points: float) -> float:
        """Grade content relevance and completeness"""
        # Calculate semantic similarity between question and answer
        similarity = await self.similarity_service.calculate_similarity(question, answer)
        
        # Extract keywords from question
        question_keywords = await self.nlp_service.extract_keywords(question)
        answer_keywords = await self.nlp_service.extract_keywords(answer)
        
        # Calculate keyword coverage
        keyword_coverage = len(set(question_keywords).intersection(set(answer_keywords)))
        keyword_score = (keyword_coverage / len(question_keywords)) if question_keywords else 0
        
        # Combine similarity and keyword coverage
        content_score = (similarity * 0.6 + keyword_score * 0.4) * max_points
        
        return min(max_points, content_score)
    
    async def _grade_structure(self, answer: str, max_points: float) -> float:
        """Grade answer structure and organization"""
        # Count sentences
        sentences = re.split(r'[.!?]+', answer)
        sentence_count = len([s for s in sentences if s.strip()])
        
        # Check for paragraph structure
        paragraphs = answer.split('\n\n')
        paragraph_count = len([p for p in paragraphs if p.strip()])
        
        # Calculate structure score
        structure_score = 0
        
        # Sentence count (optimal range: 3-10 sentences)
        if 3 <= sentence_count <= 10:
            structure_score += 0.3
        elif sentence_count > 10:
            structure_score += 0.2
        else:
            structure_score += 0.1
        
        # Paragraph structure
        if paragraph_count > 1:
            structure_score += 0.3
        else:
            structure_score += 0.1
        
        # Check for transition words
        transition_words = ['however', 'therefore', 'moreover', 'furthermore', 'additionally', 'consequently']
        has_transitions = any(word in answer.lower() for word in transition_words)
        if has_transitions:
            structure_score += 0.4
        else:
            structure_score += 0.2
        
        return structure_score * max_points
    
    async def _grade_language(self, answer: str, max_points: float) -> float:
        """Grade language quality and complexity"""
        # Get text complexity metrics
        complexity = await self.nlp_service.calculate_text_complexity(answer)
        
        # Calculate language score based on complexity
        lexical_diversity = complexity['lexical_diversity']
        avg_sentence_length = complexity['avg_sentence_length']
        avg_word_length = complexity['avg_word_length']
        
        # Optimal ranges for good writing
        diversity_score = min(1.0, lexical_diversity / 0.7)  # Target: 0.7
        sentence_score = min(1.0, avg_sentence_length / 15)  # Target: 15 words per sentence
        word_score = min(1.0, avg_word_length / 5)  # Target: 5 characters per word
        
        language_score = (diversity_score * 0.4 + sentence_score * 0.3 + word_score * 0.3)
        
        return language_score * max_points
    
    async def _grade_relevance(self, question: str, answer: str, max_points: float) -> float:
        """Grade how relevant the answer is to the question"""
        # Calculate semantic similarity
        similarity = await self.similarity_service.calculate_similarity(question, answer)
        
        # Check if answer addresses the question type
        question_lower = question.lower()
        answer_lower = answer.lower()
        
        relevance_score = similarity
        
        # Additional checks for specific question types
        if 'what' in question_lower and 'what' in answer_lower:
            relevance_score += 0.1
        if 'how' in question_lower and ('how' in answer_lower or 'by' in answer_lower):
            relevance_score += 0.1
        if 'why' in question_lower and ('because' in answer_lower or 'reason' in answer_lower):
            relevance_score += 0.1
        
        return min(1.0, relevance_score) * max_points
    
    async def _generate_feedback(self, content_score: float, structure_score: float, 
                               language_score: float, relevance_score: float,
                               question: str, answer: str, max_score: int) -> List[str]:
        """Generate detailed feedback based on scores"""
        feedback = []
        
        # Content feedback
        content_percentage = (content_score / (max_score * 0.4)) * 100
        if content_percentage >= 80:
            feedback.append("Excellent content coverage and relevance to the question.")
        elif content_percentage >= 60:
            feedback.append("Good content coverage, but could be more comprehensive.")
        else:
            feedback.append("Content needs improvement. Focus more on directly addressing the question.")
        
        # Structure feedback
        structure_percentage = (structure_score / (max_score * 0.2)) * 100
        if structure_percentage >= 80:
            feedback.append("Well-structured answer with clear organization.")
        elif structure_percentage >= 60:
            feedback.append("Good structure, but could benefit from better organization.")
        else:
            feedback.append("Structure needs improvement. Consider using paragraphs and clear transitions.")
        
        # Language feedback
        language_percentage = (language_score / (max_score * 0.2)) * 100
        if language_percentage >= 80:
            feedback.append("Excellent use of language and vocabulary.")
        elif language_percentage >= 60:
            feedback.append("Good language use, but could be more varied.")
        else:
            feedback.append("Language could be improved. Try using more varied vocabulary and sentence structures.")
        
        # Relevance feedback
        relevance_percentage = (relevance_score / (max_score * 0.2)) * 100
        if relevance_percentage >= 80:
            feedback.append("Highly relevant to the question asked.")
        elif relevance_percentage >= 60:
            feedback.append("Mostly relevant, but could be more focused.")
        else:
            feedback.append("Answer needs to be more directly relevant to the question.")
        
        return feedback
    
    async def _identify_strengths(self, content_score: float, structure_score: float,
                                language_score: float, relevance_score: float) -> List[str]:
        """Identify strengths in the answer"""
        strengths = []
        
        if content_score > 0.7:
            strengths.append("Comprehensive content coverage")
        if structure_score > 0.7:
            strengths.append("Well-organized structure")
        if language_score > 0.7:
            strengths.append("Good language use")
        if relevance_score > 0.7:
            strengths.append("High relevance to question")
        
        return strengths
    
    async def _identify_weaknesses(self, content_score: float, structure_score: float,
                                 language_score: float, relevance_score: float) -> List[str]:
        """Identify weaknesses in the answer"""
        weaknesses = []
        
        if content_score < 0.5:
            weaknesses.append("Insufficient content coverage")
        if structure_score < 0.5:
            weaknesses.append("Poor organization")
        if language_score < 0.5:
            weaknesses.append("Limited vocabulary and sentence variety")
        if relevance_score < 0.5:
            weaknesses.append("Low relevance to question")
        
        return weaknesses
    
    async def _generate_suggestions(self, weaknesses: List[str], answer: str) -> List[str]:
        """Generate improvement suggestions based on weaknesses"""
        suggestions = []
        
        if "Insufficient content coverage" in weaknesses:
            suggestions.append("Expand your answer with more detailed explanations and examples")
        
        if "Poor organization" in weaknesses:
            suggestions.append("Organize your answer into clear paragraphs with topic sentences")
        
        if "Limited vocabulary and sentence variety" in weaknesses:
            suggestions.append("Use more varied vocabulary and different sentence structures")
        
        if "Low relevance to question" in weaknesses:
            suggestions.append("Focus more directly on answering the specific question asked")
        
        # General suggestions based on answer length
        word_count = len(answer.split())
        if word_count < 50:
            suggestions.append("Provide more detailed explanations to support your points")
        elif word_count > 500:
            suggestions.append("Consider being more concise while maintaining clarity")
        
        return suggestions
    
    async def _calculate_confidence(self, content_score: float, structure_score: float,
                                  language_score: float, relevance_score: float) -> float:
        """Calculate confidence in the grading based on score consistency"""
        scores = [content_score, structure_score, language_score, relevance_score]
        
        # Calculate standard deviation
        mean_score = sum(scores) / len(scores)
        variance = sum((score - mean_score) ** 2 for score in scores) / len(scores)
        std_dev = variance ** 0.5
        
        # Confidence is higher when scores are more consistent
        # Lower standard deviation = higher confidence
        confidence = max(0.0, 1.0 - (std_dev / mean_score)) if mean_score > 0 else 0.0
        
        return min(1.0, confidence)
