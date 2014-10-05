part of directcode.services;

MongoDbService<Member> members = new MongoDbService<Member>("members");

class Member {
  @Id()
  String id;
  
  @Field()
  String name;
}

@Group("/api/members")
class MemberService {
  @Encode()
  @Route("/list")
  listMembers() =>
      members.find();
  
  @RequiresToken()
  @Route("/add", methods: const [POST])
  addMember(@Decode() Member member) =>
      members.insert(member);
}
