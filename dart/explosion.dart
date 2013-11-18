part of creeper;

class Explosion {
  Sprite sprite;
  static int counter = 0;
  static List<Explosion> explosions = new List<Explosion>();

  Explosion(Vector position) {
    sprite = new Sprite(3, engine.images["explosion"], position, 64, 64);
    sprite.animated = true;
    sprite.rotation = engine.randomInt(0, 359);
    sprite.anchor = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addDisplayObject(sprite);
  }
  
  static void clear() {
    explosions.clear();
    counter = 0;
  }
  
  static Explosion add(Vector position) {
    Explosion explosion = new Explosion(position);
    explosions.add(explosion);
    return explosion;
  }
  
  static void update() {
    counter++;
    if (counter == 1) {
      counter = 0;
      for (int i = explosions.length - 1; i >= 0; i--) {
        if (explosions[i].sprite.frame == 44) {
          engine.canvas["buffer"].removeDisplayObject(explosions[i].sprite);
          explosions.removeAt(i);
        }
        else
          explosions[i].sprite.frame++;
      }
    }
  }
}