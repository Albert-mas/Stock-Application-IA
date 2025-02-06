// balance_provider.dart
import 'package:flutter/material.dart';
import 'package:stock_application/utils/business_data.dart';

class BalanceProvider extends ChangeNotifier {
  double _balance = 25000.0;
  final List<Map<String, dynamic>> _transactionHistory = [];
  final Map<String, int> _ownedShares = {}; // Track shares owned by stock symbol

  double get balance => _balance;
  List<Map<String, dynamic>> get transactionHistory => _transactionHistory;
  Map<String, int> get ownedShares => _ownedShares;

  /// This getter returns only those transaction records for stocks that are still owned.
  List<Map<String, dynamic>> get portfolioTransactions {
    return _transactionHistory.where((transaction) {
      final String stockSymbol = transaction['stockSymbol'];
      return _ownedShares.containsKey(stockSymbol);
    }).toList();
  }

  void updateBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }

 void recordSale(String stockName, String stockSymbol, double revenue, int quantity) {
  if (_ownedShares.containsKey(stockSymbol)) {
    _ownedShares[stockSymbol] = _ownedShares[stockSymbol]! - quantity;
    if (_ownedShares[stockSymbol]! <= 0) {
      _ownedShares.remove(stockSymbol);
    }

    // Add a sale record to transaction history
   

    notifyListeners();
  }
}



  void recordPurchase(String stockName, String stockSymbol, double pricePaid, int quantity) {
    // Find the business data by stock symbol
    Map<String, dynamic>? targetBusiness = popularBusinesses.firstWhere(
      (business) => business['symbol'] == stockSymbol,
      orElse: () => {},
    );

    // Update owned shares
    if (_ownedShares.containsKey(stockSymbol)) {
      _ownedShares[stockSymbol] = _ownedShares[stockSymbol]! + quantity;
    } else {
      _ownedShares[stockSymbol] = quantity;
    }

    // Record the purchase in the transaction history
    _transactionHistory.add({
      'stockName': stockName,
      'stockSymbol': stockSymbol,
      'pricePaid': pricePaid,
      'quantity': quantity,
      'date': DateTime.now(),
      'lightColor': (targetBusiness != null && targetBusiness.isNotEmpty) ? targetBusiness['lightColor'] : Colors.grey,
      'darkColor': (targetBusiness != null && targetBusiness.isNotEmpty) ? targetBusiness['darkColor'] : Colors.black,
    });

    notifyListeners();
  }

  double calculateNetAmount(String stockSymbol) {
    double totalSpent = 0.0;
    double totalRevenue = 0.0;

    for (var transaction in _transactionHistory) {
      if (transaction['stockSymbol'] == stockSymbol) {
        if (transaction.containsKey('pricePaid')) {
          totalSpent += transaction['pricePaid'];
        }
        if (transaction.containsKey('revenue')) {
          totalRevenue += transaction['revenue'];
        }
      }
    }

    return totalSpent - totalRevenue;
  }
}
