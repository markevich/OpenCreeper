part of creeper;

class UISymbol {
  Rectangle rectangle;
  String imageID;
  int size, packets, radius, keyCode;
  bool active = false, hovered = false;
  static UISymbol activeSymbol = null;
  static List<UISymbol> symbols = new List<UISymbol>();

  UISymbol(position, this.imageID, this.keyCode, this.size, this.packets, this.radius) {
    rectangle = new Rectangle(position.x, position.y, 80, 55);
  }
  
  static void clear() {
    symbols.clear();
  }
  
  static void reset() {
    activeSymbol = null;
    UISymbol.deselect();
    engine.canvas["main"].view.style.cursor = "url('images/Normal.cur') 2 2, pointer";
  }
  
  static void add(UISymbol symbol) {
    symbols.add(symbol);
  }
  
  static void checkHovered() {
    for (int i = 0; i < symbols.length; i++) {
      symbols[i].hovered = symbols[i].rectangle.containsPoint(new Point(engine.mouseGUI.x, engine.mouseGUI.y));
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
        engine.canvas["main"].view.style.cursor = "none";
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
      engine.canvas["main"].view.style.cursor = "none";
    }

  }
  
  void draw() {
    CanvasRenderingContext2D context = engine.canvas["gui"].context;
    
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

    context.drawImageScaled(engine.images[imageID], rectangle.left + 24, rectangle.top + 20, 32, 32); // scale buildings to 32x32
    
    // draw cannon gun and ships
    if (imageID == "cannon")
      context.drawImageScaled(engine.images["cannongun"], rectangle.left + 24, rectangle.top + 20, 32, 32);
    if (imageID == "bomber")
      context.drawImageScaled(engine.images["bombership"], rectangle.left + 24, rectangle.top + 20, 32, 32);
    
    context
      ..fillStyle = '#fff'
      ..font = '10px'
      ..textAlign = 'center'
      ..fillText(imageID.substring(0, 1).toUpperCase() + imageID.substring(1), rectangle.left + (rectangle.width / 2), rectangle.top + 15)
      ..textAlign = 'left'
      ..fillText("(${new String.fromCharCode(keyCode)})", rectangle.left + 5, rectangle.top + 50)
      ..textAlign = 'right'
      ..fillText(packets.toString(), rectangle.left + rectangle.width - 5, rectangle.top + 50);
  }

}