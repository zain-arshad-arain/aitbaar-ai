import os
import json
from groq import Groq
from dotenv import load_dotenv

# 8. Loads dotenv at top
load_dotenv()

# 7. Gets API key from os.environ["GROQ_API_KEY"]
if "GROQ_API_KEY" not in os.environ:
    print("Warning: GROQ_API_KEY not found in environment variables.")

# 1. Reads skills/reputation_skill.md file at the start
def load_skill_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error loading skill file {filepath}: {e}")
        return ""

SKILL_FILE_PATH = os.path.join(os.path.dirname(__file__), "skills", "reputation_skill.md")
REPUTATION_SKILL_PROMPT = load_skill_file(SKILL_FILE_PATH)
DATABASE_FILE_PATH = os.path.join(os.path.dirname(__file__), "scam_database.json")

# 2. Has function reputation_agent(phone, url)
def reputation_agent(phone, url):
    try:
        # 3. Loads scam_database.json and finds matching entries
        matches = []
        if os.path.exists(DATABASE_FILE_PATH):
            with open(DATABASE_FILE_PATH, 'r', encoding='utf-8') as f:
                try:
                    db = json.load(f)
                    # Handle both list and dict-with-records formats
                    records = db if isinstance(db, list) else db.get('records', db.get('scams', []))
                    
                    for record in records:
                        rec_phone = record.get('phone')
                        rec_url = record.get('url')
                        # Check matches
                        if (phone and rec_phone and phone == rec_phone) or \
                           (url and rec_url and url == rec_url):
                            matches.append(record)
                except json.JSONDecodeError:
                    pass

        # 4. If NO matches: return directly without calling Groq
        if not matches:
            return {
                "reputation_score": 5, 
                "times_reported": 0, 
                "last_reported": None, 
                "known_scammer": False, 
                "explanation": "No previous reports found"
            }

        if not REPUTATION_SKILL_PROMPT:
            raise ValueError("Reputation skill prompt could not be loaded.")

        # Initialize the new Groq client
        client = Groq(api_key=os.environ.get("GROQ_API_KEY", ""))

        # 6. Send matches as JSON string to Groq
        system_prompt = f"System Instructions:\n{REPUTATION_SKILL_PROMPT}"
        user_input = f"Please analyze the following matched database records according to your skill instructions and return the JSON analysis.\n\nRecords:\n{json.dumps(matches, indent=2)}\n\nIMPORTANT: You MUST respond with ONLY a valid JSON object. No explanations, no markdown, no bullet points, no extra text. Just the raw JSON object starting with {{ and ending with }}"

        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_input}
            ],
            temperature=0.1,
            max_tokens=2048

        )
        
        # Get text
        response_text = response.choices[0].message.content

        # 9. Cleans response and returns parsed JSON dict
        cleaned_text = response_text.strip()
        if cleaned_text.startswith("```json"):
            cleaned_text = cleaned_text[7:]
        elif cleaned_text.startswith("```"):
            cleaned_text = cleaned_text[3:]
            
        if cleaned_text.endswith("```"):
            cleaned_text = cleaned_text[:-3]

        cleaned_text = cleaned_text.strip()

        result = json.loads(cleaned_text)
        return result

    except Exception as e:
        # On any error return
        return {
            "reputation_score": 0, 
            "times_reported": 0, 
            "last_reported": None, 
            "known_scammer": False, 
            "explanation": "Error", 
            "error": str(e)
        }

# At bottom if __name__ == "__main__": test
if __name__ == "__main__":
    test_phone = "03001234567"
    test_url = "techpk-jobs.xyz"
    
    print("Testing Reputation Agent with:")
    print(f"Phone: {test_phone}")
    print(f"URL: {test_url}\n")
    
    result = reputation_agent(phone=test_phone, url=test_url)
    print("Result:")
    print(json.dumps(result, indent=2))
