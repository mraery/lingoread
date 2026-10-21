import json
import re

extra = {
    "peru": ("Peru (Güney Amerika ülkesi)", "özel isim", "/pəˈruː/"),
    "protein": ("protein (vücut için elzem besin maddesi)", "isim", "/ˈproʊtiːn/"),
    "sanat": ("sanat (estetik yaratım faaliyeti)", "isim", None),
    "tarih": ("tarih (geçmiş zaman bilimi)", "isim", None),
    "verici": ("verici (sinyal yayan veya ileten aygıt)", "isim", None),
}

with open('lib/services/dictionary_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

def make_entry(word, def_tuple):
    meaning, pos, phon = def_tuple
    meaning_esc = meaning.replace("'", "\\'")
    pos_esc = pos.replace("'", "\\'")
    if phon:
        phon_esc = phon.replace("'", "\\'")
        return f"    '{word}': const WordDefinition(word: '{word}', turkishMeaning: '{meaning_esc}', partOfSpeech: '{pos_esc}', phonetic: '{phon_esc}'),"
    else:
        return f"    '{word}': const WordDefinition(word: '{word}', turkishMeaning: '{meaning_esc}', partOfSpeech: '{pos_esc}'),"

for word, def_tuple in extra.items():
    word_pattern = re.compile(rf"'{re.escape(word)}':\s*const WordDefinition\([^)]+\),")
    new_str = make_entry(word, def_tuple)
    if word_pattern.search(content):
        content = word_pattern.sub(new_str, content)
    else:
        dict_start = content.find('static final Map<String, WordDefinition> _dictionary = {')
        insert_pos = content.find('{', dict_start) + 1
        content = content[:insert_pos] + "\n" + new_str + content[insert_pos:]

with open('lib/services/dictionary_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Updated the 5 words successfully.')
