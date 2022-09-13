import 'package:clean_architecture/core/errors/failure.dart';
import 'package:clean_architecture/core/usecase.dart';
import 'package:clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';

class GetRandomNumberTrivia extends UseCase {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, dynamic>> call({required params}) async {
    return await repository.getRandomNumberTrivia();
  }

}