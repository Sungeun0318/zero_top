import 'package:flutter/material.dart';
import 'package:zero_top/features/swimming/swimming_main_screen.dart';


class TrainingScreen extends StatelessWidget {
  const TrainingScreen({Key? key}) : super(key: key);

  Widget _buildTrainingIcon(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == "Swimming") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SwimmingMainScreen()),
          );


        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$label 화면은 준비 중입니다.")),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("트레이닝"),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("왕관 버튼이 눌렸습니다!")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),

          // 🔥 Z⋮TOP 로고 대신 이미지로 대체
          // 원하는 PNG 파일을 사용 (예: assets/images/z_top_logo.png)
          Center(
            child: Image.asset(
              'assets/images/z_top_logo.png', // 실제 경로로 교체
              width: 200,                     // 적절한 크기
              // height: 150,                 // 필요하다면 높이도 지정
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 30),

          // 2x2 운동 선택 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildTrainingIcon(context, Icons.pool, "Swimming"),
                  _buildTrainingIcon(context, Icons.directions_run, "Athletics"),
                  _buildTrainingIcon(context, Icons.track_changes, "Short Track"),
                  _buildTrainingIcon(context, Icons.ice_skating_outlined, "Speed Skating"),
                ],
              ),
            ),
          ),
          // 광고 배너 영역
          Container(
            width: screenWidth * 0.9,
            height: 60,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              "광고 배너",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
