import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stock_application/screens/stock_details_screen.dart';
import 'package:stock_application/providers/balance_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stock_application/utils/app_colors.dart';

class PortfolioTile extends StatefulWidget {
  final String stockName;
  final String stockSymbol;
  final double? amountSpent; // Total amount spent (not per share)
  final String lightColorHex2;
  final String darkColorHex2;
  final double? stockPrice; // Current stock price

  const PortfolioTile({
    super.key,
    required this.stockName,
    required this.stockSymbol,
    required this.amountSpent,
    required this.lightColorHex2,
    required this.darkColorHex2,
    this.stockPrice,
  });

  @override
  State<PortfolioTile> createState() => _PortfolioTileState();
}

class _PortfolioTileState extends State<PortfolioTile> {
  double currentPrice = 0.0;

  @override
  void initState() {
    super.initState();
    currentPrice = widget.stockPrice ?? 5.0;
    getPrice();
  }

  Future<void> getPrice() async {
    const apiKey = 'HFTET2IRCH6ZQCSL';
    final url =
        'https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=${widget.stockSymbol}&interval=1min&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timeSeries = data['Time Series (1min)'] as Map?;
        if (timeSeries != null && timeSeries.isNotEmpty) {
          final latestTime = timeSeries.keys.first;
          final latestData = timeSeries[latestTime];
          setState(() {
            currentPrice = double.tryParse(latestData['1. open']) ??
                widget.stockPrice ??
                5.0; // Default fallback price
          });
        }
      } else {
        print('Failed to load stock price: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stock price: $e');
      setState(() {
        currentPrice = widget.stockPrice ?? 5.0;
      });
    }
  }

  Color _hexToColor(String hexColor) {
    try {
      return Color(int.parse(hexColor));
    } catch (e) {
      print('Invalid color format for $hexColor: $e');
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color lightColor = _hexToColor(widget.lightColorHex2);
    Color darkColor = _hexToColor(widget.darkColorHex2);

    final balanceProvider = Provider.of<BalanceProvider>(context);
    final updatedQuantity = balanceProvider.ownedShares[widget.stockSymbol] ?? 0;

    if (updatedQuantity > 0) {
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return StockDetailsScreen(
              companySymbol: widget.stockSymbol,
              companyName: widget.stockName,
              stockPrice: currentPrice > 0 ? currentPrice : 5.0,
              amountSharesOwned: updatedQuantity,
            );
          }));
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [lightColor, darkColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.stockName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.stockSymbol,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                updatedQuantity.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Display current total value of the shares:
                              Text(
  NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2)
      .format(updatedQuantity * currentPrice),
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
