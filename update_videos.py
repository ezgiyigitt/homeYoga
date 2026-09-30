import sys
from supabase import create_client, Client

SUPABASE_URL = "https://tuvgfpugfdeondeaxzmi.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1dmdmcHVnZmRlb25kZWF4em1pIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODAwMDE2NiwiZXhwIjoyMTAzNTc2MTY2fQ.ST0hfn5xmqRR_xVNMhDuLvwslQModx7zqa8hw-cgIA8"

def main():
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    updates = [
        {"match": {"name": "Downward-Facing Dog"}, "video_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/downward_facing_dog.mp4"},
        {"match": {"name": "Downward Facing Dog"}, "video_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/downward_facing_dog.mp4"},
        {"match": {"name": "Plank Pose"}, "video_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/plank.mp4"},
        {"match": {"name": "Plank"}, "video_url": "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/plank.mp4"}
    ]
    
    for update in updates:
        try:
            res = supabase.table("exercises").update({"video_url": update["video_url"]}).eq("name", update["match"]["name"]).execute()
            if len(res.data) > 0:
                print(f"Updated {update['match']['name']}")
        except Exception as e:
            print(f"Error updating {update['match']['name']}: {e}")

if __name__ == "__main__":
    main()
