import "dart:html";
import "package:polymer/polymer.dart";
import "package:core_elements/core_menu.dart";
import "package:core_elements/core_item.dart";

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
    CoreMenu menu = $["menu"];
    
    menu.addEventListener("core-select", (e) {
      print("Menu Selection Changed");
      title.text = menu.selectedItem.label;
      url.src = menu.selectedItem.getAttribute("data-page");
    });
  }
}
