import json
import sys

def parse_number_string(s):
    """
    Attempt to parse a string into either:
    1) A single float, if it contains exactly one token.
    2) A list of floats, if it contains multiple space-separated tokens.
    If parsing fails, return the original string.
    """
    # Split by whitespace
    tokens = s.strip().split()
    
    # Case 1: Single token -> try converting directly to float
    if len(tokens) == 1:
        try:
            return float(tokens[0])
        except ValueError:
            return s
    
    # Case 2: Multiple tokens -> try converting each to float
    try:
        return [float(tok) for tok in tokens]
    except ValueError:
        return s

def fix_numbers(obj):
    """
    Recursively traverse the JSON structure.
    - If 'obj' is a dict, recurse for each value.
    - If 'obj' is a list, recurse for each element.
    - If 'obj' is a string, try converting to float or list of floats.
    - Otherwise, return 'obj' as is.
    """
    if isinstance(obj, dict):
        return {k: fix_numbers(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [fix_numbers(item) for item in obj]
    elif isinstance(obj, str):
        return parse_number_string(obj)
    else:
        # For int, float, bool, None, etc.
        return obj

def main(input_file, output_file):
    # Load JSON from the input file
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Convert string numbers into actual numbers
    fixed_data = fix_numbers(data)

    # Write the updated JSON to the output file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(fixed_data, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    """
    Usage:
        python convert_numbers.py input.json output.json
    """
    if len(sys.argv) < 3:
        print("Usage: python convert_numbers.py <input.json> <output.json>")
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    main(input_path, output_path)
