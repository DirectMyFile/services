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
}

String generateBasicId({int length: 30}) {
  var r = new Random(random.nextInt(5000));
  var buffer = new StringBuffer();
  for (int i = 1; i <= length; i++) {
    var n = r.nextInt(50);
    if (n >= 0 && n <= 32) {
      String letter = alphabet[r.nextInt(alphabet.length)];
      buffer.write(r.nextBool() ? letter.toLowerCase() : letter);
    } else if (n > 32 && n <= 43) {
      buffer.write(numbers[r.nextInt(numbers.length)]);
    } else if (n > 43) {
      buffer.write(specials[r.nextInt(specials.length)]);
    }
  }
  return buffer.toString();
}

const List<String> alphabet = const [
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z"
];

const List<int> numbers = const [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9
];

const List<String> specials = const [
  "@",
  "=",
  "_",
  "+",
  "-",
  "!",
  "."
];