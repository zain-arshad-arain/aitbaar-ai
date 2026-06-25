import os
import json
import re
import ast
from groq import Groq
from dotenv import load_dotenv

# 5. Loads dotenv at top
load_dotenv()

# 4. Gets API key from os.environ["GROQ_API_KEY"]
if "GROQ_API_KEY" not in os.environ:
    print("Warning: GROQ_API_KEY not found in environment variables.")

# 1. Reads skills/scam_pattern_skill.md file at the start
def load_skill_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error loading skill file {filepath}: {e}")
        return ""

SKILL_FILE_PATH = os.path.join(os.path.dirname(__file__), "skills", "scam_pattern_skill.md")
# 6. Builds system prompt by reading the skill file content
PATTERN_SKILL_PROMPT = load_skill_file(SKILL_FILE_PATH)

def clean_json(text):
    text = text.strip()
    # Remove markdown code blocks
    text = text.replace("```json", "").replace("```", "")
    text = text.strip()
    # Strip any text before the first { and after the last }
    start = text.find('{')
    end = text.rfind('}')
    if start != -1 and end != -1:
        text = text[start:end+1]
    elif start != -1:
        text = text[start:]
    return text.strip()

# 2. Has function scam_pattern_agent(message_text)
def scam_pattern_agent(message_text):
    try:
        if not PATTERN_SKILL_PROMPT:
            raise ValueError("Scam pattern skill prompt could not be loaded.")

        # Initialize the new Groq client
        client = Groq(api_key=os.environ.get("GROQ_API_KEY", ""))

        # 7. Sends message_text to Groq
        system_prompt = f"System Instructions:\n{PATTERN_SKILL_PROMPT}\n\nPlease analyze the following message according to your skill instructions and return the JSON analysis."
        user_input = f"Message:\n{message_text}\n\nCRITICAL: Return ONLY a raw JSON object. No markdown, no code blocks, no backticks, no bullet points. Start directly with {{ and end with }}"

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

        # 8. Cleans response
        cleaned_text = clean_json(response_text)

        # 1. Remove special unicode characters
        cleaned_text = re.sub(r'[\u200b\u200c\u200d\ufeff]', '', cleaned_text)

        # 2. Fix trailing commas before } or ]
        cleaned_text = re.sub(r',\s*([}\]])', r'\1', cleaned_text)

        # 3. Fix any apostrophes or smart quotes
        cleaned_text = cleaned_text.replace('“', '"').replace('”', '"').replace('‘', "'").replace('’', "'")

        # 4. Make the JSON parsing more robust
        try:
            # 9. Returns parsed JSON dict
            result = json.loads(cleaned_text)
        except json.JSONDecodeError:
            try:
                # Fallback to ast.literal_eval to handle Python-like dict strings
                eval_text = cleaned_text.replace('true', 'True').replace('false', 'False').replace('null', 'None')
                result = ast.literal_eval(eval_text)
            except (ValueError, SyntaxError) as e:
                raise ValueError(f"Could not parse JSON even with robust fallback. Error: {e}")
                
        result['pattern_score'] = result.get('pattern_score', 0)
        result['scam_type'] = result.get('scam_type') or (result.get('detected_categories', [{}])[0].get('category_name', 'UNKNOWN') if result.get('detected_categories') else 'UNKNOWN')
        result['matched_patterns'] = result.get('matched_patterns') or result.get('trigger_phrases_found') or []
        result['requests_money'] = result.get('requests_money', False)

        return result

    except Exception as e:
        # On any error return the specified dictionary
        return {
            "pattern_score": 0, 
            "scam_type": "UNKNOWN", 
            "confidence": "low", 
            "matched_patterns": [], 
            "suspicious_phrases": [], 
            "requests_money": False, 
            "requests_nic": False, 
            "requests_otp": False, 
            "explanation": "Error", 
            "error": str(e)
        }

# At bottom if __name__ == "__main__": test
if __name__ == "__main__":
    test_message = "Congratulations! Aap ko remote job mil gai hai salary 80,000 per month. Sirf 2000 registration fee send karo JazzCash 0300-1234567 par. Apply karo agly 24 ghanton mein warna offer cancel ho jaye ga."
    
    print("Testing Scam Pattern Agent with message:")
    print(f'"{test_message}"\n')
    
    result = scam_pattern_agent(test_message)
    print("Result:")
    print(json.dumps(result, indent=2))
