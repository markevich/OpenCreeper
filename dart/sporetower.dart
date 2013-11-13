part of creeper;

class Sporetower {
  Sprite sprite;
  int sporeCounter = 0;

  Sporetower(position) {
    sprite = new Sprite(0, engine.images["sporetower"], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addSprite(sprite);
    reset();
  }

  void reset() {
    sporeCounter = engine.randomInt(7500, 12500);
  }

  void update() {
    sporeCounter -= 1;
    if (sporeCounter <= 0) {
      reset();
      spawn();
    }
  }

  void spawn() {
    Building target = null;
    do {
      target = game.buildings[engine.randomInt(0, game.buildings.length - 1)];
    } while (!target.built);
    game.spores.add(new Spore(sprite.position, target.getCenter()));
  }
}