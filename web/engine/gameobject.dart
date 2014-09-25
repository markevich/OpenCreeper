part of zei;

abstract class GameObject {
  update();
  
  static List<GameObject> gameObjects = new List<GameObject>();
  
  /**
   * Adds a game object.
   */
  static void add(GameObject gameObject) {
    gameObjects.add(gameObject);
    if (debug) {
      print("Added ${gameObject.runtimeType}");
      print("# GameObjects: ${gameObjects.length}");
    }
  }
  
  /**
   * Removes a game object.
   */
  static void remove(GameObject gameObject) {
    gameObjects.remove(gameObject);
    if (debug) {
      print("Removed ${gameObject.runtimeType}");
      print("# GameObjects: ${gameObjects.length}");
    }
  }
  
  /**
   * Updates all game objects based on their update() implementations.
   */
  static void updateAll() {
    for (int i = gameObjects.length - 1; i >= 0; i--) {
      gameObjects[i].update();
    }
  }
  
  /**
   * Clears all game objects.
   */
  static void clear() {
    gameObjects.clear();
  }
}