import uuid
from supabase import create_client, Client

SUPABASE_URL = "https://tuvgfpugfdeondeaxzmi.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1dmdmcHVnZmRlb25kZWF4em1pIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODAwMDE2NiwiZXhwIjoyMTAzNTc2MTY2fQ.ST0hfn5xmqRR_xVNMhDuLvwslQModx7zqa8hw-cgIA8"

def main():
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # 1. Restore Warrior III Hold
    supabase.table("exercises").update({
        "video_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/warrior_III_hold.mp4",
        "audio_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/warrior_III.mp3"
    }).eq("name", "Warrior III Hold").execute()
    print("Restored Warrior III Hold.")
    
    # 2. Check if exact Warrior II exists
    existing = supabase.table("exercises").select("*").eq("name", "Warrior II").execute()
    if existing.data and len(existing.data) > 0:
        print("Warrior II exists, updating...")
        row_id = existing.data[0]["id"]
        res = supabase.table("exercises").update({
            "video_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/wariior_2_right.mp4,https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/warrior_2_left.mp4",
            "audio_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/warrior_2.mp3"
        }).eq("id", row_id).execute()
        print("Updated Warrior II:", res.data)
        return

    ex = {
        "id": str(uuid.uuid4()),
        "name": "Warrior II",
        "description": "A foundational standing pose that builds lower body strength, opens the hips and chest, and enhances stability and focus.",
        "category": "Yoga",
        "difficulty": "Beginner",
        "duration_seconds": 60,
        "rest_seconds": 15,
        "muscle_groups": ["Legs", "Hips", "Core", "Shoulders"],
        "instructions": "Step your feet wide apart. Turn right foot out 90 degrees, bend the right knee over the ankle, and extend your arms parallel to the floor with gaze forward. Switch to the left side halfway.",
        "video_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/wariior_2_right.mp4,https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/warrior_2_left.mp4",
        "audio_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/warrior_2.mp3",
        "xp_reward": 10
    }
    
    try:
        res = supabase.table("exercises").insert(ex).execute()
        print("Successfully inserted Warrior II:", res.data)
    except Exception as e:
        print("Error inserting Warrior II:", e)

if __name__ == "__main__":
    main()
