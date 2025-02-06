import 'package:flutter/material.dart';
import 'package:stock_application/widgets/stock_card.dart';

class RandomStockCards extends StatelessWidget {
  final List<Map<String, dynamic>> stocks;

  const RandomStockCards({Key? key, required this.stocks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stocks.map((business) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: StockCard(
            key: ValueKey(business['symbol']), // Unique key for each card
            stockName: business['name'] as String,
            stockSymbol: business['symbol'] as String,
            lightColorHex: business['lightColor'] as String,
            darkColorHex: business['darkColor'] as String,
          ),
        );
      }).toList(),
    );
  }
}
