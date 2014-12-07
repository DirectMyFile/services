import "package:mustache4dart/mustache4dart.dart";

class Test {
  final String value;
  
  Test(this.value);
}

void main() {
  print(render("{{test.value}}", {
    "test": new Test("Alex")
  }));
}