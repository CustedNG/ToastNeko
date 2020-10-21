import 'package:dio/dio.dart';

class Request {
  Response response;
  Dio dio = Dio();

  Future<void> go(String method, String url,
      {dynamic data, Function success}) async {
    switch(method){
      case 'get':
        response = await dio.get(url, queryParameters: data);
        break;
      case 'post':
        if(data == null)return null;
        response = await dio.post(url, data: data);
        break;
      case 'delete':
        if(data == null)return null;
        response = await dio.delete(url, data: data);
        break;
      case 'put':
        if(data == null)return null;
        response = await dio.put(url, data: data);
        break;
    }


    if(success != null)success(response.toString());

    print('${response.request.uri.toString()}\n'
        '${response.statusCode}\n'
        '${response.toString()}');
  }
}