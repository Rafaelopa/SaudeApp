import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saude_app/src/features/exams/domain/exam_model.dart';
import 'package:saude_app/src/features/exams/presentation/screens/add_lab_exam_screen.dart'; 
import 'package:saude_app/src/features/exams/presentation/screens/add_image_exam_screen.dart'; 
import 'package:saude_app/src/features/exams/presentation/providers/exam_providers.dart'; 
import 'package:url_launcher/url_launcher.dart';

class ViewExamDetailsScreen extends ConsumerWidget {
  final ExamModel exam;

  const ViewExamDetailsScreen({super.key, required this.exam});

  Future<void> _deleteExam(BuildContext context, WidgetRef ref) async {
    final bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: const Text('Tem certeza que deseja excluir este exame? Esta ação não pode ser desfeita.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      ref.read(examSavingProvider.notifier).state = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excluindo exame...')),
      );
      try {
        final examService = ref.read(examServiceProvider);
        await examService.deleteExam(exam.examId!, exam.examType, exam.imageFiles, exam.labAttachmentPath);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exame excluído com sucesso!')),
        );
        // Pop twice to go back to the list screen, assuming details screen was pushed over list screen
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 1); 
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir exame: ${e.toString()}')),
        );
      } finally {
        ref.read(examSavingProvider.notifier).state = false;
      }
    }
  }

  void _editExam(BuildContext context, WidgetRef ref) {
    if (exam.examType == 'laboratory') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddLabExamScreen(
            patientProfileId: exam.patientProfileId,
            patientName: exam.patientName,
            examToEdit: exam, // Passar o examModel para pré-preencher
          ),
        ),
      ).then((_) {
        // Atualizar a stream ou o estado se necessário após a edição
        // Isso pode ser feito invalidando o provider da lista ou refazendo a query
        // ref.invalidate(patientExamsStreamProvider(exam.patientProfileId));
      });
    } else if (exam.examType == 'image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddImageExamScreen(
            patientProfileId: exam.patientProfileId,
            patientName: exam.patientName,
            examToEdit: exam, // Passar o examModel para pré-preencher
          ),
        ),
      ).then((_) {
        // ref.invalidate(patientExamsStreamProvider(exam.patientProfileId));
      });
    }
  }

 Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Não foi possível abrir $urlString');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaving = ref.watch(examSavingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Exame'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: isSaving ? null : () => _editExam(context, ref),
            tooltip: 'Editar Exame',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: isSaving ? null : () => _deleteExam(context, ref),
            tooltip: 'Excluir Exame',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSectionTitle(context, 'Informações Gerais'),
            _buildInfoRow('Paciente:', exam.patientName),
            _buildInfoRow('Título do Exame:', exam.examTitle),
            _buildInfoRow('Data da Realização:', DateFormat('dd/MM/yyyy').format(exam.examDate.toDate())),
            _buildInfoRow('Tipo de Exame:', exam.examType == 'laboratory' ? 'Laboratorial' : 'Imagem'),
            if (exam.clinicName != null && exam.clinicName!.isNotEmpty)
              _buildInfoRow('Clínica/Laboratório:', exam.clinicName!),
            if (exam.notes != null && exam.notes!.isNotEmpty)
              _buildInfoRow('Notas:', exam.notes!),
            const SizedBox(height: 20),
            if (exam.examType == 'laboratory' && exam.labResults != null && exam.labResults!.isNotEmpty)
              _buildLabResultsSection(context, exam.labResults!),
            if (exam.examType == 'laboratory' && exam.labAttachmentUrl != null)
              _buildLabAttachmentSection(context, exam.labAttachmentUrl!, exam.labAttachmentPath),
            if (exam.examType == 'image' && exam.imageFiles != null && exam.imageFiles!.isNotEmpty)
              _buildImageFilesSection(context, exam.imageFiles!),
            if (isSaving) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
          children: <TextSpan>[
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildLabResultsSection(BuildContext context, List<LabResultItem> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Resultados Laboratoriais'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.biomarkerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Valor: ${item.value} ${item.unit}'),
                    if (item.referenceRange != null && item.referenceRange!.isNotEmpty)
                      Text('Referência: ${item.referenceRange}'),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLabAttachmentSection(BuildContext context, String url, String? path) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Laudo Anexado'),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const Icon(Icons.attach_file, color: Colors.blueAccent, size: 30),
            title: Text(path?.split('/').last ?? 'Arquivo Anexado', overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.visibility_outlined),
            onTap: () async {
              try {
                await _launchUrl(url);
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Não foi possível abrir o anexo: ${e.toString()}')),
                 );
              }
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildImageFilesSection(BuildContext context, List<ImageFileAttachment> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Arquivos de Imagem/Laudos'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.image_outlined, color: Colors.green, size: 30),
                title: Text(file.fileName, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.visibility_outlined),
                onTap: () async {
                   try {
                     await _launchUrl(file.fileUrl);
                   } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Não foi possível abrir o arquivo: ${e.toString()}')),
                     );
                   }
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

