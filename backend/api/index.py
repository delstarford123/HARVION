import os
import sys

# Ensure parent directory (backend/) is on sys.path so modules and blueprints import cleanly
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)

if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)

from app import app

# Vercel WSGI / Serverless handler
handler = app

