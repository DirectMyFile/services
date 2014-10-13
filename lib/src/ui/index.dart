part of directcode.services.ui;

@Markdown(title: "DirectCode Services")
@Route("/", responseType: "text/html")
index() => www("index.md");
