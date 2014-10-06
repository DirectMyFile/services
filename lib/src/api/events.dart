part of directcode.services.api;

@Group("/api/events")
@WebSocketHandler("/api/events/ws")
class EventService {
  Map<String, List<WebSocketSession>> events = {};
  Map<WebSocketSession, String> tokened = {};
  Map<String, int> eventCounts = {};
  
  @OnOpen()
  void onOpen(WebSocketSession session) {
    sendMessage(session, {
      "type": "ready"
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
    
    if (type == "token") {
      var token = json['token'];
      
      if (token == null) {
        sendMessage(session, {
          "type": "error",
          "error": "token.missing",
          "message": "token is missing"
        });
        return;
      }
      
      if (!tokens.contains(token)) {
        sendMessage(session, {
          "type": "error",
          "error": "token.invalid",
          "message": "token is invalid"
        });
        return;
      }
      
      tokened[session] = token;
      
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
    
    if (!tokens.contains(tokened[session])) {
      sendMessage(session, {
        "type": "error",
        "error": "token.revoked",
        "message": "the token you provided has been revoked"
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
      
      var list = events.putIfAbsent(event, () => []);
      
      if (list.contains(session)) {
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
      
      var list = events.putIfAbsent(event, () => []);
      
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
    for (var session in events[eventName]) {
      sendMessage(session, {
        "type": "event",
        "event": eventName,
        "data": data
      });
    }
  }
  
  @Route("/stats")
  stats() {
    var out =  {
      "listeners": {},
      "events": {}
    };
    
    var listeners = out["listeners"];
    
    for (var event in events.keys) {
      listeners[event] = events[event].length;
    }
    
    var eventz = out["events"];
    
    for (var event in eventCounts.keys) {
      eventz[event] = eventCounts[event];
    }
    
    return out;
  }
  
  
  @OnClose()
  void onClose(WebSocketSession session) {
    for (var list in events.values) {
      list.remove(session);
    }
    
    tokened.remove(session);
  }
}
