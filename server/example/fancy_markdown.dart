import "package:services/common.dart";

String input = """
---
title: Hello World
greeting: Hello
html_template: fancy_markdown
template_binding:
  test: World
---

```dart
{{data.greeting}}
```
""";

void main() {
  config = {};
  
  print(renderMarkdown(input));
}