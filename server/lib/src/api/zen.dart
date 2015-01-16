part of directcode.services.api;

const List<String> _ZENS = const [
  "Half measures are as bad as nothing at all.",
  "Keep it logically awesome.",
  "Don't be evil.",
  "Be fun.",
  "Don't be afraid to fail.",
  "Practicality beats purity.",
  "Make mistakes, and learn from them.",
  "Do not be afraid to rewrite something, if it is for a better cause.",
  "Innovation is just as good as invention.",
  "Shoot for the best and you get the rest.",
  "Break it."
];

@Route("/zen")
zen() {
  return {
    "zen": _ZENS[random.nextInt(_ZENS.length)]
  };
}
