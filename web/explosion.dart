part of creeper;

class Explosion extends GameObject {
  Sprite sprite;

  Explosion(Vector position) {
    sprite = new Sprite("buffer", "explosion", Zei.images["explosion"], position, 64, 64, animated: true, animationFPS: 30, anchor: new Vector(0.5, 0.5), rotation: Zei.randomInt(0, 359));
  }
  
  static void add(Vector position) {
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