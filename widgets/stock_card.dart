import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stock_application/screens/stock_details_screen.dart';
import 'package:http/http.dart' as http;

class StockCard extends StatefulWidget {
  final String stockName;
  final String stockSymbol;
  final String lightColorHex;
  final String darkColorHex;

  const StockCard({
    Key? key,
    required this.stockName,
    required this.stockSymbol,
    required this.lightColorHex,
    required this.darkColorHex,
  }) : super(key: key);

  @override
  _StockCardState createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {
  double? stockPrice;

  @override
  void initState() {
    super.initState();
    getPrice();
  }

  Future<void> getPrice() async {
    const apiKey = 'B3URQTOJYT9RK868';
    final url =
        'https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=${widget.stockSymbol}&interval=1min&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timeSeries = data['Time Series (1min)'];
        final latestTime = timeSeries.keys.first;
        final latestData = timeSeries[latestTime];
        setState(() {
          stockPrice = double.parse(latestData['1. open']);
        });
      } else {
        print('Failed to load stock price');
      }
    } catch (e) {
      print('Error fetching stock price: $e');
    }
  }

  Color _getColorFromHex(String hexColor) {
    return Color(int.parse(hexColor));
  }

  @override
  Widget build(BuildContext context) {
    final lightColor = _getColorFromHex(widget.lightColorHex);
    final darkColor = _getColorFromHex(widget.darkColorHex);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailsScreen(
              companySymbol: widget.stockSymbol,
              companyName: widget.stockName,
              stockPrice: stockPrice,
              amountSharesOwned: 0,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Card(
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
                children: [
                  Text(
                    widget.stockName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    stockPrice != null
                        ? '\$${stockPrice!.toStringAsFixed(2)}'
                        : 'Loading...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
