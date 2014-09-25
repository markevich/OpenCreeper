part of creeper;

class Smoke extends Zei.GameObject {
  Zei.Sprite sprite;

  Smoke(Zei.Vector2 position) {
    sprite = Zei.Sprite.create("buffer", "smoke", Zei.images["smoke"], position, 128, 128, animated: true, animationFPS: 30, anchor: new Zei.Vector2(0.5, 0.5), scale: new Zei.Vector2(0.5, 0.5));
  }
   
  static void add(Zei.Vector2 position) {
    Smoke smoke = new Smoke(position);
    Zei.GameObject.add(smoke);
  }
  
  void update() {
    if (sprite.frame == 36) {
      Zei.renderer["buffer"].removeDisplayObject(sprite);
      Zei.GameObject.remove(this);
    }
  }
}