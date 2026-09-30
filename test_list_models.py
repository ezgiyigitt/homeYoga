import json
import os
import urllib.request

api_key = os.environ.get('GEMINI_API_KEY', 'YOUR_GEMINI_API_KEY')
url = f'https://generativelanguage.googleapis.com/v1beta/models?key={api_key}'
try:
    with urllib.request.urlopen(url) as response:
        print(response.read().decode())
except Exception as e:
    print('Error:', e)
    if hasattr(e, 'read'):
        print(e.read().decode())
