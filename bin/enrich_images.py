import re
import hashlib

thematic_photos = {
    'space': [
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1502134249126-9f3755a50d78?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1447433589675-4aaa569f3e05?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1541185933-ef5d8ed016c2?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1454789548928-9efd52dc4031?w=900&auto=format&fit=crop&q=80',
    ],
    'books': [
        'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1507842229451-9f7988383e20?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1532012164546-f432f2e3edd3?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=900&auto=format&fit=crop&q=80',
    ],
    'nature': [
        'https://images.unsplash.com/photo-1448375240586-882707db888b?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1511497584788-87676104235f?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1518495973542-4542c06a5843?w=900&auto=format&fit=crop&q=80',
    ],
    'ocean': [
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1498623116890-37e912163d5d?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1513002749550-c59d786b8e6c?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1439405326854-014607f694d7?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1468581264429-2548ef9eb732?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=900&auto=format&fit=crop&q=80',
    ],
    'history_cities': [
        'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1543429776-2782fc8e1acd?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=900&auto=format&fit=crop&q=80',
    ],
    'art_music': [
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1460661419200-fd4357ef7956?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1549887534-1541e9326642?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1499781350541-7783f6c6a0c8?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1513829596324-4bb2800c5efb?w=900&auto=format&fit=crop&q=80',
    ],
    'science_tech': [
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1518770660439-4636190af475?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=900&auto=format&fit=crop&q=80',
    ],
    'cozy_travel': [
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1507146426996-ef05306b995a?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1498804103079-a6351b050096?w=900&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=900&auto=format&fit=crop&q=80',
    ],
}

def pick_image(article_id, title, category):
    combined = (title + ' ' + category).lower()
    
    if any(k in combined for k in ['space', 'uzay', 'quantum', 'mars', 'astronomi', 'yıldız', 'galaksi', 'apollo', 'teleskop', 'tokamak', 'evren']):
        pool = thematic_photos['space']
    elif any(k in combined for k in ['kitap', 'book', 'library', 'kütüphane', 'edebiyat', 'yazar', 'poem', 'novel', 'roman', 'hikaye', 'gutenberg', 'dickens', 'austen']):
        pool = thematic_photos['books']
    elif any(k in combined for k in ['ocean', 'deniz', 'okyanus', 'su', 'water', 'reef', 'mercan', 'hadal', 'balık', 'plankton', 'kıyı']):
        pool = thematic_photos['ocean']
    elif any(k in combined for k in ['art', 'sanat', 'müzik', 'music', 'keman', 'violin', 'resim', 'heykel', 'chopin', 'flamenco', 'gitar', 'luthier']):
        pool = thematic_photos['art_music']
    elif any(k in combined for k in ['bilim', 'science', 'tıp', 'medicine', 'sağlık', 'dna', 'beyin', 'ai', 'robot', 'teknoloji', 'hücre']):
        pool = thematic_photos['science_tech']
    elif any(k in combined for k in ['tarih', 'history', 'antik', 'roma', 'mısır', 'pyramid', 'kale', 'castle', 'şehir', 'kent', 'arkeoloji', 'byzantine']):
        pool = thematic_photos['history_cities']
    elif any(k in combined for k in ['çay', 'tea', 'kahve', 'coffee', 'fırın', 'ekmek', 'cafe', 'pankek', 'peynir', 'seyahat', 'nostalji', 'kedi']):
        pool = thematic_photos['cozy_travel']
    else:
        pool = thematic_photos['nature']
        
    h = int(hashlib.md5(article_id.encode('utf-8')).hexdigest(), 16)
    return pool[h % len(pool)]

with open('lib/services/content_service.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
current_id = ''
current_title = ''
current_cat = ''
replaced_count = 0

for line in lines:
    id_m = re.search(r"id:\s*'([^']+)'", line)
    if id_m:
        current_id = id_m.group(1)
        
    title_m = re.search(r"title:\s*'([^']+)'", line)
    if title_m:
        current_title = title_m.group(1)
        
    cat_m = re.search(r"category:\s*'([^']+)'", line)
    if cat_m:
        current_cat = cat_m.group(1)
        
    if "imageUrl:" in line:
        url = pick_image(current_id, current_title, current_cat)
        indent = line[:line.find("imageUrl:")]
        new_lines.append(f"{indent}imageUrl: '{url}',\n")
        replaced_count += 1
    else:
        new_lines.append(line)

with open('lib/services/content_service.dart', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f'Successfully replaced {replaced_count} imageUrls with diverse thematic photography.')
