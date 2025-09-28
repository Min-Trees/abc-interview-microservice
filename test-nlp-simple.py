from fastapi import FastAPI
import uvicorn

app = FastAPI(title="NLP Service Test", version="1.0.0")

@app.get("/health")
def health():
    return {"status": "healthy", "service": "nlp-service", "version": "1.0.0"}

@app.get("/")
def root():
    return {"message": "NLP Service is running!"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8088)
