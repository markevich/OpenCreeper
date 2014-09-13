part of creeper;

class Smoke extends GameObject {
  Sprite sprite;
  int counter = 0;

  Smoke(Vector position) {
    sprite = new Sprite("buffer", Layer.SMOKE, game.engine.images["smoke"], position, 128, 128);
    sprite.animated = true;
    sprite.anchor = new Vector(0.5, 0.5);
    sprite.scale = new Vector(0.5, 0.5);
  }
   
  static void add(Vector position) {
    Smoke smoke = new Smoke(position);
    game.engine.addGameObject(smoke);
  }
  
  void update() {
    if (!game.paused) {
      counter += 1; // * game.speed;
      if (counter >= 3) {
        counter -= 3;
  
        if (sprite.frame == 36) {
          game.engine.renderer["buffer"].removeDisplayObject(sprite);
          game.engine.removeGameObject(this);
        }
        else {
          sprite.frame++;
        }
      }
    }
  }
}