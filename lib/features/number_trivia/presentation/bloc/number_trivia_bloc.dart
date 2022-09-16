import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clean_architecture/core/errors/failure.dart';
import 'package:clean_architecture/core/usecase.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/presentation/util/input_converter.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';

part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>(_handleOnNumberTriviaEvent);
    on<GetTriviaForRandomNumber>(_handleOnRandomTriviaEvent);
  }

  void _handleOnNumberTriviaEvent(
      NumberTriviaEvent event, Emitter<NumberTriviaState> emit) {
    emit(Loading());
    final inputEither = inputConverter.stringToUnsignedInteger(
        (event as GetTriviaForConcreteNumber).numberString);
    inputEither.fold(
        (failure) => emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE)),
        (integer) async {
      final failureOrTrivia =
          await getConcreteNumberTrivia.call(params: Params(number: integer));
      emit(failureOrTrivia.fold(
          (usecaseFailure) =>
              Error(message: _mapFailureToMessage(usecaseFailure)),
          (trivia) => Loaded(trivia: trivia)));
    });
  }

  void _handleOnRandomTriviaEvent(
      NumberTriviaEvent event, Emitter<NumberTriviaState> emit) async {
    emit(Loading());
    final failureOrTrivia =
        await getRandomNumberTrivia.call(params: NoParams());
    emit(failureOrTrivia.fold(
        (usecaseFailure) =>
            Error(message: _mapFailureToMessage(usecaseFailure)),
        (trivia) => Loaded(trivia: trivia)));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return "Unexpected Error";
    }
  }
}
