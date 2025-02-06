import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_application/providers/balance_provider.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionHistory =
        context.watch<BalanceProvider>().transactionHistory;

    return Column(
      children: [
        SizedBox(
          height: 24.0,
          child: ListView.builder(
            itemCount: transactionHistory.length,
            itemBuilder: (context, index) {
              final transaction = transactionHistory[index];
              final isBuy = transaction['isBuy'];
              final color = isBuy ? Colors.green : Colors.red;
              final sign = isBuy ? '+' : '-';
              return ListTile(
                leading: Text(
                  '€ ${transaction['amount'].toStringAsFixed(2)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                title: Text(
                  '${isBuy ? 'Buy' : 'Sell'} "${transaction['stockSymbol']}" Stock',
                  style: TextStyle(color: color),
                ),
                subtitle: Text(
                  'Shares: ${transaction['shares']}',
                  style: const TextStyle(color: Colors.black54),
                ),
                trailing: Text(
                  '${transaction['date'].day} ${transaction['date'].month} ${transaction['date'].year}',
                  style: const TextStyle(color: Colors.black54),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
