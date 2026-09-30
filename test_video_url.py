import urllib.request

url = "https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/savasana.mp4"
try:
    req = urllib.request.Request(url, method='HEAD')
    with urllib.request.urlopen(req) as response:
        print(f"Status: {response.status}")
        print(f"Content-Type: {response.headers.get('Content-Type')}")
except Exception as e:
    print(f"Error: {e}")
