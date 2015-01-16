part of directcode.services.common;

class Markdown {
  final PartialProvider partial;
  
  const Markdown({this.partial: null});
}

const Markdown markdown = const Markdown();

@plugin
void MarkdownPlugin(Manager manager) {
  manager.addResponseProcessor(Markdown, (Markdown metadata, handlerName, value, injector) {
    return renderMarkdown(value, isRequest: true, partial: metadata.partial);
  }, includeGroups: true);
}

abstract class DataConsumer {
  void provideData(Map<String, dynamic> data);
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

typedef dynamic PartialProvider(String name);

String renderTemplate(String templateName, binding, {PartialProvider partial}) {
  if (partial == null) {
    partial = (name) {
      var f = new File("templates/${name}.mustache");
      if (!f.existsSync()) {
        throw new Exception("Template does not exist.");
      }
      return f.readAsStringSync();
    };
  }
  
  var file = new File("templates/${templateName}.mustache");
  
  if (!file.existsSync()) {
    throw new ArgumentError("Template does not exist.");
  }
  
  var lines = file.readAsLinesSync();
  
  if (hasYamlBlock(lines)) {
    var data = extractYamlBlock(lines);
    
    if (binding is Map) {
      binding["data"] = data;
      if (data.containsKey("defaults")) {
        var b = new Map.from(data["defaults"]);
        b.addAll(binding);
        binding = b;
      }
    } else if (binding is DataConsumer) {
      binding.provideData(data);
    } else {
      throw new ArgumentError("Template with a binding that does not support consuming data cannot have a data block.");
    }
  }

  return render(lines.join("\n"), binding, partial: partial);
}

String renderMarkdown(value, {bool isRequest: false, PartialProvider partial}) {
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
  var b = {
    "title": title,
    "content": out
  };
  
  if (data.containsKey("template_binding")) {
    b.addAll(data["template_binding"]);
  }
  
  return renderTemplate(data.containsKey("html_template") ? data["html_template"] : "markdown", b, partial: partial);
}

File www(String path) => new File("www/${path}");
