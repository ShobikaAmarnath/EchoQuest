import json
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI
import os
from dotenv import load_dotenv
load_dotenv()


client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.getenv("OPENROUTER_API_KEY")
)

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/generate-lesson")
async def generate_lesson(category: str, level: int, topic: str):
    print(f"Generating lesson for category: {category}, level: {level}")
    prompt = f"Write a short and engaging {category} lesson for Level {level} students aged 10-12, on the topic: '{topic}'. Use fun, imaginative language and keep it under 150 words. Introduce the concept clearly, include simple real-world examples, and spark curiosity. The tone should be playful, exploratory, and age-appropriate, like you're guiding kids on an exciting discovery. Avoid technical jargon, and end with an encouraging or curious note to keep them interested in learning more."
    response = client.chat.completions.create(
        model="mistralai/mistral-7b-instruct",
        messages=[
            {"role": "system", "content": "You're an educational assistant for kids."},
            {"role": "user", "content": prompt}
        ]
    )
    print("RAW response:", response)
    print("TYPE:", type(response))

# If it's a string, parse it
    if isinstance(response, str):
        response = json.loads(response)

    # return {"lesson": response['choices'][0]['message']['content']} # for TYPE: <dict>
    return {"lesson": response.choices[0].message.content} # for TYPE: <class 'openai.types.chat.chat_completion.ChatCompletion'>

import json
import re

def parse_questions(raw_text):
    questions = []

    # Attempt to parse as JSON first
    try:
        parsed = json.loads(raw_text)
        if isinstance(parsed, list):
            for item in parsed:
                if all(k in item for k in ("question", "options", "correctAnswer", "explanation")):
                    questions.append({
                        "question": item["question"].strip(),
                        "options": [opt.strip() for opt in item["options"]],
                        "correctAnswer": item["correctAnswer"],
                        "explanation": item["explanation"].strip()
                    })
            return questions
    except json.JSONDecodeError:
        pass  # Fall back to manual parsing

    # Manual fallback parser (for "Question 1:"-style formats)
    blocks = re.split(r'\bQuestion \d+:', raw_text)
    
    for block in blocks:
        if not block.strip():
            continue

        try:
            lines = block.strip().split('\n')
            question_text = lines[0].strip()

            options = [line.strip() for line in lines[1:5]]
            answer_line = next(line for line in lines if "Answer:" in line)
            explanation_line = next((line for line in lines if "Explanation:" in line), "")

            correct_letter = re.search(r'Answer:\s*([A-D])', answer_line).group(1)
            correct_index = ord(correct_letter.upper()) - ord('A')

            clean_options = [opt[3:].strip() if len(opt) > 2 and opt[1] == ')' else opt for opt in options]

            explanation_text = re.sub(r'^Explanation:\s*', '', explanation_line).strip()

            questions.append({
                "question": question_text,
                "options": clean_options,
                "correctAnswer": correct_index,
                "explanation": explanation_text
            })

        except Exception as e:
            print("Error parsing question block:", block)
            print("Error:", e)

    return questions



@app.get("/generate-questions")
async def generate_questions(category: str, level: int, topic: str):
    print(f"Generating questions for category: {category}, level: {level} with topic: {topic}")
    prompt = f"""
    Create 5 multiple choice questions with 4 options each on {category} for level {level} based on this lesson content "{topic}", for kids aged 10-12. Mark the correct answer clearly.
    Each question should have:
      - a "question" (string)
      - an "options" array with 4 strings (A, B, C, D)
      - a "correctAnswer" as an index (0-based: 0 for A, 1 for B, etc.)
      - an "explanation" (1-2 sentences)

      Return a list of 5 questions only in JSON format, no extra text.
    """ 
    response = client.chat.completions.create(
        model="mistralai/mistral-7b-instruct",
        messages=[
            {"role": "system", "content": "You're a kids quiz creator. Always respond only with valid JSON format as instructed."},
            {"role": "user", "content": prompt}
        ]
    )
    print("RAW response:", response)
    print("TYPE:", type(response))
    formatted_response = parse_questions(response.choices[0].message.content)
    print("New formatted list = ",formatted_response)
    return {"questions": formatted_response}
