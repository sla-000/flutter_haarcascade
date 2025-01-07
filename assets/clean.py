import json
import sys

def fix_classifiers(classifiers):
    fixed_classifiers = []
    for classifier in classifiers:
        fixed_classifier = {}
        fixed_classifier['feature_index'] = classifier['internalNodes'][2]
        fixed_classifier['threshold'] = classifier['internalNodes'][3]
        fixed_classifier['leaf_x'] = classifier['leafValues'][0]
        fixed_classifier['leaf_y'] = classifier['leafValues'][1]
        fixed_classifiers.append(fixed_classifier)
    return fixed_classifiers

def fix_stages(stages):
    fixed_stages = []
    for stage in stages:
        fixed_stage = {}
        fixed_stage['threshold'] = stage['stageThreshold']
        fixed_stage['weak_classifers'] = fix_classifiers(stage['weakClassifiers'])
        fixed_stages.append(fixed_stage)
    return fixed_stages

def fix_rects(rects):
    fixed_rects = []
    for rect in rects:
        fixed_rect = {}
        fixed_rect['x'] = rect[0]
        fixed_rect['y'] = rect[1]
        fixed_rect['width'] = rect[2]
        fixed_rect['height'] = rect[3]
        fixed_rect['weight'] = rect[4]
        fixed_rects.append(fixed_rect)
    return fixed_rects

def fix_features(features):
    fixed_features = []
    for feature in features:
        fixed_feature = {}
        fixed_feature['rectangles'] = fix_rects(feature['rects'])
        fixed_features.append(fixed_feature)
    return fixed_features

def main():
    # Load JSON from the input file
    with open('haarcascade.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixed_stages = fix_stages(data['stages'])

    # Write the updated JSON to the output file
    with open('stages.json', 'w', encoding='utf-8') as f:
        json.dump(fixed_stages, f, ensure_ascii=False, indent=4)

    fixed_features = fix_features(data['features'])

    # Write the updated JSON to the output file
    with open('features.json', 'w', encoding='utf-8') as f:
        json.dump(fixed_features, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()