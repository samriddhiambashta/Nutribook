class StepInfo {
  final int? id;

  int? steps;

  final String? dateTime;

  StepInfo({
    this.id,
    //required this.title,
    this.steps,
    this.dateTime,
    //this.steps
  });

  StepInfo.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        steps = res["steps"],
        dateTime = res["dateTime"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'steps': steps,
      'dateTime': dateTime,
      //'steps': steps
    };
  }
}
