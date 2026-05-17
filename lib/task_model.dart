class TaskModel {
  String? id;
  String username;
  String title;
  String category;
  bool isCompleted;
  String date;

  TaskModel({
    this.id,
    required this.username,
    required this.title,
    required this.category,
    this.isCompleted = false,
    required this.date,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json["_id"],
    username: json["username"],
    title: json["title"],
    category: json["category"] ?? "General",
    isCompleted: json["isCompleted"] ?? false,
    date: json["createdAt"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "title": title,
    "category": category,
    "isCompleted": isCompleted,
  };
}
