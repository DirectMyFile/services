part of directcode.services.api;

PasswordHasher hasher = new PasswordHasher();

MongoDbService<User> users = new MongoDbService<User>("users");

var userValidator = new Validator(User, true);

class User {
  @Id()
  String _id;
  
  @Field()
  @NotEmpty()
  String username;
  
  @Field()
  @NotEmpty()
  String email;
  
  @Field()
  @NotEmpty()
  String passwordHash;
  
  bool checkPassword(String password) => hasher.checkPassword(passwordHash, password);
}

class RegisterUser {
  @Field()
  String username;
  
  @Field()
  String email;
  
  @Field()
  String password;
}

class CheckUser {
  @Field()
  String username;
  
  @Field()
  String password;
}

class UserCheckSuccess {
  UserCheckSuccess(this.email);
  
  @Field()
  bool success = true;
  
  @Field()
  String email;
}

class UserRegistered {
  @Field()
  bool registered = true;
}

@Group("/users")
class UserService {
  @Encode()
  @Route("/register", methods: const [POST])
  @RequiresToken(permissions: const ["users.register"])
  register(@Decode() RegisterUser registerUser) {
    return users.find({
      "username": registerUser.username
    }).then((allUsers) {
      if (allUsers.isNotEmpty) {
        return new ErrorResponse(400, new APIError("user.exists", "A user with that username already exists."));
      }
      
      var user = new User();
      var passwordHash = hasher.hashPassword(registerUser.password);
      
      user.username = registerUser.username;
      user.passwordHash = passwordHash;
      user.email = registerUser.email;
      
      return users.insert(user);
    }).then((_) {
      
      if (_ is ErrorResponse) return _;
      
      var email = new Envelope();
      
      email.subject = "DirectCode User Registration";
      
      email.recipients.add(registerUser.email);
      
      email.text = template("registration_email", {
        "email": registerUser.email,
        "username": registerUser.username
      });
      
      emailTransport.send(email);
      
      return new UserRegistered();
    });
  }
  
  /*@Encode()
  @RequiresToken()
  @Route("/list")*/
  list() =>
      users.find();
  
  @RequiresToken(permissions: const ["users.email.send"])
  @Route("/send_email", methods: const [POST])
  sendEmail(@Body(JSON) Map input) {
    var username = input['username'];
    
    if (username == null) {
      return new ErrorResponse(400, new APIError("user.not.specified", "A user is not specified"));
    }
    
    var subject = input['subject'];
    var from = input['from'];
    var content = input['body'];
    
    if (content == null) {
      return new ErrorResponse(400, new APIError("body.not.specified", "Email body was not specified"));
    }
    
    return users.findOne({
      "username": username
    }).then((user) {
      var email = new Envelope();
      
      if (subject != null) email.subject = subject;
      if (from != null) email.from = from;
      
      email.recipients.add(user.email);
      email.text = content;
      
      return emailTransport.send(email);
    }).then((_) {
      return {
        "sent": true
      };
    }).catchError((e) {
      return new ErrorResponse(404, new APIError("user.not.found", "User not found."));
    });
  }
  
  @Encode()
  @RequiresToken(permissions: const ["users.check"])
  @Route("/check", methods: const [POST])
  check(@Decode() CheckUser info) {
    return users.find({
      "username": info.username
    }).then((userz) {
      if (userz.isNotEmpty) {
        var user = userz.first;
        
        if (!user.checkPassword(info.password)) {
          return new ErrorResponse(401, new APIError("user.password.invalid", "The password that was provided is invalid."));
        }
        
        return new UserCheckSuccess(user.email);        
      } else {
        return new ErrorResponse(404, new APIError("user.not.found", "The provided user was not found."));
      }
    });
  }
}
