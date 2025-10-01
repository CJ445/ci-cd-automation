#!/usr/bin/env python3
"""
Unit tests for the Flask application.
"""

import pytest
import json
from app import app, VERSION

@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

class TestHomeEndpoint:
    """Test cases for the home endpoint."""

    def test_home_returns_200(self, client):
        """Test that home endpoint returns 200 status code."""
        response = client.get('/')
        assert response.status_code == 200

    def test_home_returns_json(self, client):
        """Test that home endpoint returns JSON."""
        response = client.get('/')
        assert response.content_type == 'application/json'

    def test_home_contains_version(self, client):
        """Test that home endpoint contains version information."""
        response = client.get('/')
        data = json.loads(response.data)
        assert 'version' in data
        assert data['version'] == VERSION

    def test_home_contains_required_fields(self, client):
        """Test that home endpoint contains all required fields."""
        response = client.get('/')
        data = json.loads(response.data)
        required_fields = ['service', 'version', 'build_sha', 'status', 'timestamp']
        for field in required_fields:
            assert field in data

class TestHealthEndpoint:
    """Test cases for the health endpoint."""

    def test_health_returns_200(self, client):
        """Test that health endpoint returns 200 status code."""
        response = client.get('/health')
        assert response.status_code == 200

    def test_health_returns_healthy_status(self, client):
        """Test that health endpoint returns healthy status."""
        response = client.get('/health')
        data = json.loads(response.data)
        assert data['status'] == 'healthy'

    def test_health_contains_hostname(self, client):
        """Test that health endpoint contains hostname."""
        response = client.get('/health')
        data = json.loads(response.data)
        assert 'hostname' in data
        assert data['hostname'] is not None

class TestEchoEndpoint:
    """Test cases for the echo endpoint."""

    def test_echo_returns_200(self, client):
        """Test that echo endpoint returns 200 status code."""
        test_data = {'message': 'test'}
        response = client.post('/api/echo',
                               data=json.dumps(test_data),
                               content_type='application/json')
        assert response.status_code == 200

    def test_echo_returns_posted_data(self, client):
        """Test that echo endpoint returns the posted data."""
        test_data = {'message': 'hello', 'number': 42}
        response = client.post('/api/echo',
                               data=json.dumps(test_data),
                               content_type='application/json')
        data = json.loads(response.data)
        assert data['received'] == test_data

    def test_echo_includes_version(self, client):
        """Test that echo endpoint includes version information."""
        test_data = {'test': 'data'}
        response = client.post('/api/echo',
                               data=json.dumps(test_data),
                               content_type='application/json')
        data = json.loads(response.data)
        assert 'version' in data

class TestInfoEndpoint:
    """Test cases for the info endpoint."""

    def test_info_returns_200(self, client):
        """Test that info endpoint returns 200 status code."""
        response = client.get('/api/info')
        assert response.status_code == 200

    def test_info_contains_application_details(self, client):
        """Test that info endpoint contains application details."""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert 'application' in data
        assert 'name' in data['application']
        assert 'version' in data['application']

    def test_info_contains_system_details(self, client):
        """Test that info endpoint contains system details."""
        response = client.get('/api/info')
        data = json.loads(response.data)
        assert 'system' in data
        assert 'hostname' in data['system']

class TestErrorHandlers:
    """Test cases for error handlers."""

    def test_404_handler(self, client):
        """Test that 404 errors are handled correctly."""
        response = client.get('/nonexistent')
        assert response.status_code == 404
        data = json.loads(response.data)
        assert 'error' in data
        assert data['error'] == 'Not Found'

    def test_404_includes_version(self, client):
        """Test that 404 response includes version."""
        response = client.get('/nonexistent')
        data = json.loads(response.data)
        assert 'version' in data
