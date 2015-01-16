part of directcode.services.api;

const List<String> _QUOTES = const [
  "I'm going to fstab this fstab. -Logan",
  "if (username == \"samrg472\" && password == \"12345\") // Such secure authentication -samrg472"
];

@Route("/quote")
quote() {
  return {
    "quote": _QUOTES[random.nextInt(_QUOTES.length)]
  };
}
