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
    final second = [coffee, tea];
    expect(identical(first, second), isFalse);
    expect(first == second, isFalse);
    expect(manager().sameProductList(first, second), isTrue);
    expect(manager().sameProductList(first, [tea, coffee]), isFalse);
  });

  test('indexById строит read-only Map для поиска по id', () {
    final index = manager().indexById(const [coffee, tea]);
    expect(index['tea'], tea);
    expect(index['missing'], isNull);
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
