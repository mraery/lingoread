import re

with open('lib/services/dictionary_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Let's find _dictionary declaration
dict_start = content.find('static final Map<String, WordDefinition> _dictionary = {')
dict_end = content.find('};\n\n  // Irregular verbs mapping', dict_start)
if dict_end == -1:
    dict_end = content.find('};', dict_start)

dict_block = content[dict_start:dict_end]

# Extract all lines in dict_block
lines = dict_block.splitlines()
seen_keys = set()
new_lines = []

for line in lines:
    m = re.match(r"\s*'([^']+)':\s*const WordDefinition", line)
    if m:
        key = m.group(1).lower()
        if key in seen_keys:
            # Skip duplicate key
            continue
        seen_keys.add(key)
    new_lines.append(line)

new_dict_block = '\n'.join(new_lines)

content = content[:dict_start] + new_dict_block + content[dict_end:]

with open('lib/services/dictionary_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print(f'Deduplicated _dictionary: {len(seen_keys)} unique keys preserved.')
