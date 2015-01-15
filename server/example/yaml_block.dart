import "package:services/common.dart";

void main() {
  config = {};
  var input = [
    "---",
    "testA: Hello",
    "testB: World",
    "---",
    "# {{data.testA}} {{data.testB}}"
  ];
  
  if (hasYamlBlock(input)) {
    print("It has a block.");
    var result = extractYamlBlock(input);
    print(result);
    print("");
    print(input);
  } else {
    print("It doesn't have a block.");
  }
}