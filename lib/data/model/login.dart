import 'package:json_annotation/json_annotation.dart';


part 'login.g.dart';

@JsonSerializable(explicitToJson: true)
class Login {
  final String? userId;
  final String? name;
  final String? token;

  Login({
    this.userId,
    this.name,
    this.token,
  });

  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);

  Map<String, dynamic> toJson() => _$LoginToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LoginResult {
  final bool? error;
  final String? message;
  final Login? loginResult;

  LoginResult({
    this.error,
    this.message,
    this.loginResult,
  });
  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}
