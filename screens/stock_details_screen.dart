import 'package:flutter/material.dart';
import 'package:stock_application/screens/home_screen.dart';
import 'package:stock_application/utils/app_colors.dart';
import 'package:stock_application/utils/font_size.dart';
import 'package:stock_application/widgets/buy_sell_shares.dart';

class StockDetailsScreen extends StatefulWidget {
  final String companySymbol;
  final String companyName;
  final double? stockPrice;
  final int amountSharesOwned;

  const StockDetailsScreen({
    Key? key,
    required this.companySymbol,
    required this.companyName,
    required this.stockPrice,
    required this.amountSharesOwned,
  }) : super(key: key);

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.all(24.0),
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          constraints: const BoxConstraints(
            minWidth: 70,
            minHeight: 70,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns content to the left
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0,
                  top: 24.0), // Reduced left padding for closer alignment
              child: Text(
                '${widget.companyName}  (${widget.companySymbol})', // Add company name here that was shown in the stock card

                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: fontSize.title,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 10.0),
              child: Text(
                'Current market price: \$${widget.stockPrice?.toStringAsFixed(2) ?? 1}', //if null then returns 5
                style: const TextStyle(
                  color: AppColors.greyColor,
                  fontSize: fontSize.large,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                  left: 24.0,
                  top: 30.0), // Align graph label to the same left padding
              child: Row(
                children: [
                  Icon(
                    Icons.insert_chart_outlined_rounded,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  SizedBox(
                      width:
                          8), // Add a bit of spacing between the icon and text
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                    ),
                    
                    child: Text(
                      'Graph: past 30 days',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: fontSize.header,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            //StockGraph(
//symbol: widget.companySymbol, name: widget.companyName,
          //  ),
            const SizedBox(height: 30),
            BuySellShares(
              stockPrice: widget.stockPrice ?? 1,
              stockName: widget.companyName,
              stockSymbol: widget.companySymbol,
              amountSharesOwned: widget.amountSharesOwned,
            ), 
          ],
        ),
      ),
    );
  }
}
