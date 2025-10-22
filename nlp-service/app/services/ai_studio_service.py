import requests
import json
from typing import Dict, Any, Optional
import os
from dotenv import load_dotenv

load_dotenv()

class AIStudioService:
    """Service for integrating with Google AI Studio for answer validation and grading"""
    
    def __init__(self):
        self.api_key = os.getenv('AI_STUDIO_API_KEY', 'AIzaSyARkZIcLTr1n-zH2U38ztdFzxq1zwKED_c')
        self.base_url = "https://generativelanguage.googleapis.com/v1beta"
        self.model = "gemini-1.5-flash"
        
    async def validate_answer(self, question: str, answer: str, expected_answer: Optional[str] = None) -> Dict[str, Any]:
        """
        Validate if an answer is correct using AI Studio
        
        Args:
            question: The question text
            answer: The user's answer
            expected_answer: The expected correct answer (optional)
            
        Returns:
            Dict containing validation results
        """
        try:
            prompt = self._build_validation_prompt(question, answer, expected_answer)
            
            response = await self._call_ai_studio(prompt)
            
            return {
                "is_correct": response.get("is_correct", False),
                "confidence": response.get("confidence", 0.0),
                "feedback": response.get("feedback", ""),
                "score": response.get("score", 0),
                "max_score": response.get("max_score", 10),
                "explanation": response.get("explanation", ""),
                "suggestions": response.get("suggestions", [])
            }
            
        except Exception as e:
            return {
                "is_correct": False,
                "confidence": 0.0,
                "feedback": f"Error validating answer: {str(e)}",
                "score": 0,
                "max_score": 10,
                "explanation": "",
                "suggestions": []
            }
    
    async def grade_essay(self, question: str, answer: str, max_score: int = 10) -> Dict[str, Any]:
        """
        Grade an essay answer using AI Studio
        
        Args:
            question: The question text
            answer: The user's answer
            max_score: Maximum possible score
            
        Returns:
            Dict containing grading results
        """
        try:
            prompt = self._build_grading_prompt(question, answer, max_score)
            
            response = await self._call_ai_studio(prompt)
            
            return {
                "score": min(response.get("score", 0), max_score),
                "max_score": max_score,
                "feedback": response.get("feedback", ""),
                "criteria_scores": response.get("criteria_scores", {}),
                "strengths": response.get("strengths", []),
                "weaknesses": response.get("weaknesses", []),
                "suggestions": response.get("suggestions", [])
            }
            
        except Exception as e:
            return {
                "score": 0,
                "max_score": max_score,
                "feedback": f"Error grading essay: {str(e)}",
                "criteria_scores": {},
                "strengths": [],
                "weaknesses": [],
                "suggestions": []
            }
    
    def _build_validation_prompt(self, question: str, answer: str, expected_answer: Optional[str] = None) -> str:
        """Build prompt for answer validation"""
        base_prompt = f"""
You are an expert teacher grading a student's answer. Please evaluate the following:

Question: {question}

Student's Answer: {answer}
"""
        
        if expected_answer:
            base_prompt += f"\nExpected Answer: {expected_answer}"
        
        base_prompt += """

Please provide your evaluation in the following JSON format:
{
    "is_correct": true/false,
    "confidence": 0.0-1.0,
    "feedback": "Detailed feedback for the student",
    "score": 0-10,
    "max_score": 10,
    "explanation": "Explanation of why the answer is correct/incorrect",
    "suggestions": ["suggestion1", "suggestion2"]
}

Consider:
- Accuracy of the answer
- Completeness
- Understanding demonstrated
- Clarity of explanation
- Technical correctness (if applicable)
"""
        
        return base_prompt
    
    def _build_grading_prompt(self, question: str, answer: str, max_score: int) -> str:
        """Build prompt for essay grading"""
        return f"""
You are an expert teacher grading an essay answer. Please evaluate the following:

Question: {question}

Student's Answer: {answer}

Please grade this answer on a scale of 0 to {max_score} and provide detailed feedback.

Provide your evaluation in the following JSON format:
{{
    "score": 0-{max_score},
    "feedback": "Comprehensive feedback for the student",
    "criteria_scores": {{
        "content": 0-{max_score//4},
        "organization": 0-{max_score//4},
        "clarity": 0-{max_score//4},
        "technical_accuracy": 0-{max_score//4}
    }},
    "strengths": ["strength1", "strength2"],
    "weaknesses": ["weakness1", "weakness2"],
    "suggestions": ["suggestion1", "suggestion2"]
}}

Consider:
- Content accuracy and depth
- Organization and structure
- Clarity of expression
- Technical accuracy
- Originality of thought
- Use of examples and evidence
"""
    
    async def _call_ai_studio(self, prompt: str) -> Dict[str, Any]:
        """Call Google AI Studio API"""
        url = f"{self.base_url}/models/{self.model}:generateContent"
        
        headers = {
            "Content-Type": "application/json",
        }
        
        params = {
            "key": self.api_key
        }
        
        payload = {
            "contents": [{
                "parts": [{
                    "text": prompt
                }]
            }],
            "generationConfig": {
                "temperature": 0.1,
                "topK": 32,
                "topP": 1,
                "maxOutputTokens": 2048,
            }
        }
        
        try:
            response = requests.post(url, headers=headers, params=params, json=payload)
            response.raise_for_status()
            
            result = response.json()
            
            # Extract the generated text
            if "candidates" in result and len(result["candidates"]) > 0:
                generated_text = result["candidates"][0]["content"]["parts"][0]["text"]
                
                # Try to parse as JSON
                try:
                    return json.loads(generated_text)
                except json.JSONDecodeError:
                    # If not JSON, return a basic response
                    return {
                        "is_correct": "correct" in generated_text.lower(),
                        "confidence": 0.7,
                        "feedback": generated_text,
                        "score": 5,
                        "max_score": 10,
                        "explanation": generated_text,
                        "suggestions": []
                    }
            else:
                raise Exception("No response from AI Studio")
                
        except requests.exceptions.RequestException as e:
            raise Exception(f"AI Studio API error: {str(e)}")
        except Exception as e:
            raise Exception(f"Error processing AI Studio response: {str(e)}")
    
    async def check_plagiarism(self, text: str) -> Dict[str, Any]:
        """
        Check for potential plagiarism using AI Studio
        
        Args:
            text: Text to check for plagiarism
            
        Returns:
            Dict containing plagiarism check results
        """
        try:
            prompt = f"""
Analyze the following text for potential plagiarism or originality issues:

Text: {text}

Please provide your analysis in the following JSON format:
{{
    "is_original": true/false,
    "confidence": 0.0-1.0,
    "similarity_score": 0.0-1.0,
    "feedback": "Analysis of originality",
    "concerns": ["concern1", "concern2"],
    "suggestions": ["suggestion1", "suggestion2"]
}}

Consider:
- Uniqueness of content
- Potential copying from common sources
- Originality of ideas
- Proper attribution if needed
"""
            
            response = await self._call_ai_studio(prompt)
            
            return {
                "is_original": response.get("is_original", True),
                "confidence": response.get("confidence", 0.8),
                "similarity_score": response.get("similarity_score", 0.1),
                "feedback": response.get("feedback", ""),
                "concerns": response.get("concerns", []),
                "suggestions": response.get("suggestions", [])
            }
            
        except Exception as e:
            return {
                "is_original": True,
                "confidence": 0.0,
                "similarity_score": 0.0,
                "feedback": f"Error checking plagiarism: {str(e)}",
                "concerns": [],
                "suggestions": []
            }



