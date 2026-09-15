# 📚 LingoRead - İngilizce Okuma & Kelime Öğrenme Uygulaması

**LingoRead**, yabancı gazete haberleri ve sürükleyici hikayeler okuyarak İngilizce kelime dağarcığını geliştirmek ve okuduğunu anlama yeteneğini test etmek için geliştirilmiş modern, etkileşimli bir Flutter uygulamasıdır.

---

## ✨ Temel Özellikler

### 1. 📰 Zengin İçerik Kütüphanesi (108 İçerik)
- **59 Uluslararası Gazete Haberi:** Yapay zeka, kuantum bilişimi, uzay araştırmaları, nöroloji, derin deniz keşifleri, yenilenebilir enerji, biyoteknoloji ve daha fazlası.
- **49 Özgün Kısa Hikaye:** Bilim kurgu, siberpunk, mitoloji, felsefe, fantastik ve sıcak yaşam öyküleri.
- **Seviye ve Kategori Filtreleme:** A1, A2, B1, B2, C1 seviye filtreleri ve onlarca dinamik konu kategorisi.
- **Canlı Arama:** İçeriklerde başlık veya konuya göre anlık arama motoru.
- **Responsive Dergi Görünümü:** Masaüstü, tablet ve mobilde kusursuz ölçeklenen 3 sütunlu ızgara düzeni.

### 2. ⚡ Etkileşimli Kelime Deneyimi (Interactive Reading)
- **Sarı Işık Vurgusu (Glowing Yellow Hover & Select):** Metin üzerinde kelimelerin üzerine gelindiğinde veya tıklandığında yumuşak ve şık bir sarı ışık/vurgu efekti.
- **Akıllı Açılır Kart (Smart Floating Card):** Ekranda tıklanan konuma göre taşma yapmadan (ekran üstü veya altı duyarlı) açılan hızlı eylem penceresi.
- **Tek Tıkla Kelime Haznesine Ekleme:** Bilinmeyen kelimeleri doğrudan kişisel sözlüğere kaydetme.
- **Kelimenin Geçtiği Örnek Cümle:** Kart üzerinde kelimenin metin içerisindeki bağlamını anında görüntüleme.

### 3. 📖 5.200+ Kelimelik Kapsamlı Çevrimdışı Türkçe Sözlük
- Kütüphanedeki 108 içeriğin tamamını kapsayan **5.220 kelimelik** özel sözlük veritabanı.
- **Düzensiz Fiil Analizi (Irregular Verbs):** *went* ➔ *go* (gitmek), *saw* ➔ *see* (görmek) vb.
- **Düzensiz Çoğul Analizi (Irregular Plurals):** *children* ➔ *child* (çocuk), *mice* ➔ *fareler* vb.
- **Kısaltmalar (Contractions):** *don't*, *it's*, *can't*, *we've*, *they're* gibi kelimeleri hatasız tanıma.
- **İyelik Ekleri (Possessives):** *Earth's*, *scientist's* vb. eklerin akıllıca köklerine indirgenmesi.
- **Canlı Çeviri Fallback (Async Lookup):** Sözlükte bulunmayan herhangi bir yeni kelime için arkaplanda anlık canlı çeviri desteği.

### 4. 🧠 Okuduğunu Anlama Testleri (Comprehension Quizzes)
- Her makale ve hikayenin sonunda, metnin anlaşılıp anlaşılmadığını ölçen çoktan seçmeli İngilizce sorular.
- Anında doğru/yanlış geri bildirimi ve Türkçe açıklama kartları.
- Kartlar üzerinde tamamlanma ve başarı yüzdesi (`✓ Test: %100`).

### 5. 🗂️ Kelime Haznesi & Flashcard Çalışma Modu
- Kaydedilen tüm kelimeleri listeleme, silme ve arama.
- 3D çevrilebilir interaktif **Flashcard (Kelime Kartı)** modu ile pratik yapma.
- Çevrimdışı kalıcı hafıza (`SharedPreferences`).

---

## 🚀 Başlangıç ve Kurulum

### Gereksinimler
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x veya üzeri)
- Dart SDK
- Google Chrome / Edge veya herhangi bir modern tarayıcı (veya Android/iOS/Desktop emülatörü)

### Kurulum Adımları

1. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

2. **Uygulamayı geliştirme modunda çalıştırın:**
   ```bash
   flutter run -d chrome
   ```
   veya web sunucusu olarak:
   ```bash
   flutter run -d web-server --web-port 8080
   ```

3. **Web sürümünü derlemek için:**
   ```bash
   flutter build web
   ```

4. **Testleri çalıştırmak için:**
   ```bash
   flutter test
   ```

---

## 📁 Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası ve tema yapılandırması
├── models/
│   ├── article.dart          # Gazete haberleri ve hikaye veri modelleri
│   ├── quiz_question.dart    # Anlama testi soru modelleri
│   └── vocabulary_item.dart  # Kelime haznesi veri modelleri
├── providers/
│   └── vocabulary_provider.dart # Kelime haznesi state yönetimi (ChangeNotifier)
├── screens/
│   ├── home_screen.dart      # 3 sütunlu responsive dergi ve arama ekranı
│   ├── article_detail_screen.dart # İnteraktif okuma ve kelime seçme ekranı
│   ├── quiz_screen.dart      # Okuduğunu anlama testi ekranı
│   └── vocabulary_screen.dart # Kelime haznesi ve Flashcard ekranı
├── services/
│   ├── content_service.dart  # 108 adet makale, hikaye ve quiz içerik verisi
│   └── dictionary_service.dart # 5.220+ kelimelik lemmatizer & çeviri motoru
└── widgets/
    └── interactive_paragraph.dart # Sarı parıltılı, tıklanabilir kelime widget'ı
```

---

## 📄 Lisans
Bu proje açık kaynaklıdır. İncelemek ve geliştirmek için özgürce kullanabilirsiniz.
