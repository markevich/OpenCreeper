part of creeper;

class Shell extends GameObject {
  Vector2 targetPosition;
  bool remove = false;
  int trailCounter = 0;
  Sprite sprite;
  static final num baseSpeed = 1.5;

  Shell(position, this.targetPosition) {
    sprite = new Sprite("buffer", "shell", Zei.images["shell"], position, 16, 16, anchor: new Vector2(0.5, 0.5));
  }
  
  static Shell add(Vector2 position, Vector2 targetPosition) {
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
      Smoke.add(new Vector2(sprite.position.x, sprite.position.y - 16));
    }

    sprite.rotate(20);
    sprite.position += ((targetPosition - sprite.position).normalize() * Shell.baseSpeed * game.speed).clamp(targetPosition - sprite.position);

    // if the target is reached explode and remove
    if (sprite.position == targetPosition) {
      remove = true;

      Vector2 targetPositionTiled = Tile.position(targetPosition);
      Explosion.add(targetPosition);
      Zei.playSound("explosion", targetPosition, game.scroll, game.zoom);

      for (int i = -4; i <= 4; i++) {
        for (int j = -4; j <= 4; j++) {
          
          Vector2 tilePosition = targetPositionTiled + new Vector2(i, j);
          
          if (game.world.contains(tilePosition)) {
            if ((tilePosition * Tile.size + new Vector2(8, 8)).distanceTo(targetPosition) <= Tile.size * 4) {
              Tile tile = game.world.getTile(tilePosition * Tile.size);
              
              tile.creep -= 10;
              tile.creep = Zei.clamp(tile.creep, 0, 1000);
              World.creeperDirty = true;
            }
          }
        }
      }

    }
  }
}