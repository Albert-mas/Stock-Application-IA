import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_application/providers/balance_provider.dart';
import 'package:stock_application/providers/widget_visibility_provider.dart';
import 'package:stock_application/screens/portfolio.dart';
import 'package:stock_application/utils/app_colors.dart';
import 'package:intl/intl.dart';

class BuySellShares extends StatefulWidget {
  final double? stockPrice;
  final String stockSymbol;
  final String stockName;
  final int amountSharesOwned;

  const BuySellShares({
    super.key,
    required this.stockPrice,
    required this.stockSymbol,
    required this.stockName,
    required this.amountSharesOwned,
  });

  @override
  State<BuySellShares> createState() => _BuySellSharesState();
}

class _BuySellSharesState extends State<BuySellShares> {
  bool isBuySelected = true;
  double _totalCost = 0.0;
  double _totalRevenue = 0.0;
  final TextEditingController _sharesController = TextEditingController();
  late int ownedShares;

  @override
  void initState() {
    super.initState();
    _sharesController.addListener(_updateTotal);
    ownedShares = widget.amountSharesOwned;
  }

  @override
  void dispose() {
    _sharesController.dispose();
    super.dispose();
  }

  double get stockPrice => widget.stockPrice ?? 5.0;

  void _updateTotal() {
    final int? shares = int.tryParse(_sharesController.text);
    setState(() {
      if (shares != null) {
        if (isBuySelected) {
          _totalCost = shares * stockPrice;
          _totalRevenue = 0.0;
        } else {
          _totalRevenue = shares * stockPrice;
          _totalCost = 0.0;
        }
      } else {
        _totalCost = 0.0;
        _totalRevenue = 0.0;
      }
    });
  }

  void _processTransaction() {
    final int? shares = int.tryParse(_sharesController.text);

    if (shares == null || shares <= 0) {
      ElegantNotification.error(
        title: const Text("Invalid Input"),
        description: const Text("Please enter a positive integer for shares."),
      ).show(context);
      return;
    }

    final provider = Provider.of<BalanceProvider>(context, listen: false);

    if (isBuySelected) {
      if (_totalCost > provider.balance) {
        ElegantNotification.error(
          title: const Text("Insufficient Balance"),
          description: const Text("You don't have enough balance to buy."),
        ).show(context);
        return;
      }

      provider.updateBalance(provider.balance - _totalCost);

      provider.recordPurchase(
        widget.stockName,
        widget.stockSymbol,
        _totalCost,
        shares,
        
      );

      setState(() {
        ownedShares += shares;
      });
    } else {
      if (shares > ownedShares) {
        ElegantNotification.error(
          title: const Text("Insufficient Shares"),
          description: const Text("You don't own enough shares to sell."),
        ).show(context);
        return;
      }

      provider.updateBalance(provider.balance + _totalRevenue);

      provider.recordSale(
        widget.stockName,
        widget.stockSymbol,
        _totalRevenue,
        shares,
      );

      setState(() {
        ownedShares -= shares;
      });

      // If all shares have been sold, remove the portfolio widget.
      if (ownedShares == 0) {
        context.read<WidgetVisibilityProvider>().removeWidget();
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PortfolioScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buy/Sell toggle buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isBuySelected = true;
                    });
                    _updateTotal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBuySelected
                        ? AppColors.greenColor
                        : AppColors.greyColor,
                  ),
                  child: const Text(
                    'Buy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(width: 16),
                if (ownedShares > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isBuySelected = false;
                      });
                      _updateTotal();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBuySelected
                          ? AppColors.greyColor
                          : AppColors.redColor,
                    ),
                    child: const Text(
                      'Sell',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isBuySelected && ownedShares > 0)
              Text(
                'You currently own $ownedShares shares of this stock.',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 24),
            // Shares input
            Row(
              children: [
                Expanded(
                  child: Text(
                    isBuySelected
                        ? 'Amount of shares to buy:'
                        : 'Amount of shares to sell:',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _sharesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Total cost or revenue
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Text(
                    isBuySelected ? 'Total cost:' : 'Total revenue:',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
  isBuySelected
      ? NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2)
          .format(_totalCost)
      : NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2)
          .format(_totalRevenue),
  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // New balance display
            Row(
              children: [
                const Text(
                  'New balance:',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Consumer<BalanceProvider>(
                  builder: (context, provider, _) => Text(
  isBuySelected
      ? NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2)
          .format(provider.balance - _totalCost)
      : NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2)
          .format(provider.balance + _totalRevenue),
  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
),

                ),
              ],
            ),
            const SizedBox(height: 32),
            // Confirm button
            Center(
              child: ElevatedButton.icon(
                onPressed: _processTransaction,
                icon: const Icon(
                  Icons.check_circle_outline_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38ba7c),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
