import 'package:wialon/wialon.dart';

void main(List<String> arguments) async {
  // Example token from https://sdk.wialon.com/playground/demo/get_units
  String token = "5dce19710a5e26ab8b7b8986cb3c49e58C291791B7F0A7AEB8AFBFCEED7DC03BC48FF5F8";
  await oauthLogin("wialon_user", "wialon_password");
  await tokenLogin(token);
  await getUnits(token);
  await reverseGeocoding(token);
}

Future<void> oauthLogin(String username, String password) async {
  WialonSdk sdk = WialonSdk();
  String? accessToken = await sdk.oauthLogin(username: username, password: password);
  print(accessToken);

  /// !Important note:
  /// - We don't recommend use this method more than one time in your project, because Wialon has restrictions on the number of tokens generated.
}

Future<void> tokenLogin(String token) async {
  WialonSdk sdk = WialonSdk();
  Map<String, dynamic> loginResult = await sdk.tokenLogin(token: token);
  print(loginResult);

  /// !Important note:
  /// If you don't want to create algorithms to store the Wialon session, we suggest to perform the logout method at the end of the program.
  await sdk.logout();
}

Future<void> getUnits(String token) async {
  WialonSdk sdk = WialonSdk();
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

  /// Your units should will come in [result['items']]
  print(result['items']);

  await sdk.logout();
}

Future<void> reverseGeocoding(String token) async {
  WialonSdk sdk = WialonSdk();
  await sdk.tokenLogin(token: token);

  String result = await sdk.reverseGeocoding(latitude: 0, longitude: 0);

  /// If your reverse server configured in Wialon can handle your coordinates
  /// (For this example, [latitude] and [longitude] are 0), you should get a result.
  /// Otherwise, you should get an empty string.
  ///
  /// If you run this script (Placing your token, of course), the response will be an empty string.
  print(result);

  await sdk.logout();
}
