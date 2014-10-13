part of directcode.services.common;

final Random random = new Random();
final http.Client httpClient = new http.Client();
final Logger logger = new Logger("Services");

class Markdown {
  final String title;

  const Markdown({this.title: "No Title"});
}

void ServicesPlugin(Manager manager) {
  manager.addResponseProcessor(Markdown, (Markdown metadata, handlerName, value, injector) {
    String str;

    if (value is File) {
      str = value.readAsStringSync();
    } else if (value is String) {
      return str;
    } else {
      throw new ArgumentError("Can't create markdown from the routes return type!");
    }

    return template("markdown", {
      "title": metadata.title,
      "content": markdownToHtml(str)
    });
  }, includeGroups: true);
}
