/// Bộ lọc theo loại giao dịch trên màn hình danh sách (section 8 của spec).
enum TransactionTypeFilter { all, income, expense }

/// Trạng thái tìm kiếm + lọc đang áp dụng cho danh sách giao dịch.
class TransactionQuery {
  const TransactionQuery({this.searchText = '', this.typeFilter = TransactionTypeFilter.all});

  final String searchText;
  final TransactionTypeFilter typeFilter;

  TransactionQuery copyWith({String? searchText, TransactionTypeFilter? typeFilter}) {
    return TransactionQuery(
      searchText: searchText ?? this.searchText,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }
}
