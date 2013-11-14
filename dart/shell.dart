part of creeper;

class Shell {
  Vector targetPosition, speed = new Vector(0, 0);
  bool remove = false;
  int trailCounter = 0;
  Sprite sprite;
  static final num baseSpeed = 1.5;

  Shell(position, this.targetPosition) {
    sprite = new Sprite(2, engine.images["shell"], position, 16, 16);
    sprite.anchor = new Vector(0.5, 0.5);  
    engine.canvas["buffer"].addDisplayObject(sprite);
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
      Smoke.add(new Smoke(new Vector(sprite.position.x, sprite.position.y - 16)));
    }

    sprite.rotation += 20;
    if (sprite.rotation > 359)
      sprite.rotation -= 359;

    sprite.position += speed;

    if (sprite.position.x > targetPosition.x - 2 && sprite.position.x < targetPosition.x + 2 && sprite.position.y > targetPosition.y - 2 && sprite.position.y < targetPosition.y + 2) {
      // if the target is reached explode and remove
      remove = true;

      Explosion.add(new Explosion(targetPosition));
      engine.playSound("explosion", targetPosition.real2tiled());

      for (int i = (targetPosition.x / game.tileSize).floor() - 4; i < (targetPosition.x / game.tileSize).floor() + 5; i++) {
        for (int j = (targetPosition.y / game.tileSize).floor() - 4; j < (targetPosition.y / game.tileSize).floor() + 5; j++) {
          if (game.world.contains(new Vector(i, j))) {
            num distance = pow((i * game.tileSize + game.tileSize / 2) - targetPosition.x, 2) + pow((j * game.tileSize + game.tileSize / 2) - targetPosition.y, 2);
            if (distance < pow(game.tileSize * 4, 2)) {
              game.world.tiles[i][j].creep -= 10;
              if (game.world.tiles[i][j].creep < 0)
                game.world.tiles[i][j].creep = 0;
              game.world.tiles[i][j].newcreep -= 10;
              if (game.world.tiles[i][j].newcreep < 0)
                game.world.tiles[i][j].newcreep = 0;
            }
          }
        }
      }

    }
  }
}