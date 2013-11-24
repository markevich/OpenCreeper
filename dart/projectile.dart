part of creeper;

class Projectile {
  Vector targetPosition, speed = new Vector(0, 0);
  bool remove = false;
  Sprite sprite;
  static num baseSpeed = 7;
  static List<Projectile> projectiles = new List<Projectile>();

  Projectile(position, this.targetPosition, rotation) {
    sprite = new Sprite(Layer.PROJECTILE, engine.images["projectile"], position, 16, 16);
    sprite.anchor = new Vector(0.5, 0.5);
    sprite.rotation = rotation;
    engine.renderer["buffer"].addDisplayObject(sprite);
  }
  
  static void clear() {
    projectiles.clear();
  }
  
  static Projectile add(Vector position, Vector targetPosition, num rotation) {
    Projectile projectile = new Projectile(position, targetPosition, rotation);
    projectiles.add(projectile);
    return projectile;
  }
  
  static void update() {
    for (int i = projectiles.length - 1; i >= 0; i--) {
      if (projectiles[i].remove) {
        engine.renderer["buffer"].removeDisplayObject(projectiles[i].sprite);
        projectiles.removeAt(i);
      }
      else
        projectiles[i].move();
    }
  }

  void calculateVector() {
    Vector delta = targetPosition - sprite.position;
    num distance = sprite.position.distanceTo(targetPosition);

    speed.x = (delta.x / distance) * Projectile.baseSpeed * game.speed;
    speed.y = (delta.y / distance) * Projectile.baseSpeed * game.speed;
    
    if (speed.x.abs() > delta.x.abs())
      speed.x = delta.x;
    if (speed.y.abs() > delta.y.abs())
      speed.y = delta.y;
  }

  void move() {
    calculateVector();

    sprite.position += speed;

    if (sprite.position == targetPosition) {
      // if the target is reached smoke and remove
      remove = true;

      Vector targetPositionTiled = targetPosition.real2tiled();
      Smoke.add(targetPosition);

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