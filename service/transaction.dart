class Transaction {
  final String stockSymbol;
  final String stockName;
  final double amount;
  final String type; // "buy" or "sell"
  final DateTime date;
  final double? changePercent; // Optional: for displaying percent change on sell

  Transaction({
    required this.stockSymbol,
    required this.stockName,
    required this.amount,
    required this.type,
    required this.date,
    this.changePercent,
  });
}
