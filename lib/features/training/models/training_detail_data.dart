// lib/features/training_generation/models/training_detail_data.dart

class TrainingDetailData {
  String description;     // 훈련 내용
  String restTime;        // 쉬는 시간
  String distance;        // 거리
  String count;           // 개수
  String totalDistance;   // 총 거리
  String gap;             // 간격
  String numPeople;       // 인원
  String totalTime;       // 총 시간
  String cycle;           // 싸이클

  TrainingDetailData({
    this.description = "",
    this.restTime = "",
    this.distance = "",
    this.count = "",
    this.totalDistance = "",
    this.gap = "",
    this.numPeople = "",
    this.totalTime = "",
    this.cycle = "",
  });
}
