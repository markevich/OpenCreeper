part of creeper;

class Sporetower extends GameObject {
  Sprite sprite;
  int sporeCounter = 0;

  Sporetower(position) {
    sprite = new Sprite("buffer", "sporetower", Zei.images["sporetower"], position, 48, 48, anchor: new Vector(0.5, 0.5));
    reset();
  }
   
  static Sporetower add(Vector position) {
    Sporetower sporetower = new Sporetower(position);
    Zei.addGameObject(sporetower);
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
    for (var building in Zei.gameObjects) {
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
    for (var sporetower in Zei.gameObjects) {
      if (sporetower is Sporetower) {
        Rectangle sporetowerRect = new Rectangle(sporetower.sprite.position.x - 3 * game.tileSize / 2,
                                                 sporetower.sprite.position.y - 3 * game.tileSize / 2,
                                                 3 * game.tileSize - 1,
                                                 3 * game.tileSize - 1);     
        if (rectangle.intersects(sporetowerRect)) {
          return true;
        }
      }
    }
    return false;
  }
}