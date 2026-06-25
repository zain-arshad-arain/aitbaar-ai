import os
import json
from groq import Groq
from dotenv import load_dotenv

# 5. Loads dotenv at top
load_dotenv()

# 4. Gets API key from os.environ["GROQ_API_KEY"]
if "GROQ_API_KEY" not in os.environ:
    print("Warning: GROQ_API_KEY not found in environment variables.")

# 1. Reads skills/action_skill.md file at the start
def load_skill_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error loading skill file {filepath}: {e}")
        return ""

SKILL_FILE_PATH = os.path.join(os.path.dirname(__file__), "skills", "action_skill.md")
ACTION_SKILL_PROMPT = load_skill_file(SKILL_FILE_PATH)

# 2. Has function action_agent(trust_score, verdict, scam_type, key_reasons)
def action_agent(trust_score, verdict, scam_type, key_reasons):
    try:
        if not ACTION_SKILL_PROMPT:
            raise ValueError("Action skill prompt could not be loaded.")

        # Initialize the new Groq client
        client = Groq(api_key=os.environ.get("GROQ_API_KEY", ""))

        # 7. Sends input data to Groq
        input_data = {
            "trust_score": trust_score,
            "verdict": verdict,
            "scam_type": scam_type,
            "key_reasons": key_reasons
        }

        system_prompt = f"System Instructions:\n{ACTION_SKILL_PROMPT}"
        user_input = f"Please provide the protective action plan based on the following verdict details according to your skill instructions.\n\nInput Details:\n{json.dumps(input_data, indent=2)}\n\nIMPORTANT: You MUST respond with ONLY a valid JSON object. No explanations, no markdown, no bullet points, no extra text. Just the raw JSON object starting with {{ and ending with }}\n\nCRITICAL: Return ONLY a raw JSON object. No markdown, no extra text. Start with {{ end with }}"

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

        # 8. Cleans response and returns parsed JSON dict
        cleaned_text = response_text.strip()
        if cleaned_text.startswith("```json"):
            cleaned_text = cleaned_text[7:]
        elif cleaned_text.startswith("```"):
            cleaned_text = cleaned_text[3:]
            
        if cleaned_text.endswith("```"):
            cleaned_text = cleaned_text[:-3]

        cleaned_text = cleaned_text.strip()

        result = json.loads(cleaned_text)

        result['actions'] = result.get('actions') or result.get('actions_to_take') or []
        result['total_actions'] = len(result['actions'])
        result['severity_level'] = result.get('severity_level', 'high')

        return result

    except Exception as e:
        # On any error return
        return {
            "actions": [], 
            "severity_level": "unknown", 
            "total_actions": 0, 
            "error": str(e)
        }

# At bottom if __name__ == "__main__": test
if __name__ == "__main__":
    test_trust_score = 18
    test_verdict = "CONFIRMED SCAM"
    test_scam_type = "JOB_SCAM"
    test_key_reasons = ["registration fee", "fake company", "urgency"]
    
    print("Testing Action Agent...")
    print(f"Trust Score: {test_trust_score}")
    print(f"Verdict: {test_verdict}")
    print(f"Scam Type: {test_scam_type}")
    print(f"Key Reasons: {test_key_reasons}\n")
    
    result = action_agent(
        trust_score=test_trust_score, 
        verdict=test_verdict, 
        scam_type=test_scam_type, 
        key_reasons=test_key_reasons
    )
    print("Result:")
    print(json.dumps(result, indent=2))
