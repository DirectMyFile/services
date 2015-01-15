import "dart:html";
import "dart:convert";

void main() {
  print("Fetching Event Statistics");
  HttpRequest.getString("/api/events/stats").then((value) {
    print("Fetched Event Statistics");
    var json = JSON.decode(value);
    var listeners = json["listeners"].keys.map((it) {
      return new Listener()..name = it..count = json["listeners"][it];
    }).toList();

    var $l = querySelector("#rows-listeners");
    for (var listener in listeners) {
      $l.appendHtml("""
      <tr>
        <td>${listener.name}</td>
        <td>${listener.count}</td>
      </tr>
      """);
    }
    
    var $c = querySelector("#connections");
    var $u = querySelector("#unique_tokens");
    $c.appendHtml("Connections: ${json['connections']}");
    $u.appendHtml("Unique Tokens: ${json['unique_tokens']}");
  });
}

class Listener {
  String name;
  int count;
}