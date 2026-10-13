import os
import json
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
from openai import OpenAI
from supabase import create_client, Client

load_dotenv()

# inicializar clientes
ai_client = OpenAI(
    base_url='https://openrouter.ai/api/v1',
    api_key=os.getenv("OPENROUTER_API_KEY"),
)

supabase: Client = create_client(
    os.getenv("SUPABASE_URL", ""),
    os.getenv("SUPABASE_KEY", "")
)

app = FastAPI(
    title="PocketAI Backend",
    description="Microservicio de procesamiento de notas con IA (OpenRouter Free Tier)",
    version="1.0.0"
)

# permitir llmadas desde flutter web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ProcessNoteRequest(BaseModel):
    note_id: str 
    content: str

class ProcessNoteResponse(BaseModel):
    summary: str 
    action_items: list[str]

@app.get("/")
def health_check():
    return {"status": "online", "service": "PocketAI Backend (OpenRouter Powered)"}

@app.post("/api/v1/analyze-note", response_model=ProcessNoteResponse)
async def analyze_note(payload: ProcessNoteRequest):
    try:
        prompt = f"""
        Analiza la siguiente nota y realiza dos tareas:
        1. Escribe un resumen de maximo 2 oraciones.
        2. Extrae una lista de puntos de accion concretos o tareas pendientes detectadas.
        
        Nota:
        \"\"\"{payload.content}\"\"\"
        
        Responde UNICAMENTE en formato JSON valido con esta estrcutura exacta, sin texto introductorio ni explicaciones:
        {{
            "summary": "resumen aqui",
            "action_items": ["tarea 1", "tarea 2"]
        }}
        """

        # Modelo gratuito en OpenRouter
        response = ai_client.chat.completions.create(
            model="openrouter/free",
            messages=[
                {
                    "role": "system",
                    "content": "Eres un asistente de productividad que responde estrictamente en JSON valido."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            temperature=0.2
        )

        raw_content = response.choices[0].message.content.strip()

        # Blindaje pro: extraer unicamente el objeto JSON entre llaves
        start_idx = raw_content.find('{')
        end_idx = raw_content.rfind('}')
        if start_idx != -1 and end_idx != -1:
            raw_content = raw_content[start_idx:end_idx+1]

        data = json.loads(raw_content)

        summary = data.get("summary", "Sin resumen disponible")
        action_items = data.get("action_items", [])

        # Actualizar automaticamente en Supabase
        supabase.table("notes").update({"summary": summary}).eq("id", payload.note_id).execute()

        return ProcessNoteResponse(
            summary=summary,
            action_items=action_items
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
        

