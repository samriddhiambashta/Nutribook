class WeightInfo {
  final int? id;

  double? weight;

  final String? dateTime;

  WeightInfo({
    this.id,
    //required this.title,
    this.weight,
    this.dateTime,
    //this.steps
  });

  WeightInfo.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        weight = res["weight"],
        dateTime = res["dateTime"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'weight': weight,
      'dateTime': dateTime,
      //'steps': steps
    };
  }
}
