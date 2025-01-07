import json
import sys
from pathlib import Path

def fix_arrays(obj):
    """
    Recursively walks the object (dict/list/primitive).
    If it finds a dict with a single key "_" whose value is a list,
    it replaces that dict with the list.
    Otherwise, it keeps traversing.
    """

    if isinstance(obj, dict):
        # If this dict has exactly one key and that key is "_", 
        # and the value is a list, then replace the dict with that list.
        if len(obj) == 1 and "_" in obj and isinstance(obj["_"], list):
            return [fix_arrays(item) for item in obj["_"]]
        else:
            # Otherwise, keep traversing.
            return {k: fix_arrays(v) for k, v in obj.items()}

    elif isinstance(obj, list):
        # If this is a list, fix each element in the list.
        return [fix_arrays(item) for item in obj]

    # If primitive (str, int, float, bool, None), just return as is.
    return obj

def main(input_file, output_file):
    # Load JSON from input file
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Fix the JSON structure
    cleaned_data = fix_arrays(data)

    # Write out the cleaned JSON
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(cleaned_data, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    """
    Usage:
        python clean.py input.json output.json
    """
    if len(sys.argv) < 3:
        print("Usage: python clean.py <input.json> <output.json>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    main(input_path, output_path)
