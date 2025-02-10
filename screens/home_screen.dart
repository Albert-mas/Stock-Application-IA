import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stock_application/screens/portfolio.dart';
import 'package:stock_application/utils/app_colors.dart';
import 'package:stock_application/screens/browse_screen.dart';
import 'package:stock_application/providers/balance_provider.dart';
import 'package:stock_application/utils/business_data.dart';
import 'package:stock_application/utils/font_size.dart';
import 'package:stock_application/widgets/random_stock_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final Random _random = Random();
  List<Map<String, dynamic>> _stockData = [];

  @override
  void initState() {
    super.initState();
    _generateRandomStocks();
  }

  void _generateRandomStocks() {
    List<Map<String, dynamic>> shuffledBusinesses = List.from(popularBusinesses)..shuffle(_random);
    _stockData = shuffledBusinesses.take(5).toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BrowseScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PortfolioScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceProvider = Provider.of<BalanceProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Home",
                    style: TextStyle(
                      fontSize: fontSize.title,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My balance",
                        style: TextStyle(
                          fontSize: fontSize.large,
                          color: AppColors.subHeaderColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      
// Correct US representation of $ format. Including commas, symbol, and appropriate (2) decimal places when necessary.
                      Text(
                      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(balanceProvider.balance),
                      style: const TextStyle(
                        fontSize: fontSize.title,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      ],
                        ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Padding(
                        padding:  EdgeInsets.only(right:8.0),
                        child:  Icon(Icons.store_rounded, color: AppColors.black, size: 30.0),
                      ),
                      const Text(
                        "Stock Market",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize.header,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _generateRandomStocks(); // Refresh stock data
                            });
                          },
                          child: const Icon(Icons.refresh_rounded, color: AppColors.black, size: 30.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  RandomStockCards(stocks: _stockData), // Pass the stock data to the widget
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Portfolio',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.navigationBarBlueColor,
        unselectedItemColor: AppColors.greyColor,
        backgroundColor: AppColors.whiteBackground,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}
