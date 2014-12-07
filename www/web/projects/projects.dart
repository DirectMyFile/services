import "dart:html";
import "dart:convert";
import "package:polymer/polymer.dart";

void main() {
  initPolymer();
}

@CustomTag("services-projects")
class ServicesProjects extends PolymerElement {
  @observable List<Project> projects = [];
  
  ServicesProjects.created() : super.created();
  
  @override
  void attached() {
    HttpRequest.getString("/api/projects/list").then((value) {
      var list = JSON.decode(value);
      projects = list.map((it) {
        return new Project()
          ..name = it['name']
          ..description = it['description']
          ..url = it['url'];
      }).toList();
    });
  }
}

class Project {
  String name;
  String description;
  String url;
}