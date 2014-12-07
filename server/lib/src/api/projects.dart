part of directcode.services.api;

MongoDbService<Project> projects = new MongoDbService<Project>("projects");

class ProjectDescriptor {
  @Field()
  @NotEmpty()
  String name;

  toSelector() => {
    "name": name
  };
}

class Project {
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
}

@Group("/projects")
class ProjectService {
  @Encode()
  @Route("/list")
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