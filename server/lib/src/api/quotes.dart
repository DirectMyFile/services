part of directcode.services.api;

List<String> getQuotes() => fromDataFile("quotes.yaml");

@Route("/quote")
quote() {
  var q  = getQuotes();
  return {
    "quote": q[random.nextInt(q.length)]
  };
}
