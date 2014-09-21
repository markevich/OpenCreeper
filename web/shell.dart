part of creeper;

class Shell extends GameObject {
  Vector targetPosition;
  bool remove = false;
  int trailCounter = 0;
  Sprite sprite;
  static final num baseSpeed = 1.5;

  Shell(position, this.targetPosition) {
    sprite = new Sprite("buffer", "shell", Zei.images["shell"], position, 16, 16, anchor: new Vector(0.5, 0.5));
  }
  
  static Shell add(Vector position, Vector targetPosition) {
    Shell shell = new Shell(position, targetPosition);
    Zei.addGameObject(shell);
    return shell;
  }
  
  void update() {
    if (!game.paused) {
      if (remove) {
        Zei.renderer["buffer"].removeDisplayObject(sprite);
        Zei.removeGameObject(this);
      }
      else
        move();
    }
  }

  void move() {
    trailCounter++;
    if (trailCounter == 10) {
      trailCounter = 0;
      Smoke.add(new Vector(sprite.position.x, sprite.position.y - 16));
    }

    sprite.rotate(20);
    sprite.position += ((targetPosition - sprite.position).normalize() * Shell.baseSpeed * game.speed).clamp(targetPosition - sprite.position);

    // if the target is reached explode and remove
    if (sprite.position == targetPosition) {
      remove = true;

      Vector targetPositionTiled = game.real2tiled(targetPosition);
      Explosion.add(targetPosition);
      Zei.playSound("explosion", targetPosition, game.scroll, game.zoom);

      for (int i = -4; i <= 4; i++) {
        for (int j = -4; j <= 4; j++) {
          
          Vector tilePosition = targetPositionTiled + new Vector(i, j);
          
          if (game.world.contains(tilePosition)) {
            if ((tilePosition * game.tileSize + new Vector(8, 8)).distanceTo(targetPosition) <= game.tileSize * 4) {
              Tile tile = game.world.getTile(tilePosition * game.tileSize);
              
              tile.creep -= 10;
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