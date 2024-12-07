class Product {
  late int id;
  late String title;
  late String description;
  late List<int> duration;
  late DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.createdAt,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    title = json['title'];
    description = json['description'];
    duration = List<int>.from(json['duration']);
    createdAt = DateTime.parse(json['created_at']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'title': title,
      'description': description,
      'duration': duration, // Convert List<int> directly
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, title: $title, description: $description, duration: $duration, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.duration == duration &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    description.hashCode ^
    duration.hashCode ^
    createdAt.hashCode;
  }

  Product copyWith({
    int? id,
    String? title,
    String? description,
    List<int>? duration,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
