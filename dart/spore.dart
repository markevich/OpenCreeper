part of creeper;

class Spore {
  Vector targetPosition, speed = new Vector(0, 0);
  bool remove = false;
  num health = 100;
  int trailCounter = 0;
  Sprite sprite;
  static final int baseSpeed = 1;

  Spore(position, this.targetPosition) {   
    sprite = new Sprite(2, engine.images["spore"], position, 32, 32);
    sprite.anchor = new Vector(0.5, 0.5);  
    engine.canvas["buffer"].addDisplayObject(sprite);
    init();
  }

  void init() {
    Vector delta = targetPosition - sprite.position;
    num distance = sprite.position.distanceTo(targetPosition);

    speed.x = (delta.x / distance) * Spore.baseSpeed * game.speed;
    speed.y = (delta.y / distance) * Spore.baseSpeed * game.speed;
  }

  void move() {
    trailCounter++;
    if (trailCounter == 10) {
      trailCounter = 0;
      game.smokes.add(new Smoke(new Vector(sprite.position.x, sprite.position.y - 16)));
    }
    sprite.rotation += 10;
    if (sprite.rotation > 359)
      sprite.rotation -= 359;

    sprite.position += speed;

    if (sprite.position.x > targetPosition.x - 2 && sprite.position.x < targetPosition.x + 2 && sprite.position.y > targetPosition.y - 2 && sprite.position.y < targetPosition.y + 2) {
      // if the target is reached explode and remove
      remove = true;
      engine.playSound("explosion", targetPosition.real2tiled());

      for (int i = (targetPosition.x ~/ game.tileSize) - 2; i < (targetPosition.x ~/ game.tileSize) + 2; i++) {
        for (int j = (targetPosition.y ~/ game.tileSize) - 2; j < (targetPosition.y ~/ game.tileSize) + 2; j++) {
          if (game.world.contains(new Vector(i, j))) {
            num distance = pow((i * game.tileSize + game.tileSize / 2) - (targetPosition.x + game.tileSize), 2) + pow((j * game.tileSize + game.tileSize / 2) - (targetPosition.y + game.tileSize), 2);
            if (distance < pow(game.tileSize, 2)) {
              game.world.tiles[i][j].creep += .05;
            }
          }
        }
      }
    }
  }
}