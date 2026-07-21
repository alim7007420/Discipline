import 'package:isar/isar.dart';

part 'shopping_item.g.dart';

@collection
class ShoppingItem {
  Id id = Isar.autoIncrement;

  late String name;
  bool isPurchased = false;
}
