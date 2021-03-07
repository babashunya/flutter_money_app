class Money {
  static const tblMoney = 'moneys';
  static const colId = 'id';
  static const colCategoryId = 'categoryId';
  static const colAmount = 'amount';
  static const colDescription = 'description';
  static const colDate = 'date';
  static const colCreatedAt = 'craetedAt';
  static const colUpdatedAt = 'updatedAt';
  static const Map<int, String> category = {
    1: 'Eat in',
    2: 'Eat out',
    3: 'Groceries',
    4: 'House',
    5: 'Clothes',
    6: 'Entertainment',
    7: 'Health',
    8: 'Beauty',
    9: 'Saving',
    10: 'Fee'
  };

  Money({
    this.id,
    this.categoryId,
    this.amount,
    this.description,
    this.date,
    this.updatedAt,
    this.createdAt,
  });

  int id;
  int categoryId;
  int amount;
  String description;
  DateTime date;
  DateTime updatedAt;
  DateTime createdAt;

  Money.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    categoryId = map[colCategoryId];
    amount = map[colAmount];
    description = map[colDescription];
    // NOTE: DateTime型は文字列で保存されているため、DateTime型に変換し直す
    date = DateTime.parse(map[colDate]).toLocal();
    createdAt = DateTime.parse(map[colCreatedAt]).toLocal();
    updatedAt = DateTime.parse(map[colUpdatedAt]).toLocal();
  }

  Map<String, dynamic> toMap({method: ''}) {
    // NOTE: sqliteではDate型は直接保存できないため、文字列形式で保存する
    var map = <String, dynamic>{
      colCategoryId: categoryId,
      colAmount: amount,
      colDate: date.toUtc().toIso8601String(),
      colCreatedAt: 'insert' == 'insert'
          ? DateTime.now().toUtc().toIso8601String()
          : createdAt.toUtc().toIso8601String(),
      // TODO: こっちの形に変更する
      // colCreatedAt: () {
      //   DateTime d = 'insert' == 'insert' ? DateTime.now() : createdAt;
      //   return d.toUtc().toIso8601String();
      // },
      colUpdatedAt: DateTime.now().toUtc().toIso8601String(),
    };
    if (id != null) map[colId] = id;
    if (description != null) map[colDescription] = description;
    return map;
  }
}
