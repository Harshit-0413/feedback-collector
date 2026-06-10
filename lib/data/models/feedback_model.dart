import 'package:equatable/equatable.dart';

class FeedbackModel extends Equatable {
  final int? id;
  final String deviceOwner;
  final String userName;
  final String userEmail;
  final String userContact;
  final String bugDescription;
  final String userDevice;
  final List<String> mediaPaths;
  final DateTime createdAt;

  const FeedbackModel({
    this.id,
    required this.deviceOwner,
    required this.userName,
    required this.userEmail,
    required this.userContact,
    required this.bugDescription,
    required this.userDevice,
    required this.mediaPaths,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deviceOwner': deviceOwner,
      'userName': userName,
      'userEmail': userEmail,
      'userContact': userContact,
      'bugDescription': bugDescription,
      'userDevice': userDevice,
      'mediaPaths': mediaPaths.join('|'),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'],
      deviceOwner: map['deviceOwner'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userContact: map['userContact'] ?? '',
      bugDescription: map['bugDescription'] ?? '',
      userDevice: map['userDevice'] ?? '',
      mediaPaths: map['mediaPaths'] != null && map['mediaPaths'].isNotEmpty
          ? (map['mediaPaths'] as String).split('|')
          : [],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  FeedbackModel copyWith({
    int? id,
    String? deviceOwner,
    String? userName,
    String? userEmail,
    String? userContact,
    String? bugDescription,
    String? userDevice,
    List<String>? mediaPaths,
    DateTime? createdAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      deviceOwner: deviceOwner ?? this.deviceOwner,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userContact: userContact ?? this.userContact,
      bugDescription: bugDescription ?? this.bugDescription,
      userDevice: userDevice ?? this.userDevice,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceOwner,
    userName,
    userEmail,
    userContact,
    bugDescription,
    userDevice,
    mediaPaths,
    createdAt,
  ];
}
