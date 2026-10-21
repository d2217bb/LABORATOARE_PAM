import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/review.dart';

class ReviewStorage {
  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/gemstore_reviews.json');
  }

  Future<Map<String, List<ReviewModel>>> load() async {
    final file = await _file();
    if (!await file.exists()) return {};

    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) return {};

    return {
      for (final entry in decoded.entries)
        if (entry.value is List)
          entry.key: [
            for (final item in entry.value)
              if (item is Map<String, dynamic>) ReviewModel.fromJson(item),
          ],
    };
  }

  Future<void> save(Map<String, List<ReviewModel>> reviewsByProduct) async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode({
        for (final entry in reviewsByProduct.entries)
          entry.key: entry.value.map((review) => review.toJson()).toList(),
      }),
    );
  }
}
