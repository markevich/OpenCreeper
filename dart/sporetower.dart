part of creeper;

class Sporetower {
  Sprite sprite;
  int sporeCounter = 0;
  static List<Sporetower> sporetowers = new List<Sporetower>();

  Sporetower(position) {
    sprite = new Sprite(Layer.SPORETOWER, engine.images["sporetower"], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    engine.renderer["buffer"].addDisplayObject(sprite);
    reset();
  }
  
  static void clear() {
    sporetowers.clear();
  }
  
  static Sporetower add(Vector position) {
    Sporetower sporetower = new Sporetower(position);
    sporetowers.add(sporetower);
    return sporetower;
  }
  
  static void update() {
    for (int i = sporetowers.length - 1; i >= 0; i--) {
      sporetowers[i].sporeCounter -= 1;
      if (sporetowers[i].sporeCounter <= 0) {
        sporetowers[i].reset();
        sporetowers[i].spawn();
      }
    }
  }

  void reset() {
    sporeCounter = engine.randomInt(7500, 12500);
  }

  void spawn() {
    Building target = null;
    do {
      target = Building.buildings[engine.randomInt(0, Building.buildings.length - 1)];
    } while (!target.built);
    Spore.add(sprite.position, target.sprite.position);
  }
  
  
  static bool collision(Rectangle rectangle) { 
    for (int i = 0; i < sporetowers.length; i++) {
      Rectangle sporetowerRect = new Rectangle(sporetowers[i].sprite.position.x - 3 * game.tileSize / 2,
                                               sporetowers[i].sprite.position.y - 3 * game.tileSize / 2,
                                               3 * game.tileSize - 1,
                                               3 * game.tileSize - 1);     
      if (rectangle.intersects(sporetowerRect)) {
        return true;
      }
    }
    return false;
  }
}