import re

with open('lib/services/content_service.dart', 'r', encoding='utf-8') as f:
    text = f.read()

words = set(re.findall(r'\b[a-zA-Z]{2,}\b', text.lower()))

with open('lib/services/dictionary_service.dart', 'r', encoding='utf-8') as f:
    dict_text = f.read()

dict_keys = set(re.findall(r"'([a-zA-Z]{2,})':\s*const WordDefinition", dict_text))
missing = sorted(list(words - dict_keys))

with open('bin/missing_words.txt', 'w', encoding='utf-8') as out:
    for w in missing:
        out.write(w + '\n')

print(f'Wrote {len(missing)} words to bin/missing_words.txt')
