import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:rinosat_manager/main_screen.dart';
import 'package:rinosat_manager/token_store.dart';

class _SplashScreen extends StatefulWidget {
  const _SplashScreen({super.key});

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowFade;
  late final Animation<double> _glowScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _outroFade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    _glowFade = Tween<double>(begin: 0.0, end: 0.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    _glowScale = Tween<double>(begin: 0.2, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.32, curve: Curves.easeIn),
      ),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _outroFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.86, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 2300), _onFinished);
  }

  Future<void> _onFinished() async {
    final tokenStore = TokenStore();
    var unlocked = false;
    final has = await tokenStore.hasToken();
    FirebaseCrashlytics.instance.log('Splash: hasToken=$has');
    if (has) {
      unlocked = await tokenStore.authenticate();
      FirebaseCrashlytics.instance.log('Splash: authenticate=$unlocked');
    }
    if (!mounted || navigatorKey.currentContext == null) return;
    Navigator.of(navigatorKey.currentContext!).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainScreen(biometricsUnlocked: unlocked),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _outroFade,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FadeTransition(
                      opacity: _glowFade,
                      child: ScaleTransition(
                        scale: _glowScale,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF3B82F6).withValues(alpha: 0.35),
                                const Color(0xFF3B82F6).withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Image.asset(
                          'assets/logo.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LetterSpacingTitle(controller: _controller),
                  const SizedBox(height: 14),
                  _GoldLine(controller: _controller),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LetterSpacingTitle extends StatelessWidget {
  const _LetterSpacingTitle({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    const text = 'Rinosat GPS';
    final letters = text.split('');
    final spacing = _Spacing(size: 10);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < letters.length; i++)
          if (letters[i] == ' ')
            spacing
          else
            _BouncyLetter(
              letter: letters[i],
              index: i,
              controller: controller,
            ),
      ],
    );
  }
}

class _Spacing extends StatelessWidget {
  const _Spacing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size);
}

class _GoldLine extends StatelessWidget {
  const _GoldLine({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.75, 0.95, curve: Curves.easeOutCubic),
      ),
    );
    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.72, 0.9, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([scale, opacity]),
      builder: (context, child) {
        return Opacity(
          opacity: opacity.value,
          child: ClipRect(
            child: Align(
              alignment: Alignment.center,
              widthFactor: scale.value,
              child: Container(
                width: 120,
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x00C9A24C),
                      Color(0xFFC9A24C),
                      Color(0x00C9A24C),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC9A24C).withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BouncyLetter extends StatelessWidget {
  const _BouncyLetter({
    required this.letter,
    required this.index,
    required this.controller,
  });

  final String letter;
  final int index;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final start = 0.5 + index * 0.02;
    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, (start + 0.14).clamp(0.0, 1.0), curve: Curves.easeIn),
      ),
    );
    final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, (start + 0.18).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );
    final offset = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, (start + 0.18).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([fade, scale, offset]),
      builder: (context, child) => Opacity(
        opacity: fade.value,
        child: Transform.translate(
          offset: Offset(0, offset.value),
          child: Transform.scale(
            scale: scale.value,
            child: child,
          ),
        ),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 3,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(MainApp());
}

final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  RateMyApp rateMyApp = RateMyApp();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      final dialogContext = navigatorKey.currentContext;
      if (dialogContext != null && dialogContext.mounted && rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(dialogContext);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const _SplashScreen(),
      builder: (context, child) {
        final brightness = MediaQuery.of(context).platformBrightness;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          ),
        );
        return child!;
      },
    );
  }
}
