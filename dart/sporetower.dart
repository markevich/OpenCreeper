part of creeper;

class Sporetower {
  Sprite sprite;
  int sporeCounter = 0;
  static List<Sporetower> sporetowers = new List<Sporetower>();

  Sporetower(position) {
    sprite = new Sprite(0, engine.images["sporetower"], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addDisplayObject(sprite);
    reset();
  }
  
  static void clear() {
    sporetowers.clear();
  }
  
  static void add(Sporetower sporetower) {
    sporetowers.add(sporetower);
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
    Spore.add(new Spore(sprite.position, target.sprite.position));
  }
}