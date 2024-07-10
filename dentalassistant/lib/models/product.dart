class Product {
  late int id;
  late String title;
  late String description;
  late bool forFirstList;
  late Duration duration;
  late DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.forFirstList,
    required this.duration,
    required this.createdAt,
  });

  Product.fromJson(Map json) {
    id = int.parse(json['id']);
    title = json['title'];
    description = json['description'];
    forFirstList = json['for_first_list'] == "1";
    duration = Duration(seconds: int.parse(json['duration']));
    createdAt = DateTime.parse(json['created_at']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['title'] = title;
    data['description'] = description;
    data['for_first_list'] = forFirstList ? '1' : '0';
    data['duration'] = duration.inSeconds.toString();
    data['created_at'] = createdAt.toIso8601String();
    return data;
  }

  @override
  String toString() {
    return 'Product(id: $id, title: $title, description: $description, forFirstList: $forFirstList, duration: $duration, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.forFirstList == forFirstList &&
        other.duration == duration &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        forFirstList.hashCode ^
        duration.hashCode ^
        createdAt.hashCode;
  }

  Product copyWith({
    int? id,
    String? title,
    String? description,
    bool? forFirstList,
    Duration? duration,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      forFirstList: forFirstList ?? this.forFirstList,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
