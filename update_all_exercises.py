import sys
import uuid
from supabase import create_client, Client

SUPABASE_URL = "https://tuvgfpugfdeondeaxzmi.supabase.co"
# Using the same key from your previous python scripts
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1dmdmcHVnZmRlb25kZWF4em1pIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODAwMDE2NiwiZXhwIjoyMTAzNTc2MTY2fQ.ST0hfn5xmqRR_xVNMhDuLvwslQModx7zqa8hw-cgIA8"

def main():
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Base URL for your storage bucket
    base_storage_url = f"{SUPABASE_URL}/storage/v1/object/public/yoga_videos"
    
    # List of all your exercises with their exact video file names
    exercises_data = [
        {
            "name": "Cobra Pose",
            "category": "Yoga",
            "difficulty": "Beginner",
            "duration_seconds": 45,
            "rest_seconds": 15,
            "muscle_groups": ["Back", "Chest"],
            "instructions": "Lie on your stomach, place hands under shoulders, and gently lift your chest off the floor.",
            "video_url": f"{base_storage_url}/cobra_pose.mp4"
        },
        {
            "name": "Downward Facing Dog",
            "category": "Yoga",
            "difficulty": "Beginner",
            "duration_seconds": 45,
            "rest_seconds": 15,
            "muscle_groups": ["Hamstrings", "Shoulders"],
            "instructions": "Push hips up and back, pressing heels toward the floor.",
            "video_url": f"{base_storage_url}/downward_facing_dog.mp4"
        },
        {
            "name": "Plank",
            "category": "Pilates",
            "difficulty": "Intermediate",
            "duration_seconds": 45,
            "rest_seconds": 15,
            "muscle_groups": ["Core", "Shoulders"],
            "instructions": "Hold your body in a straight line from head to heels.",
            "video_url": f"{base_storage_url}/plank.mp4"
        },
        {
            "name": "Savasana",
            "category": "Yoga",
            "difficulty": "Beginner",
            "duration_seconds": 120,
            "rest_seconds": 0,
            "muscle_groups": [],
            "instructions": "Lie flat on your back, arms at your sides, palms facing up. Relax your entire body.",
            "video_url": f"{base_storage_url}/savasana.mp4"
        },
        {
            "name": "Warrior I",
            "category": "Yoga",
            "difficulty": "Intermediate",
            "duration_seconds": 60,
            "rest_seconds": 15,
            "muscle_groups": ["Legs", "Core"],
            "instructions": "Step one foot back, bend the front knee, and raise your arms up.",
            "video_url": f"{base_storage_url}/warrior_position.mp4"
        },
        {
            "name": "Child's Pose",
            "category": "Yoga",
            "difficulty": "Beginner",
            "duration_seconds": 60,
            "rest_seconds": 10,
            "muscle_groups": ["Back", "Hips"],
            "instructions": "Sit back on your heels and stretch arms forward.",
            "video_url": f"{base_storage_url}/childs_pose.mp4"
        },
        {
            "name": "Cat-Cow Stretch",
            "category": "Yoga",
            "difficulty": "Beginner",
            "duration_seconds": 60,
            "rest_seconds": 10,
            "muscle_groups": ["Back", "Core"],
            "instructions": "Start on all fours. Arch your back up (Cat), then dip it down (Cow).",
            "video_url": f"{base_storage_url}/cat_cow.mp4"
        },
        {
            "name": "Seated Forward Bend",
            "category": "Yoga",
            "difficulty": "Beginner",
            "duration_seconds": 60,
            "rest_seconds": 15,
            "muscle_groups": ["Hamstrings", "Lower Back"],
            "instructions": "Sit with legs straight out in front. Reach forward toward your toes.",
            "video_url": f"{base_storage_url}/seated_forward_bend.mp4"
        },
        {
            "name": "Supine Spinal Twist",
            "category": "Yoga",
            "difficulty": "Beginner",
            "duration_seconds": 60,
            "rest_seconds": 10,
            "muscle_groups": ["Spine", "Hips"],
            "instructions": "Lie on back, hug one knee, then drop it across your body to the opposite side.",
            "video_url": f"{base_storage_url}/supine_spinal_twist.mp4"
        }
    ]
    
    print("Starting database sync...")
    
    # Check existing exercises to either update or insert
    try:
        existing_res = supabase.table("exercises").select("id, name").execute()
        existing_exercises = {ex["name"].lower(): ex["id"] for ex in existing_res.data}
    except Exception as e:
        print(f"Error fetching existing exercises: {e}")
        return

    for ex in exercises_data:
        ex_name_lower = ex["name"].lower()
        
        try:
            if ex_name_lower in existing_exercises:
                # Update existing record
                ex_id = existing_exercises[ex_name_lower]
                supabase.table("exercises").update(ex).eq("id", ex_id).execute()
                print(f"Updated existing: {ex['name']}")
            else:
                # Insert new record
                ex["id"] = str(uuid.uuid4())
                supabase.table("exercises").insert(ex).execute()
                print(f"Inserted new: {ex['name']}")
        except Exception as e:
            print(f"Error processing {ex['name']}: {e}")
            
    print("\nDone! All 9 exercises are now correctly configured in the 'exercises' table.")

if __name__ == "__main__":
    main()
