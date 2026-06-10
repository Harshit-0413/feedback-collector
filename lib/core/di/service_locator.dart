import 'package:get_it/get_it.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import '../../data/services/media_service.dart';
import '../../data/services/export_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<DatabaseService>(() => DatabaseService.instance);
  sl.registerLazySingleton<MediaService>(() => MediaService());
  sl.registerLazySingleton<ExportService>(() => ExportService());
}
