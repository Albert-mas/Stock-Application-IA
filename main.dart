import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_application/screens/home_screen.dart';
import 'package:stock_application/providers/balance_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_application/providers/widget_visibility_provider.dart';

// Import the provider
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
        ChangeNotifierProvider(create: (_) => WidgetVisibilityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

//alpha vantage api key: B3URQTOJYT9RK868
//another key: 7EKD7QM8T8UL17D5
//HFTET2IRCH6ZQCSL

//key from marketstack
//72ada1bc79f14e8f1099b53eee587f38