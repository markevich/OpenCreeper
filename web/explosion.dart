part of creeper;

class Explosion extends GameObject {
  Sprite sprite;

  Explosion(Vector position) {
    sprite = new Sprite("buffer", "explosion", game.engine.images["explosion"], position, 64, 64, animated: true, animationFPS: 30, anchor: new Vector(0.5, 0.5), rotation: Engine.randomInt(0, 359));
  }
  
  static void add(Vector position) {
    Explosion explosion = new Explosion(position);
    game.engine.addGameObject(explosion);
  }
  
  void update() {
    if (sprite.frame == 44) {
      game.engine.renderer["buffer"].removeDisplayObject(sprite);
      game.engine.removeGameObject(this);
    }
  }
}