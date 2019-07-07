import 'dart:convert';
import 'package:dahttp/src/http_client.dart';
import 'package:dahttp/src/http_result.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

Future<void> main() async {
  final GetDogCeo getDogCeo = GetDogCeo();
  final HttpResult<DogCeo> result = await getDogCeo.call();

  // checking boolean properties
  if (result.isSuccess) {
    print('Success: ${result.data.url}');
  } else if (result.isError) {
    print('Error: ${result.response.statusCode}');
  } else if (result.hasException) {
    print('Exception: ${result.exception}');
  }

  // passing callbacks (named parameters)
  result.handle(success: (DogCeo dog, Response response) {
    print('Success: ${dog.url}');
  }, error: (Response response) {
    print('Error: ${response.statusCode}');
  }, exception: (dynamic exception) {
    print('Exception: $exception');
  });

  // passing callbacks (chained notation)
  result.onSuccess((DogCeo dog, Response response) {
    print('Success: ${dog.url}');
  }).onError((Response response) {
    print('Error: ${response.statusCode}');
  }).onException((dynamic exception) {
    print('Exception: $exception');
  });

  // passing callbacks (cascade notation)
  result
    ..onSuccess((DogCeo dog, Response response) {
      print('Success: ${dog.url}');
    })
    ..onError((Response response) {
      print('Error: ${response.statusCode}');
    })
    ..onException((dynamic exception) {
      print('Exception: $exception');
    });
}

@immutable
class GetDogCeo extends ValuedHttpClient<DogCeo> {
  Future<HttpResult<DogCeo>> call() {
    return super.get('https://dog.ceo/api/breeds/image/random');
  }

  @override
  DogCeo convert(Response response) {
    return DogCeo.fromJson(response.body);
  }
}

@immutable
class DogCeo {
  final String url;

  const DogCeo(this.url);

  static DogCeo fromJson(String json) {
    final dynamic data = jsonDecode(json);

    return DogCeo(data['message']);
  }
}
