import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:russia_app/screens/login_screen.dart';
import 'package:russia_app/main_screen.dart';
import 'package:russia_app/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ru'),
        Locale('uz'),
        Locale('ky'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      startLocale: const Locale('ru'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Russia App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Show splash screen for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    final isLoggedIn = await _apiService.isLoggedIn();
    
    if (mounted) {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/splash.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Animated Text
          Align(
            alignment: const Alignment(0, -0.5), // Position text slightly above center
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'welcome_message'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'lib/assets/sp.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Loader at the bottom
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       SizedBox(
          //         width: 32,
          //         height: 32,
          //         child: CircularProgressIndicator(
          //           strokeWidth: 2,
          //           valueColor: AlwaysStoppedAnimation<Color>(
          //             Colors.white.withOpacity(0.8),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(height: 80), // Keep it above the bottom edge
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
