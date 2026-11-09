class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;

  /// Lifetime of the access token in seconds (3600 = 1 hour).
  final int expiresIn;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      expiresIn: (data['expiresIn'] as num).toInt(),
    );
  }

  /// When the access token stops being valid, counted from now.
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));
}
