import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stock_application/utils/trending_business_data.dart';
import 'package:stock_application/widgets/stock_card.dart';

class TrendingStockCards extends StatefulWidget {
  const TrendingStockCards({super.key});

  @override
  _TrendingStockCardsState createState() => _TrendingStockCardsState();
}

class _TrendingStockCardsState extends State<TrendingStockCards> {
  final Random _random = Random();
  List<Map<String, dynamic>> randomTrendingBusinesses = [];

  @override
  void initState() {
    super.initState();
    randomTrendingBusinesses = getRandomTrendingBusinesses();
  }

  List<Map<String, dynamic>> getRandomTrendingBusinesses() {
    List<Map<String, dynamic>> shuffledBusinesses = List.from(trendingBusinesses)
      ..shuffle(_random);
    return shuffledBusinesses.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: randomTrendingBusinesses.map((business) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: StockCard(
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