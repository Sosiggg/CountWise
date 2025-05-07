import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class SensorService {
  static const String apiUrl = 'https://<your-backend>.onrender.com/api/events/';

  static Future<List<SensorEvent>> fetchEvents() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => SensorEvent.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load sensor data');
    }
  }
}
