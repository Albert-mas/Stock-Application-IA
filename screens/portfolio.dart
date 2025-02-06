import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stock_application/providers/widget_visibility_provider.dart';
import 'package:stock_application/utils/app_colors.dart';
import 'package:stock_application/screens/home_screen.dart';
import 'package:stock_application/screens/browse_screen.dart';
import 'package:stock_application/providers/balance_provider.dart';
import 'package:stock_application/utils/font_size.dart';
import 'package:stock_application/widgets/portfolio_tile.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  int _selectedIndex = 2; // Set the initial index to Portfolio

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BrowseScreen()),
        );
        break;
      case 2:
        // Do nothing as we are already on the Portfolio screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceProvider = Provider.of<BalanceProvider>(context);
    final widgetVisibilityProvider = Provider.of<WidgetVisibilityProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Stocks",
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
               Text(
  NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2)
      .format(balanceProvider.balance),
  style: const TextStyle(
    fontSize: fontSize.title,
    fontWeight: FontWeight.bold,
  ),
),

              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: balanceProvider.transactionHistory.isEmpty // If no stocks bought, show a message
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Icon(
                              Icons.error_rounded,
                              color: AppColors.redColor,
                              size: 35,
                            ),
                          ),
                          Text(
                            'No stocks bought',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Portfolio",
                          style: TextStyle(
                            fontSize: fontSize.header,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        WidgetVisibilityProvider().isVisible
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: balanceProvider.transactionHistory.length,
                                  itemBuilder: (context, index) {
                                    final transaction = balanceProvider.transactionHistory[index];
                                    return PortfolioTile(
                                      stockName: transaction['stockName'],
                                      stockSymbol: transaction['stockSymbol'],
                                      amountSpent: transaction['pricePaid'] ?? 5,
                                      

                                      lightColorHex2: transaction['lightColor'] ?? '0xFFCCCCCC',
                                      darkColorHex2: transaction['darkColor'] ?? '0xFF888888',
                                      stockPrice: transaction['stockPrice'] ?? 1,
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}
