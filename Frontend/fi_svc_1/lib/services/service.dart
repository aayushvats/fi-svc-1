import 'package:dio/dio.dart';
import '../models/categoryData.dart';

final dio = Dio();
final String baseUrl = '192.168.1.11';

Future<Response<dynamic>?> pushTransactionData(Map<String, dynamic> jsonString) async {
  try {
    dio.options.connectTimeout = Duration(seconds: 5);
    dio.options.receiveTimeout = Duration(seconds: 5);
    var response = await dio.post(
      'http://${baseUrl}:8080/transactions',
      data: jsonString,
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );
    print('Transaction data pushed successfully');
    return response;
  } catch (e) {
    print('Failed to push transaction data. Error: $e');
    return null;
  }
}

Future<List<CategoryData>?> fetchCategoryData() async {
  try {
    dio.options.connectTimeout = Duration(seconds: 5);
    dio.options.receiveTimeout = Duration(seconds: 5);
    var response = await dio.get('http://${baseUrl}:8080/spending');

    print(response);

    List<CategoryData> categoryDataList = [];
    for (var jsonItem in response.data) {
      CategoryData categoryData = CategoryData.fromJSON(jsonItem);
      categoryDataList.add(categoryData);
    }

    print("wgujhurwvb ${categoryDataList.length}");

    return categoryDataList;
  } catch (e) {
    print('Failed to fetch category data. Error: $e');
    return null;
  }
}