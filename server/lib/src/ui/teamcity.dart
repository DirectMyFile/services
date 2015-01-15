part of directcode.services.ui;

final String teamcityBuildStatusUrl = "${config['teamcity_url']}/app/rest/builds/buildType:(id:@)/statusIcon";
final File teamcityTempFile = new File("${Directory.systemTemp.path}/teamcity-status.png");

@Route("/teamcity/buildStatus/:build.png")
buildStatusImage(String build) {
  var url = teamcityBuildStatusUrl.replaceAll("@", build);

  var bytes;

  return httpClient.get(url).then((clientResponse) {

    if (clientResponse.statusCode != 200) {
      throw new ErrorResponse(404, "Not Found");
    }

    bytes = clientResponse.bodyBytes;

    return teamcityTempFile.exists();
  }).then((exists) {
    if (exists) {
      return teamcityTempFile.delete();
    }
  }).then((_) {
    return teamcityTempFile.writeAsBytes(bytes);
  });
}
