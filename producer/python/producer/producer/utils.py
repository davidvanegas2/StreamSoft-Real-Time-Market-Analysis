"""Utility functions for producer."""
import json
import sys


def format_dict_to_json(data: dict) -> str:
    """Format dictionary to JSON string."""
    return json.dumps(data)


def get_average_size(data: list) -> float:
    """Get the average size on Kilobytes of a list of JSON objects."""
    return (
        sum(sys.getsizeof(json.dumps(d).encode("utf-8")) for d in data)
        / len(data)
        / 1024
    )
