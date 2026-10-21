import re

with open('bin/actual_missing_words.txt', 'r', encoding='utf-8') as f:
    missing_words = [line.strip() for line in f if line.strip()]

print(f'Total missing from dictionary keys: {len(missing_words)}')
print(f'First 40 missing words: {missing_words[:40]}')
