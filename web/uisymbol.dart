part of creeper;

class UISymbol {
  Rectangle rectangle;
  int keyCode;
  bool active = false, hovered = false;
  Building building;
  static UISymbol activeSymbol = null;
  static List<UISymbol> symbols = new List<UISymbol>();

  UISymbol(position, this.building, this.keyCode) {
    rectangle = new Rectangle(position.x, position.y, 80, 55);
  }
  
  static void clear() {
    symbols.clear();
  }
  
  static void reset() {
    activeSymbol = null;
    UISymbol.deselect();
    Zei.renderer["main"].view.style.cursor = "url('images/Normal.cur') 2 2, pointer";
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
        Zei.renderer["main"].view.style.cursor = "none";
      }
    }
  }
  
  static void deselect() {
    for (int i = 0; i < symbols.length; i++) {
      symbols[i].active = false;
    }
    activeSymbol = null;
  }

  static void setActive() {
    for (int i = 0; i < symbols.length; i++) {
      if (symbols[i].hovered) {
        activeSymbol = symbols[i];
        symbols[i].active = true;
      } else {
        symbols[i].active = false;
      }
    }
    

    if (activeSymbol != null) {
      Zei.renderer["main"].view.style.cursor = "none";
    }

  }
  
  void draw() {
    CanvasRenderingContext2D context = Zei.renderer["gui"].context;
    
    if (active) {
      context.fillStyle = "#696";
    } else {
      if (hovered) {
        context.fillStyle = "#232";
      } else {
        context.fillStyle = "#454";
      }
    }
    context.fillRect(rectangle.left + 1, rectangle.top + 1, rectangle.width, rectangle.height);

    context.drawImageScaled(Zei.images[building.type], rectangle.left + 24, rectangle.top + 20, 32, 32); // scale buildings to 32x32
    
    // draw cannon gun and ships
    if (building.type == "cannon")
      context.drawImageScaled(Zei.images["cannongun"], rectangle.left + 24, rectangle.top + 20, 32, 32);
    if (building.type == "bomber")
      context.drawImageScaled(Zei.images["bombership"], rectangle.left + 24, rectangle.top + 20, 32, 32);
    
    context
      ..fillStyle = '#fff'
      ..font = '10px'
      ..textAlign = 'center'
      ..fillText(building.type.substring(0, 1).toUpperCase() + building.type.substring(1), rectangle.left + (rectangle.width / 2), rectangle.top + 15)
      ..textAlign = 'left'
      ..fillText("(${new String.fromCharCode(keyCode)})", rectangle.left + 5, rectangle.top + 50)
      ..textAlign = 'right'
      ..fillText(building.maxHealth.toString(), rectangle.left + rectangle.width - 5, rectangle.top + 50);
  }

}