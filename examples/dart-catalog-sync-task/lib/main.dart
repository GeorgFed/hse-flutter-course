import 'package:collection/collection.dart';

/*
Продуктовый контекст

Приложение хранит локальный список товаров и получает его новую версию
с бэкенда. Чтобы не обновлять все карточки, нужно определить товары,
которые добавились, исчезли или изменились.

Задача

Сделать так, чтобы товары с одинаковыми данными считались равными, сравнить
две версии списка и вернуть множество id, требующих обновления.
Некорректные данные должны давать понятную ошибку, а важные этапы — оставлять
короткие сообщения в логе.
*/

typedef LogSink = void Function(String message);

final class Product {
  static const tagsEquality = ListEquality<String>();

  final String id;
  final String name;
  final int priceRubles;
  final String? category;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    required this.priceRubles,
    this.category,
    this.tags = const [],
  })  : assert(id != ''),
        assert(name != ''),
        assert(priceRubles >= 0);

  @override
  bool operator ==(Object other) {
    // TODO 1: товары с одинаковыми данными должны считаться равными.
    return identical(this, other);
  }

  @override
  int get hashCode {
    // TODO 1: соблюдите контракт между равенством объектов и hashCode.
    return identityHashCode(this);
  }
}

/// Описывает операции для сравнения двух версий списка товаров.
abstract interface class ProductCartManager {
  /// Проверяет, содержат ли два списка одинаковые товары
  /// в одинаковом порядке.
  bool sameProductList(List<Product> left, List<Product> right);

  /// Создаёт доступный только для чтения индекс товаров по id.
  /// Сообщает об ошибке, если один id встречается несколько раз.
  Map<String, Product> indexById(
    List<Product> products, {
    LogSink? log,
  });

  /// Возвращает id товаров, добавленных, удалённых или изменённых
  /// между двумя версиями списка.
  Set<String> findChangedIds(
    List<Product> previous,
    List<Product> current, {
    LogSink? log,
  });
}

ProductCartManager createProductCartManager() {
  // TODO 2–4: создайте реализацию ProductCartManager и верните её здесь.
  throw UnimplementedError();
}

// -----------------------------------------------------------------------------
// Готовый пример запуска. Код ниже менять не требуется.
// После реализации он печатает: [coffee, tea, water] и три сообщения LOG.
// -----------------------------------------------------------------------------

void main() {
  const previous = [
    Product(id: 'coffee', name: 'Кофе', priceRubles: 159),
    Product(id: 'tea', name: 'Чай', priceRubles: 99),
  ];
  const current = [
    Product(id: 'coffee', name: 'Кофе', priceRubles: 179),
    Product(id: 'water', name: 'Вода', priceRubles: 50),
  ];

  final manager = createProductCartManager();
  final logs = <String>[];

  try {
    final changedIds = manager.findChangedIds(
      previous,
      current,
      log: logs.add,
    );
    print('Изменившиеся товары: ${changedIds.toList()..sort()}');
    for (final message in logs) {
      print('LOG: $message');
    }
  } on FormatException catch (error) {
    print('Не удалось сравнить списки товаров: $error');
  }
}
