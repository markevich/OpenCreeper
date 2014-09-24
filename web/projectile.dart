part of creeper;

class Projectile extends Zei.GameObject {
  Zei.Vector2 targetPosition;
  bool flagRemove = false;
  Zei.Sprite sprite;
  static num baseSpeed = 7;

  Projectile(position, this.targetPosition, rotation) {
    sprite = new Zei.Sprite("buffer", "projectile", Zei.images["projectile"], position, 16, 16, anchor: new Zei.Vector2(0.5, 0.5), rotation: rotation);
  }
  
  static void add(Zei.Vector2 position, Zei.Vector2 targetPosition, num rotation) {
    Projectile projectile = new Projectile(position, targetPosition, rotation);
    Zei.GameObject.add(projectile);
  }
   
  void update() {
    if (!game.paused) {
      if (flagRemove) {
        Zei.renderer["buffer"].removeDisplayObject(sprite);
        Zei.GameObject.remove(this);
      }
      else {
        move();
      }
    }
  }

  void move() {
    sprite.position += ((targetPosition - sprite.position).normalize() * Projectile.baseSpeed * game.speed).clamp(targetPosition - sprite.position);

    if (sprite.position == targetPosition) {
      // if the target is reached smoke and remove
      flagRemove = true;

      Smoke.add(targetPosition);
      
      Zei.Vector2 targetPositionTiled = Tile.position(targetPosition);
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {

          Zei.Vector2 tilePosition = targetPositionTiled + new Zei.Vector2(i, j);

          if (game.world.contains(tilePosition)) {
            if ((tilePosition * Tile.size + new Zei.Vector2(8, 8)).distanceTo(targetPosition) <= Tile.size * 4) {
              Tile tile = game.world.getTile(tilePosition * Tile.size);
              tile.creep -= 1;
              tile.creep = Zei.clamp(tile.creep, 0, 1000);
              World.creeperDirty = true;
            }
          }
        }
      }
    }
  }
}