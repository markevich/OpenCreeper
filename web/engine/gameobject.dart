part of zei;

abstract class GameObject {
  update();
  
  static List<GameObject> gameObjects = new List<GameObject>();
  
  static void add(GameObject gameObject) {
    gameObjects.add(gameObject);
    if (debug) {
      print("Added ${gameObject.runtimeType}");
      print("# GameObjects: ${gameObjects.length}");
    }
  }
  
  static void remove(GameObject gameObject) {
    gameObjects.remove(gameObject);
    if (debug) {
      print("Removed ${gameObject.runtimeType}");
      print("# GameObjects: ${gameObjects.length}");
    }
  }
  
  static void updateAll() {
    for (int i = gameObjects.length - 1; i >= 0; i--) {
      gameObjects[i].update();
    }
  }
  
  static void clear() {
    gameObjects.clear();
  }
}