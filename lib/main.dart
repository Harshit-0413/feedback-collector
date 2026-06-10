import 'package:feedback_collector/presentation/login_screen.dart';
import 'package:feedback_collector/presentation/screens/media_collections_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth_bloc.dart';
import 'presentation/blocs/feedback_bloc.dart';
import 'presentation/screens/user_details_screen.dart';
import 'presentation/screens/bug_description_screen.dart';
import 'presentation/screens/thank_you_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(AuthCheckRequested()),
        ),
        BlocProvider<FeedbackBloc>(create: (_) => FeedbackBloc()),
      ],
      child: MaterialApp(
        title: 'Feedback Collector',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/user-details': (context) => const UserDetailsScreen(),
          '/bug-description': (context) => const BugDescriptionScreen(),
          '/media-collection': (context) => const MediaCollectionScreen(),
          '/thank-you': (context) => const ThankYouScreen(),
        },
      ),
    );
  }
}
