part of directcode.services.ui;

@Route("/", responseType: "text/html")
index() {
  return markdownToHtml(www("index.md").readAsStringSync());
}