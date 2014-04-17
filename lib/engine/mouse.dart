part of zengine;

class Mouse {
  Vector position = new Vector.empty();
  bool overCanvas = true;
  int buttonPressed = 0;
  Vector dragStart;
  Renderer renderer;
  
  Mouse(this.renderer);
  
  void update(MouseEvent evt) {
    position.x = (evt.client.x - renderer.view.getBoundingClientRect().left).toInt();
    position.y = (evt.client.y - renderer.view.getBoundingClientRect().top).toInt();
  }
  
  String toString() {
    return "$position";
  }
}