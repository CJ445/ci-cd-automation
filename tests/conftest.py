#!/usr/bin/env python3
"""
Pytest configuration and shared fixtures.
"""

import pytest
import sys
import os

# Add parent directory to path to import app
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
