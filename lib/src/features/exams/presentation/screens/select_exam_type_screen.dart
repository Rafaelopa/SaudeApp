import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saude_app/src/features/exams/presentation/screens/add_image_exam_screen.dart';
import 'package:saude_app/src/features/exams/presentation/screens/add_lab_exam_screen.dart';

class SelectExamTypeScreen extends ConsumerWidget {
  final String patientProfileId;
  final String patientName;

  const SelectExamTypeScreen({
    super.key,
    required this.patientProfileId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Exame'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Para qual perfil: $patientName',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              'Qual tipo de exame você deseja adicionar?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.science_outlined, size: 40),
                title: const Text('Exame Laboratorial'),
                subtitle: const Text('Resultados de sangue, urina, etc.'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddLabExamScreen(
                        patientProfileId: patientProfileId,
                        patientName: patientName,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.image_outlined, size: 40),
                title: const Text('Exame de Imagem'),
                subtitle: const Text('Raio-X, Ressonância, PDF de laudo, etc.'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddImageExamScreen(
                        patientProfileId: patientProfileId,
                        patientName: patientName,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

