part of creeper;

class Mouse {
  Vector position = new Vector.empty();
  bool overCanvas = true;
  int buttonPressed = 0;
  Vector dragStart;
  
  Mouse();
  
  void update(MouseEvent evt) {
    position.x = (evt.client.x - game.engine.renderer["main"].view.getBoundingClientRect().left).toInt();
    position.y = (evt.client.y - game.engine.renderer["main"].view.getBoundingClientRect().top).toInt();
    if (game != null) {
      game.oldHoveredTile = game.hoveredTile;
      game.hoveredTile = new Vector(
            ((position.x - game.engine.renderer["main"].view.width / 2) / (game.tileSize * game.zoom)).floor() + game.scroll.x,
            ((position.y - game.engine.renderer["main"].view.height / 2) / (game.tileSize * game.zoom)).floor() + game.scroll.y);
      game.updateVariousInfo();   
    }
  }
  
  String toString() {
    return "$position";
  }
}