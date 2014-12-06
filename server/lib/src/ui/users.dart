part of directcode.services.ui;

@Group("/users")
class UserPages {
  @Route("/register")
  registerPage() => www("users/register.html");

  @Route("/register.js")
  registerPageJavaScript() => www("users/register.js");
}
