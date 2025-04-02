import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';

class ExerciseGraphWidget extends StatelessWidget {
  final DateTimeRange dateRange;
  final Map<DateTime, List<TrainingItem>> events;

  ExerciseGraphWidget({required this.dateRange, required this.events});

  // "25m x 6"와 같은 문자열을 파싱하여 총 거리를 계산 (예: 25 * 6 = 150)
  double parseDistance(String s) {
    try {
      List<String> parts = s.split('m');
      double value = double.parse(parts[0].trim());
      // "x 6"와 같은 부분에서 숫자만 추출
      String multStr = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
      double multiplier = double.parse(multStr);
      return value * multiplier;
    } catch (e) {
      return 0;
    }
  }

  // 선택된 날짜 범위 내 각 날짜의 운동량(총 거리) 데이터를 계산
  List<_DayExercise> computeData() {
    List<_DayExercise> data = [];
    DateTime current = dateRange.start;
    while (!current.isAfter(dateRange.end)) {
      DateTime key = DateTime.utc(current.year, current.month, current.day);
      double total = 0;
      if (events.containsKey(key)) {
        for (var item in events[key]!) {
          total += parseDistance(item.distance);
        }
      }
      data.add(_DayExercise(date: current, totalDistance: total));
      current = current.add(Duration(days: 1));
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    List<_DayExercise> data = computeData();
    double maxVal = data.fold(0, (prev, element) => max(prev, element.totalDistance));
    if (maxVal == 0) maxVal = 1; // 0으로 나누는 오류 방지
    return Container(
      width: double.maxFinite,
      height: 200, // 그래프 영역 높이
      child: CustomPaint(
        painter: _LineGraphPainter(data: data, maxVal: maxVal),
      ),
    );
  }
}

class _LineGraphPainter extends CustomPainter {
  final List<_DayExercise> data;
  final double maxVal;

  _LineGraphPainter({required this.data, required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    // 선 그리기용 Paint 설정
    final paintLine = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 데이터 포인트(원) 그리기용 Paint 설정
    final paintPoint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.fill;

    // 데이터 포인트 간의 수평 간격 계산
    double spacing =
    data.length > 1 ? size.width / (data.length - 1) : size.width / 2;

    // 각 데이터 포인트의 좌표 계산
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      double x = i * spacing;
      // 값이 클수록 위쪽에 위치하도록 size.height에서 비율만큼 뺍니다.
      double y = size.height - (data[i].totalDistance / maxVal) * size.height;
      points.add(Offset(x, y));
    }

    // 선 그래프 경로 그리기
    if (points.isNotEmpty) {
      Path path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paintLine);
    }

    // 각 데이터 포인트에 원 그리기
    for (Offset p in points) {
      canvas.drawCircle(p, 4, paintPoint);
    }

    // 각 데이터 포인트 위에 숫자(총 운동량) 표시
    for (int i = 0; i < points.length; i++) {
      final valueText = data[i].totalDistance.toStringAsFixed(0);
      final textSpan = TextSpan(
        text: valueText,
        style: TextStyle(color: Colors.black, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      // 점 위쪽에 텍스트가 중앙 정렬되도록 위치 계산
      Offset textOffset = Offset(
        points[i].dx - textPainter.width / 2,
        points[i].dy - textPainter.height - 4,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _DayExercise {
  final DateTime date;
  final double totalDistance;
  _DayExercise({required this.date, required this.totalDistance});
}

/// 1. TrainingItem 모델 클래스 정의
class TrainingItem {
  final String name;
  final String distance;
  final String time;

  TrainingItem({
    required this.name,
    required this.distance,
    required this.time,
  });
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isFabExpanded = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // _events를 TrainingItem 객체를 저장하도록 변경
  Map<DateTime, List<TrainingItem>> _events = {};

  Future<void> _showExerciseGraphDialog() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 7)),
        end: DateTime.now(),
      ),
    );
    if (picked != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("운동량 그래프"),
          content: Container(
            width: double.maxFinite,
            height: 200, // 그래프 영역 높이
            child: ExerciseGraphWidget(dateRange: picked, events: _events),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("닫기"),
            ),
          ],
        ),
      );
    }
  }



  void _showPreScheduleDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("스케줄 미리 작성"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "예: 자유형 25m x 6"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("작성된 스케줄: ${controller.text.trim()}"),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: Text("저장"),
          ),
        ],
      ),
    );
  }

  Widget _buildFabMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isFabExpanded) ...[
          _buildMiniFab(
            icon: Icons.edit,
            label: "훈련 추가",
            onPressed: () {
              _showTrainingInputDialog();
              setState(() => _isFabExpanded = false);
            },
          ),
          _buildMiniFab(
            icon: Icons.share,
            label: "캘린더 공유",
            onPressed: () {
              _showShareDialog();
              setState(() => _isFabExpanded = false);
            },
          ),
          _buildMiniFab(
            icon: Icons.delete,
            label: "리스트 삭제",
            onPressed: () {
              _showDeleteDialog();
              setState(() => _isFabExpanded = false);
            },
          ),
          SizedBox(height: 10),
        ],
        FloatingActionButton(
          backgroundColor: Colors.pinkAccent,
          child: Icon(_isFabExpanded ? Icons.close : Icons.add),
          onPressed: () {
            setState(() {
              _isFabExpanded = !_isFabExpanded;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMiniFab({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FloatingActionButton(
        heroTag: label,
        mini: true,
        backgroundColor: Colors.pinkAccent,
        onPressed: onPressed,
        child: Icon(icon, size: 20),
      ),
    );
  }

  // 선택한 날짜의 훈련 목록(TrainingItem 리스트)를 반환
  List<TrainingItem> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  // 새로운 훈련 항목(TrainingItem 객체)를 해당 날짜에 추가
  void _addTraining(TrainingItem training) {
    final dateKey = DateTime.utc(
      _selectedDay?.year ?? _focusedDay.year,
      _selectedDay?.month ?? _focusedDay.month,
      _selectedDay?.day ?? _focusedDay.day,
    );

    setState(() {
      if (_events[dateKey] == null) {
        _events[dateKey] = [];
      }
      _events[dateKey]!.add(training);
    });
  }

  void _showDeleteDialog() {
    DateTime day = DateTime.utc(
      (_selectedDay ?? _focusedDay).year,
      (_selectedDay ?? _focusedDay).month,
      (_selectedDay ?? _focusedDay).day,
    );
    List<TrainingItem> events = List.from(_events[day] ?? []);
    List<bool> selected = List.generate(events.length, (_) => false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("삭제할 항목 선택"),
        content: Container(
          width: double.maxFinite,
          child: events.isEmpty
              ? Text("삭제할 일정이 없습니다.")
              : ListView.builder(
            shrinkWrap: true,
            itemCount: events.length,
            itemBuilder: (context, index) => CheckboxListTile(
              title: Text(events[index].name),
              value: selected[index],
              onChanged: (val) {
                setState(() {
                  selected[index] = val!;
                });
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                for (int i = events.length - 1; i >= 0; i--) {
                  if (selected[i]) {
                    _events[day]?.remove(events[i]);
                  }
                }
                if (_events[day]?.isEmpty ?? false) {
                  _events.remove(day);
                }
              });
              Navigator.pop(context);
            },
            child: Text("삭제", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: 80),
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("캘린더 공유",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    "공유 링크 생성, 이미지 저장, PDF 내보내기 등 가능 (기능은 아직 개발 전)",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // 실제 공유 로직 연결
                    },
                    icon: Icon(Icons.link),
                    label: Text("공유 링크 생성"),
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("닫기"),
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, -1), end: Offset.zero)
              .animate(animation1),
          child: child,
        );
      },
    );
  }

  // 훈련 내용 추가 다이얼로그 (훈련명, 거리, 시간 입력)
  void _showTrainingInputDialog() {
    final nameController = TextEditingController();
    final distanceController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("훈련 내용 입력"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "훈련명",
                  hintText: "예: 자유형 느리게",
                ),
              ),
              TextField(
                controller: distanceController,
                decoration: InputDecoration(
                  labelText: "거리",
                  hintText: "예: 25m x 6",
                ),
              ),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: "시간",
                  hintText: "예: 50초 x 6",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final distance = distanceController.text.trim();
              final time = timeController.text.trim();
              if (name.isNotEmpty && distance.isNotEmpty && time.isNotEmpty) {
                final newTraining = TrainingItem(
                  name: name,
                  distance: distance,
                  time: time,
                );
                _addTraining(newTraining);
              }
              Navigator.pop(context);
            },
            child: Text("추가"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단바
            Container(
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.white),
                  Spacer(),
                  Text(
                    "Z:TOP",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.settings, color: Colors.white),
                ],
              ),
            ),
            // 캘린더 상단 커스텀 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 왼쪽: 운동량 그래프 버튼
                  IconButton(
                    icon: Icon(Icons.bar_chart),
                    tooltip: "운동량 그래프",
                    onPressed: _showExerciseGraphDialog,
                  ),
                  // 가운데: 좌우 화살표와 년/월 텍스트
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month - 1,
                              1,
                            );
                          });
                        },
                      ),
                      Text(
                        DateFormat('yyyy.MM').format(_focusedDay),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month + 1,
                              1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  // 오른쪽: 스케줄 미리 작성 버튼 (기존 "=" 버튼)
                  IconButton(
                    icon: Icon(Icons.menu),
                    tooltip: '스케줄 미리 작성',
                    onPressed: _showPreScheduleDialog,
                  ),
                ],
              ),
            ),

            // 달력
            TableCalendar(
              headerVisible: false,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 날짜 및 일정 리스트 제목
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _selectedDay != null
                    ? DateFormat('yyyy.MM.dd.E', 'ko').format(_selectedDay!)
                    : "날짜를 선택해주세요",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            // 훈련 리스트: 왼쪽에 훈련명, 오른쪽에 거리/시간 정보를 2줄로 표시 (삭제 버튼 제거)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount:
                    _getEventsForDay(_selectedDay ?? _focusedDay).length,
                    itemBuilder: (context, index) {
                      final item =
                      _getEventsForDay(_selectedDay ?? _focusedDay)[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(item.distance,
                                    style: TextStyle(fontSize: 14)),
                                Text(item.time,
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 2,
                            color: Colors.black,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // + 버튼 → 미니 FAB 메뉴 (여기서는 기존 메뉴 유지)
      floatingActionButton: _buildFabMenu(),
    );
  }
}
