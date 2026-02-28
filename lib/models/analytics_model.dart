class AnalyticsModel {
  final int studyHours;
  final int completedTasks;

  AnalyticsModel({
    required this.studyHours,
    required this.completedTasks,
  });

  Map<String, dynamic> toMap() => {
        "studyHours": studyHours,
        "completedTasks": completedTasks,
      };
}