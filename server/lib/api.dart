library directcode.services.api;

import "package:mailer/mailer.dart";

import "package:password_hasher/password_hasher.dart";

import "dart:convert" as Convert;

import "dart:async";
import "dart:io";
import "package:quiver/async.dart";
import "common.dart";

import "package:http/http.dart" as http;

import "package:mongo_dart/mongo_dart.dart";

part "src/api/members.dart";
part "src/api/users.dart";
part "src/api/projects.dart";
part "src/api/events.dart";
part "src/api/teamcity.dart";
part "src/api/zen.dart";
part "src/api/internal.dart";
part "src/api/quotes.dart";
part "src/api/tokens.dart";

SmtpTransport emailTransport;

@Setup
void setupGmail() {
  var options = new GmailSmtpOptions();

  options.username = config['gmail_username'];
  options.password = config['gmail_password'];

  emailTransport = new SmtpTransport(options);
}

class APIError {
  APIError(this.error, this.message);

  @Field()
  String error;

  @Field()
  String message;
}
