import 'package:flutter/material.dart';
import 'common/navigation/bottom_nav_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zero_top/login/login_sc.dart';
import 'package:zero_top/login/signgup_sc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login/profile_sc.dart';
import 'login/search.dart';
// 필요에 따라 localization 패키지 임포트

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ko', '');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swim Training',
      initialRoute: '/login',
      // 라우트(화면) 목록 등록
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/success': (context) => const BottomNavScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/search': (context) => const PasswordResetScreen(),
      },
      locale: _locale,
      theme: ThemeData(
        fontFamily: 'MyCustomFont',  // 전체 텍스트에 커스텀 폰트 적용
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          // 필요에 따라 다른 스타일 지정
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', ''), // 한국어
        Locale('en', ''), // 영어
        Locale('es', ''), // 스페인어
        Locale('zh', ''), // 중국어
      ],
      home: const BottomNavScreen(),
    );
  }
}
