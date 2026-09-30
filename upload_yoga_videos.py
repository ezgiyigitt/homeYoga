import os
import sys
from supabase import create_client, Client

# Use the Service Role Key to bypass RLS for administrative uploads
SUPABASE_URL = "https://tuvgfpugfdeondeaxzmi.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1dmdmcHVnZmRlb25kZWF4em1pIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4ODAwMDE2NiwiZXhwIjoyMTAzNTc2MTY2fQ.ST0hfn5xmqRR_xVNMhDuLvwslQModx7zqa8hw-cgIA8"

def main():
    if not SUPABASE_URL or not SUPABASE_KEY:
        print("Missing Supabase credentials.")
        sys.exit(1)
        
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Define local videos folder
    videos_folder = "assets/videos"
    if not os.path.exists(videos_folder):
        os.makedirs(videos_folder)
        print(f"Created {videos_folder}. Please put your .mp4 files there and run this script again.")
        sys.exit(0)
        
    files = [f for f in os.listdir(videos_folder) if f.endswith('.mp4')]
    if not files:
        print(f"No .mp4 files found in {videos_folder}.")
        sys.exit(0)
        
    print(f"Found {len(files)} videos. Uploading to 'yoga_videos' bucket...")
    
    for file_name in files:
        file_path = os.path.join(videos_folder, file_name)
        with open(file_path, 'rb') as f:
            try:
                # Upload to storage
                print(f"Uploading {file_name}...")
                res = supabase.storage.from_("yoga_videos").upload(
                    path=file_name,
                    file=f,
                    file_options={"content-type": "video/mp4"}
                )
                
                # Get public URL
                public_url = supabase.storage.from_("yoga_videos").get_public_url(file_name)
                print(f"Success! Public URL: {public_url}")
                
            except Exception as e:
                print(f"Error uploading {file_name}: {e}")

if __name__ == "__main__":
    main()
