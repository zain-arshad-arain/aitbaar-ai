from groq import Groq
import os
from dotenv import load_dotenv

load_dotenv()

client = Groq(api_key=os.environ.get('GROQ_API_KEY'))

# Test with identity skill content directly
f = open('skills/identity_skill.md', encoding='utf-8')
skill_content = f.read()
f.close()

print(f"Skill length: {len(skill_content)} chars")

response = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[
        {"role": "system", "content": skill_content},
        {"role": "user", "content": "URL: hbl-secure-login.xyz\nPhone: 03001234567\nSender: HBL Bank Officer\nEmail: hbl.officer@gmail.com"}
    ],
    temperature=0.1,
    max_tokens=2048
)

raw = response.choices[0].message.content
print("FINISH REASON:", response.choices[0].finish_reason)
print("RAW RESPONSE:", repr(raw[:500]))