part of directcode.services.api;

@Group("/teamcity")
class TeamCityService {
  http.Client client = new http.Client();

  static String get url => config['teamcity_url'] + "/httpAuth/app/rest/latest";
  static String get username => config['teamcity_username'];
  static String get password => config['teamcity_password'];

  Future getJSON(String path) {
    var u = url + path;
    var auth = Crypto.CryptoUtils.bytesToBase64(Convert.UTF8.encode("$username:$password"));
    return http.get(u, headers: {
      "Authorization": "Basic ${auth}",
      "Accept": "application/json"
    }).then((response) {
      if (response.statusCode != 200) {
        throw new ErrorResponse(response.statusCode, response.body);
      }

      return Convert.JSON.decode(response.body);
    });
  }

  @Route("/version")
  @Encode()
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
  @Encode()
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
