import nltk
import spacy
from transformers import pipeline
import re
from typing import List, Dict, Any
import asyncio

class NLPService:
    def __init__(self):
        self.nlp = spacy.load("en_core_web_sm")
        self.sentiment_analyzer = pipeline("sentiment-analysis")
        self.text_classifier = pipeline("zero-shot-classification")
        
    async def preprocess_text(self, text: str) -> str:
        """Preprocess text for analysis"""
        # Convert to lowercase
        text = text.lower()
        
        # Remove special characters but keep spaces
        text = re.sub(r'[^a-zA-Z0-9\s]', '', text)
        
        # Remove extra whitespace
        text = ' '.join(text.split())
        
        return text
    
    async def extract_keywords(self, text: str, max_keywords: int = 10) -> List[str]:
        """Extract keywords from text"""
        doc = self.nlp(text)
        
        # Extract nouns and adjectives as keywords
        keywords = []
        for token in doc:
            if token.pos_ in ['NOUN', 'ADJ'] and not token.is_stop and len(token.text) > 2:
                keywords.append(token.lemma_)
        
        # Remove duplicates and return top keywords
        unique_keywords = list(set(keywords))
        return unique_keywords[:max_keywords]
    
    async def analyze_sentiment(self, text: str) -> Dict[str, Any]:
        """Analyze sentiment of text"""
        result = self.sentiment_analyzer(text)
        return {
            "label": result[0]["label"],
            "score": result[0]["score"]
        }
    
    async def classify_text(self, text: str, categories: List[str]) -> Dict[str, Any]:
        """Classify text into categories"""
        result = self.text_classifier(text, categories)
        return {
            "labels": result["labels"],
            "scores": result["scores"]
        }
    
    async def extract_entities(self, text: str) -> List[Dict[str, Any]]:
        """Extract named entities from text"""
        doc = self.nlp(text)
        entities = []
        
        for ent in doc.ents:
            entities.append({
                "text": ent.text,
                "label": ent.label_,
                "start": ent.start_char,
                "end": ent.end_char
            })
        
        return entities
    
    async def calculate_text_complexity(self, text: str) -> Dict[str, Any]:
        """Calculate text complexity metrics"""
        doc = self.nlp(text)
        
        # Basic metrics
        word_count = len([token for token in doc if not token.is_punct])
        sentence_count = len(list(doc.sents))
        avg_sentence_length = word_count / sentence_count if sentence_count > 0 else 0
        
        # Calculate average word length
        word_lengths = [len(token.text) for token in doc if not token.is_punct]
        avg_word_length = sum(word_lengths) / len(word_lengths) if word_lengths else 0
        
        # Calculate lexical diversity (unique words / total words)
        unique_words = len(set([token.lemma_ for token in doc if not token.is_punct]))
        lexical_diversity = unique_words / word_count if word_count > 0 else 0
        
        return {
            "word_count": word_count,
            "sentence_count": sentence_count,
            "avg_sentence_length": avg_sentence_length,
            "avg_word_length": avg_word_length,
            "lexical_diversity": lexical_diversity,
            "complexity_score": (avg_sentence_length * 0.3 + avg_word_length * 0.3 + lexical_diversity * 0.4)
        }
