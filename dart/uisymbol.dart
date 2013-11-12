part of creeper;

class UISymbol {
  Rectangle rectangle;
  String imageID;
  int size, packets, radius, keyCode;
  bool active = false, hovered = false;

  UISymbol(position, this.imageID, this.keyCode, this.size, this.packets, this.radius) {
    rectangle = new Rectangle(position.x, position.y, 80, 55);
  }

  void checkHovered() {
    hovered = rectangle.containsPoint(new Point(engine.mouseGUI.x, engine.mouseGUI.y));
  }

  void setActive() {
    if (hovered) {
      game.activeSymbol = (rectangle.left ~/ 81) + (rectangle.top ~/ 56) * 6;
      active = true;
    } else {
      active = false;
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