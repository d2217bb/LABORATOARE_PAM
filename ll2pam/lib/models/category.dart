class CategoryModel {
  final String id;
  final String label;
  final String iconType;
  final bool isSelected;

  const CategoryModel({
    required this.id,
    required this.label,
    required this.iconType,
    this.isSelected = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final label = (json['label'] ?? json['name'] ?? '') as String;
    final iconType = (json['iconType'] ?? json['id'] ?? 'women') as String;
    final isSelected = (json['isSelected'] ?? json['selected'] ?? false) as bool;

    return CategoryModel(
      id: json['id'] as String? ?? '',
      label: label,
      iconType: iconType,
      isSelected: isSelected,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? label,
    String? iconType,
    bool? isSelected,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      label: label ?? this.label,
      iconType: iconType ?? this.iconType,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
