import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:stock_application/screens/stock_details_screen.dart';
import 'package:stock_application/utils/app_colors.dart';
import 'package:stock_application/utils/business_data.dart';
import 'package:stock_application/utils/font_size.dart';
import 'package:stock_application/widgets/trending_stock_cards.dart';

class StockSearchBar extends StatefulWidget {
  const StockSearchBar({super.key});

  @override
  _StockSearchBarState createState() => _StockSearchBarState();
}

class _StockSearchBarState extends State<StockSearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  double stockPrice = 0; // Holds the fetched stock price

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      searchStocks(_controller.text);
    });
  }

  void searchStocks(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      searchResults = popularBusinesses.where((business) {
        final name = business['name']?.toLowerCase() ?? '';
        final symbol = business['symbol']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) || symbol.contains(query.toLowerCase());
      }).map((business) {
        return {
          'name': business['name'],
          'symbol': business['symbol'],
          'lightColor': business['lightColor'],
          'amountSharesOwned': business['amountSharesOwned'] ?? 0, // Provide default value
        };
      }).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getStockPrice(String symbol) async {
    const apiKey = 'HFTET2IRCH6ZQCSL';
    final url = 'https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=$symbol&interval=1min&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if rate limit message is present
        if (data.containsKey('Information')) {
          print(data['Information']);
          setState(() {
            stockPrice = 0.0;
          });
          return;
        }

        final timeSeries = data['Time Series (1min)'];
        final latestTime = timeSeries.keys.first;
        final latestData = timeSeries[latestTime];

        setState(() {
          stockPrice = double.parse(latestData['1. open']); // Update the stock price
        });
      } else {
        print('Failed to load stock price');
      }
    } catch (e) {
      print('Error fetching stock price: $e');
      setState(() {
        stockPrice = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search for stocks',
              fillColor: AppColors.greyColor,
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 14),
                child: Icon(Icons.search_rounded, color: Colors.black),
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 14.0),
                        child: Icon(Icons.clear_rounded, color: Colors.black),
                      ),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          searchResults = [];
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: AppColors.greyColor),
              ),
            ),
          ),
        ),
        Expanded(
          child: _controller.text.isEmpty
              ? const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.0),
                      Padding(
                        padding: EdgeInsets.only(left: 24.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right:8.0),
                                    child: Icon(
                                      Icons.trending_up_rounded,
                                      color: AppColors.greenColor,
                                      size: 30.0,
                                    ),
                                  ),
                                  Text(
                                    'Popular Stocks ',
                                    style: TextStyle(
                                      fontSize: fontSize.header,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: TrendingStockCards(),
                      ),
                    ],
                  ),
                )
              : searchResults.isEmpty
                  ? const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              Icons.error_rounded,
                              color: AppColors.redColor,
                              size: 24,
                            ),
                          ),
                          Text(
                            'No results found',
                            style: TextStyle(
                                fontSize: fontSize.large,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return GestureDetector(
                          onTap: () async {
                            await getStockPrice(result['symbol']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockDetailsScreen(
                                  companySymbol: result['symbol'],
                                  companyName: result['name'],
                                  stockPrice: stockPrice,
                                  amountSharesOwned: 0, //change this cuh
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(result['symbol']),
                            subtitle: Text(result['name']),
                            tileColor:
                                Color(int.parse(result['lightColor'] ?? '0xFFFFFFFF')),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
