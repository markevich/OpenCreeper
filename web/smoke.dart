part of creeper;

class Smoke extends Zei.GameObject {
  Zei.Sprite sprite;

  Smoke(Zei.Vector2 position) {
    sprite = Zei.Sprite.create("main", "smoke", Zei.images["smoke"], position, 128, 128, animated: true, animationFPS: 30, anchor: new Zei.Vector2(0.5, 0.5), scale: new Zei.Vector2(0.5, 0.5));
  }

  static void add(Zei.Vector2 position) {
    Smoke smoke = new Smoke(position);
  }

  void update() {
    if (sprite.frame == 36) {
      Zei.renderer["main"].removeDisplayObject(sprite);
      Zei.GameObject.remove(this);
    }
  }

  void onMouseEvent(evt) {}

  void onKeyEvent(evt, String type) {}
}