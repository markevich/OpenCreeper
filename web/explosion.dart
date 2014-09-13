part of creeper;

class Explosion extends GameObject {
  Sprite sprite;
  int counter = 0;

  Explosion(Vector position) {
    sprite = new Sprite("buffer", Layer.EXPLOSION, game.engine.images["explosion"], position, 64, 64);
    sprite.animated = true;
    sprite.rotation = Engine.randomInt(0, 359);
    sprite.anchor = new Vector(0.5, 0.5);
  }
  
  static void add(Vector position) {
    Explosion explosion = new Explosion(position);
    game.engine.addGameObject(explosion);
  }
  
  void update() {
    if (!game.paused) {
      counter += 1; // * game.speed;
      if (counter >= 1) {
        counter -= 1;
        if (sprite.frame == 44) {
          game.engine.renderer["buffer"].removeDisplayObject(sprite);
          game.engine.removeGameObject(this);
        }
        else
          sprite.frame++;
      }
    }
  }
}