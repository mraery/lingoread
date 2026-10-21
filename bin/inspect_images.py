import re

with open('lib/services/content_service.dart', 'r', encoding='utf-8') as f:
    text = f.read()

image_urls = re.findall(r"imageUrl:\s*'([^']*)'", text)
print(f'Total articles with imageUrl: {len(image_urls)}')
print(f'Unique imageUrls: {len(set(image_urls))}')
empty_count = sum(1 for u in image_urls if not u.strip())
print(f'Empty imageUrls: {empty_count}')
from collections import Counter
c = Counter(image_urls)
print('Most common images:', c.most_common(10))
