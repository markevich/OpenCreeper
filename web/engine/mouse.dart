part of zei;

class Mouse {
  Vector2 position = new Vector2.empty();
  int buttonPressed = 0;
  Vector2 dragStart;
  String cursor;
  
  Mouse();
  
  void update(MouseEvent evt) {
    position = new Vector2(evt.client.x, evt.client.y); 
  }
   
  void setCursor(String path) {
    cursor = path;
  }
  
  void showCursor() {
    querySelector('body').style.cursor = cursor;
  }
  
  void hideCursor() {
    querySelector('body').style.cursor = "";
  }
  
  String toString() {
    return "$position";
  }
}