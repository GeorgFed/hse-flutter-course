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
  const catalog = [
    Product(id: 'coffee', name: 'Кофе', priceRubles: 179, category: 'Напитки'),
    Product(id: 'tea', name: 'Чай', priceRubles: 99, category: 'Напитки'),
    Product(id: 'coffee-decaf', name: 'Кофе без кофеина', priceRubles: 249, category: 'Напитки'),
    Product(id: 'cookie', name: 'Печенье', priceRubles: 99),
    Product(id: 'water', name: 'Вода', priceRubles: 50, category: 'Напитки'),
  ];
  List<String> ids(List<Product> products) => products.map((p) => p.id).toList();

  test('searchProducts ищет подстроку имени, игнорируя регистр и края', () {
    expect(ids(manager().searchProducts(catalog, query: ' КоФе ')), ['coffee', 'coffee-decaf']);
    expect(ids(manager().searchProducts(catalog, query: 'ФЕИН')), ['coffee-decaf']);
    expect(manager().searchProducts(catalog, query: 'coffee'), isEmpty);
  });
  test('searchProducts учитывает включительную границу цены', () {
    expect(ids(manager().searchProducts(catalog, maxPriceRubles: 99)), ['water', 'cookie', 'tea']);
    expect(manager().searchProducts(catalog, maxPriceRubles: -1), isEmpty);
    const free = Product(id: 'gift', name: 'Подарок', priceRubles: 0);
    expect(ids(manager().searchProducts([free, ...catalog], maxPriceRubles: 0)), ['gift']);
  });
  test('searchProducts точно сравнивает категорию, null не ограничивает', () {
    expect(ids(manager().searchProducts(catalog, category: 'Напитки')), ['water', 'tea', 'coffee', 'coffee-decaf']);
    expect(manager().searchProducts(catalog, category: 'напитки'), isEmpty);
    expect(ids(manager().searchProducts(catalog, category: null)), ['water', 'cookie', 'tea', 'coffee', 'coffee-decaf']);
  });
  test('searchProducts объединяет все фильтры через И', () {
    expect(ids(manager().searchProducts(catalog, query: 'КоФе', maxPriceRubles: 200, category: 'Напитки')), ['coffee']);
    expect(manager().searchProducts(catalog, query: 'Печенье', maxPriceRubles: 100, category: 'Напитки'), isEmpty);
    expect(ids(manager().searchProducts(catalog, maxPriceRubles: 99, category: 'Напитки')), ['water', 'tea']);
  });
  test('searchProducts пустой запрос не ограничивает и сортирует результат', () {
    const sortedIds = ['water', 'cookie', 'tea', 'coffee', 'coffee-decaf'];
    expect(ids(manager().searchProducts(catalog)), sortedIds);
    expect(ids(manager().searchProducts(catalog, query: '   ')), sortedIds);
  });
  test('searchProducts при одинаковой цене сортирует по id, а не имени', () {
    const tied = [
      Product(id: 'b', name: 'А', priceRubles: 10),
      Product(id: 'a', name: 'Я', priceRubles: 10),
    ];
    expect(ids(manager().searchProducts(tied)), ['a', 'b']);
  });
  test('searchProducts возвращает пустой список при пустом входе или отсутствии совпадений', () {
    expect(manager().searchProducts([]), isEmpty);
    expect(manager().searchProducts(catalog, query: 'сок'), isEmpty);
    expect(manager().searchProducts(catalog, category: 'Другое'), isEmpty);
  });
  test('searchProducts не меняет вход и всегда возвращает новый список', () {
    final input = List<Product>.of(catalog);
    final before = List<Product>.of(input);
    final result = manager().searchProducts(input);
    expect(identical(result, input), isFalse);
    expect(ids(input), ids(before));
    for (var i = 0; i < input.length; i++) {
      expect(identical(input[i], before[i]), isTrue);
    }
    final alreadySorted = [catalog.last];
    expect(identical(manager().searchProducts(alreadySorted), alreadySorted), isFalse);
    final empty = <Product>[];
    expect(identical(manager().searchProducts(empty), empty), isFalse);
  });

}
