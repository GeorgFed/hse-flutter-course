import 'package:dart_catalog_sync_task/main.dart';
import 'package:test/test.dart';

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

void main() {
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
