part of directcode.services.api;

final List<String> _ZENS = fromDataFile("zen.yaml");

@Route("/zen")
zen() {
  return {
    "zen": _ZENS[random.nextInt(_ZENS.length)]
  };
}
