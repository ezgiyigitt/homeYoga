import urllib.request
import json
url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=invalid_key_xyz'
req = urllib.request.Request(
    url, 
    data=b'{"contents": [{"parts":[{"text": "Hello"}]}]}', 
    headers={'Content-Type': 'application/json'}
)
try:
    with urllib.request.urlopen(req) as response:
        print(response.read().decode())
except Exception as e:
    if hasattr(e, 'read'):
        print(e.read().decode())
