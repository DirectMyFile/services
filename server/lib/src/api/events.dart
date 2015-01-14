part of directcode.services.api;

EventEndpoint eventEndpoint;

@WebSocketHandler("/events/ws")
class EventEndpoint {
  bool _exitHookSetup = false;
  Map<String, List<WebSocketSession>> events = {};
  Map<WebSocketSession, String> tokened = {};
  Map<String, int> eventCounts = {};
  List<WebSocketSession> activeClients = [];
  List<WebSocketSession> globalListeners = [];

  EventEndpoint() {
    eventEndpoint = this;
  }

  @OnOpen()
  void onOpen(WebSocketSession session) {
    if (!_exitHookSetup) {
      ProcessSignal.SIGINT.watch().listen((_) {
        for (var session in activeClients) {
          session.connection.close(5000, "stopping");
        }
        exit(0);
      });
      _exitHookSetup = true; 
    }
    
    activeClients.add(session);
    
    sendMessage(session, {
      "type": "connect"
    });
  }

  void sendMessage(WebSocketSession session, Map message) {
    var json = Convert.JSON.encode(message);
    session.connection.add(json);
  }

  @OnMessage()
  void onMessage(String message, WebSocketSession session) {
    var json = Convert.JSON.decode(message);

    if (json['type'] == null) {
      sendMessage(session, {
        "type": "error",
        "error": "type.missing",
        "message": "type is missing"
      });
      return;
    }

    String type = json['type'];

    if (type == "connect") {
      var token = json['token'];

      if (token == null) {
        sendMessage(session, {
          "type": "error",
          "error": "token.missing",
          "message": "token is missing"
        });
        return;
      }

      if (!tokens.containsKey(token)) {
        sendMessage(session, {
          "type": "error",
          "error": "token.invalid",
          "message": "token is invalid"
        });
        return;
      }

      if (!hasPermission(token, "events.${type}")) {
        sendMessage(session, {
          "type": "error",
          "error": "token.no.permission",
          "message": "token does not have permission to access events"
        });
        return;
      }

      tokened[session] = token;

      sendMessage(session, {
        "type": "ready",
        "permissions": tokens[token]
      });

      return;
    }

    if (!tokened.containsKey(session)) {
      sendMessage(session, {
        "type": "error",
        "error": "token.not.provided",
        "message": "a token has not been provided"
      });
      return;
    }

    if (!tokens.containsKey(tokened[session])) {
      sendMessage(session, {
        "type": "error",
        "error": "token.revoked",
        "message": "the token you provided has been revoked"
      });
      return;
    }

    if (!hasPermission(tokened[session], "events.${type}")) {
      sendMessage(session, {
        "type": "error",
        "error": "token.no.permission",
        "message": "the token you provided does not have permission to use that"
      });
      return;
    }

    if (type == "subscribe") {
      var event = json['event'];

      if (event == null) {
        sendMessage(session, {
          "type": "error",
          "error": "event.missing",
          "message": "event is missing"
        });
        return;
      }
      
      if (!hasPermission(tokened[session], "event.subscribe.${event}")) {
        sendMessage(session, {
          "type": "error",
          "error": "token.no.permission",
          "message": "you do not have permission to subscribe for this event"
        });
        return;
      }

      var list = event == "*" ? globalListeners : events.putIfAbsent(event, () => []);

      if (list.contains(session) || globalListeners.contains(session)) {
        sendMessage(session, {
          "type": "error",
          "error": "event.already.subscribed",
          "message": "you are already subscribed to this event"
        });
        return;
      }

      list.add(session);

      sendMessage(session, {
        "type": "subscribed",
        "event": event
      });
    } else if (type == "unsubscribe") {
      var event = json['event'];

      if (event == null) {
        sendMessage(session, {
          "type": "error",
          "error": "event.missing",
          "message": "event is missing"
        });
        return;
      }

      var list = event == "*" ? globalListeners : events.putIfAbsent(event, () => []);

      if (!list.contains(session)) {
        sendMessage(session, {
          "type": "error",
          "error": "event.not.subscribed",
          "message": "you have not subscribed to this event"
        });
        return;
      }

      list.remove(session);

      sendMessage(session, {
        "type": "unsubscribed",
        "event": event
      });
    } else if (type == "emit") {
      var event = json['event'];
      
      if (!hasPermission(tokened[session], "event.emit.${event}")) {
        sendMessage(session, {
          "type": "error",
          "error": "token.no.permission",
          "message": "the token you provided does not have permission to emit that event"
        });
        return;
      }

      if (event == null) {
        sendMessage(session, {
          "type": "error",
          "error": "event.missing",
          "message": "event is missing"
        });
        return;
      }

      var data = json['data'];

      if (data == null) data = {};

      emit(event, data);
    } else {
      sendMessage(session, {
        "type": "error",
        "error": "type.illegal",
        "message": "illegal type given"
      });
    }
  }

  void emit(String eventName, Map data) {
    if (!eventCounts.containsKey(eventName)) {
      eventCounts[eventName] = 0;
    }

    eventCounts[eventName] = eventCounts[eventName] + 1;

    if (!events.containsKey(eventName)) return;

    var id = generateToken(length: 60);
    
    var msg = {
      "type": "event",
      "event": eventName,
      "data": data
    };

    for (var session in events[eventName]) {
      sendMessage(session, {
        "id": id
      }..addAll(msg));
    }

    for (var session in globalListeners) {
      sendMessage(session, {
        "id": id
      }..addAll(msg));
    }
    
    new Future.delayed(new Duration(milliseconds: 50), () {
      return webhooks.find();
    }).then((List<WebHook> hooks) {
      var group = new FutureGroup();
      hooks.where((hook) => hook.events.contains(eventName)).forEach((hook) {
        group.add(http.post(hook.url, body: Convert.JSON.encode(data), headers: {
          "X-DirectCode-WebHook": hook.id,
          "X-DirectCode-Event": id
        }).then((response) {
        }).catchError((e) {
        }));
      });
      
      return group.future;
    });
  }

  @OnClose()
  void onClose(WebSocketSession session) {
    for (var list in events.values) {
      list.remove(session);
    }

    activeClients.remove(session);
    globalListeners.remove(session);
    tokened.remove(session);
  }
}

@Group("/events")
class EventService {
  @Route("/stats")
  stats() {
    var endpoint = eventEndpoint;
    var listeners = {};

    for (var event in endpoint.events.keys) {
      listeners[event] = endpoint.events[event].length;
    }

    var eventz = {};

    for (var event in endpoint.eventCounts.keys) {
      eventz[event] = endpoint.eventCounts[event];
    }

    return {
      "listeners": listeners,
      "events": eventz
    };
  }
  
  @RequiresToken(permissions: const ["events.http.emit"])
  @Route("/emit", methods: const [POST])
  emitter(@QueryParam() String event) {
    var body = request.body;
    if (body is String) body = Convert.JSON.decode(body);
    emit(event, body);
    return {
      "status": "success"
    };
  }
}

MongoDbService<WebHook> webhooks = new MongoDbService<WebHook>("webhooks");

@Group("/events/webhooks")
class EventWebHookService {
  @Encode()
  @RequiresToken(permissions: const ["events.webhook.add"])
  @Route("/add", methods: const [POST])
  add(@Attr("token") String creatorToken, @Decode() WebHook hook) {
    hook.creator = creatorToken;
    
    return webhooks.insert(hook).then((_) {
      return {
        "status": "success",
        "id": hook.id
      };
    });
  }
  
  @Encode()
  @RequiresToken(permissions: const ["events.webhook.delete"])
  @Route("/remove", methods: const [POST])
  remove(@Decode() RemoveWebHookRequest request) {
    return webhooks.remove(new SelectorBuilder().id(new ObjectId.fromHexString(request.id))).then((_) {
      return {
        "status": "success"
      };
    });
  }
}

void emit(String event, Map data) {
  eventEndpoint.emit(event, data);
}

class RemoveWebHookRequest {
  @Field()
  String id;
}

class WebHook {
  @Id()
  String id;
  @Field()
  String url;
  @Field()
  List<String> events;
  String creator;
  
  Future<bool> ping() {
    return http.post(url, headers: {
      "X-DirectCode-WebHook": id
    }, body: Convert.JSON.encode({
      "type": "ping"
    })).then((response) {
      return response.statusCode == 200;
    }).catchError((e) {
      return false;
    });
  }
}