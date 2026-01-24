import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    required super.id,
    required super.name,
    required super.color,
    required super.icon,
    super.monthlyBudgetId,
  });

  // Convert Entity -> Model
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      icon: entity.icon,
      monthlyBudgetId: entity.monthlyBudgetId,
    );
  }

  // Convert Model -> Entity
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      color: color,
      icon: icon,
      monthlyBudgetId: monthlyBudgetId,
    );
  }

  // From JSON / SQL
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      color: Color(int.parse(json['color'])),
      icon: IconData(json['icon'] ?? json['iconCodePoint'], fontFamily: 'MaterialIcons'),
      monthlyBudgetId: json['monthlyBudgetId'],
    );
  }

  // To JSON / SQL
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.value.toString(),
        'icon': icon.codePoint,
        'monthlyBudgetId': monthlyBudgetId,
      };
}
