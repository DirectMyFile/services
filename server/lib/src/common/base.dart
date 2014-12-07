part of directcode.services.common;

final Random random = new Random();
final http.Client httpClient = new http.Client();
final Logger logger = new Logger("Services");

class Markdown {
  final String title;

  const Markdown({this.title: "No Title"});
}

class SetupMethod {
  const SetupMethod();
}

class PluginMethod {
  const PluginMethod();
}

const SetupMethod Setup = const SetupMethod();
const PluginMethod Plugin = const PluginMethod();

void ServicesPlugin(Manager manager) {
  var setupMethods = manager.findFunctions(SetupMethod);
  var pluginMethods = manager.findFunctions(PluginMethod);
  
  for (var setupMethod in setupMethods) {
    var owner = setupMethod.mirror.owner as LibraryMirror;
    owner.invoke(setupMethod.mirror.simpleName, []);
  }
  
  for (var pluginMethod in pluginMethods) {
    var owner = pluginMethod.mirror.owner as LibraryMirror;
    owner.invoke(pluginMethod.mirror.simpleName, [manager]);
  }
  
  manager.addResponseProcessor(Markdown, (Markdown metadata, handlerName, value, injector) {
    String str;

    if (value is File) {
      str = value.readAsStringSync();
    } else if (value is String) {
      return str;
    } else {
      throw new ArgumentError("Can't create markdown from the routes return type!");
    }

    var out = markdownToHtml(render(str, {
      "title": metadata.title,
      "request": app.request
    }));
    
    return template("markdown", {
      "title": metadata.title,
      "content": out
    });
  }, includeGroups: true);
}
