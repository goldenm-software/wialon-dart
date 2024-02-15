part of wialon;

class SdkException implements Exception {
  String message;
  SdkException({this.message = 'Constructor error'});

  String toString() => "SdkException(reason: ${this.message})";
}

class WialonError implements Exception {
  int? code = 0;
  String? details = '';
  String _message = '';

  Map<int, String> _messages = {
    -1: "Unhandled error code",
    1: "Invalid session",
    2: "Invalid service name",
    3: "Invalid result",
    4: "Invalid input",
    5: "Error performing request",
    6: "Unknown error",
    7: "Access denied",
    8: "Invalid user name or password",
    9: "Authorization server is unavailable",
    10: "Reached limit of concurrent requests",
    11: "Password reset error",
    14: "Billing error",
    1001: "No messages for selected interval",
    1002: "Item with such unique property already exists or Item "
        "cannot be created according to billing restrictions",
    1003: "Only one request is allowed at the moment",
    1004: "Limit of messages has been exceeded",
    1005: "Execution time has exceeded the limit",
    1006: "Exceeding the limit of attempts to enter a two-factor "
        "authorization code",
    1011: "Your IP has changed or session has expired",
    2014: "Selected user is a creator for some system objects, "
        "thus this user cannot be bound to a new account",
    2015: "Sensor deleting is forbidden because of using in another "
        "sensor or advanced properties of the unit"
  };

  WialonError({int? code, String? details}) {
    this.code = code;
    if (this._messages[code] != null) {
      this._message = "${this._messages[code]}";
    } else {
      this._message = "${this._messages[-1]}";
    }

    if (details?.isNotEmpty ?? false) {
      this._message += " - ${details}";
    }
  }

  String toString() =>
      "WialonError(code: ${this.code}, details: ${this._message})";
}
