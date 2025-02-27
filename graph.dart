import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:stock_application/utils/font_size.dart';

class StockGraph extends StatefulWidget {
  final String companyName;
  final String companySymbol;

  const StockGraph({
    Key? key,
    required this.companyName,
    required this.companySymbol,
  }) : super(key: key);

  @override
  _StockGraphState createState() => _StockGraphState();
}

class _StockGraphState extends State<StockGraph> {
  List<FlSpot> _dataPoints = [];
  List<String> _dates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStockData();
  }

  Future<void> _fetchStockData() async {
    const apiKey = 'YOUR_API_KEY_HERE'; // Replace with your API key
    final url =
        'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=${widget.companySymbol}&apikey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timeSeries = data['Time Series (Daily)'];

        if (timeSeries == null) {
          throw Exception('Invalid API response. Check your API key or symbol.');
        }

        // Convert map entries to a list and sort them by date in ascending order
        // so the oldest date is at index 0, newest at the end.
        List<MapEntry<String, dynamic>> sortedEntries = timeSeries.entries.toList()
..sort((MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) => a.key.compareTo(b.key));

        const int daysToShow = 30;

        // Get the last N entries from the sorted list in ascending order.
        int startIndex = max(0, sortedEntries.length - daysToShow);
        List<MapEntry<String, dynamic>> lastNEntries =
            sortedEntries.sublist(startIndex, sortedEntries.length);

        List<FlSpot> spots = [];
        List<String> dates = [];

        // Build the data points: oldest to newest
        for (int i = 0; i < lastNEntries.length; i++) {
          final date = lastNEntries[i].key; 
          final closePrice = double.parse(lastNEntries[i].value['4. close']);
          spots.add(FlSpot(i.toDouble(), closePrice));
          dates.add(date);
        }

        setState(() {
          _dataPoints = spots;
          _dates = dates;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }


  /// Formats date.
  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    final day = parsedDate.day;
    final month = DateFormat('MMM').format(parsedDate); 
    final suffix = _getDaySuffix(day);
    return '$day$suffix $month';
  }

  /// Determines the correct suffix for day numbers
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Calculate a “nice” y-axis range with evenly spaced ticks.
  Map<String, double> _calculateNiceYRange() {
    // Get the raw min and max from the data points.
    double rawMin = _dataPoints.isEmpty
        ? 0
        : _dataPoints.map((e) => e.y).reduce(min);
    double rawMax = _dataPoints.isEmpty
        ? 0
        : _dataPoints.map((e) => e.y).reduce(max);
    double rawRange = rawMax - rawMin;

    // If the data range is zero, create a default range.
    if (rawRange == 0) {
      rawRange = rawMax == 0 ? 1 : rawMax.abs();
      rawMin -= rawRange / 2;
      rawMax += rawRange / 2;
    }

    // Choose the number of intervals (e.g., 5 intervals => 6 ticks)
    const int intervals = 5;
    double rawInterval = rawRange / intervals;

    // “Nice” the rawInterval to one of 1, 2, 5, or 10 times a power of 10.
    double magnitude = pow(10, (log(rawInterval) / ln10).floor()).toDouble();
    double residual = rawInterval / magnitude;
    double niceInterval;
    if (residual < 1.5) {
      niceInterval = 1 * magnitude;
    } else if (residual < 3) {
      niceInterval = 2 * magnitude;
    } else if (residual < 7) {
      niceInterval = 5 * magnitude;
    } else {
      niceInterval = 10 * magnitude;
    }

    // Expand the raw min and max to multiples of niceInterval.
    double niceMin = (rawMin / niceInterval).floor() * niceInterval;
    double niceMax = (rawMax / niceInterval).ceil() * niceInterval;

    return {
      'min': niceMin,
      'max': niceMax,
      'interval': niceInterval,
    };
  }

  @override
  Widget build(BuildContext context) {
    // If data is loaded and valid, compute the nice Y-axis range.
    final Map<String, double> yRange = (!_isLoading && _errorMessage == null)
        ? _calculateNiceYRange()
        : {'min': 0, 'max': 1, 'interval': 1};

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Stock Price History for ${widget.companyName} for ${_dataPoints.length} days',
            style: const TextStyle(
              fontSize: fontSize.medium,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_errorMessage != null)
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
            )
          else
            SizedBox(
              height: 300,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: yRange['interval']!,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        // If we're only showing 7 data points, an interval of 1 is fine
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _dates.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _formatDate(_dates[index]),
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.black12, width: 1),
                      bottom: BorderSide(color: Colors.black12, width: 1),
                      right: BorderSide(color: Colors.transparent, width: 0),
                      top: BorderSide(color: Colors.transparent, width: 0),
                    ),
                  ),
                  minX: 0,
                  maxX: _dataPoints.isEmpty
                      ? 0
                      : _dataPoints.length.toDouble() - 1,
                  minY: yRange['min']!,
                  maxY: yRange['max']!,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _dataPoints,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
