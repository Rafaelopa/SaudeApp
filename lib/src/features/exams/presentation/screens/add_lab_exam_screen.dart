import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// TODO: Importar provedores e modelos necessários quando forem criados

class LabExamData {
  String biomarkerName;
  String value;
  String unit;
  String referenceRange;

  LabExamData({
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

  List<LabExamData> _labResults = [LabExamData()];
  DateTime? _selectedDate;

  // TODO: Adicionar lógica para anexo de arquivo

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
      _labResults.add(LabExamData());
    });
  }

  void _removeBiomarker(int index) {
    setState(() {
      if (_labResults.length > 1) {
        _labResults.removeAt(index);
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar lógica de salvamento com Firebase
      // Coletar dados:
      // String examTitle = _examTitleController.text;
      // DateTime examDate = _selectedDate!;
      // String clinicName = _clinicNameController.text;
      // String notes = _notesController.text;
      // List<Map<String, String>> resultsToSave = _labResults.map((item) => {
      //   'biomarkerName': item.biomarkerName,
      //   'value': item.value,
      //   'unit': item.unit,
      //   'referenceRange': item.referenceRange,
      // }).toList();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvando exame laboratorial...')),
      );
      // Simulação de salvamento
      Future.delayed(const Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exame salvo com sucesso! (Simulado)')),
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: const InputDecoration(labelText: 'Título do Exame*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título do exame';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _examDateController,
                decoration: const InputDecoration(labelText: 'Data da Realização*'),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data de realização';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _clinicNameController,
                decoration: const InputDecoration(labelText: 'Clínica/Laboratório'),
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
              // TODO: Adicionar UI para anexo de laudo
              ElevatedButton(onPressed: () {/* TODO: Anexar laudo */}, child: const Text('Anexar Laudo Original (PDF, Imagem)')),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas/Observações'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Salvar Exame'),
              ),
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
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Item ${i + 1}', style: Theme.of(context).textTheme.titleSmall),
                      if (_labResults.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeBiomarker(i),
                        ),
                    ],
                  ),
                  TextFormField(
                    initialValue: _labResults[i].biomarkerName,
                    decoration: const InputDecoration(labelText: 'Nome do Item/Biomarcador*'),
                    onChanged: (value) => _labResults[i].biomarkerName = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o nome do item';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _labResults[i].value,
                    decoration: const InputDecoration(labelText: 'Valor*'),
                    onChanged: (value) => _labResults[i].value = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o valor';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _labResults[i].unit,
                    decoration: const InputDecoration(labelText: 'Unidade*'),
                    onChanged: (value) => _labResults[i].unit = value,
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira a unidade';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _labResults[i].referenceRange,
                    decoration: const InputDecoration(labelText: 'Faixa de Referência'),
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

