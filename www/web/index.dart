import "dart:html";
import "dart:async";
import "package:polymer/polymer.dart";
import "package:core_elements/core_menu.dart";

void main() {
  initPolymer();
}

@CustomTag("services-dashboard")
class DashboardElement extends PolymerElement {
  DashboardElement.created() : super.created();
  
  @override
  void attached() {
    super.attached();
    
    var title = $["page-title"] as SpanElement;
    var url = $["page"] as IFrameElement;
    var menu = $["menu"] as CoreMenu;
    
    menu.addEventListener("core-select", (e) {
      if (!e.detail['isSelected']) return;
      var item = e.detail['item'];
      title.text = item.text;
      url.src = item.dataset['page'];
    });
  }
}
