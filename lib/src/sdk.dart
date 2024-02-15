part of wialon;

/// Wialon SDK for dart
/// Documentation available at https://sdk.wialon.com/wiki/en/sidebar/remoteapi/apiref/apiref
class WialonSdk {
  /// Enables the logging of the library
  final bool debug;

  /// Is an existing session id, use it to reuse the session
  String? sessionId;

  /// Is the hostname (And port if apply) of the Wialon server, by default it is 'https://hst-api.wialon.com'
  /// But you can change it to your server, or if you use Wialon Local, replace the host to your
  /// server
  final String host;

  /// Constructor
  WialonSdk({
    this.debug = false,
    this.sessionId,
    this.host = 'https://hst-api.wialon.com',
  });

  int? _userId;

  String get baseUrl => '$host/wialon/ajax.html?';

  /// Login into Wialon using username and password through OAuth, this method will return an Access Token
  Future<String?> oauthLogin({
    required String username,
    required String password,
    String host = "https://hosting.wialon.com",
  }) async {
    Map<String, String> headers = {
      'origin': host,
    };
    String urlToGetSign = "$host/login.html?"
        "client_id=Layrz External Accounts"
        "&access_type=-1"
        "&activation_time=0"
        "&duration=0"
        "&flags=0x1";

    Uri uri = Uri.parse(urlToGetSign);
    http.Response signGetter = await http.get(uri, headers: headers);
    Document page = parser.parse(signGetter.body);
    List<Element> elements = page.getElementsByTagName("input");

    String? sign;
    for (Element element in elements) {
      if (element.attributes["name"] == "sign") {
        sign = element.attributes["value"];
        break;
      }
    }

    if (sign == null) {
      throw SdkException(message: "Sign not found");
    }

    print(sign);

    Map<String, String> request = {
      'response_type': 'token',
      'wialon_sdk_url': 'https://hst-api.wialon.com',
      'client_id': username,
      'access_type': '-1',
      'activation_time': '0',
      'duration': '0',
      'flags': '7',
      'login': username,
      'passw': password,
      'sign': sign,
      'redirect_uri': '$host/post_token.html',
    };

    uri = Uri.parse("https://hosting.wialon.com/oauth.html");
    http.Client client = http.Client();
    http.StreamedResponse redirectGetter = await client.send(http.Request("POST", uri)
      ..bodyFields = request
      ..headers.addAll(headers));
    String? redirect = redirectGetter.headers['location'];

    if (redirect == null) {
      throw SdkException(message: "Redirect url not found");
    }

    uri = Uri.parse(redirect);
    http.StreamedResponse authGetter = await client.send(
      http.Request("GET", uri)
        ..headers.addAll(headers)
        ..followRedirects = false,
    );
    String? responseUrl = authGetter.headers['location'];
    if (responseUrl == null) {
      throw SdkException(message: "Response url not found");
    }

    responseUrl = responseUrl.split("?").last;
    Map<String, dynamic> responseMap = Uri.splitQueryString(responseUrl);
    String? token = responseMap['access_token'];
    return token;
  }

  /// Login into Wialon with the Access Token
  Future<Map<String, dynamic>> tokenLogin({required String token}) async {
    dynamic result = await call(
      method: 'token/login',
      parameters: {'token': token},
    );

    _userId = result['user']['id'];
    sessionId = result['eid'];

    return result;
  }

  /// Logout of Wialon
  Future<void> logout() async {
    await call(
      method: 'core/logout',
      parameters: {'action': 'logout'},
    );

    _userId = null;
    sessionId = null;
  }

  /// Rever geocoding, returns name of the location that corresponds to the latitude and longitude given
  Future<String> reverseGeocoding({
    /// [latitude] is the latitude of the location, in decimal degrees
    required double latitude,

    /// [longitude] is the longitude of the location, in decimal degrees
    required double longitude,

    /// [flags] is the flags of the request, by default it is 1255211008
    /// For more information about the flags, refer to https://sdk.wialon.com/wiki/en/sidebar/remoteapi/apiref/requests/address
    int flags = 1255211008,
  }) async {
    final Map<String, double> coordinates = {'lon': longitude, 'lat': latitude};

    Uri parsedHost = Uri.parse(host);

    Uri url = Uri.parse(
      "https://geocode-maps.wialon.com/${parsedHost.host}/gis_geocode?"
      "coords=[${jsonEncode(coordinates)}]"
      "&flags=$flags"
      "&uid=$_userId",
    );

    try {
      final response = await http.post(url);
      final result = jsonDecode(response.body);

      if (result is Map) {
        throw WialonError(code: result['error']);
      }
      if (result.isEmpty) {
        return 'N/A';
      }
      return result.first;
    } catch (e) {
      throw SdkException(message: "Internal error: $e");
    }
  }

  /// Make a call to the Wialon API
  Future<Map<String, dynamic>> call({
    /// [method] is the svc method declarated in the Wialon SDK documentation
    required String method,

    /// [parameters] is the parameters of the method, should be a Map or a List
    /// Refer to the documentation of the desired method to know the parameters
    required dynamic parameters,
  }) async {
    dynamic arguments = {};

    if (parameters is List) {
      arguments = [...parameters];
    } else {
      arguments.addAll(parameters);
    }

    Map<String, dynamic> payload = {
      'svc': method,
      'params': jsonEncode(arguments),
      'sid': sessionId ?? "",
    };

    if (debug) {
      log('Method Call: ${payload["svc"]}');
      log('Pararams: ${payload["params"]}');
      log('SessionId: ${payload["sid"]}');
    }

    try {
      http.Response response = await http.post(
        Uri.parse(baseUrl),
        body: payload,
      );
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      throw SdkException(message: "Internal error: $e");
    }
  }

  /// debug printer
  void log(dynamic content) {
    print("[${DateTime.now()}]: $content");
  }
}
