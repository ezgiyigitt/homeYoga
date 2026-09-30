import sys
from supabase import create_client, Client

SUPABASE_URL = "https://tuvgfpugfdeondeaxzmi.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1dmdmcHVnZmRlb25kZWF4em1pIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODAwMDE2NiwiZXhwIjoyMTAzNTc2MTY2fQ.ST0hfn5xmqRR_xVNMhDuLvwslQModx7zqa8hw-cgIA8"

def main():
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # We only want to keep the 9 exact names that our app uses.
    valid_names = [
        "Cobra Pose",
        "Downward Facing Dog",
        "Plank",
        "Savasana",
        "Warrior I",
        "Child's Pose",
        "Cat-Cow Stretch",
        "Seated Forward Bend",
        "Supine Spinal Twist"
    ]
    
    try:
        # Fetch all records
        data = supabase.table("exercises").select("id, name").execute()
        
        deleted_count = 0
        for ex in data.data:
            # If the exact name is not in our valid list, delete it.
            if ex["name"] not in valid_names:
                supabase.table("exercises").delete().eq("id", ex["id"]).execute()
                print(f"Deleted duplicate/old record: {ex['name']}")
                deleted_count += 1
                
        print(f"\nCleanup complete! Removed {deleted_count} old/duplicate records.")
    except Exception as e:
        print(f"Error during cleanup: {e}")

if __name__ == "__main__":
    main()
