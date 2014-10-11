part of directcode.services.common;

String template(String templateName, binding) {
  var file = new File("templates/${templateName}.mustache");

  if (!file.existsSync()) {
    throw new ArgumentError("Template does not exist.");
  }

  return render(file.readAsStringSync(), binding);
}

File www(String path) => new File("www/${path}");