part of zei;

class Scroller {
  Renderer renderer;
  Vector2 position, mouseScrolling, keyScrolling, min = new Vector2.empty(), max = new Vector2.empty();
  bool hasChanged = false;
  int scrollSize = 1;

  Scroller(this.renderer, this.scrollSize, this.min, this.max) {
    position = new Vector2.empty();
    mouseScrolling = new Vector2.empty();
    keyScrolling = new Vector2.empty();
  }

  void update() {
    hasChanged = false;

    // check mouse scrolling only if the mouse is enabled
    if (mouse != null) {
      mouseScrolling = new Vector2.empty();

      if (mouse.position.x == renderer.left)
        mouseScrolling.x = -1;
      else if (mouse.position.x == renderer.right - 1)
        mouseScrolling.x = 1;

      if (mouse.position.y == renderer.top)
        mouseScrolling.y = -1;
      else if (mouse.position.y == renderer.bottom - 1)
        mouseScrolling.y = 1;
    }

    if (mouseScrolling.x != 0 || mouseScrolling.y != 0 || keyScrolling.x != 0 || keyScrolling.y != 0) {
      position.x = clamp(position.x += (mouseScrolling.x + keyScrolling.x), min.x, max.x);
      position.y = clamp(position.y += (mouseScrolling.y + keyScrolling.y), min.y, max.y);
      hasChanged = true;

      setPosition(position);
    }
  }

  void setPosition(Vector2 pos) {
    position = pos;
    renderer.updatePosition(position * scrollSize);
  }

  void onMouseEvent(evt) {}

  void onKeyEvent(evt, String type) {
    if (type == "down") {
      if (evt.keyCode == KeyCode.LEFT)
        keyScrolling.x = -1;
      if (evt.keyCode == KeyCode.UP)
        keyScrolling.y = -1;
      if (evt.keyCode == KeyCode.RIGHT)
        keyScrolling.x = 1;
      if (evt.keyCode == KeyCode.DOWN)
        keyScrolling.y = 1;
    } else if (type == "up") {
      if (evt.keyCode == KeyCode.LEFT || evt.keyCode == KeyCode.RIGHT)
        keyScrolling.x = 0;
      if (evt.keyCode == KeyCode.UP || evt.keyCode == KeyCode.DOWN)
        keyScrolling.y = 0;
    }
  }

}