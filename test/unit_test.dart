import 'package:flutter_test/flutter_test.dart';
import 'package:lingoread/models/article.dart';
import 'package:lingoread/services/dictionary_service.dart';
import 'package:lingoread/services/content_service.dart';

void main() {
  group('DictionaryService Tests', () {
    test('Cleans punctuation and casing properly', () {
      expect(DictionaryService.cleanWord('Breakthrough!'), 'breakthrough');
      expect(DictionaryService.cleanWord('"fascinating,"'), 'fascinating');
      expect(DictionaryService.cleanWord('  artificial... '), 'artificial');
    });

    test('Exact word match returns definition', () {
      final def = DictionaryService.lookup('breakthrough');
      expect(def.word, 'breakthrough');
      expect(def.turkishMeaning, contains('çığır açıcı'));
    });

    test('Stemmed inflections return base definition', () {
      final defPlural = DictionaryService.lookup('algorithms');
      expect(defPlural.word, 'algorithm');

      final defPast = DictionaryService.lookup('accelerated');
      expect(defPast.word, 'accelerate');

      final defIng = DictionaryService.lookup('scrutinizing');
      expect(defIng.word, 'scrutinize');
    });

    test('Translates common story and news words accurately', () {
      final sampleWords = [
        'laboratory', 'medicine', 'patient', 'diagnose',
        'morning', 'journey', 'forest', 'telescope',
        'world', 'time', 'people', 'whisper'
      ];
      for (final word in sampleWords) {
        final def = DictionaryService.lookup(word);
        expect(def.turkishMeaning.isNotEmpty, true);
        expect(def.turkishMeaning.contains('sözcüğü için Türkçe anlam'), false);
      }
    });

    test('Handles irregular verbs, plurals and contractions', () {
      expect(DictionaryService.lookup('went').word, 'went');
      expect(DictionaryService.lookup('went').turkishMeaning.isNotEmpty, true);

      expect(DictionaryService.lookup('children').word, 'children');
      expect(DictionaryService.lookup('children').turkishMeaning.isNotEmpty, true);

      expect(DictionaryService.lookup("don't").turkishMeaning, contains('yapma'));
      expect(DictionaryService.lookup("it's").turkishMeaning, contains('o'));

      // Possessive cleaning
      final defPossessive = DictionaryService.lookup("Earth's");
      expect(defPossessive.word, 'earth');
      expect(defPossessive.turkishMeaning.isNotEmpty, true);
    });
  });

  group('ContentService Tests', () {
    test('Provides curated articles with quizzes', () {
      final articles = ContentService.getArticles();
      expect(articles.length, greaterThanOrEqualTo(100));
      final newsArticles = articles.where((a) => a.type == ArticleType.news).toList();
      final storyArticles = articles.where((a) => a.type == ArticleType.story).toList();
      expect(newsArticles.length, greaterThanOrEqualTo(45));
      expect(storyArticles.length, greaterThanOrEqualTo(45));

      for (final article in articles) {
        expect(article.title.isNotEmpty, true);
        expect(article.imageUrl.isNotEmpty, true);
        expect(article.paragraphs.isNotEmpty, true);
        expect(article.quizQuestions.isNotEmpty, true);
        for (final q in article.quizQuestions) {
          expect(q.options.length, greaterThanOrEqualTo(3));
          expect(q.correctOptionIndex, lessThan(q.options.length));
          expect(q.explanation.isNotEmpty, true);
        }
      }
    });
  });
}
