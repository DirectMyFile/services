import "dart:html";
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
      menu.items.forEach((item) {
        item.classes.remove("selected");
      });
      
      title.text = menu.selectedItem.text;
      url.src = menu.selectedItem.getAttribute("data-page");
      menu.selectedItem.classes.add("selected");
    });
  }
}
