import json
import time
from behavioral_agent import behavioral_agent
from identity_agent import identity_agent
from scam_pattern_agent import scam_pattern_agent
from reputation_agent import reputation_agent
from risk_scoring_agent import risk_scoring_agent
from action_agent import action_agent

# ===== TEST INPUT =====
test_message = "Congratulations! Aap ko remote job mil gai hai salary 80,000 per month. Sirf 2000 registration fee send karo JazzCash 0300-1234567 par. Apply karo agly 24 ghanton mein warna offer cancel ho jaye ga."
test_url = "techpk-jobs.xyz"
test_phone = "03001234567"
test_sender = "TechPk HR"
test_email = "hr@gmail.com"

print("=" * 60)
print("   AITBAAR AI — FULL PIPELINE TEST")
print("=" * 60)
print(f"\nInput Message: {test_message[:60]}...")
print(f"URL: {test_url} | Phone: {test_phone}\n")

# ===== AGENT 1 — BEHAVIORAL =====
print("-" * 40)
print("Running Agent 1: Behavioral Agent...")
time.sleep(3)
behavioral_result = behavioral_agent(test_message)
print("✅ Done!")
if "error" in behavioral_result:
    print(f"   ❌ Error: {behavioral_result['error']}")
else:
    score = behavioral_result.get('manipulation_score') or behavioral_result.get('risk_score', '?')
    tactics = behavioral_result.get('tactics_detected') or behavioral_result.get('detected_tactics', [])
    print(f"   Score: {score}")
    print(f"   Tactics found: {len(tactics)}")

# ===== AGENT 2 — IDENTITY =====
print("\n-" * 40)
print("Running Agent 2: Identity Agent...")
time.sleep(3)
identity_result = identity_agent(test_url, test_phone, test_sender, test_email)
print("✅ Done!")
if "error" in identity_result:
    print(f"   ❌ Error: {identity_result['error']}")
else:
    print(f"   Identity Risk Score: {identity_result.get('identity_risk_score', '?')}")
    print(f"   Impersonating Brand: {identity_result.get('is_impersonating_brand', '?')}")

# ===== AGENT 3 — SCAM PATTERN =====
print("\n-" * 40)
print("Running Agent 3: Scam Pattern Agent...")
time.sleep(3)
pattern_result = scam_pattern_agent(test_message)
print("✅ Done!")
if "error" in pattern_result:
    print(f"   ❌ Error: {pattern_result['error']}")
else:
    print(f"   Pattern Score: {pattern_result.get('pattern_score', '?')}")
    print(f"   Scam Type: {pattern_result.get('scam_type', '?')}")

# ===== AGENT 4 — REPUTATION =====
print("\n-" * 40)
print("Running Agent 4: Reputation Agent...")
time.sleep(3)
reputation_result = reputation_agent(test_phone, test_url)
print("✅ Done!")
if "error" in reputation_result:
    print(f"   ❌ Error: {reputation_result['error']}")
else:
    print(f"   Reputation Score: {reputation_result.get('reputation_score', '?')}")
    print(f"   Known Scammer: {reputation_result.get('known_scammer', '?')}")

# ===== AGENT 5 — RISK SCORING =====
print("\n-" * 40)
print("Running Agent 5: Risk Scoring Agent...")
time.sleep(3)
risk_result = risk_scoring_agent(identity_result, pattern_result, behavioral_result, reputation_result)
print("✅ Done!")
if "error" in risk_result:
    print(f"   ❌ Error: {risk_result['error']}")
else:
    print(f"   Trust Score: {risk_result.get('trust_score', '?')}")
    print(f"   Verdict: {risk_result.get('verdict', '?')}")
    print(f"   Verdict Urdu: {risk_result.get('verdict_urdu', '?')}")

# ===== AGENT 6 — ACTION =====
print("\n-" * 40)
print("Running Agent 6: Action Agent...")
time.sleep(3)
action_result = action_agent(
    trust_score=risk_result.get('trust_score', 50),
    verdict=risk_result.get('verdict', 'SUSPICIOUS'),
    scam_type=pattern_result.get('scam_type', 'UNKNOWN'),
    key_reasons=risk_result.get('key_reasons', [])
)
print("✅ Done!")
if "error" in action_result:
    print(f"   ❌ Error: {action_result['error']}")
else:
    actions = action_result.get('actions', [])
    print(f"   Total Actions: {len(actions)}")
    for a in actions:
        name = a.get('action_name', a.get('action', '?'))
        print(f"   → {name}")

# ===== FINAL RESULT =====
print("\n" + "=" * 60)
print("   FINAL RESULT")
print("=" * 60)
print(f"Trust Score : {risk_result.get('trust_score', '?')} / 100")
print(f"Verdict     : {risk_result.get('verdict', '?')}")
print(f"Urdu Verdict: {risk_result.get('verdict_urdu', '?')}")
print(f"Scam Type   : {pattern_result.get('scam_type', '?')}")
print(f"Confidence  : {risk_result.get('confidence', '?')}")
print(f"Actions     : {action_result.get('total_actions', len(action_result.get('actions', [])))}")
print("=" * 60)
print("\n✅ PIPELINE COMPLETE!")
