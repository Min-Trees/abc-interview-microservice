import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import textdistance
from typing import List, Dict, Any
import asyncio

class SimilarityService:
    def __init__(self):
        # Load pre-trained sentence transformer model
        self.model = SentenceTransformer('all-MiniLM-L6-v2')
        
    async def calculate_similarity(self, text1: str, text2: str) -> float:
        """Calculate similarity between two texts using multiple methods"""
        # Method 1: Sentence Transformers (semantic similarity)
        semantic_similarity = await self._calculate_semantic_similarity(text1, text2)
        
        # Method 2: Jaccard similarity (word overlap)
        jaccard_similarity = await self._calculate_jaccard_similarity(text1, text2)
        
        # Method 3: Levenshtein distance (edit distance)
        levenshtein_similarity = await self._calculate_levenshtein_similarity(text1, text2)
        
        # Weighted combination of different similarity measures
        final_similarity = (
            semantic_similarity * 0.6 +  # Most important for semantic understanding
            jaccard_similarity * 0.3 +   # Good for word overlap
            levenshtein_similarity * 0.1  # Good for exact matches
        )
        
        return min(1.0, max(0.0, final_similarity))
    
    async def _calculate_semantic_similarity(self, text1: str, text2: str) -> float:
        """Calculate semantic similarity using sentence transformers"""
        try:
            # Encode texts to embeddings
            embeddings = self.model.encode([text1, text2])
            
            # Calculate cosine similarity
            similarity = cosine_similarity([embeddings[0]], [embeddings[1]])[0][0]
            
            return float(similarity)
        except Exception as e:
            print(f"Error in semantic similarity calculation: {e}")
            return 0.0
    
    async def _calculate_jaccard_similarity(self, text1: str, text2: str) -> float:
        """Calculate Jaccard similarity based on word overlap"""
        try:
            # Convert to sets of words
            words1 = set(text1.lower().split())
            words2 = set(text2.lower().split())
            
            # Calculate Jaccard similarity
            intersection = len(words1.intersection(words2))
            union = len(words1.union(words2))
            
            return intersection / union if union > 0 else 0.0
        except Exception as e:
            print(f"Error in Jaccard similarity calculation: {e}")
            return 0.0
    
    async def _calculate_levenshtein_similarity(self, text1: str, text2: str) -> float:
        """Calculate similarity based on Levenshtein distance"""
        try:
            # Calculate Levenshtein distance
            distance = textdistance.levenshtein(text1, text2)
            
            # Convert to similarity (0-1 scale)
            max_length = max(len(text1), len(text2))
            similarity = 1 - (distance / max_length) if max_length > 0 else 0.0
            
            return max(0.0, similarity)
        except Exception as e:
            print(f"Error in Levenshtein similarity calculation: {e}")
            return 0.0
    
    async def find_similar_questions(self, question_text: str, existing_questions: List[Dict[str, Any]], threshold: float = 0.7) -> List[Dict[str, Any]]:
        """Find similar questions from a list of existing questions"""
        similar_questions = []
        
        for question in existing_questions:
            similarity = await self.calculate_similarity(question_text, question.get('text', ''))
            
            if similarity >= threshold:
                similar_questions.append({
                    'question_id': question.get('id'),
                    'question_text': question.get('text'),
                    'similarity_score': similarity
                })
        
        # Sort by similarity score (highest first)
        similar_questions.sort(key=lambda x: x['similarity_score'], reverse=True)
        
        return similar_questions
    
    async def detect_duplicates(self, text: str, existing_texts: List[str], threshold: float = 0.8) -> List[Dict[str, Any]]:
        """Detect duplicate texts from a list of existing texts"""
        duplicates = []
        
        for i, existing_text in enumerate(existing_texts):
            similarity = await self.calculate_similarity(text, existing_text)
            
            if similarity >= threshold:
                duplicates.append({
                    'index': i,
                    'text': existing_text,
                    'similarity_score': similarity
                })
        
        return duplicates
