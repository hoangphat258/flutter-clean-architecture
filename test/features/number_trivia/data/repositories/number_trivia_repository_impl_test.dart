import 'package:clean_architecture/core/errors/exception.dart';
import 'package:clean_architecture/core/errors/failure.dart';
import 'package:clean_architecture/core/network/network_info.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks([NumberTriviaRemoteDataSource, NumberTriviaLocalDataSource, NetworkInfo])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  const tNumber = 1;
  const tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: tNumber);
  const NumberTrivia tNumberTrivia = tNumberTriviaModel;

  setUp(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {

    runTestsOnline(() {
      test('should check if the device is online', () {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        repository.getConcreteNumberTrivia(tNumber);
        verify(mockNetworkInfo.isConnected);
      });

      test('should return remote data when the call to remote data source is successful',
              () async {
            when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
                .thenAnswer((_) async => tNumberTriviaModel);
            final result = await repository.getConcreteNumberTrivia(tNumber);
            verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            expect(result, equals(const Right(tNumberTrivia)));
          });

      test('should cache the data locally when the call to remote data source is successful', () async {
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        await repository.getConcreteNumberTrivia(tNumber);
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel));
      });

      test('should return server failure when the call to remote data source is unsuccessful', () async {
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber)).thenThrow(ServerException());
        final result = await repository.getConcreteNumberTrivia(tNumber);
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test('should return last locally cached data when the cached data is present', () async {
        when(mockLocalDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        final result = await repository.getConcreteNumberTrivia(tNumber);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return CacheFailure when there is no cached data present', () async {
        when(mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
        final result = await repository.getConcreteNumberTrivia(tNumber);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });

  });

  group('getRandomNumberTrivia', () {

    runTestsOnline(() {
      test('should check if the device is online', () {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        repository.getRandomNumberTrivia();
        verify(mockNetworkInfo.isConnected);
      });

      test('should return remote data when the call to remote data source is successful',
              () async {
            when(mockRemoteDataSource.getRandomNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);
            final result = await repository.getRandomNumberTrivia();
            verify(mockRemoteDataSource.getRandomNumberTrivia());
            expect(result, equals(const Right(tNumberTrivia)));
          });

      test('should cache the data locally when the call to remote data source is successful', () async {
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        await repository.getRandomNumberTrivia();
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivia as NumberTriviaModel));
      });

      test('should return server failure when the call to remote data source is unsuccessful', () async {
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenThrow(ServerException());
        final result = await repository.getRandomNumberTrivia();
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test('should return last locally cached data when the cached data is present', () async {
        when(mockLocalDataSource.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        final result = await repository.getRandomNumberTrivia();
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(tNumberTrivia)));
      });

      test('should return CacheFailure when there is no cached data present', () async {
        when(mockLocalDataSource.getLastNumberTrivia()).thenThrow(CacheException());
        final result = await repository.getRandomNumberTrivia();
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });

  });
}