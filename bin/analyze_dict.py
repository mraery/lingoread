import re

with open('lib/services/content_service.dart', 'r', encoding='utf-8') as f:
    text = f.read()

words = set(re.findall(r'\b[a-zA-Z]{2,}\b', text.lower()))
print(f'Total unique words in content_service: {len(words)}')

with open('lib/services/dictionary_service.dart', 'r', encoding='utf-8') as f:
    dict_text = f.read()

dict_keys = set(re.findall(r"'([a-zA-Z]{2,})':\s*const WordDefinition", dict_text))
print(f'Total keys in dictionary: {len(dict_keys)}')

missing = sorted(list(words - dict_keys))
print(f'Missing words count: {len(missing)}')
print(f'Sample 30 missing words: {missing[:30]}')
