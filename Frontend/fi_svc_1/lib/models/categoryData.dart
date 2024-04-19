class CategoryData {
  final String category;
  final double totalSpending;

  CategoryData({required this.category, required this.totalSpending});

  factory CategoryData.fromJSON(Map<String, dynamic> json) {
    return CategoryData(
      category: json['category'],
      totalSpending: json['totalSpending'].toDouble(),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'category': category,
      'totalSpending': totalSpending,
    };
  }
}