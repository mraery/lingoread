import re

with open('lib/services/dictionary_service.dart', 'r', encoding='utf-8') as f:
    text = f.read()

pattern = re.compile(r"'([a-zA-Z]+)':\s*const WordDefinition\(word:\s*'([^']+)',\s*turkishMeaning:\s*'([^']+)'")
matches = pattern.findall(text)
same = [k for k, w, m in matches if k == m.lower()]
print(f'Words where turkishMeaning equals the word itself: {len(same)}')
print(f'Sample 40: {same[:40]}')
