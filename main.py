import json
from identity_agent import identity_agent
from behavioral_agent import behavioral_agent
from reputation_agent import reputation_agent
from scam_pattern_agent import scam_pattern_agent
from risk_scoring_agent import risk_scoring_agent
from action_agent import action_agent

def run_pipeline(message_text, url, phone, sender_name, email):
    # 1. Run Identity Agent
    identity_result = identity_agent(url, phone, sender_name, email)
    
    # 2. Run Scam Pattern Agent
    pattern_result = scam_pattern_agent(message_text)
    
    # 3. Run Behavioral Agent
    behavioral_result = behavioral_agent(message_text)
    
    # 4. Run Reputation Agent
    reputation_result = reputation_agent(phone, url)
    
    # 5. Run Risk Scoring Agent
    risk_result = risk_scoring_agent(
        identity_result=identity_result,
        pattern_result=pattern_result,
        behavioral_result=behavioral_result,
        reputation_result=reputation_result
    )
    
    # 6. Run Action Agent
    # Extract required inputs for Action Agent from previous results
    trust_score = risk_result.get("trust_score", risk_result.get("final_trust_score", 50))
    verdict = risk_result.get("verdict", risk_result.get("verdict_english", "UNKNOWN"))
    
    scam_type = pattern_result.get("scam_type", "UNKNOWN")
    if scam_type == "UNKNOWN" and pattern_result.get("detected_categories"):
        scam_type = pattern_result.get("detected_categories")[0].get("category_name", "UNKNOWN")
        
    key_reasons = risk_result.get("key_reasons", [])
    
    action_result = action_agent(
        trust_score=trust_score,
        verdict=verdict,
        scam_type=scam_type,
        key_reasons=key_reasons
    )
    
    # Combine all results into a single dictionary
    complete_result = {
        "identity_analysis": identity_result,
        "scam_pattern_analysis": pattern_result,
        "behavioral_analysis": behavioral_result,
        "reputation_analysis": reputation_result,
        "risk_scoring": risk_result,
        "action_plan": action_result
    }
    
    return complete_result

if __name__ == "__main__":
    # Test data
    test_message = "Congratulations! Aap ko remote job mil gai hai salary 80,000 per month. Sirf 2000 registration fee send karo JazzCash 0300-1234567 par."
    
    print("Running full pipeline...")
    result = run_pipeline(
        message_text=test_message,
        url="techpk-jobs.xyz",
        phone="03001234567",
        sender_name="TechPk HR",
        email="hr@gmail.com"
    )
    
    print("\nFinal Complete Result:")
    print(json.dumps(result, indent=2))
