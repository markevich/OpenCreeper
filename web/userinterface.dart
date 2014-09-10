part of creeper;

class UserInterface {
  Renderer renderer;
  
  UserInterface(this.renderer) {
    setupSymbols(); 
  }
  
  void setupSymbols() {
    UISymbol.add(new Vector(0, 0), new Building.template("cannon"), KeyCode.Q);
    UISymbol.add(new Vector(81, 0), new Building.template("collector"), KeyCode.W);
    UISymbol.add(new Vector(2 * 81, 0), new Building.template("reactor"), KeyCode.E);
    UISymbol.add(new Vector(3 * 81, 0), new Building.template("storage"), KeyCode.R);
    UISymbol.add(new Vector(4 * 81, 0), new Building.template("shield"), KeyCode.T);
    UISymbol.add(new Vector(5 * 81, 0), new Building.template("analyzer"), KeyCode.Z);
    UISymbol.add(new Vector(0, 56), new Building.template("relay"), KeyCode.A);
    UISymbol.add(new Vector(81, 56), new Building.template("mortar"), KeyCode.S);
    UISymbol.add(new Vector(2 * 81, 56), new Building.template("beam"), KeyCode.D);
    UISymbol.add(new Vector(3 * 81, 56), new Building.template("bomber"), KeyCode.F);
    UISymbol.add(new Vector(4 * 81, 56), new Building.template("terp"), KeyCode.G);
  }
  
  /**
   * Draws the GUI with symbols, height and creep meter.
   */
  void draw() {
    CanvasRenderingContext2D context = renderer.context;
    
    renderer.clear();
    for (int i = 0; i < UISymbol.symbols.length; i++) {
      UISymbol.symbols[i].draw();
    }

    if (game.world.contains(game.hoveredTile)) {

      num total = game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep;

      // draw height and creep meter
      context
        ..fillStyle = '#fff'
        ..font = '9px'
        ..textAlign = 'right'
        ..strokeStyle = '#fff'
        ..lineWidth = 1
        ..fillStyle = "rgba(205, 133, 63, 1)"
        ..fillRect(555, 110, 25, -game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height * 10 - 10)
        ..fillStyle = "rgba(100, 150, 255, 1)"
        ..fillRect(555, 110 - game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height * 10 - 10, 25, -total * 10)
        ..fillStyle = "rgba(255, 255, 255, 1)";
      for (int i = 1; i < 11; i++) {
        context
          ..fillText(i.toString(), 550, 120 - i * 10)
          ..beginPath()
          ..moveTo(555, 120 - i * 10)
          ..lineTo(580, 120 - i * 10)
          ..stroke();
      }
      context.textAlign = 'left';
      context.fillText(total.toStringAsFixed(2), 605, 10);
    }
  }
  
}