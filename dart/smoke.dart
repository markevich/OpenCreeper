part of creeper;

class Smoke {
  Sprite sprite;
  static int counter = 0;
  static List<Smoke> smokes = new List<Smoke>();

  Smoke(Vector position) {
    sprite = new Sprite(Layer.SMOKE, engine.images["smoke"], position, 128, 128);
    sprite.animated = true;
    sprite.anchor = new Vector(0.5, 0.5);
    sprite.scale = new Vector(0.5, 0.5);
    engine.renderer["buffer"].addDisplayObject(sprite);
  }
  
  static void clear() {
    smokes.clear();
    counter = 0;
  }
  
  static Smoke add(Vector position) {
    Smoke smoke = new Smoke(position);
    smokes.add(smoke);
    return smoke;
  }
  
  static void update() {
    counter++;
    if (counter > 3) {
      counter = 0;
      for (int i = smokes.length - 1; i >= 0; i--) {
        if (smokes[i].sprite.frame == 36) {
          engine.renderer["buffer"].removeDisplayObject(smokes[i].sprite);
          smokes.removeAt(i);
        }
        else {
          smokes[i].sprite.frame++;
        }
      }
    }
  }
}