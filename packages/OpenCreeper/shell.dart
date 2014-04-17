part of creeper;

class Shell extends GameObject {
  Vector targetPosition, speed = new Vector(0, 0);
  bool remove = false;
  int trailCounter = 0;
  Sprite sprite;
  static final num baseSpeed = 1.5;

  Shell(position, this.targetPosition) {
    sprite = new Sprite(Layer.SHELL, game.engine.images["shell"], position, 16, 16);
    sprite.anchor = new Vector(0.5, 0.5);  
    game.engine.renderer["buffer"].addDisplayObject(sprite);
  }
  
  static Shell add(Vector position, Vector targetPosition) {
    Shell shell = new Shell(position, targetPosition);
    game.engine.gameObjects.add(shell);
    return shell;
  }
  
  void update() {
    if (remove) {
      game.engine.renderer["buffer"].removeDisplayObject(sprite);
      game.engine.gameObjects.remove(this);
    }
    else
      move();
  }

  void move() {
    trailCounter++;
    if (trailCounter == 10) {
      trailCounter = 0;
      Smoke.add(new Vector(sprite.position.x, sprite.position.y - 16));
    }

    sprite.rotation += 20;
    if (sprite.rotation > 359)
      sprite.rotation -= 359;

    sprite.position += game.engine.calculateVelocity(sprite.position, targetPosition, Shell.baseSpeed * game.speed);

    // if the target is reached explode and remove
    if (sprite.position == targetPosition) {
      remove = true;

      Vector targetPositionTiled = game.real2tiled(targetPosition);
      Explosion.add(targetPosition);
      game.engine.playSound("explosion", targetPosition, game.scroll, game.zoom);

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