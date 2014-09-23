part of creeper;

class Explosion extends Zei.GameObject {
  Zei.Sprite sprite;

  Explosion(Zei.Vector2 position) {
    sprite = new Zei.Sprite("buffer", "explosion", Zei.images["explosion"], position, 64, 64, animated: true, animationFPS: 30, anchor: new Zei.Vector2(0.5, 0.5), rotation: Zei.randomInt(0, 359));
  }
  
  static void add(Zei.Vector2 position) {
    Explosion explosion = new Explosion(position);
    Zei.addGameObject(explosion);
  }
  
  void update() {
    if (sprite.frame == 44) {
      Zei.renderer["buffer"].removeDisplayObject(sprite);
      Zei.removeGameObject(this);
    }
  }
}