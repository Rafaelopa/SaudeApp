import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:saude_app/src/features/exams/domain/exam_model.dart';

class ExamRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- Métodos de Criação ---
  Future<DocumentReference> addExam(ExamModel exam) async {
    try {
      // Se examId já foi pré-gerado (recomendado para consistência com paths de storage)
      if (exam.examId != null && exam.examId!.isNotEmpty) {
        await _firestore.collection('exams').doc(exam.examId).set(exam.toMap());
        return _firestore.collection('exams').doc(exam.examId);
      } else {
        return await _firestore.collection('exams').add(exam.toMap());
      }
    } catch (e) {
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
      print('Erro ao fazer upload do arquivo: $e');
      rethrow;
    }
  }

  // --- Métodos de Leitura ---
  Stream<List<ExamModel>> getExamsForPatient(String patientProfileId) {
    return _firestore
        .collection('exams')
        .where('patientProfileId', isEqualTo: patientProfileId)
        .orderBy('examDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ExamModel.fromDocument(doc)).toList());
  }

  // --- Métodos de Atualização ---
  Future<void> updateExam(ExamModel exam) async {
    if (exam.examId == null || exam.examId!.isEmpty) {
      throw ArgumentError('Exam ID não pode ser nulo ou vazio para atualização.');
    }
    try {
      await _firestore.collection('exams').doc(exam.examId).update(exam.toMap());
    } catch (e) {
      print('Erro ao atualizar exame no Firestore: $e');
      rethrow;
    }
  }

  // --- Métodos de Exclusão ---
  Future<void> deleteExam(String examId) async {
    if (examId.isEmpty) {
      throw ArgumentError('Exam ID não pode ser nulo ou vazio para exclusão.');
    }
    try {
      await _firestore.collection('exams').doc(examId).delete();
    } catch (e) {
      print('Erro ao excluir exame no Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String filePath) async {
    if (filePath.isEmpty) {
      print('Caminho do arquivo vazio, não é possível excluir.');
      return;
    }
    try {
      final ref = _storage.ref().child(filePath);
      await ref.delete();
    } catch (e) {
      // Tratar erro de objeto não encontrado de forma silenciosa, pois pode já ter sido excluído
      if (e is FirebaseException && e.code == 'object-not-found') {
        print('Arquivo não encontrado no Storage (pode já ter sido excluído): $filePath');
      } else {
        print('Erro ao excluir arquivo do Storage: $e');
        // Considerar rethrow dependendo da política de tratamento de erros
      }
    }
  }
}

