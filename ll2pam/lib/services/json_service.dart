import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/home_data.dart';

class JsonService {
  Future<HomePageData> loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/gemstore_data.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return HomePageData.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load JSON data: ${e.toString()}');
    }
  }
}
