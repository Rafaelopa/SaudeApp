import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saude_app/src/features/exams/domain/exam_model.dart';
import 'package:saude_app/src/features/exams/infrastructure/exam_repository.dart';

class ExamService {
  final ExamRepository _examRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ExamService(this._examRepository);

  Future<String> _getCurrentUserId() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado.');
    }
    return currentUser.uid;
  }

  Future<ExamModel> addLabExam({
    required String patientProfileId,
    required String patientName,
    required String examTitle,
    required DateTime examDate,
    String? clinicName,
    String? notes,
    required List<LabResultItem> labResults,
    File? attachmentFile,
  }) async {
    final userId = await _getCurrentUserId();
    String? labAttachmentUrl;
    String? labAttachmentPath;
    final examId = _examRepository._firestore.collection("exams").doc().id;

    if (attachmentFile != null) {
      final fileName = 'laudo_${DateTime.now().millisecondsSinceEpoch}.${attachmentFile.path.split(".").last}';
      labAttachmentPath = 'users/$userId/patients/$patientProfileId/exams/$examId/lab_attachments/$fileName';
      labAttachmentUrl = await _examRepository.uploadFile(attachmentFile, labAttachmentPath);
    }

    final exam = ExamModel(
      examId: examId,
      userId: userId,
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
    return exam;
  }

  Future<ExamModel> addImageExam({
    required String patientProfileId,
    required String patientName,
    required String examTitle,
    required DateTime examDate,
    String? clinicName,
    String? notes,
    required List<File> imageFilesToUpload,
  }) async {
    final userId = await _getCurrentUserId();
    List<ImageFileAttachment> uploadedImageFiles = [];
    final examId = _examRepository._firestore.collection("exams").doc().id;

    for (File file in imageFilesToUpload) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split("/").last}';
      final filePath = 'users/$userId/patients/$patientProfileId/exams/$examId/image_attachments/$fileName';
      final fileUrl = await _examRepository.uploadFile(file, filePath);
      uploadedImageFiles.add(ImageFileAttachment(
        fileName: file.path.split("/").last,
        fileUrl: fileUrl,
        filePath: filePath,
        fileType: file.path.split(".").last,
      ));
    }

    final exam = ExamModel(
      examId: examId,
      userId: userId,
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
    return exam;
  }

  Future<void> updateLabExam({
    required String examIdToUpdate,
    required String patientProfileId,
    required String patientName,
    required String examTitle,
    required DateTime examDate,
    String? clinicName,
    String? notes,
    required List<LabResultItem> labResults,
    File? newAttachmentFile,
    String? existingAttachmentPath,
    String? existingAttachmentUrl,
  }) async {
    final userId = await _getCurrentUserId();
    String? finalAttachmentUrl = existingAttachmentUrl;
    String? finalAttachmentPath = existingAttachmentPath;

    if (newAttachmentFile != null) {
      if (existingAttachmentPath != null && existingAttachmentPath.isNotEmpty) {
        await _examRepository.deleteFile(existingAttachmentPath);
      }
      final fileName = 'laudo_${DateTime.now().millisecondsSinceEpoch}.${newAttachmentFile.path.split(".").last}';
      finalAttachmentPath = 'users/$userId/patients/$patientProfileId/exams/$examIdToUpdate/lab_attachments/$fileName';
      finalAttachmentUrl = await _examRepository.uploadFile(newAttachmentFile, finalAttachmentPath);
    } else if (existingAttachmentPath != null && newAttachmentFile == null && finalAttachmentUrl == null) {
        await _examRepository.deleteFile(existingAttachmentPath);
        finalAttachmentPath = null;
        finalAttachmentUrl = null;
    }

    final exam = ExamModel(
      examId: examIdToUpdate,
      userId: userId,
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
      labAttachmentUrl: finalAttachmentUrl,
      labAttachmentPath: finalAttachmentPath,
    );
    await _examRepository.updateExam(exam);
  }

  Future<void> updateImageExam({
    required String examIdToUpdate,
    required String patientProfileId,
    required String patientName,
    required String examTitle,
    required DateTime examDate,
    String? clinicName,
    String? notes,
    required List<File> newImageFilesToUpload,
    required List<ImageFileAttachment> originalAttachmentsInExam, 
    required List<ImageFileAttachment> currentAttachmentsFromUI,
  }) async {
    final userId = await _getCurrentUserId();
    List<ImageFileAttachment> finalImageFiles = [];

    for (File newFile in newImageFilesToUpload) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${newFile.path.split("/").last}';
      final filePath = 'users/$userId/patients/$patientProfileId/exams/$examIdToUpdate/image_attachments/$fileName';
      final fileUrl = await _examRepository.uploadFile(newFile, filePath);
      finalImageFiles.add(ImageFileAttachment(
        fileName: newFile.path.split("/").last,
        fileUrl: fileUrl,
        filePath: filePath,
        fileType: newFile.path.split(".").last,
      ));
    }

    List<String> currentAttachmentsPathsFromUI = currentAttachmentsFromUI.map((att) => att.filePath).toList();
    for (var originalAttachment in originalAttachmentsInExam) {
      if (!currentAttachmentsPathsFromUI.contains(originalAttachment.filePath)) {
        await _examRepository.deleteFile(originalAttachment.filePath);
      }
    }
    
    finalImageFiles.addAll(currentAttachmentsFromUI);
    
    final uniqueFinalImageFiles = <String, ImageFileAttachment>{};
    for (var attachment in finalImageFiles) {
      uniqueFinalImageFiles[attachment.filePath] = attachment;
    }
    finalImageFiles = uniqueFinalImageFiles.values.toList();

    final exam = ExamModel(
      examId: examIdToUpdate,
      userId: userId,
      patientProfileId: patientProfileId,
      patientName: patientName,
      examType: 'image',
      examTitle: examTitle,
      examDate: Timestamp.fromDate(examDate),
      clinicName: clinicName,
      notes: notes,
      createdAt: Timestamp.now(), 
      updatedAt: Timestamp.now(),
      imageFiles: finalImageFiles,
    );
    await _examRepository.updateExam(exam);
  }

  Future<void> deleteExam(String examId, String examType, List<ImageFileAttachment>? imageFiles, String? labAttachmentPath) async {
    await _getCurrentUserId();
    if (examType == 'image' && imageFiles != null) {
      for (var fileAttachment in imageFiles) {
        if (fileAttachment.filePath.isNotEmpty) {
          await _examRepository.deleteFile(fileAttachment.filePath);
        }
      }
    } else if (examType == 'laboratory' && labAttachmentPath != null && labAttachmentPath.isNotEmpty) {
      await _examRepository.deleteFile(labAttachmentPath);
    }
    await _examRepository.deleteExam(examId);
  }
}

