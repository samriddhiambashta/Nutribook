class HistoryInfo {
  final int? id;
  //String title;
  int protein;
  int calorie;
  String mealName;
  final String? dateTime;
  // final int? steps;

  HistoryInfo({
    this.id,
    //required this.title,
    required this.protein,
    required this.calorie,
    required this.mealName,
    this.dateTime,

    //this.steps
  });

  HistoryInfo.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        protein = res["protein"],
        calorie = res["calorie"],
        mealName = res["mealName"],
        dateTime = res["dateTime"];
  //steps=res["steps"];
  //date=res["dateTime"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'protein': protein,
      'calorie': calorie,
      'mealName': mealName,
      'dateTime': dateTime,
      //'steps': steps
    };
  }
}
