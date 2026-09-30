import sys
import uuid
from supabase import create_client, Client

SUPABASE_URL = "https://tuvgfpugfdeondeaxzmi.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1dmdmcHVnZmRlb25kZWF4em1pIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODAwMDE2NiwiZXhwIjoyMTAzNTc2MTY2fQ.ST0hfn5xmqRR_xVNMhDuLvwslQModx7zqa8hw-cgIA8"

def main():
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    ex = {
        "id": str(uuid.uuid4()), 
        "name": "Warrior I", 
        "category": "Yoga", 
        "difficulty": "Intermediate", 
        "duration_seconds": 60, 
        "rest_seconds": 15,
        "muscle_groups": ["Legs", "Core"], 
        "instructions": "Step one foot back, bend the front knee, and raise your arms up.",
        "video_url": "assets/videos/warrior_position.mp4"
    }
    
    try:
        supabase.table("exercises").insert(ex).execute()
        print(f"Successfully inserted: {ex['name']}")
    except Exception as e:
        print(f"Error inserting {ex['name']}: {e}")

if __name__ == "__main__":
    main()

