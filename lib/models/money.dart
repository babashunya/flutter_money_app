class Money {
  static const tblMoney = 'moneys';
  static const colId = 'id';
  static const colCategoryId = 'categoryId';
  static const colAmount = 'amount';

  Money({
    this.id,
    this.categoryId,
    this.amount,
    // this.updatedAt,
    // this.createdAt,
  });

  int id;
  int categoryId;
  int amount;

  Money.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    categoryId = map[colCategoryId];
    amount = map[colAmount];
  }

  // DateTime updatedAt;
  // DateTime createdAt;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colCategoryId: categoryId, colAmount: amount};
    if (id != null) map[colId] = id;
    return map;
  }
}
