part of directcode.services.api;

const List<String> _QUOTES = const ["I'm going to fstab this fstab. -Logan"];

@Route("/quote")
quote() {
  return {
    "quote": _QUOTES[random.nextInt(_QUOTES.length)]
  };
}
