part of directcode.services.api;

EventEndpoint eventEndpoint;

@WebSocketHandler("/events/ws")
class EventEndpoint {
  Map<String, List<WebSocketSession>> events = {
  };

  Map<WebSocketSession, String> tokened = {
  };

  Map<String, int> eventCounts = {
  };

  List<WebSocketSession> globalListeners = [];

  EventEndpoint() {
    eventEndpoint = this;
  }

  @OnOpen()
  void onOpen(WebSocketSession session) {
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

    if (!hasPermission(tokened[session], "event.${type}")) {
      sendMessage(session, {
          "type": "error",
          "error": "token.no.permission",
          "message": "the token you provided does not have permission to use that"
      });
      return;
    }

    if (type == "register") {
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

      if (list.contains(session) || globalListeners.contains(session)) {
        sendMessage(session, {
            "type": "error",
            "error": "event.already.registered",
            "message": "you have already been registered for this event"
        });
        return;
      }

      list.add(session);

      sendMessage(session, {
          "type": "registered",
          "event": event
      });
    } else if (type == "unregister") {
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
            "error": "event.not.registered",
            "message": "you have not been registered for this event"
        });
        return;
      }

      list.remove(session);

      sendMessage(session, {
          "type": "unregistered",
          "event": event
      });
    } else if (type == "emit") {
      var event = json['event'];

      if (event == null) {
        sendMessage(session, {
            "type": "error",
            "error": "event.missing",
            "message": "event is missing"
        });
        return;
      }

      var data = json['data'];

      if (data == null) data = {
      };

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

    var msg = {
        "type": "event",
        "event": eventName,
        "data": data
    };

    for (var session in events[eventName]) {
      sendMessage(session, msg);
    }

    for (var session in globalListeners) {
      sendMessage(session, msg);
    }
  }

  @OnClose()
  void onClose(WebSocketSession session) {
    for (var list in events.values) {
      list.remove(session);
    }

    globalListeners.remove(session);

    tokened.remove(session);
  }
}

@Group("/events")
class EventService {
  @Route("/stats")
  stats() {
    var endpoint = eventEndpoint;
    var listeners = {
    };

    for (var event in endpoint.events.keys) {
      listeners[event] = endpoint.events[event].length;
    }

    var eventz = {
    };

    for (var event in endpoint.eventCounts.keys) {
      eventz[event] = endpoint.eventCounts[event];
    }

    return {
        "listeners": listeners,
        "events": eventz
    };
  }
}
