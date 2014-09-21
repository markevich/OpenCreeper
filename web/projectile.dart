part of creeper;

class Projectile extends GameObject {
  Vector targetPosition;
  bool remove = false;
  Sprite sprite;
  static num baseSpeed = 7;

  Projectile(position, this.targetPosition, rotation) {
    sprite = new Sprite("buffer", "projectile", Zei.images["projectile"], position, 16, 16, anchor: new Vector(0.5, 0.5), rotation: rotation);
  }
  
  static void add(Vector position, Vector targetPosition, num rotation) {
    Projectile projectile = new Projectile(position, targetPosition, rotation);
    Zei.addGameObject(projectile);
  }
   
  void update() {
    if (!game.paused) {
      if (remove) {
        Zei.renderer["buffer"].removeDisplayObject(sprite);
        Zei.removeGameObject(this);
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
      remove = true;

      Smoke.add(targetPosition);
      
      Vector targetPositionTiled = game.real2tiled(targetPosition);
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {

          Vector tilePosition = targetPositionTiled + new Vector(i, j);

          if (game.world.contains(tilePosition)) {
            if ((tilePosition * game.tileSize + new Vector(8, 8)).distanceTo(targetPosition) <= game.tileSize * 4) {
              Tile tile = game.world.getTile(tilePosition * game.tileSize);
              tile.creep -= 1;
              if (tile.creep < 0)
                tile.creep = 0;
              World.creeperDirty = true;
            }
          }
        }
      }
    }
  }
}