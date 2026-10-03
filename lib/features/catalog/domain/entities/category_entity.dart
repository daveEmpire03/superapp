import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int itemCount;
  final String imageUrl;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.itemCount,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, icon, itemCount, imageUrl];
}
