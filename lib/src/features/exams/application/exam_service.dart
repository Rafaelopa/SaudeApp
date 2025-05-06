import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saude_app_mobile/src/features/exams/domain/exam_model.dart';
import 'package:saude_app_mobile/src/features/exams/infrastructure/exam_repository.dart';

class ExamService {
  final ExamRepository _examRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ExamService(this._examRepository);

  Future<void> addLabExam({
    required String patientProfileId,
    required String patientName,
    required String examTitle,
    required DateTime examDate,
    String? clinicName,
    String? notes,
    required List<LabResultItem> labResults,
    File? attachmentFile, // Laudo original
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado.');
    }

    String? labAttachmentUrl;
    String? labAttachmentPath;

    final examId = _examRepository._firestore.collection("exams").doc().id; // Gerar ID antes para o path

    if (attachmentFile != null) {
      final fileName = 'laudo_${DateTime.now().millisecondsSinceEpoch}.${attachmentFile.path.split(".").last}';
      labAttachmentPath = 'users/${currentUser.uid}/patients/$patientProfileId/exams/$examId/lab_attachments/$fileName';
      labAttachmentUrl = await _examRepository.uploadFile(attachmentFile, labAttachmentPath);
    }

    final exam = ExamModel(
      examId: examId, // Passar o ID gerado
      userId: currentUser.uid,
      patientProfileId: patientProfileId,
      patientName: patientName,
      examType: 'laboratory',
      examTitle: examTitle,
      examDate: Timestamp.fromDate(examDate),
      clinicName: clinicName,
      notes: notes,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      labResults: labResults,
      labAttachmentUrl: labAttachmentUrl,
      labAttachmentPath: labAttachmentPath,
    );

    await _examRepository.addExam(exam);
  }

  Future<void> addImageExam({
    required String patientProfileId,
    required String patientName,
    required String examTitle,
    required DateTime examDate,
    String? clinicName,
    String? notes,
    required List<File> imageFilesToUpload, // Lista de arquivos de imagem
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado.');
    }

    List<ImageFileAttachment> uploadedImageFiles = [];
    final examId = _examRepository._firestore.collection("exams").doc().id; // Gerar ID antes para o path

    for (File file in imageFilesToUpload) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split("/").last}';
      final filePath = 'users/${currentUser.uid}/patients/$patientProfileId/exams/$examId/image_attachments/$fileName';
      final fileUrl = await _examRepository.uploadFile(file, filePath);
      uploadedImageFiles.add(ImageFileAttachment(
        fileName: file.path.split("/").last, // Nome original
        fileUrl: fileUrl,
        filePath: filePath,
        fileType: file.path.split(".").last, // Extensão como tipo simplificado
      ));
    }

    final exam = ExamModel(
      examId: examId, // Passar o ID gerado
      userId: currentUser.uid,
      patientProfileId: patientProfileId,
      patientName: patientName,
      examType: 'image',
      examTitle: examTitle,
      examDate: Timestamp.fromDate(examDate),
      clinicName: clinicName,
      notes: notes,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      imageFiles: uploadedImageFiles,
    );

    await _examRepository.addExam(exam);
  }
}

