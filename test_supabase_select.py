import sys
from supabase import create_client, Client

SUPABASE_URL = "https://tuvgfpugfdeondeaxzmi.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1dmdmcHVnZmRlb25kZWF4em1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgwMDAxNjYsImV4cCI6MjEwMzU3NjE2Nn0.ENe10_-nXbRTxyjUp385_VQZHoRVcT-rog05YvQHXhM" # ANON KEY from supabase_config.dart

def main():
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    try:
        data = supabase.table("exercises").select("*").execute()
        for ex in data.data:
            print(f"Name: {ex.get('name')}, Video URL: {ex.get('video_url')}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
