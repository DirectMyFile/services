part of directcode.services.common;

final Random random = new Random();
final http.Client httpClient = new http.Client();
final Logger logger = new Logger("Services");

class Markdown {
  final PartialProvider partial;
  
  const Markdown({this.partial: null});
}

class SetupMethod {
  const SetupMethod();
}

class PluginMethod {
  const PluginMethod();
}

const SetupMethod setup = const SetupMethod();
const PluginMethod plugin = const PluginMethod();

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
    return renderMarkdown(value, isRequest: true, partial: metadata.partial);
  }, includeGroups: true);
}
