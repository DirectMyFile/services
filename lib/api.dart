library directcode.services.api;

import "package:password_hasher/password_hasher.dart";

import "common.dart";

part "src/api/members.dart";
part "src/api/users.dart";

class APIError {
  APIError(this.error, this.message);
  
  @Field()
  String error;
  
  @Field()
  String message;
}