import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/firebase_service.dart';
import 'data/services/settings_service.dart';
import 'firebase_options.dart'; // keep the file FlutterFire generated for your project
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/chatbot_viewmodel.dart';
import 'presentation/viewmodels/cost_viewmodel.dart';
import 'presentation/viewmodels/export_viewmodel.dart';
import 'presentation/viewmodels/interior_viewmodel.dart';
import 'presentation/viewmodels/layout_viewmodel.dart';
import 'presentation/viewmodels/material_viewmodel.dart';
import 'presentation/viewmodels/plot_input_viewmodel.dart';
import 'presentation/viewmodels/prices_viewmodel.dart';
import 'presentation/viewmodels/profile_viewmodel.dart';
import 'presentation/viewmodels/projects_viewmodel.dart';
import 'presentation/views/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final settings = await SettingsService.load();
  runApp(DomexaApp(settings: settings));
}

class DomexaApp extends StatelessWidget {
  const DomexaApp({super.key, required this.settings});
  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (Model layer)
        Provider<SettingsService>.value(value: settings),
        Provider<ApiService>(create: (c) => ApiService(c.read<SettingsService>())),
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        // ViewModels
        ChangeNotifierProvider(create: (c) => AuthViewModel(c.read<FirebaseService>())),
        ChangeNotifierProxyProvider<AuthViewModel, ProjectsViewModel>(
          create: (c) => ProjectsViewModel(c.read<FirebaseService>()),
          update: (_, auth, vm) => vm!..bind(auth.user?.uid),
        ),
        ChangeNotifierProvider(create: (_) => PlotInputViewModel()),
        ChangeNotifierProvider(create: (c) => LayoutViewModel(c.read<ApiService>())),
        ChangeNotifierProvider(create: (c) => MaterialViewModel(c.read<ApiService>())),
        ChangeNotifierProvider(create: (c) => CostViewModel(c.read<ApiService>())),
        ChangeNotifierProvider(create: (c) => InteriorViewModel(c.read<ApiService>())),
        ChangeNotifierProvider(create: (c) => ChatbotViewModel(c.read<ApiService>())),
        ChangeNotifierProvider(create: (c) => ExportViewModel(c.read<ApiService>())),
        ChangeNotifierProvider(create: (c) => PricesViewModel(c.read<ApiService>())),
        ChangeNotifierProvider(create: (c) => ProfileViewModel(c.read<SettingsService>(), c.read<ApiService>())),
      ],
      child: MaterialApp(
        title: 'Domexa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}