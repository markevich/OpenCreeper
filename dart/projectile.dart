part of creeper;

class Projectile {
  Vector targetPosition, speed = new Vector(0, 0);
  bool remove = false;
  Sprite sprite;
  static num baseSpeed = 5;

  Projectile(position, this.targetPosition, rotation) {
    sprite = new Sprite(1, engine.images["projectile"], position, 16, 16);
    sprite.anchor = new Vector(0.5, 0.5);
    sprite.rotation = rotation;
    engine.canvas["buffer"].addSprite(sprite);
  }

  void calculateVector() {
    Vector delta = new Vector(targetPosition.x - sprite.position.x, targetPosition.y - sprite.position.y);
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

    if (sprite.position.x > targetPosition.x - 2 && sprite.position.x < targetPosition.x + 2 && sprite.position.y > targetPosition.y - 2 && sprite.position.y < targetPosition.y + 2) {
      // if the target is reached smoke and remove
      remove = true;

      game.smokes.add(new Smoke(targetPosition));
      Vector tiledPosition = targetPosition.real2tiled();
      
      game.world.tiles[tiledPosition.x][tiledPosition.y].creep -= 1;
      if (game.world.tiles[tiledPosition.x][tiledPosition.y].creep < 0)
        game.world.tiles[tiledPosition.x][tiledPosition.y].creep = 0;
      game.world.tiles[tiledPosition.x][tiledPosition.y].newcreep -= 1;
      if (game.world.tiles[tiledPosition.x][tiledPosition.y].newcreep < 0)
        game.world.tiles[tiledPosition.x][tiledPosition.y].newcreep = 0;
      
    }
  }
}