part of directcode.services.ui;

const String TEAMCITY_BUILD_STATUS_URL = "http://ci.directcode.org/app/rest/builds/buildType:(id:@)/statusIcon";

@Route("/teamcity/buildStatus/:build.png")
buildStatusImage(String build) {
  var url = TEAMCITY_BUILD_STATUS_URL.replaceAll("@", build);
  
  return httpClient.get(url).then((clientResponse) {
    
    if (clientResponse.statusCode != 200) {
      return new ErrorResponse(404, "Not Found");
    }
    
    var bytes = clientResponse.bodyBytes;
    
    var temp = Directory.systemTemp;
    
    var file = new File("${temp.path}/teamcity-status.png");
    
    if (file.existsSync()) file.deleteSync();
    
    file.writeAsBytesSync(bytes);
    
    return file;
  });
}