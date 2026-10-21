import re

with open('lib/services/content_service.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Extract paragraphs blocks
paragraph_blocks = re.findall(r'paragraphs:\s*\[(.*?)\]\s*,', text, re.DOTALL)
print(f'Found {len(paragraph_blocks)} paragraph blocks')

story_words = set()
for pb in paragraph_blocks:
    # Match single-quoted or double-quoted strings
    strings = re.findall(r"'([^'\\]*(?:\\.[^'\\]*)*)'", pb)
    for s in strings:
        words = re.findall(r"[a-zA-Z]+(?:'[a-zA-Z]+)?", s.lower())
        for w in words:
            clean = re.sub(r"^[^a-zA-Z]+|[^a-zA-Z]+$", "", w)
            if len(clean) >= 1:
                story_words.add(clean)

titles = re.findall(r"title:\s*'([^']*)'", text)
for t in titles:
    words = re.findall(r"[a-zA-Z]+(?:'[a-zA-Z]+)?", t.lower())
    for w in words:
        clean = re.sub(r"^[^a-zA-Z]+|[^a-zA-Z]+$", "", w)
        if len(clean) >= 1:
            story_words.add(clean)

subtitles = re.findall(r"subtitle:\s*'([^']*)'", text)
for t in subtitles:
    words = re.findall(r"[a-zA-Z]+(?:'[a-zA-Z]+)?", t.lower())
    for w in words:
        clean = re.sub(r"^[^a-zA-Z]+|[^a-zA-Z]+$", "", w)
        if len(clean) >= 1:
            story_words.add(clean)

print(f'Total distinct story words: {len(story_words)}')

with open('lib/services/dictionary_service.dart', 'r', encoding='utf-8') as f:
    dict_text = f.read()

dict_keys = set(re.findall(r"'([a-zA-Z]+)':\s*const WordDefinition", dict_text))
print(f'Dictionary keys: {len(dict_keys)}')

missing = sorted(list(story_words - dict_keys))
print(f'Actual missing story words: {len(missing)}')

with open('bin/actual_missing_words.txt', 'w', encoding='utf-8') as out:
    for w in missing:
        out.write(w + '\n')
