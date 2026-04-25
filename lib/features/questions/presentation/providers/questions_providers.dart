import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/answers_remote_data_source.dart';
import '../../data/datasources/questions_remote_data_source.dart';
import '../../data/repositories/answers_repository_impl.dart';
import '../../data/repositories/questions_repository_impl.dart';
import '../../domain/repositories/questions_repository.dart';

final questionsRemoteDataSourceProvider = Provider<QuestionsRemoteDataSource>((
  ref,
) {
  final dio = ref.read(dioClientProvider);
  return QuestionsRemoteDataSourceImpl(dio);
});

final answersRemoteDataSourceProvider = Provider<AnswersRemoteDataSource>((
  ref,
) {
  final dio = ref.read(dioClientProvider);
  return AnswersRemoteDataSourceImpl(dio);
});

final questionsRepositoryProvider = Provider<QuestionsRepository>((ref) {
  return QuestionsRepositoryImpl(
    remoteDataSource: ref.read(questionsRemoteDataSourceProvider),
  );
});

final answersRepositoryProvider = Provider<AnswersRepository>((ref) {
  return AnswersRepositoryImpl(
    remoteDataSource: ref.read(answersRemoteDataSourceProvider),
  );
});
