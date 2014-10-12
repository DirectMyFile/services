part of directcode.services.api;

@Group("/teamcity")
class TeamCityService {

  HttpClient client = new HttpClient()
    ..addCredentials(Uri.parse(url), "TeamCity", new HttpClientBasicCredentials(username, password));

  static String get url => config['teamcity_url'] + "/httpAuth/app/rest/latest";

  static String get username => config['teamcity_username'];

  static String get password => config['teamcity_password'];

  Future getJSON(String path) {
    var uri = Uri.parse(url + path);
    return client.getUrl(uri).then((request) {
      request.headers.add("Accept", "application/json");
      return request.close();
    }).then((response) {
      return response.transform(Convert.UTF8.decoder).join();
    }).then((value) {
      return Convert.JSON.decode(value);
    });
  }

  @Route("/version")
  version() {
    return getJSON("/server").then((response) {
      return {
          "full_version": response['version'],
          "major": response['versionMajor'],
          "minor": response['versionMinor'],
          "build_number": response['buildNumber'],
          "build_date": response['buildDate']
      };
    });
  }

  @Route("/projects")
  projects() {
    return getJSON("/projects").then((response) {
      var projects = response['project'];
      var list = [];

      for (var prj in projects) {
        list.add({
            "id": prj['id'],
            "name": prj['name'],
            "description": prj['description'],
            "url": prj['webUrl']
        });
      }

      return list;
    });
  }
}