import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/di/service_locator.dart';
import '../../data/models/feedback_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/export_service.dart';

// Events
abstract class FeedbackEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedbackUserDetailsSubmitted extends FeedbackEvent {
  final String userName;
  final String userEmail;
  final String userContact;

  FeedbackUserDetailsSubmitted({
    required this.userName,
    required this.userEmail,
    required this.userContact,
  });

  @override
  List<Object?> get props => [userName, userEmail, userContact];
}

class FeedbackBugDescriptionSubmitted extends FeedbackEvent {
  final String bugDescription;
  final String userDevice;

  FeedbackBugDescriptionSubmitted({
    required this.bugDescription,
    required this.userDevice,
  });

  @override
  List<Object?> get props => [bugDescription, userDevice];
}

class FeedbackMediaAdded extends FeedbackEvent {
  final String mediaPath;
  FeedbackMediaAdded(this.mediaPath);
  @override
  List<Object?> get props => [mediaPath];
}

class FeedbackMediaRemoved extends FeedbackEvent {
  final String mediaPath;
  FeedbackMediaRemoved(this.mediaPath);
  @override
  List<Object?> get props => [mediaPath];
}

class FeedbackSubmitted extends FeedbackEvent {
  final String deviceOwner;
  FeedbackSubmitted(this.deviceOwner);
  @override
  List<Object?> get props => [deviceOwner];
}

class FeedbackReset extends FeedbackEvent {}

class FeedbackExportRequested extends FeedbackEvent {}

class FeedbackLoadAll extends FeedbackEvent {}

// States
abstract class FeedbackState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackUserDetailsSet extends FeedbackState {
  final String userName;
  final String userEmail;
  final String userContact;

  FeedbackUserDetailsSet({
    required this.userName,
    required this.userEmail,
    required this.userContact,
  });

  @override
  List<Object?> get props => [userName, userEmail, userContact];
}

class FeedbackBugDescriptionSet extends FeedbackState {
  final String userName;
  final String userEmail;
  final String userContact;
  final String bugDescription;
  final String userDevice;

  FeedbackBugDescriptionSet({
    required this.userName,
    required this.userEmail,
    required this.userContact,
    required this.bugDescription,
    required this.userDevice,
  });

  @override
  List<Object?> get props => [
    userName,
    userEmail,
    userContact,
    bugDescription,
    userDevice,
  ];
}

class FeedbackMediaState extends FeedbackState {
  final String userName;
  final String userEmail;
  final String userContact;
  final String bugDescription;
  final String userDevice;
  final List<String> mediaPaths;

  FeedbackMediaState({
    required this.userName,
    required this.userEmail,
    required this.userContact,
    required this.bugDescription,
    required this.userDevice,
    required this.mediaPaths,
  });

  FeedbackMediaState copyWith({List<String>? mediaPaths}) {
    return FeedbackMediaState(
      userName: userName,
      userEmail: userEmail,
      userContact: userContact,
      bugDescription: bugDescription,
      userDevice: userDevice,
      mediaPaths: mediaPaths ?? this.mediaPaths,
    );
  }

  @override
  List<Object?> get props => [
    userName,
    userEmail,
    userContact,
    bugDescription,
    userDevice,
    mediaPaths,
  ];
}

class FeedbackSubmitSuccess extends FeedbackState {}

class FeedbackAllLoaded extends FeedbackState {
  final List<FeedbackModel> feedbacks;
  FeedbackAllLoaded(this.feedbacks);
  @override
  List<Object?> get props => [feedbacks];
}

class FeedbackExportSuccess extends FeedbackState {
  final String filePath;
  FeedbackExportSuccess(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

class FeedbackExportAuthFailed extends FeedbackState {}

class FeedbackError extends FeedbackState {
  final String message;
  FeedbackError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final DatabaseService _dbService = sl<DatabaseService>();
  final ExportService _exportService = sl<ExportService>();

  FeedbackBloc() : super(FeedbackInitial()) {
    on<FeedbackUserDetailsSubmitted>(_onUserDetailsSubmitted);
    on<FeedbackBugDescriptionSubmitted>(_onBugDescriptionSubmitted);
    on<FeedbackMediaAdded>(_onMediaAdded);
    on<FeedbackMediaRemoved>(_onMediaRemoved);
    on<FeedbackSubmitted>(_onFeedbackSubmitted);
    on<FeedbackReset>(_onFeedbackReset);
    on<FeedbackExportRequested>(_onExportRequested);
    on<FeedbackLoadAll>(_onLoadAll);
  }

  void _onUserDetailsSubmitted(
    FeedbackUserDetailsSubmitted event,
    Emitter<FeedbackState> emit,
  ) {
    emit(
      FeedbackUserDetailsSet(
        userName: event.userName,
        userEmail: event.userEmail,
        userContact: event.userContact,
      ),
    );
  }

  void _onBugDescriptionSubmitted(
    FeedbackBugDescriptionSubmitted event,
    Emitter<FeedbackState> emit,
  ) {
    if (state is FeedbackUserDetailsSet) {
      final prev = state as FeedbackUserDetailsSet;
      emit(
        FeedbackBugDescriptionSet(
          userName: prev.userName,
          userEmail: prev.userEmail,
          userContact: prev.userContact,
          bugDescription: event.bugDescription,
          userDevice: event.userDevice,
        ),
      );
    }
  }

  void _onMediaAdded(FeedbackMediaAdded event, Emitter<FeedbackState> emit) {
    if (state is FeedbackBugDescriptionSet) {
      final prev = state as FeedbackBugDescriptionSet;
      emit(
        FeedbackMediaState(
          userName: prev.userName,
          userEmail: prev.userEmail,
          userContact: prev.userContact,
          bugDescription: prev.bugDescription,
          userDevice: prev.userDevice,
          mediaPaths: [event.mediaPath],
        ),
      );
    } else if (state is FeedbackMediaState) {
      final prev = state as FeedbackMediaState;
      emit(prev.copyWith(mediaPaths: [...prev.mediaPaths, event.mediaPath]));
    }
  }

  void _onMediaRemoved(
    FeedbackMediaRemoved event,
    Emitter<FeedbackState> emit,
  ) {
    if (state is FeedbackMediaState) {
      final prev = state as FeedbackMediaState;
      emit(
        prev.copyWith(
          mediaPaths: prev.mediaPaths
              .where((p) => p != event.mediaPath)
              .toList(),
        ),
      );
    }
  }

  Future<void> _onFeedbackSubmitted(
    FeedbackSubmitted event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    try {
      String userName = '';
      String userEmail = '';
      String userContact = '';
      String bugDescription = '';
      String userDevice = '';
      List<String> mediaPaths = [];

      if (state is FeedbackMediaState) {
        final s = state as FeedbackMediaState;
        userName = s.userName;
        userEmail = s.userEmail;
        userContact = s.userContact;
        bugDescription = s.bugDescription;
        userDevice = s.userDevice;
        mediaPaths = s.mediaPaths;
      }

      final feedback = FeedbackModel(
        deviceOwner: event.deviceOwner,
        userName: userName,
        userEmail: userEmail,
        userContact: userContact,
        bugDescription: bugDescription,
        userDevice: userDevice,
        mediaPaths: mediaPaths,
        createdAt: DateTime.now(),
      );

      await _dbService.insertFeedback(feedback);
      emit(FeedbackSubmitSuccess());
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  void _onFeedbackReset(FeedbackReset event, Emitter<FeedbackState> emit) {
    emit(FeedbackInitial());
  }

  Future<void> _onExportRequested(
    FeedbackExportRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    try {
      final feedbacks = await _dbService.getAllFeedbacks();
      final filePath = await _exportService.exportToCSV(feedbacks);
      if (filePath != null) {
        emit(FeedbackExportSuccess(filePath));
      } else {
        emit(FeedbackExportAuthFailed());
      }
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
    FeedbackLoadAll event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    try {
      final feedbacks = await _dbService.getAllFeedbacks();
      emit(FeedbackAllLoaded(feedbacks));
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }
}
