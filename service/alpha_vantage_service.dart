import 'dart:convert';
import 'package:http/http.dart' as http;

class AlphaVantageService {
  final String apiKey = 'B3URQTOJYT9RK868';

  Future<Map<String, dynamic>> getStockData(String symbol) async {
    final url = 'https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=$symbol&interval=1min&apikey=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stock data');
    }
  }
}
