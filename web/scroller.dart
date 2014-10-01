part of creeper;

class Scroller extends Zei.GameObject {
  Zei.Vector2 scroll = new Zei.Vector2.empty(), mouseScrolling = new Zei.Vector2.empty(), keyScrolling = new Zei.Vector2.empty();

  Scroller() {
    document
      ..onKeyDown.listen((event) => onKeyDown(event))
      ..onKeyUp.listen((event) => onKeyUp(event));
  }

  void update() {
    mouseScrolling = new Zei.Vector2.empty();

    if (Zei.mouse.position.x == 0) mouseScrolling.x = -1;
      else if (Zei.mouse.position.x == Zei.renderer["main"].view.width - 1) mouseScrolling.x = 1;

    if (Zei.mouse.position.y == 0) mouseScrolling.y = -1;
      else if (Zei.mouse.position.y == Zei.renderer["main"].view.height - 1) mouseScrolling.y = 1;

    // scroll left or right
    scroll.x += mouseScrolling.x + keyScrolling.x;
    if (scroll.x < 0) scroll.x = 0;
    else if (scroll.x > game.world.size.x) scroll.x = game.world.size.x;

    // scroll up or down
    scroll.y += mouseScrolling.y + keyScrolling.y;
    if (scroll.y < 0) scroll.y = 0;
    else if (scroll.y > game.world.size.y) scroll.y = game.world.size.y;

    if (mouseScrolling.x != 0 || mouseScrolling.y != 0 || keyScrolling.x != 0 || keyScrolling.y != 0) {
      Zei.renderer["main"].updatePosition(new Zei.Vector2(scroll.x * Tile.size, scroll.y * Tile.size));
      game.world.copyTiles();
      game.world.drawCollection();
      World.creeperDirty = true;
    }
  }

  void onKeyDown(KeyboardEvent evt) {
    if (evt.keyCode == KeyCode.LEFT)
      keyScrolling.x = -1;
    if (evt.keyCode == KeyCode.UP)
      keyScrolling.y = -1;
    if (evt.keyCode == KeyCode.RIGHT)
      keyScrolling.x = 1;
    if (evt.keyCode == KeyCode.DOWN)
      keyScrolling.y = 1;
  }

  void onKeyUp(KeyboardEvent evt) {
    if (evt.keyCode == KeyCode.LEFT || evt.keyCode == KeyCode.RIGHT)
      keyScrolling.x = 0;
    if (evt.keyCode == KeyCode.UP || evt.keyCode == KeyCode.DOWN)
      keyScrolling.y = 0;
  }

  void onMouseEvent(evt) {}

  void onKeyEvent(evt, String type) {}

}