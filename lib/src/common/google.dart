part of directcode.services.common;

final List<String> GOOGLE_SCOPES = [
    drive.DriveApi.DriveReadonlyScope
];
AccessCredentials GOOGLE_CRED;


void setupGoogleAPIS() {
  var file = new File("google_key.json");

  if (!file.existsSync()) {
    print("ERROR: Please create a Google Service Account JSON key and name it google_key.json");
    exit(1);
  }

  var keyInfo = file.readAsStringSync();

  obtainAccessCredentialsViaServiceAccount(new ServiceAccountCredentials.fromJson(keyInfo), GOOGLE_SCOPES, httpClient).then((cred) {
    GOOGLE_CRED = cred;
  });
}