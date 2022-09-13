import 'dart:convert';

import 'package:clean_architecture/core/errors/exception.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttpClient;
  late NumberTriviaRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(fixture('trivia.json'), 200),
    );
  }

  void setUpMockHttpClientFailure() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response('Something went wrong', 400),
    );
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
        'should preform a GET request on a URL with number being the endpoint and with application/json header',
        () {
      //arrange
      setUpMockHttpClientSuccess200();
      // act
      dataSource.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockHttpClient.get(
        Uri.parse('http://numbersapi.com/$tNumber'),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should return NumberTrivia when the response code is 200', () async {
      //arrange
      setUpMockHttpClientSuccess200();
      // act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      // assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException', () async {
      //arrange
      setUpMockHttpClientFailure();
      // act
      final call = dataSource.getConcreteNumberTrivia;
      // assert
      expect(() => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
        'should preform a GET request on a URL with number being the endpoint and with application/json header',
            () {
          //arrange
          setUpMockHttpClientSuccess200();
          // act
          dataSource.getRandomNumberTrivia();
          // assert
          verify(mockHttpClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: {'Content-Type': 'application/json'},
          ));
        });

    test('should return NumberTrivia when the response code is 200', () async {
      //arrange
      setUpMockHttpClientSuccess200();
      // act
      final result = await dataSource.getRandomNumberTrivia();
      // assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException', () async {
      //arrange
      setUpMockHttpClientFailure();
      // act
      final call = dataSource.getRandomNumberTrivia;
      // assert
      expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}
