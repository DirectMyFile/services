part of directcode.services.api;

PasswordHasher hasher = new PasswordHasher();

MongoDbService<User> users = new MongoDbService<User>("users");

class User {
  @Id()
  String id;
  
  @Field()
  String username;
  
  @Field()
  String email;
  
  @Field()
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

@Group("/api/users")
class UserService {
  @Route("/register", methods: const [POST])
  @RequiresToken()
  register(@Decode() RegisterUser registerUser) {
    return users.find({
      "username": registerUser.username
    }).then((allUsers) {
      if (allUsers.isNotEmpty) {
        throw new ErrorResponse(400, {
          "error": "user.exists",
          "message": "A user with that username already exists."
        });
      }
      
      var user = new User();
      var passwordHash = hasher.hashPassword(registerUser.password);
      
      user.username = registerUser.username;
      user.passwordHash = passwordHash;
      user.email = registerUser.email;
      
      return users.insert(user);
    }).then((_) {
      return {
        "registered": true
      };
    });
  }
  
  /*@Encode()
  @RequiresToken()
  @Route("/list")*/
  list() =>
      users.find();
  
  @Encode()
  @RequiresToken()
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
