import json
import os
import urllib.request

api_key = os.environ.get('GEMINI_API_KEY', 'YOUR_GEMINI_API_KEY')
url = f'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}'
req = urllib.request.Request(
    url,
    data=b'{"contents": [{"parts":[{"text": "Hello"}]}]}',
    headers={'Content-Type': 'application/json'}
)
try:
    with urllib.request.urlopen(req) as response:
        print(response.read().decode())
except Exception as e:
    print('Error:', e)
    if hasattr(e, 'read'):
        print(e.read().decode())
