import json
import os
import tempfile
from pathlib import Path
from typing import Dict, List

import pdfplumber
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.responses import JSONResponse
from langchain_openai import ChatOpenAI
try:
    from langchain_core.messages import HumanMessage, SystemMessage
except ImportError:  # Fallback for older LangChain versions
    from langchain.schema import HumanMessage, SystemMessage

app = FastAPI(title="Autopredator PDF Intelligence", version="0.1.0")


def extract_last_pages_text(pdf_path: str, pages_to_keep: int = 2) -> str:
    """Extract text from the last N pages of the PDF."""
    with pdfplumber.open(pdf_path) as pdf:
        if not pdf.pages:
            raise ValueError("PDF has no readable pages.")
        start = max(0, len(pdf.pages) - pages_to_keep)
        selected_pages = pdf.pages[start:]
        text_chunks: List[str] = []
        for page in selected_pages:
            page_text = page.extract_text() or ""
            text_chunks.append(page_text)
        combined = "\n\n".join(text_chunks).strip()
        if not combined:
            raise ValueError("No text could be extracted from the PDF pages.")
        return combined


def build_prompt(text: str) -> List:
    """Create LangChain messages for spec extraction."""
    system_msg = SystemMessage(
        content=(
            "You are a precise data extractor for Indian car brochures. "
            "Return ONLY valid JSON with the following keys: "
            "model_name, variant_name, engine_cc, max_power, max_torque, mileage_arai, transmission. "
            "Values must be plain strings (keep units if present). "
            "If a value is missing, use an empty string. Do not add explanations."
        )
    )
    human_msg = HumanMessage(
        content=(
            "Brochure text (last pages):\n"
            f"{text}\n\n"
            "Extract the requested fields into a single JSON object."
        )
    )
    return [system_msg, human_msg]


def invoke_llm(prompt_messages: List) -> Dict:
    """Call OpenAI Chat model and coerce output to JSON."""
    llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
    response = llm.invoke(prompt_messages)
    content = response.content.strip()
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        # Attempt to recover JSON snippet
        start = content.find("{")
        end = content.rfind("}")
        if start != -1 and end != -1 and end > start:
            snippet = content[start : end + 1]
            try:
                return json.loads(snippet)
            except Exception:
                pass
    raise ValueError("LLM returned non-JSON output.")


@app.post("/extract-specs")
async def extract_specs(file: UploadFile = File(...)):
    if not file.filename:
        raise HTTPException(status_code=400, detail="Filename missing.")
    if file.content_type not in (None, "", "application/pdf", "application/octet-stream"):
        raise HTTPException(status_code=400, detail="Only PDF uploads are supported.")

    temp_path = None
    try:
        suffix = Path(file.filename).suffix or ".pdf"
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            content = await file.read()
            if not content:
                raise HTTPException(status_code=400, detail="Uploaded file is empty.")
            tmp.write(content)
            temp_path = tmp.name

        text = extract_last_pages_text(temp_path, pages_to_keep=2)
        messages = build_prompt(text)
        payload = invoke_llm(messages)

        # Ensure all keys are present
        response = {
            "model_name": payload.get("model_name", ""),
            "variant_name": payload.get("variant_name", ""),
            "engine_cc": payload.get("engine_cc", ""),
            "max_power": payload.get("max_power", ""),
            "max_torque": payload.get("max_torque", ""),
            "mileage_arai": payload.get("mileage_arai", ""),
            "transmission": payload.get("transmission", ""),
        }
        return JSONResponse(content=response)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Extraction failed: {exc}") from exc
    finally:
        if temp_path and os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except OSError:
                pass
