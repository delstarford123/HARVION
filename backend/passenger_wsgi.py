import sys
import os

# Set current directory on Python path so all modules are discoverable
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

# Import the Flask application as 'application' (expected by WSGI / Phusion Passenger)
from app import app as application

