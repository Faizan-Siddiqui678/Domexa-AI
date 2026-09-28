import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/plot_input_viewmodel.dart';
import 'presentation/viewmodels/interior_viewmodel.dart';
import 'presentation/viewmodels/cost_viewmodel.dart';
import 'presentation/viewmodels/export_viewmodel.dart';
import 'presentation/viewmodels/chatbot_viewmodel.dart';
import 'presentation/views/splash/splash_screen.dart';
import 'presentation/views/home/home_screen.dart';
import 'presentation/views/auth/login_screen.dart';
import 'presentation/views/auth/register_screen.dart';
import 'presentation/views/plot_input/plot_input_screen.dart';
import 'presentation/views/layout/layout_display_screen.dart';
import 'presentation/views/interior/interior_screen.dart';
import 'presentation/views/materials/materials_screen.dart';
import 'presentation/views/cost/cost_screen.dart';
import 'presentation/views/export/export_screen.dart';
import 'presentation/views/chatbot/chatbot_screen.dart';
import 'presentation/views/profile/profile_screen.dart';
import 'core/constants/color_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DomexaApp());
}

class DomexaApp extends StatelessWidget {
  const DomexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PlotInputViewModel()),
        ChangeNotifierProvider(create: (_) => InteriorViewModel()),
        ChangeNotifierProvider(create: (_) => CostViewModel()),
        ChangeNotifierProvider(create: (_) => ExportViewModel()),
        ChangeNotifierProvider(create: (_) => ChatbotViewModel()),
      ],
      child: MaterialApp(
        title: 'Domexa - Build Your Dream Home',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            elevation: 0,
            centerTitle: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.bgInput,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/plot-input': (context) => const PlotInputScreen(),
          '/layout': (context) => LayoutDisplayScreen(),
          '/interior': (context) => const InteriorScreen(),
          '/materials': (context) => const MaterialsScreen(),
          '/cost': (context) => const CostScreen(),
          '/export': (context) => const ExportScreen(),
          '/chatbot': (context) => const ChatbotScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}