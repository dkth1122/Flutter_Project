class Ad {
  final String id;
  final String title;
  final String description;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final String userId; // 사용자 정보 추가

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.userId, // 사용자 정보 추가
  });
}
