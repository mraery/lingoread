import json
import re

with open('bin/new_translations.json', 'r', encoding='utf-8') as f:
    new_defs = json.load(f)

with open('lib/services/dictionary_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Let's inspect how _dictionary is declared
dict_start = content.find('static final Map<String, WordDefinition> _dictionary = {')
if dict_start == -1:
    print('Error: Could not find _dictionary start!')
    exit(1)

# Let's find all entries in _dictionary
# Regex for an entry: 'key': const WordDefinition(...)
pattern = re.compile(r"'([a-zA-Z0-9_\-']+)'\s*:\s*const WordDefinition\((.*?)\),", re.DOTALL)

# Let's replace or add new entries into _dictionary
# First, let's see which new entries already exist and replace them
modified_content = content

updated_count = 0
added_count = 0

# Prepare new entry string formatter
def make_entry(word, def_tuple):
    meaning, pos, phon = def_tuple
    # escape single quotes in meaning
    meaning_esc = meaning.replace("'", "\\'")
    pos_esc = pos.replace("'", "\\'")
    if phon:
        phon_esc = phon.replace("'", "\\'")
        return f"    '{word}': const WordDefinition(word: '{word}', turkishMeaning: '{meaning_esc}', partOfSpeech: '{pos_esc}', phonetic: '{phon_esc}'),\n"
    else:
        return f"    '{word}': const WordDefinition(word: '{word}', turkishMeaning: '{meaning_esc}', partOfSpeech: '{pos_esc}'),\n"

# First, fix dummy ones or replace in file if already present
for word, def_tuple in new_defs.items():
    # search for 'word': const WordDefinition(...)
    word_pattern = re.compile(rf"'{re.escape(word)}':\s*const WordDefinition\([^)]+\),")
    new_str = make_entry(word, def_tuple).strip()
    if word_pattern.search(modified_content):
        modified_content = word_pattern.sub(new_str, modified_content)
        updated_count += 1
    else:
        # We will insert it right after the start of _dictionary
        insert_pos = modified_content.find('{', dict_start) + 1
        modified_content = modified_content[:insert_pos] + "\n" + make_entry(word, def_tuple) + modified_content[insert_pos:]
        added_count += 1

print(f'Updated {updated_count} existing entries, added {added_count} new entries.')

with open('lib/services/dictionary_service.dart', 'w', encoding='utf-8') as f:
    f.write(modified_content)

print('Wrote updated dictionary_service.dart successfully.')
