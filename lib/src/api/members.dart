part of directcode.services.api;

MongoDbService<Member> members = new MongoDbService<Member>("members");

class Member {
  @Id()
  String _id;
  
  @Field()
  String name;
}

@Group("/members")
class MemberService {
  @Encode()
  @Route("/list")
  listMembers() =>
      members.find();
  
  @RequiresToken(permissions: const ["members.add"])
  @Route("/add", methods: const [POST])
  addMember(@Decode() Member member) =>
      members.insert(member);
  
  @RequiresToken(permissions: const ["members.remove"])
  @Route("/remove", methods: const [POST])
  removeMember(@Decode() Member member) =>
      members.remove(member);
}
