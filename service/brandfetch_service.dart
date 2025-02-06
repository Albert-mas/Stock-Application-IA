import 'dart:convert';
import 'package:http/http.dart' as http;

class BrandfetchService {
  static Future<String?> fetchLogoUrl(String companyName) async {
    final url = 'https://api.brandfetch.io/v2/logo/$companyName';

    try {
      final response = await http.get(Uri.parse(url), headers: {
  'Authorization': 'Bearer YTimSAG05EtAqxmJSvTBJNmtkZheE6CMTqGSjkqpPkSE=',
});


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Brandfetch response: ${json.encode(data)}'); // Print entire response to check structure
        
        // Check if logoUrl exists at the path
        if (data is Map && data.containsKey('logo') && data['logo'] is String) {
          return data['logo']; // Adjust this based on actual JSON structure from Brandfetch
        } else {
          print('Logo URL not found in response structure');
          return null;
        }
      } else {
        print('Failed to load logo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching logo: $e');
      return null;
    }
  }
}
