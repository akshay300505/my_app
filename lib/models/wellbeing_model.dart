class WellbeingModel {
  final double moodScore;
  final double screenTime;

  WellbeingModel({
    required this.moodScore,
    required this.screenTime,
  });

  Map<String, dynamic> toMap() => {
        "moodScore": moodScore,
        "screenTime": screenTime,
      };
}