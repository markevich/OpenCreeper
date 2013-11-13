part of creeper;

class Smoke {
  Sprite sprite;
  static int counter = 0;

  Smoke(Vector position) {
    sprite = new Sprite(1, engine.images["smoke"], position, 128, 128);
    sprite.animated = true;
    sprite.anchor = new Vector(0.5, 0.5);
    sprite.scale = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addSprite(sprite);
  }
}