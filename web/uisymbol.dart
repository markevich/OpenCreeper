part of creeper;

class UISymbol {
  Rectangle rectangle;
  int keyCode;
  bool active = false, hovered = false;
  Building building;
  static UISymbol activeSymbol = null;
  static List<UISymbol> symbols = new List<UISymbol>();
  Zei.Rect backgroundRect;
  Zei.Sprite sprite, sprite2;
  Zei.Text name, shortcut, health;

  UISymbol(position, this.building, this.keyCode) {
    rectangle = new Rectangle(position.x, position.y, 80, 55);
    backgroundRect = Zei.Rect.create("gui", "default", position, new Zei.Vector2(80, 55), 0, new Zei.Color(68, 85, 68), null);
    sprite = Zei.Sprite.create("gui", "default", Zei.images[building.type], new Zei.Vector2(position.x + 24,  position.y + 20), 32, 32);
       
    if (building.type == "cannon")
      sprite2 = Zei.Sprite.create("gui", "default", Zei.images["cannongun"], new Zei.Vector2(position.x + 24,  position.y + 20), 32, 32);
    if (building.type == "bomber")
      sprite2 = Zei.Sprite.create("gui", "default", Zei.images["bombership"], new Zei.Vector2(position.x + 24,  position.y + 20), 32, 32);
    
    name = Zei.Text.create("gui", "default", new Zei.Vector2(rectangle.left + (rectangle.width ~/ 2), rectangle.top + 15), 10, "px", "Verdana", new Zei.Color.white(), null, building.type.substring(0, 1).toUpperCase() + building.type.substring(1), align: "center");
    shortcut = Zei.Text.create("gui", "default", new Zei.Vector2(rectangle.left + 5, rectangle.top + 50), 10, "px", "Verdana", new Zei.Color.white(), null, "(${new String.fromCharCode(keyCode)})");
    health = Zei.Text.create("gui", "default", new Zei.Vector2(rectangle.left + rectangle.width - 5,  rectangle.top + 50), 10,  "px", "Verdana", new Zei.Color.white(), null, building.maxHealth.toString(), align: "right");
  }
  
  static void clear() {
    symbols.clear();
  }
  
  static void reset() {
    activeSymbol = null;
    UISymbol.deselect();
    game.mouse.showCursor();
  }
  
  static UISymbol add(Zei.Vector2 position, Building template, int keyCode) {
    UISymbol symbol = new UISymbol(position, template, keyCode);
    symbols.add(symbol);
    return symbol;
  }
  
  static void checkHovered(evt) {
    Point mousePosition = new Point((evt.client.x - Zei.renderer["gui"].view.getBoundingClientRect().left),
                                     evt.client.y - Zei.renderer["gui"].view.getBoundingClientRect().top);
    for (int i = 0; i < symbols.length; i++) {
      symbols[i].hovered = symbols[i].rectangle.containsPoint(mousePosition);
    }   
  }
  
  // stupid name
  static void dehover() {
    for (int i = 0; i < symbols.length; i++) {
      symbols[i].hovered = false;
    }
  }
  
  static void select(evt) {
    for (int i = 0; i < symbols.length; i++) {
      symbols[i].active = false;
      if (evt.keyCode == symbols[i].keyCode) {
        activeSymbol = symbols[i];
        symbols[i].active = true;
        symbols[i].backgroundRect.fillColor = new Zei.Color(102, 153, 102);
        game.mouse.hideCursor();
      }
    }
  }
  
  static void deselect() {
    for (int i = 0; i < symbols.length; i++) {
      symbols[i].active = false;
      symbols[i].backgroundRect.fillColor = new Zei.Color(68, 85, 68);
    }
    activeSymbol = null;
  }

  static void setActive() {
    for (int i = 0; i < symbols.length; i++) {
      if (symbols[i].hovered) {
        activeSymbol = symbols[i];
        symbols[i].active = true;
        symbols[i].backgroundRect.fillColor = new Zei.Color(34, 51, 34);
      } else {
        symbols[i].active = false;
        symbols[i].backgroundRect.fillColor = new Zei.Color(68, 85, 68);
      }
    }
    
    if (activeSymbol != null) {
      game.mouse.hideCursor();
    }
  }

}