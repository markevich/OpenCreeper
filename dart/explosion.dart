part of creeper;

class Explosion {
  Sprite sprite;
  static int counter = 0;

  Explosion(Vector position) {
    sprite = new Sprite(3, engine.images["explosion"], position, 64, 64);
    sprite.animated = true;
    sprite.rotation = engine.randomInt(0, 359);
    sprite.anchor = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addSprite(sprite);
  }
}