part of creeper;

class UserInterface extends Zei.GameObject {
  Zei.Renderer renderer;
  Zei.Rect tileHeight, creeperHeight;
  Zei.Text totalCreeper;
  
  UserInterface(this.renderer) {
    setupSymbols(); 
    tileHeight = Zei.Rect.create("gui", "default", new Zei.Vector2(555, 110), new Zei.Vector2(25, 0), 0, new Zei.Color(205, 133, 63), null);
    creeperHeight = Zei.Rect.create("gui", "default", new Zei.Vector2(555, 110), new Zei.Vector2(25, 0), 0, new Zei.Color(100, 150, 255), null);
    totalCreeper = Zei.Text.create("gui", "default", new Zei.Vector2(605, 10), 9, "px", "Verdana" , new Zei.Color.white(), null, "0.00");
    
    for (var i = 0; i < 10; i++) {
      Zei.Text.create("gui", "default", new Zei.Vector2(550, 110 - i * 10), 9, "px", "Verdana" , new Zei.Color.white(), null, (i + 1).toString(), align: "right");
      Zei.Line.create("gui", "default", new Zei.Vector2(555, 110 - i * 10), new Zei.Vector2(580, 110 - i * 10), 1, new Zei.Color.white());    
    }
    
    Zei.GameObject.add(this);
  }
  
  void setupSymbols() {
    UISymbol.add(new Zei.Vector2(0, 0), new Building.template("cannon"), KeyCode.Q);
    UISymbol.add(new Zei.Vector2(81, 0), new Building.template("collector"), KeyCode.W);
    UISymbol.add(new Zei.Vector2(2 * 81, 0), new Building.template("reactor"), KeyCode.E);
    UISymbol.add(new Zei.Vector2(3 * 81, 0), new Building.template("storage"), KeyCode.R);
    UISymbol.add(new Zei.Vector2(4 * 81, 0), new Building.template("shield"), KeyCode.T);
    UISymbol.add(new Zei.Vector2(5 * 81, 0), new Building.template("analyzer"), KeyCode.Z);
    UISymbol.add(new Zei.Vector2(0, 56), new Building.template("relay"), KeyCode.A);
    UISymbol.add(new Zei.Vector2(81, 56), new Building.template("mortar"), KeyCode.S);
    UISymbol.add(new Zei.Vector2(2 * 81, 56), new Building.template("beam"), KeyCode.D);
    UISymbol.add(new Zei.Vector2(3 * 81, 56), new Building.template("bomber"), KeyCode.F);
    UISymbol.add(new Zei.Vector2(4 * 81, 56), new Building.template("terp"), KeyCode.G);
  }
  
  void update() {      
    if (game.world.contains(game.hoveredTile)) {
      tileHeight.position.y = 110 - game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height * 10;
      tileHeight.size.y = game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height * 10;
      
      creeperHeight.position.y = 110 - game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height * 10 - game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep * 10;
      creeperHeight.size.y = game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep * 10;
      
      totalCreeper.text = game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep.toStringAsFixed(2);
    }
  }
  
}