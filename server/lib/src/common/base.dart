part of directcode.services.common;

final Random random = new Random();
final http.Client httpClient = new http.Client();
final Logger logger = new Logger("Services");

class Markdown {
  const Markdown();
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
    return renderMarkdown(value, isRequest: true);
  }, includeGroups: true);
}

String renderMarkdown(value, {bool isRequest: false}) {
  String str;
  Map<String, dynamic> data = {};

  if (value is File) {
    str = value.readAsStringSync();
  } else if (value is String) {
    str = value;
  } else {
    throw new ArgumentError("Can't create markdown from the route's return type!");
  }
    
  var split = new List<String>.from(str.split("\n"));
    
  if (hasYamlBlock(split)) {
    data = extractYamlBlock(split);
  }
    
  String title = data.containsKey("title") ? data["title"] : "No Title";

  var binding = {
    "title": title,
    "data": data,
    "config": config
  };
  
  if (isRequest) {
    binding.addAll({
      "request": app.request,
      "query": app.request.queryParams,
      "session": app.request.session,
      "headers": app.request.headers
    });
  }

  var out = markdownToHtml(render(split.join("\n"), binding));
    
  return template("markdown", {
    "title": title,
    "content": out
  });
}

final String yamlBlockDelimiter = config.containsKey("yaml_block_delimiter") ? config["yaml_block_delimiter"] : "---";

bool hasYamlBlock(List<String> split) {
  return split.where((line) => line.trim() == yamlBlockDelimiter).length == 2;
}
  
Map<String, dynamic> extractYamlBlock(List<String> split) {
  var begin = 0;
  var end = split.indexOf(yamlBlockDelimiter, begin + 1);
    
  if (begin <= -1 || end <= -1 || (end - begin) <= 1) {
    return {};
  } else {
    var lines = split.getRange(begin, end);
    var c = lines.join("\n");
      
    for (var i = begin; i <= end; i++) {
      split.removeAt(0);
    }
    
    return yaml.loadYaml(c);
  }
}