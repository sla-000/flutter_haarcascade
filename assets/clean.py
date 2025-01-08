import json

def combine_weak_classifiers(weak_classifiers, features):
    combined_weak_classifiers = []
    for weak_classifier in weak_classifiers:
        combined_weak_classifier = {}
        combined_weak_classifier['features'] = features[weak_classifier['feature_index']]['rectangles']
        combined_weak_classifier['threshold'] = weak_classifier['threshold']
        combined_weak_classifier['leaf_x'] = weak_classifier['leaf_x']
        combined_weak_classifier['leaf_y'] = weak_classifier['leaf_y']
        combined_weak_classifiers.append(combined_weak_classifier)
    return combined_weak_classifiers

def combine(stage, features):
    combined_stage = {}
    combined_stage['threshold'] = stage['threshold']
    combined_stage['weak_classifiers'] = combine_weak_classifiers(stage['weak_classifers'], features)
    return combined_stage

def main():
    # Load JSON from the input file
    with open('features.json', 'r', encoding='utf-8') as f:
        features = json.load(f)
    
    with open('stages.json', 'r', encoding='utf-8') as f:
        stages = json.load(f)

    combined = []
    for stage in stages:
        combined_stage = combine(stage, features)
        combined.append(combined_stage)
    
    # Write the combined JSON to the output file
    with open('combined.json', 'w', encoding='utf-8') as f:
        json.dump(combined, f, indent=4)

if __name__ == "__main__":
    main()