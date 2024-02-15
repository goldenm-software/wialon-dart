import 'package:test/test.dart';
import 'package:wialon/wialon.dart';

void main() async {
  // Example token from https://sdk.wialon.com/playground/demo/get_units
  String token = "5dce19710a5e26ab8b7b8986cb3c49e58C291791B7F0A7AEB8AFBFCEED7DC03BC48FF5F8";
  String username = const String.fromEnvironment("WIALON_USERNAME");
  String password = const String.fromEnvironment("WIALON_PASSWORD");

  test("oauthLogin", () async {
    WialonSdk sdk = WialonSdk();
    expect(sdk.sessionId, isNull);

    String? result = await sdk.oauthLogin(username: username, password: password);
    expect(result, isNotNull);
  });

  test("tokenLogin", () async {
    WialonSdk sdk = WialonSdk();
    expect(sdk.sessionId, isNull);

    Map<String, dynamic> result = await sdk.tokenLogin(token: token);
    await sdk.logout();
    expect(result['eid'], isNotNull);
  });

  test("getUnits", () async {
    WialonSdk sdk = WialonSdk();
    expect(sdk.sessionId, isNull);

    await sdk.tokenLogin(token: token);
    Map<String, dynamic> result = await sdk.call(
      method: 'core/search_items',
      parameters: {
        'spec': {
          'itemsType': 'avl_unit',
          'propName': 'sys_name',
          'propValueMask': '*',
          'sortType': 'sys_name',
          'or_logic': true,
        },
        'force': 1,
        'flags': 1,
        'from': 0,
        'to': 0
      },
    );
    await sdk.logout();
    expect(result['totalItemsCount'], result['items'].length);
  });

  test("reverseGeocoding", () async {
    WialonSdk sdk = WialonSdk();
    expect(sdk.sessionId, isNull);

    await sdk.tokenLogin(token: token);
    String result = await sdk.reverseGeocoding(latitude: 9.0817275, longitude: -79.5932219);
    await sdk.logout();
    expect(result, isNotEmpty);
  });
}
