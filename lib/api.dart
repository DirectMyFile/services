library directcode.services.api;

import "package:mailer/mailer.dart";

import "package:password_hasher/password_hasher.dart";

import "common.dart";

part "src/api/members.dart";
part "src/api/users.dart";
part "src/api/projects.dart";

SmtpTransport emailTransport;

void setupAPI() {
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