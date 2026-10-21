import re

with open('lib/services/dictionary_service.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r"'the':\s*const WordDefinition\([^)]+\),", text)
if m:
    print('Found "the":', m.group(0))

for common in ['to', 'of', 'in', 'and', 'a', 'an', 'is', 'are', 'was', 'were', 'it', 'for', 'on', 'with', 'as', 'at', 'by']:
    m = re.search(rf"'{common}':\s*const WordDefinition\([^)]+\),", text)
    if m:
        print(f"'{common}':", m.group(0))
    else:
        print(f"'{common}': NOT FOUND")
