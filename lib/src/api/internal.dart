part of directcode.services.api;

@Group("/internal")
class InternalService {
  @RequiresToken(permissions: const["internal.server"])
  @Route("/server")
  server() {
    return {
        "vm": {
            "version": Platform.version
        },
        "hostname": Platform.localHostname
    };
  }
}