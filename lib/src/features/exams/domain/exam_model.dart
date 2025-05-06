import 'package:cloud_firestore/cloud_firestore.dart';

class LabResultItem {
  final String biomarkerName;
  final String value;
  final String unit;
  final String? referenceRange;

  LabResultItem({
    required this.biomarkerName,
    required this.value,
    required this.unit,
    this.referenceRange,
  });

  Map<String, dynamic> toMap() {
    return {
      'biomarkerName': biomarkerName,
      'value': value,
      'unit': unit,
      'referenceRange': referenceRange,
    };
  }

  factory LabResultItem.fromMap(Map<String, dynamic> map) {
    return LabResultItem(
      biomarkerName: map['biomarkerName'] ?? '',
      value: map['value'] ?? '',
      unit: map['unit'] ?? '',
      referenceRange: map['referenceRange'],
    );
  }
}

class ImageFileAttachment {
  final String fileName;
  final String fileUrl; // URL do Firebase Storage
  final String filePath; // Caminho no Firebase Storage
  final String? fileType;

  ImageFileAttachment({
    required this.fileName,
    required this.fileUrl,
    required this.filePath,
    this.fileType,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'filePath': filePath,
      'fileType': fileType,
    };
  }

  factory ImageFileAttachment.fromMap(Map<String, dynamic> map) {
    return ImageFileAttachment(
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      filePath: map['filePath'] ?? '',
      fileType: map['fileType'],
    );
  }
}

class ExamModel {
  final String? examId;
  final String userId;
  final String patientProfileId;
  final String patientName;
  final String examType; // 'laboratory' ou 'image'
  final String examTitle;
  final Timestamp examDate;
  final String? clinicName;
  final String? notes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  // Específico para exames laboratoriais
  final List<LabResultItem>? labResults;
  final String? labAttachmentUrl; // Para laudo PDF/imagem do exame laboratorial
  final String? labAttachmentPath;

  // Específico para exames de imagem
  final List<ImageFileAttachment>? imageFiles;

  ExamModel({
    this.examId,
    required this.userId,
    required this.patientProfileId,
    required this.patientName,
    required this.examType,
    required this.examTitle,
    required this.examDate,
    this.clinicName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.labResults,
    this.labAttachmentUrl,
    this.labAttachmentPath,
    this.imageFiles,
  }) : assert(examType == 'laboratory' || examType == 'image');

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'patientProfileId': patientProfileId,
      'patientName': patientName,
      'examType': examType,
      'examTitle': examTitle,
      'examDate': examDate,
      'clinicName': clinicName,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (examType == 'laboratory') 'labResults': labResults?.map((item) => item.toMap()).toList(),
      if (examType == 'laboratory') 'labAttachmentUrl': labAttachmentUrl,
      if (examType == 'laboratory') 'labAttachmentPath': labAttachmentPath,
      if (examType == 'image') 'imageFiles': imageFiles?.map((item) => item.toMap()).toList(),
    };
  }

  factory ExamModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExamModel(
      examId: doc.id,
      userId: data['userId'] ?? '',
      patientProfileId: data['patientProfileId'] ?? '',
      patientName: data['patientName'] ?? '',
      examType: data['examType'] ?? '',
      examTitle: data['examTitle'] ?? '',
      examDate: data['examDate'] ?? Timestamp.now(),
      clinicName: data['clinicName'],
      notes: data['notes'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      labResults: data['examType'] == 'laboratory' && data['labResults'] != null
          ? List<LabResultItem>.from((data['labResults'] as List<dynamic>).map((item) => LabResultItem.fromMap(item as Map<String, dynamic>)))
          : null,
      labAttachmentUrl: data['examType'] == 'laboratory' ? data['labAttachmentUrl'] : null,
      labAttachmentPath: data['examType'] == 'laboratory' ? data['labAttachmentPath'] : null,
      imageFiles: data['examType'] == 'image' && data['imageFiles'] != null
          ? List<ImageFileAttachment>.from((data['imageFiles'] as List<dynamic>).map((item) => ImageFileAttachment.fromMap(item as Map<String, dynamic>)))
          : null,
    );
  }
}

