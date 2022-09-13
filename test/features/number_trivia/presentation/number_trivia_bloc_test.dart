import 'package:clean_architecture/core/presentation/util/input_converter.dart';
import 'package:clean_architecture/core/usecase.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../core/presentation/util/input_converter_test.mocks.dart';
import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test("initialState should be Empty", () {
    expect(bloc.state, Empty());
  });

  group("GetTriviaForConcreteNumber", () {
    // The event takes in a String
    const tNumberString = '1';
    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumberTrivia instance is needed too, of course
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    test(
        "should call the InputConverter to validate and convert the string to an unsigned integer",
        () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia.call(
          params: Params(number: tNumberParsed)))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));
      final expected = [
        Loading(),
        const Error(message: INVALID_INPUT_FAILURE_MESSAGE)
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test("should get data from the concrete use case", () async {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Right(tNumberParsed));
      when(mockGetConcreteNumberTrivia.call(
              params: Params(number: tNumberParsed)))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia.call(
          params: Params(number: tNumberParsed)));
      verify(
          mockGetConcreteNumberTrivia(params: Params(number: tNumberParsed)));
    });
  });
}
