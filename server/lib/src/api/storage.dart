part of directcode.services.api;

MongoDbService<StorageEntry> storageDB = new MongoDbService("storage_entries");

@Group("/storage")
class StorageService {
  @Encode()
  @RequiresToken(permissions: const ["storage.put"])
  @Route("/put", methods: const [POST])
  put(@Attr() String token, @Decode() StoragePutRequest request) {
    var entry = new StorageEntry();
    entry.key = request.key;
    entry.value = request.value;
    entry.ownerToken = token;
    return storageDB.find(new SelectorBuilder().eq("key", request.key)).then((entries) {
      if (entries.isNotEmpty) {
        throw new ErrorResponse(409, {
          "error": "key.exists",
          "message": "key already exists"
        });
      } else {
        return storageDB.insert(entry).then((_) {
          return {
            "status": "success"
          };
        });
      }
    });
  }

  @Encode()
  @RequiresToken(permissions: const ["storage.get"])
  @Route("/get", methods: const [GET])
  get(@Attr() String token, @Decode(fromQueryParams: true) StorageGetRequest request) {
    return storageDB.find(new SelectorBuilder().eq("ownerToken", token)).then((entries) {
      return entries.firstWhere((it) => it.key == request.key, orElse: () => null);
    }).then((value) {
      if (value == null) {
        throw new ErrorResponse(404, {
          "error": "key.not.found",
          "message": "key not found"
        });
      } else {
        return value;
      }
    });
  }
  
  @Encode()
  @RequiresToken(permissions: const ["storage.list"])
  @Route("/list", methods: const [GET])
  list(@Attr() String token) {
    return storageDB.find(new SelectorBuilder().eq("ownerToken", token));
  }
}

class StorageEntry {
  @Id()
  String id;
  @Field()
  String key;
  @Field()
  dynamic value;
  @Field()
  String ownerToken;
}

class StoragePutRequest {
  @Field()
  String key;
  @Field()
  String value;
}

class StorageGetRequest {
  @Field()
  String key;
}
