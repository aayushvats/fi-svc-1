class TransactionData {
  final DateTime date;
  final double amount;
  final String category;
  final String description;

  TransactionData({
    required this.date,
    required this.amount,
    required this.category,
    required this.description,
  });

  factory TransactionData.fromJSON(Map<String, dynamic> json) {
    return TransactionData(
      date: DateTime.parse(json['date']),
      amount: json['amount'].toDouble(),
      category: json['category'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'category': category,
      'description': description,
    };
  }
}
