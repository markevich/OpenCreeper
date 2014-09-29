part of creeper;

class Sporetower extends Zei.GameObject {
  Zei.Sprite sprite;
  int sporeCounter = 0;

  Sporetower(position) {
    sprite = Zei.Sprite.create("main", "sporetower", Zei.images["sporetower"], position, 48, 48, anchor: new Zei.Vector2(0.5, 0.5));
    reset();
  }
   
  static Sporetower add(Zei.Vector2 position) {
    Sporetower sporetower = new Sporetower(position);
    return sporetower;
  }
  
  void update() {
    if (!game.paused) {
      sporeCounter -= 1;
      if (sporeCounter <= 0) {
        reset();
        spawn();
      }
    }
  }

  void reset() {
    sporeCounter = Zei.randomInt(7500, 12500);
  }

  void spawn() {
    Building target = null;
    List buildings = [];
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building) {
        buildings.add(building);
      }
    }
    do {
      target = buildings[Zei.randomInt(0, buildings.length - 1)];
    } while (!target.built);
    Spore.add(sprite.position, target.sprite.position);
  }
  
  
  static bool intersect(Rectangle rectangle) { 
    for (var sporetower in Zei.GameObject.gameObjects) {
      if (sporetower is Sporetower) {
        Rectangle sporetowerRect = new Rectangle(sporetower.sprite.position.x - 3 * Tile.size / 2,
                                                 sporetower.sprite.position.y - 3 * Tile.size / 2,
                                                 3 * Tile.size - 1,
                                                 3 * Tile.size - 1);     
        if (rectangle.intersects(sporetowerRect)) {
          return true;
        }
      }
    }
    return false;
  }
  
  void onMouseEvent(evt) {}
  
  void onKeyEvent(evt) {}
}