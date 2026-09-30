import json
import os
import urllib.request

api_key = os.environ.get('GEMINI_API_KEY', 'YOUR_GEMINI_API_KEY')
url = f'https://generativelanguage.googleapis.com/v1beta/models?key={api_key}'
models = []

try:
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode())
        if 'models' in data:
            models.extend([m['name'] for m in data['models']])
        print("Models:", models)
except Exception as e:
    print('Error:', e)
    if hasattr(e, 'read'):
        print(e.read().decode())
