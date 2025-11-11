# C:\dev\ai\app.py
import os
from dotenv import load_dotenv

# Load variables from .env file
load_dotenv()

# Access a variable
api_key = os.getenv("AI_SERVICE_API_KEY")

print(f"API Key: {api_key}")
print(f"DB Host: {os.getenv('DB_HOST')}")