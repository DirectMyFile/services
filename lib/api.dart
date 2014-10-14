library directcode.services.api;

import "package:mailer/mailer.dart";

import "package:password_hasher/password_hasher.dart";

import "dart:convert" as Convert;

import "dart:async";
import "dart:io";
import "common.dart";

import "package:http/http.dart" as http;

part "src/api/members.dart";
part "src/api/users.dart";
part "src/api/projects.dart";
part "src/api/events.dart";
part "src/api/teamcity.dart";
part "src/api/zen.dart";
part "src/api/internal.dart";

SmtpTransport emailTransport;

@Setup
void setupGmail() {
  print("Setting Up Gmail");
  
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
