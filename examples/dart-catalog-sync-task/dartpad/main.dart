// DartPad: вставьте весь файл, нажмите Run. TODO находятся в начале.
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

void demoMain() {
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

// Проверяющая обвязка для DartPad. Не изменяйте тесты и код ниже.
// package:test в DartPad не нужен. Здесь используются явные проверки,
// а не assert, поэтому они выполняются и в JavaScript-сборке.
int _passed = 0;
int _failed = 0;

class _Matcher {
  final bool Function(dynamic) matches;
  final String label;
  const _Matcher(this.matches, this.label);
}

final isNull = _Matcher((x) => x == null, 'null');
final isEmpty = _Matcher((x) => x.isEmpty == true, 'empty');
final isTrue = _Matcher((x) => x == true, 'true');
final isFalse = _Matcher((x) => x == false, 'false');
bool _throws(dynamic fn, bool Function(Object) accepts) {
  try {
    (fn as Function)();
  } catch (e) {
    return accepts(e);
  }
  return false;
}

final throwsUnsupportedError = _Matcher(
    (x) => _throws(x, (e) => e is UnsupportedError), 'UnsupportedError');
final throwsFormatException =
    _Matcher((x) => _throws(x, (e) => e is FormatException), 'FormatException');
_Matcher contains(String part) =>
    _Matcher((x) => x is String && x.contains(part), 'contains $part');
void expect(dynamic actual, dynamic expected) {
  final ok = expected is _Matcher
      ? expected.matches(actual)
      : const DeepCollectionEquality().equals(actual, expected);
  if (!ok)
    throw StateError(
        'Ожидалось: ${expected is _Matcher ? expected.label : expected}; получено: $actual');
}

void test(String title, void Function() body) {
  try {
    body();
    _passed++;
    print('PASS: $title');
  } catch (e) {
    _failed++;
    print('FAIL: $title\n  $e');
  }
}

void main() {
  _passed = 0;
  _failed = 0;
  runChecks();
  print('CHECKS: $_passed/8 passed; $_failed failed');
  if (_failed == 0) demoMain();
}

const coffee = Product(
  id: 'coffee',
  name: 'Кофе',
  priceRubles: 159,
  category: 'Напитки',
  tags: ['hot', 'drink'],
);
const tea = Product(
  id: 'tea',
  name: 'Чай',
  priceRubles: 99,
  category: 'Напитки',
  tags: ['drink'],
);

void runChecks() {
  ProductCartManager manager() => createProductCartManager();

  test('Product можно создать как const с необязательной категорией', () {
    const water = Product(id: 'water', name: 'Вода', priceRubles: 50);
    expect(water.category, isNull);
    expect(water.tags, isEmpty);
  });

  test('Product сравнивается по значениям и содержимому tags', () {
    final sameCoffee = Product(
      id: 'coffee',
      name: 'Кофе',
      priceRubles: 159,
      category: 'Напитки',
      tags: List.of(['hot', 'drink']),
    );
    expect(sameCoffee, coffee);
    expect(sameCoffee.hashCode, coffee.hashCode);
    expect(coffee == sameCoffee, isTrue);
    for (final different in [
      const Product(
          id: 'other',
          name: 'Кофе',
          priceRubles: 159,
          category: 'Напитки',
          tags: ['hot', 'drink']),
      const Product(
          id: 'coffee',
          name: 'Другой',
          priceRubles: 159,
          category: 'Напитки',
          tags: ['hot', 'drink']),
      const Product(
          id: 'coffee',
          name: 'Кофе',
          priceRubles: 179,
          category: 'Напитки',
          tags: ['hot', 'drink']),
      const Product(
          id: 'coffee', name: 'Кофе', priceRubles: 159, tags: ['hot', 'drink']),
      const Product(
          id: 'coffee',
          name: 'Кофе',
          priceRubles: 159,
          category: 'Напитки',
          tags: ['drink', 'hot']),
    ]) {
      expect(coffee == different, isFalse);
    }
  });

  test('Set удаляет дубликаты равных Product', () {
    final sameCoffee = Product(
      id: 'coffee',
      name: 'Кофе',
      priceRubles: 159,
      category: 'Напитки',
      tags: List.of(['hot', 'drink']),
    );
    expect({coffee, sameCoffee}.length, 1);
  });

  test('sameProductList глубоко сравнивает два списка', () {
    final first = [coffee, tea];
    final second = [
      Product(
          id: 'coffee',
          name: 'Кофе',
          priceRubles: 159,
          category: 'Напитки',
          tags: List.of(['hot', 'drink'])),
      tea,
    ];
    expect(identical(first, second), isFalse);
    expect(first == second, isFalse);
    expect(manager().sameProductList(first, second), isTrue);
    expect(manager().sameProductList(first, [tea, coffee]), isFalse);
    expect(manager().sameProductList([], []), isTrue);
    expect(manager().sameProductList(first, [coffee]), isFalse);
  });

  test('indexById строит read-only Map для поиска по id', () {
    final index = manager().indexById(const [coffee, tea]);
    expect(index['tea'], tea);
    expect(index['missing'], isNull);
    expect(index.length, 2);
    expect(manager().indexById([]), isEmpty);
    expect(() => index['water'] = coffee, throwsUnsupportedError);
  });

  test('indexById логирует и отклоняет повторяющийся id', () {
    final logs = <String>[];
    expect(
      () => manager().indexById(const [coffee, coffee], log: logs.add),
      throwsFormatException,
    );
    expect(logs.single, contains('coffee'));
  });

  test('findChangedIds возвращает Set добавленных, удалённых и изменённых id',
      () {
    const newCoffee = Product(
      id: 'coffee',
      name: 'Кофе',
      priceRubles: 179,
      category: 'Напитки',
      tags: ['hot', 'drink'],
    );
    const water = Product(id: 'water', name: 'Вода', priceRubles: 50);

    final changed = manager().findChangedIds(
      const [coffee, tea],
      const [newCoffee, water],
    );

    expect(changed, {'coffee', 'tea', 'water'});
    expect(manager().findChangedIds([], []), isEmpty);
    expect(manager().findChangedIds([coffee, tea], [tea, coffee]), isEmpty);
    expect(manager().findChangedIds([coffee], [newCoffee]), {'coffee'});
    expect(manager().findChangedIds([], [water]), {'water'});
    expect(manager().findChangedIds([tea], []), {'tea'});
    expect(() => manager().findChangedIds([coffee, coffee], []),
        throwsFormatException);
    expect(() => manager().findChangedIds([], [coffee, coffee]),
        throwsFormatException);
  });

  test('findChangedIds не меняет входы и пишет итоговый лог', () {
    final previous = <Product>[coffee, tea];
    final current = <Product>[coffee];
    final previousCopy = List<Product>.of(previous);
    final currentCopy = List<Product>.of(current);
    final logs = <String>[];

    final productManager = manager();
    productManager.findChangedIds(previous, current, log: logs.add);

    expect(productManager.sameProductList(previous, previousCopy), isTrue);
    expect(productManager.sameProductList(current, currentCopy), isTrue);
    expect(logs.last, contains('1'));
  });
}
