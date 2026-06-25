import os
import json
from groq import Groq
from dotenv import load_dotenv

# Loads dotenv at top
load_dotenv()

# Gets API key from os.environ["GROQ_API_KEY"]
if "GROQ_API_KEY" not in os.environ:
    print("Warning: GROQ_API_KEY not found in environment variables.")

# Reads skills/behavioral_skill.md file at the start
def load_skill_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error loading skill file {filepath}: {e}")
        return ""

SKILL_FILE_PATH = os.path.join(os.path.dirname(__file__), "skills", "behavioral_skill.md")
# Builds system prompt by reading the skill file content
BEHAVIORAL_SKILL_PROMPT = load_skill_file(SKILL_FILE_PATH)

# Has function behavioral_agent(message_text)
def behavioral_agent(message_text):
    try:
        if not BEHAVIORAL_SKILL_PROMPT:
            raise ValueError("Behavioral skill prompt could not be loaded.")

        # Initialize the new Groq client
        client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

        # Build prompts
        system_prompt = f"System Instructions:\n{BEHAVIORAL_SKILL_PROMPT}\n\nPlease analyze the following message according to your skill instructions and return the JSON analysis."
        user_input = f"Message:\n{message_text}"

        # Call API using Groq
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_input}
            ],
            temperature=0.1,
            max_tokens=1000
        )
        
        # Get text
        response_text = response.choices[0].message.content

        # Cleans response (remove ```json and ``` if present)
        cleaned_text = response_text.strip()
        if cleaned_text.startswith("```json"):
            cleaned_text = cleaned_text[7:]
        elif cleaned_text.startswith("```"):
            cleaned_text = cleaned_text[3:]
            
        if cleaned_text.endswith("```"):
            cleaned_text = cleaned_text[:-3]

        cleaned_text = cleaned_text.strip()

        # Returns parsed JSON dict
        result = json.loads(cleaned_text)

        result['manipulation_score'] = result.get('manipulation_score') or result.get('risk_score', 0)
        result['tactics_detected'] = result.get('tactics_detected') or result.get('detected_tactics') or []
        result['dominant_tactic'] = result.get('dominant_tactic', 'none')
        result['evidence'] = result.get('evidence') or []

        return result

    except Exception as e:
        # On any error return the specified dictionary
        return {
            "manipulation_score": 0, 
            "tactics_detected": [], 
            "evidence": [], 
            "dominant_tactic": "none", 
            "explanation": "Error", 
            "error": str(e)
        }

# At bottom if __name__ == "__main__": test with this message and print result
if __name__ == "__main__":
    test_message = "Congratulations! Aap ko remote job mil gai hai salary 80,000 per month. Sirf 2000 registration fee send karo JazzCash 0300-1234567 par. Apply karo agly 24 ghanton mein warna offer cancel ho jaye ga."
    
    print("Testing Behavioral Agent with message:")
    print(f'"{test_message}"\n')
    
    result = behavioral_agent(test_message)
    print("Result:")
    print(json.dumps(result, indent=2))
