import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:saude_app_mobile/src/features/exams/domain/exam_model.dart';

class ExamRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<DocumentReference> addExam(ExamModel exam) async {
    try {
      return await _firestore.collection('exams').add(exam.toMap());
    } catch (e) {
      // TODO: Tratar erro de forma mais específica
      print('Erro ao adicionar exame no Firestore: $e');
      rethrow;
    }
  }

  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // TODO: Tratar erro de forma mais específica
      print('Erro ao fazer upload do arquivo: $e');
      rethrow;
    }
  }

  // TODO: Adicionar métodos para buscar, atualizar e deletar exames se necessário para o MVP
  // Exemplo de busca (não usado na inserção inicial, mas útil para o M04):
  // Stream<List<ExamModel>> getExamsForPatient(String patientProfileId) {
  //   return _firestore
  //       .collection('exams')
  //       .where('patientProfileId', isEqualTo: patientProfileId)
  //       .orderBy('examDate', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs.map((doc) => ExamModel.fromDocument(doc)).toList());
  // }
}

