import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saude_app/src/features/exams/domain/exam_model.dart';
import 'package:saude_app/src/features/exams/infrastructure/exam_repository.dart'; // Para o streamProvider
import 'package:saude_app/src/features/exams/presentation/screens/select_exam_type_screen.dart';
import 'package:saude_app/src/features/exams/presentation/screens/view_exam_details_screen.dart'; // Será criada depois

// Provedor para o stream de exames de um paciente específico
final patientExamsStreamProvider = StreamProvider.autoDispose.family<List<ExamModel>, String>((ref, patientProfileId) {
  final examRepository = ref.watch(examRepositoryProvider);
  return examRepository.getExamsForPatient(patientProfileId);
});

class ExamHistoryListScreen extends ConsumerWidget {
  final String patientProfileId;
  final String patientName;

  const ExamHistoryListScreen({
    Key? key,
    required this.patientProfileId,
    required this.patientName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsyncValue = ref.watch(patientExamsStreamProvider(patientProfileId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Exames - $patientName'),
      ),
      body: examsAsyncValue.when(
        data: (exams) {
          if (exams.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum exame registrado para $patientName.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Que tal adicionar um agora?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar Novo Exame'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectExamTypeScreen(
                              patientProfileId: patientProfileId,
                              patientName: patientName,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  leading: Icon(
                    exam.examType == 'laboratory' ? Icons.science_outlined : Icons.image_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 36,
                  ),
                  title: Text(exam.examTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data: ${DateFormat('dd/MM/yyyy').format(exam.examDate.toDate())}'),
                      if (exam.clinicName != null && exam.clinicName!.isNotEmpty)
                        Text('Clínica: ${exam.clinicName}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => ViewExamDetailsScreen(
                           exam: exam, // Passa o objeto ExamModel completo
                         ),
                       ),
                     );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Erro ao carregar exames: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectExamTypeScreen(
                patientProfileId: patientProfileId,
                patientName: patientName,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Exame'),
      ),
    );
  }
}

