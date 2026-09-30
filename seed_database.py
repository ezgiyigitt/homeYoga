import sys
from supabase import create_client, Client

SUPABASE_URL = "https://tuvgfpugfdeondeaxzmi.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1dmdmcHVnZmRlb25kZWF4em1pIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODAwMDE2NiwiZXhwIjoyMTAzNTc2MTY2fQ.ST0hfn5xmqRR_xVNMhDuLvwslQModx7zqa8hw-cgIA8"

def main():
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Let's insert some mock exercises so the Explore screen and Plan screen have data
    import uuid
    
    exercises = [
        {
            "id": str(uuid.uuid4()), "name": "Cat-Cow Stretch", "category": "Yoga",
            "difficulty": "beginner", "duration_seconds": 60, "rest_seconds": 10,
            "muscle_groups": ["Back", "Core"], "instructions": "Arch your back up, then dip it down.",
            "video_url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        },
        {
            "id": str(uuid.uuid4()), "name": "Downward Facing Dog", "category": "Yoga",
            "difficulty": "beginner", "duration_seconds": 45, "rest_seconds": 15,
            "muscle_groups": ["Hamstrings", "Shoulders"], "instructions": "Push hips up and back.",
            "video_url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        },
        {
            "id": str(uuid.uuid4()), "name": "Sun Salutation", "category": "Yoga",
            "difficulty": "beginner", "duration_seconds": 90, "rest_seconds": 10,
            "muscle_groups": ["Full Body"], "instructions": "Flow through the sequence slowly and breathe deeply.",
            "video_url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        },
        {
            "id": str(uuid.uuid4()), "name": "Plank", "category": "Pilates",
            "difficulty": "intermediate", "duration_seconds": 45, "rest_seconds": 15,
            "muscle_groups": ["Core", "Shoulders"], "instructions": "Hold body in a straight line.",
            "video_url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        },
        {
            "id": str(uuid.uuid4()), "name": "Glute Bridge", "category": "Pilates",
            "difficulty": "beginner", "duration_seconds": 60, "rest_seconds": 15,
            "muscle_groups": ["Glutes", "Core"], "instructions": "Lift your hips while keeping the ribs down.",
            "video_url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        },
        {
            "id": str(uuid.uuid4()), "name": "Seated Forward Fold", "category": "Stretching",
            "difficulty": "beginner", "duration_seconds": 60, "rest_seconds": 10,
            "muscle_groups": ["Hamstrings", "Lower Back"], "instructions": "Hinge at the hips and keep the spine long.",
            "video_url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        },
        {
            "id": str(uuid.uuid4()), "name": "Thread the Needle", "category": "Stretching",
            "difficulty": "beginner", "duration_seconds": 45, "rest_seconds": 12,
            "muscle_groups": ["Shoulders", "Upper Back"], "instructions": "Slide one arm underneath the other and gently open the chest.",
            "video_url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        },
        {
            "id": str(uuid.uuid4()), "name": "Breathing Reset", "category": "Breathing",
            "difficulty": "beginner", "duration_seconds": 60, "rest_seconds": 5,
            "muscle_groups": ["Breathing"], "instructions": "Inhale slowly through the nose and exhale longer than the inhale.",
            "video_url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        },
        {
            "id": str(uuid.uuid4()), "name": "Box Breathing", "category": "Breathing",
            "difficulty": "beginner", "duration_seconds": 90, "rest_seconds": 5,
            "muscle_groups": ["Breathing"], "instructions": "Inhale, hold, exhale, hold in even counts.",
            "video_url": "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
        }
    ]
    
    print("Seeding exercises...")
    for ex in exercises:
        try:
            supabase.table("exercises").upsert(ex).execute()
            print(f"Inserted: {ex['name']}")
        except Exception as e:
            print(f"Error inserting {ex['name']}: {e}")

    print("Done!")

if __name__ == "__main__":
    main()
