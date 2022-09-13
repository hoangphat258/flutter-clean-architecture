import 'dart:convert';
import 'dart:math';

import 'package:clean_architecture/core/errors/exception.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
      when(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .thenReturn(fixture('trivia_cached.json'));
      final result = await dataSource.getLastNumberTrivia();
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a CacheException when there is not a cached value', () {
      when(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .thenReturn(null);
      final call = dataSource.getLastNumberTrivia;
      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: 1);

    test('should call SharedPreferences to cache data', () {
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      when(mockSharedPreferences.setString(
              CACHED_NUMBER_TRIVIA, expectedJsonString))
          .thenAnswer((_) async => true);
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      verify(mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}
