class UserInfo {
  final int? id;

  int? water;

  final String? dateTime;

  UserInfo({
    this.id,
    //required this.title,
    this.water,
    this.dateTime,
    //this.steps
  });

  UserInfo.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        water = res["water"],
        dateTime = res["dateTime"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'water': water,
      'dateTime': dateTime,
      //'steps': steps
    };
  }
}
