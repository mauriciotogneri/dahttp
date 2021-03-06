import 'dart:convert';
import 'package:dahttp/src/http_logger.dart';
import 'package:dahttp/src/http_result.dart';
import 'package:http/http.dart';

abstract class ValuedHttpClient<T> {
  final HttpLogger logger;

  ValuedHttpClient({this.logger = const EmptyHttpLogger()});

  T convert(Response response);

  T alter(T input) => input;

  Future<HttpResult<T>> head(
    String url, {
    String? host,
    Map<String, Object>? path,
    Map<String, Object>? query,
    Map<String, String>? headers,
  }) async {
    final _CustomClient client = _client();

    return _process(
      client,
      client.head(
        Uri.parse(_route(url, host, path, query)),
        headers: headers,
      ),
    );
  }

  Future<HttpResult<T>> get(
    String url, {
    String? host,
    Map<String, Object>? path,
    Map<String, Object>? query,
    Map<String, String>? headers,
  }) async {
    final _CustomClient client = _client();

    return _process(
      client,
      client.get(
        Uri.parse(_route(url, host, path, query)),
        headers: headers,
      ),
    );
  }

  Future<HttpResult<T>> post(
    String url, {
    String? host,
    Map<String, Object>? path,
    Map<String, Object>? query,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
  }) async {
    final _CustomClient client = _client();

    return _process(
      client,
      client.post(
        Uri.parse(_route(url, host, path, query)),
        headers: headers,
        body: body,
        encoding: encoding,
      ),
    );
  }

  Future<HttpResult<T>> put(
    String url, {
    String? host,
    Map<String, Object>? path,
    Map<String, Object>? query,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
  }) async {
    final _CustomClient client = _client();

    return _process(
      client,
      client.put(
        Uri.parse(_route(url, host, path, query)),
        headers: headers,
        body: body,
        encoding: encoding,
      ),
    );
  }

  Future<HttpResult<T>> patch(
    String url, {
    String? host,
    Map<String, Object>? path,
    Map<String, Object>? query,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
  }) async {
    final _CustomClient client = _client();

    return _process(
      client,
      client.patch(
        Uri.parse(_route(url, host, path, query)),
        headers: headers,
        body: body,
        encoding: encoding,
      ),
    );
  }

  Future<HttpResult<T>> delete(
    String url, {
    String? host,
    Map<String, Object>? path,
    Map<String, Object>? query,
    Map<String, String>? headers,
  }) async {
    final _CustomClient client = _client();

    return _process(
      client,
      client.delete(
        Uri.parse(_route(url, host, path, query)),
        headers: headers,
      ),
    );
  }

  Future<HttpResult<T>> _process(
    _CustomClient client,
    Future<Response> futureResponse,
  ) async {
    try {
      final Response response = await futureResponse;
      logger.response(response);

      return HttpResult<T>.result(response, _data(response));
    } catch (e) {
      logger.exception(e);
      return HttpResult<T>.exception(e);
    } finally {
      client.close();
    }
  }

  _CustomClient _client() => _CustomClient(logger);

  String _route(
    String baseUrl,
    String? host,
    Map<String, Object>? path,
    Map<String, Object>? query,
  ) {
    final String url = _url(baseUrl, host, path);
    final String parameters = _queryParameters(query);

    return '$url$parameters';
  }

  String _url(
    String url,
    String? host,
    Map<String, Object>? path,
  ) {
    String result = (host != null) ? '$host$url' : url;

    if (path != null) {
      for (final String key in path.keys) {
        result = result.replaceFirst(key, path[key] as String);
      }
    }

    return result;
  }

  String _queryParameters(Map<String, Object>? query) {
    String result = '';

    if (query != null) {
      for (final String key in query.keys) {
        if (result.isEmpty) {
          result += '?';
        } else {
          result += '&';
        }

        result += '$key=${query[key]}';
      }
    }

    return result;
  }

  T? _data(Response response) {
    return ((response.statusCode >= 200) && (response.statusCode <= 299))
        ? alter(_convert(response))
        : null;
  }

  T _convert(Response response) {
    try {
      return convert(response);
    } catch (e) {
      throw FormatException(
          'Errror converting response to $T. Content:\n${response.body}', e);
    }
  }
}

class EmptyHttpClient extends ValuedHttpClient<void> {
  EmptyHttpClient({HttpLogger logger = const EmptyHttpLogger()})
      : super(logger: logger);

  @override
  void convert(Response response) {}
}

class _CustomClient extends BaseClient {
  final Client _client = Client();
  final HttpLogger _logger;

  _CustomClient(this._logger);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    _logger.request(request as Request);

    return _client.send(request);
  }

  @override
  void close() => _client.close();
}
