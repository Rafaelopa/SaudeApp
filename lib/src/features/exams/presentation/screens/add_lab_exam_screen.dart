import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:saude_app_mobile/src/features/exams/application/exam_service.dart';
import 'package:saude_app_mobile/src/features/exams/domain/exam_model.dart';
import 'package:saude_app_mobile/src/features/exams/presentation/providers/exam_providers.dart';

// Re-definindo LabExamData localmente para manter a estrutura da UI, 
// mas a conversão para LabResultItem acontecerá no momento do salvamento.
class LabExamUIData {
  String biomarkerName;
  String value;
  String unit;
  String referenceRange;

  LabExamUIData({
    this.biomarkerName = '',
    this.value = '',
    this.unit = '',
    this.referenceRange = '',
  });
}

class AddLabExamScreen extends ConsumerStatefulWidget {
  final String patientProfileId;
  final String patientName;

  const AddLabExamScreen({
    Key? key,
    required this.patientProfileId,
    required this.patientName,
  }) : super(key: key);

  @override
  _AddLabExamScreenState createState() => _AddLabExamScreenState();
}

class _AddLabExamScreenState extends ConsumerState<AddLabExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examTitleController = TextEditingController();
  final _examDateController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _notesController = TextEditingController();

  List<LabExamUIData> _labResults = [LabExamUIData()];
  DateTime? _selectedDate;
  File? _attachmentFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _examTitleController.dispose();
    _examDateController.dispose();
    _clinicNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _examDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _addBiomarker() {
    setState(() {
      _labResults.add(LabExamUIData());
    });
  }

  void _removeBiomarker(int index) {
    setState(() {
      if (_labResults.length > 1) {
        _labResults.removeAt(index);
      }
    });
  }

  Future<void> _pickAttachment() async {
    // Permitir PDF ou Imagem
    // Por simplicidade, usando image_picker para imagens. Para PDFs, file_picker seria mais adequado.
    // Aqui, vamos focar em imagem por enquanto, mas a lógica pode ser expandida.
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _attachmentFile = File(pickedFile.path);
      });
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachmentFile = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data de realização.')),
        );
        return;
      }

      ref.read(examSavingProvider.notifier).state = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvando exame laboratorial...')),
      );

      try {
        final examService = ref.read(examServiceProvider);
        await examService.addLabExam(
          patientProfileId: widget.patientProfileId,
          patientName: widget.patientName,
          examTitle: _examTitleController.text,
          examDate: _selectedDate!,
          clinicName: _clinicNameController.text.isEmpty ? null : _clinicNameController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          labResults: _labResults.map((uiData) => LabResultItem(
            biomarkerName: uiData.biomarkerName,
            value: uiData.value,
            unit: uiData.unit,
            referenceRange: uiData.referenceRange.isEmpty ? null : uiData.referenceRange,
          )).toList(),
          attachmentFile: _attachmentFile,
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exame laboratorial salvo com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a tela de seleção de tipo
        // Considerar pop duplo se quiser voltar para a lista de exames do perfil
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar exame: ${e.toString()}')),
        );
      } finally {
        ref.read(examSavingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(examSavingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Exame Laboratorial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Text('Perfil: ${widget.patientName}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _examTitleController,
                decoration: const InputDecoration(labelText: 'Título do Exame*', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título do exame';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _examDateController,
                decoration: const InputDecoration(labelText: 'Data da Realização*', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data de realização';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clinicNameController,
                decoration: const InputDecoration(labelText: 'Clínica/Laboratório', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Text('Itens do Exame', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._buildBiomarkerFields(),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Adicionar Item/Biomarcador'),
                  onPressed: _addBiomarker,
                ),
              ),
              const SizedBox(height: 20),
              Text('Anexo (Opcional)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_attachmentFile == null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Anexar Laudo Original (PDF/Imagem)'),
                  onPressed: _pickAttachment,
                )
              else
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.file_present_rounded),
                    title: Text(_attachmentFile!.path.split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: _removeAttachment,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas/Observações', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              if (isSaving)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Salvar Exame', style: TextStyle(fontSize: 16)),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

 List<Widget> _buildBiomarkerFields() {
    List<Widget> fields = [];
    for (int i = 0; i < _labResults.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Item ${i + 1}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      if (_labResults.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                          onPressed: () => _removeBiomarker(i),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _labResults[i].biomarkerName,
                    decoration: const InputDecoration(labelText: 'Nome do Item/Biomarcador*', border: OutlineInputBorder()),
                    onChanged: (value) => _labResults[i].biomarkerName = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o nome do item';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _labResults[i].value,
                    decoration: const InputDecoration(labelText: 'Valor*', border: OutlineInputBorder()),
                    onChanged: (value) => _labResults[i].value = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o valor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _labResults[i].unit,
                    decoration: const InputDecoration(labelText: 'Unidade*', border: OutlineInputBorder()),
                    onChanged: (value) => _labResults[i].unit = value,
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira a unidade';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _labResults[i].referenceRange,
                    decoration: const InputDecoration(labelText: 'Faixa de Referência', border: OutlineInputBorder()),
                    onChanged: (value) => _labResults[i].referenceRange = value,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return fields;
  }
}

