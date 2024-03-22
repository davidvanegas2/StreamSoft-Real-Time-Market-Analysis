"""Utility functions for producer."""
import json


def format_dict_to_json(data: dict) -> str:
    """Format dictionary to JSON string."""
    return json.dumps(data)
