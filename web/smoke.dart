part of creeper;

class Smoke extends GameObject {
  Sprite sprite;

  Smoke(Vector position) {
    sprite = new Sprite("buffer", "smoke", Zei.images["smoke"], position, 128, 128, animated: true, animationFPS: 30, anchor: new Vector(0.5, 0.5), scale: new Vector(0.5, 0.5));
  }
   
  static void add(Vector position) {
    Smoke smoke = new Smoke(position);
    Zei.addGameObject(smoke);
  }
  
  void update() {
    if (sprite.frame == 36) {
      Zei.renderer["buffer"].removeDisplayObject(sprite);
      Zei.removeGameObject(this);
    }
  }
}