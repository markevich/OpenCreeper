part of creeper;

class Shell {
  Vector targetPosition, speed = new Vector(0, 0);
  bool remove = false;
  int trailCounter = 0;
  Sprite sprite;
  static final num baseSpeed = 1.5;
  static List<Shell> shells = new List<Shell>();

  Shell(position, this.targetPosition) {
    sprite = new Sprite(Layer.SHELL, engine.images["shell"], position, 16, 16);
    sprite.anchor = new Vector(0.5, 0.5);  
    engine.renderer["buffer"].addDisplayObject(sprite);
  }
  
  static void clear() {
    shells.clear();
  }
  
  static Shell add(Vector position, Vector targetPosition) {
    Shell shell = new Shell(position, targetPosition);
    shells.add(shell);
    return shell;
  }
  
  static void update() {
    for (int i = shells.length - 1; i >= 0; i--) {
      if (shells[i].remove) {
        engine.renderer["buffer"].removeDisplayObject(shells[i].sprite);
        shells.removeAt(i);
      }
      else
        shells[i].move();
    }
  }

  void calculateVector() {
    Vector delta = targetPosition - sprite.position;
    num distance = sprite.position.distanceTo(targetPosition);

    speed.x = (delta.x / distance) * Shell.baseSpeed * game.speed;
    speed.y = (delta.y / distance) * Shell.baseSpeed * game.speed;

    if (speed.x.abs() > delta.x.abs())
      speed.x = delta.x;
    if (speed.y.abs() > delta.y.abs())
      speed.y = delta.y;
  }

  void move() {
    calculateVector();

    trailCounter++;
    if (trailCounter == 10) {
      trailCounter = 0;
      Smoke.add(new Vector(sprite.position.x, sprite.position.y - 16));
    }

    sprite.rotation += 20;
    if (sprite.rotation > 359)
      sprite.rotation -= 359;

    sprite.position += speed;

    // if the target is reached explode and remove
    if (sprite.position == targetPosition) {
      remove = true;

      Vector targetPositionTiled = targetPosition.real2tiled();
      Explosion.add(targetPosition);
      engine.playSound("explosion", targetPositionTiled);

      for (int i = -4; i <= 4; i++) {
        for (int j = -4; j <= 4; j++) {
          
          Vector tilePosition = targetPositionTiled + new Vector(i, j);
          
          if (game.world.contains(tilePosition)) {
            if ((tilePosition * game.tileSize + new Vector(8, 8)).distanceTo(targetPosition) <= game.tileSize * 4) {
              Tile tile = game.world.getTile(tilePosition * game.tileSize);
              
              tile.creep -= 10;
              if (tile.creep < 0)
                tile.creep = 0;
              tile.newcreep -= 10;
              if (tile.newcreep < 0)
                tile.newcreep = 0;
              game.creeperDirty = true;
            }
          }
        }
      }

    }
  }
}