import 'dart:convert';

import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTrivia = NumberTriviaModel(number: 1, text: 'Test Text');

  test('should be a subclass of NumberTrivia entity', () {
    expect(tNumberTrivia, isA<NumberTrivia>());
  });

  group('fromJson', () {
    test('should return a valid model when a JSON number is an integer', () {
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, isA<NumberTriviaModel>());
    });

    test('should return a valid model when a JSON number is a double', () {
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia_double.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, isA<NumberTriviaModel>());
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      final result = tNumberTrivia.toJson();
      final expectedJsonMap = {
        "number": 1,
        "text": "Test Text"
      };
      expect(result, expectedJsonMap);
    });
  });
}