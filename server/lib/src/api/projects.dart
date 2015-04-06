part of directcode.services.api;

MongoDbService<Project> projects = new MongoDbService<Project>("projects");

class ProjectDescriptor extends Model {
  @Field()
  @NotEmpty()
  String name;

  toSelector() => {
    "name": name
  };
}

class Project extends Model {
  @Id()
  String _id;

  @Field()
  @NotEmpty()
  String name;

  @NotEmpty()
  @Field()
  String description;

  @NotEmpty()
  @Field()
  String url;

  @Field()
  String github;

  @override
  String toString() => encodeJson(this);
}

@Group("/projects")
class ProjectService {
  @Route("/list")
  @Encode()
  listProjects() => projects.find();

  @RequiresToken(permissions: const ["projects.add"])
  @Route("/add", methods: const [POST])
  addProject(@Decode() Project project) {
    emit("projects.added", encode(project));
    projects.insert(project);
  }

  @RequiresToken(permissions: const ["project.remove"])
  @Route("/remove", methods: const [POST])
  removeProject(@Decode() ProjectDescriptor project) {
    emit("projects.removed", encode(project));
    projects.remove(project.toSelector());
  }
}
