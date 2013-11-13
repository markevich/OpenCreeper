part of creeper;

class Emitter {
  Sprite sprite;
  int strength;
  Building analyzer;
  static int counter;

  Emitter(position, this.strength) {
    sprite = new Sprite(0, engine.images["emitter"], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addSprite(sprite);
  }

  void spawn() {
// only spawn creeper if not targeted by an analyzer
    if (analyzer == null)
      game.world.getTile(sprite.position + new Vector(1, 1)).creep += strength; //game.world.tiles[sprite.position.x + 1][sprite.position.y + 1].creep += strength;
  }
}