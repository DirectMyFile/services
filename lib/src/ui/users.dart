part of directcode.services.ui;

@Route("/users/register")
registerUser() => new File("www/users/register.html");

@Route("/users/register.js")
registerUserJavaScript() => new File("www/users/register.js");