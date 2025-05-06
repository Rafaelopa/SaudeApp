import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saude_app_mobile/src/features/exams/application/exam_service.dart';
import 'package:saude_app_mobile/src/features/exams/infrastructure/exam_repository.dart';

// Provedor para ExamRepository
final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return ExamRepository();
});

// Provedor para ExamService
final examServiceProvider = Provider<ExamService>((ref) {
  final examRepository = ref.watch(examRepositoryProvider);
  return ExamService(examRepository);
});

// Provedor de estado para indicar carregamento durante o salvamento de exames
final examSavingProvider = StateProvider<bool>((ref) => false);

