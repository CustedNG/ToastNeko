import 'package:dio/dio.dart';

class Request {
  Response response;
  Dio dio = Dio();

  Future<void> go(String method, String url,
      {dynamic data, Function success, Function failed}) async {
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

    if(response.statusCode == 200){
      if(success != null)success(response.toString());
    }else{
      if(failed != null)failed(response.statusCode);
    }
    print('${response.request.uri.toString()}\n'
        '${response.statusCode}\n'
        '${response.toString()}');
  }
}