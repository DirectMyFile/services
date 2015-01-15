import "package:services/common.dart";

String input = """
---
title: Hello World
greeting: Hello
---

{{data.greeting}} World!
""";
void main() {
  config = {};
  
  print(renderMarkdown(input));
}