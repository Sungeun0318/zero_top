import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필/설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 이메일 표시
            Text(
              '이메일: ${user?.email ?? '정보 없음'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // 로그아웃 버튼
            ElevatedButton(
              onPressed: () async {
                // Firebase 로그아웃 처리
                await FirebaseAuth.instance.signOut();
                // 로그아웃 후 초기 화면으로 돌아가기
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text('로그아웃'),
            ),
            const SizedBox(height: 20),
            // 추가 설정 항목 등 필요한 위젯을 추가할 수 있습니다.
            const Text(
              '추가 설정 항목은 여기에 추가하세요.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
