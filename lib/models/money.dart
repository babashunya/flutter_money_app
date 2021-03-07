class Money {
  static const tblMoney = 'moneys';
  static const colId = 'id';
  static const colCategoryId = 'categoryId';
  static const colAmount = 'amount';
  static const colDescription = 'description';
  static const Map<int, String> category = {
    1: 'Eat in',
    2: 'Eat out',
  };

  Money({
    this.id,
    this.categoryId,
    this.amount,
    this.description,
    // this.updatedAt,
    // this.createdAt,
  });

  int id;
  int categoryId;
  int amount;
  String description;

  Money.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    categoryId = map[colCategoryId];
    amount = map[colAmount];
    description = map[colDescription];
  }

  // DateTime updatedAt;
  // DateTime createdAt;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colCategoryId: categoryId, colAmount: amount};
    if (id != null) map[colId] = id;
    if (description != null) map[colDescription] = description;
    return map;
  }
}
