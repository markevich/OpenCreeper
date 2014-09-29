part of creeper;

class Shell extends Zei.GameObject {
  Zei.Vector2 targetPosition;
  bool flagRemove = false;
  int trailCounter = 0;
  Zei.Sprite sprite;
  static final num baseSpeed = 1.5;

  Shell(position, this.targetPosition) {
    sprite = Zei.Sprite.create("main", "shell", Zei.images["shell"], position, 16, 16, anchor: new Zei.Vector2(0.5, 0.5));
  }
  
  static Shell add(Zei.Vector2 position, Zei.Vector2 targetPosition) {
    Shell shell = new Shell(position, targetPosition);
    return shell;
  }
  
  void update() {
    if (!game.paused) {
      if (flagRemove) {
        Zei.renderer["main"].removeDisplayObject(sprite);
        Zei.GameObject.remove(this);
      }
      else
        move();
    }
  }

  void move() {
    trailCounter++;
    if (trailCounter == 10) {
      trailCounter = 0;
      Smoke.add(new Zei.Vector2(sprite.position.x, sprite.position.y - 16));
    }

    sprite.rotate(20);
    sprite.position += ((targetPosition - sprite.position).normalize() * Shell.baseSpeed * game.speed).clamp(targetPosition - sprite.position);

    // if the target is reached explode and remove
    if (sprite.position == targetPosition) {
      flagRemove = true;

      Zei.Vector2 targetPositionTiled = Tile.position(targetPosition);
      Explosion.add(targetPosition);
      Zei.Audio.play("explosion", targetPosition, game.scroller.scroll, game.zoom);

      for (int i = -4; i <= 4; i++) {
        for (int j = -4; j <= 4; j++) {
          
          Zei.Vector2 tilePosition = targetPositionTiled + new Zei.Vector2(i, j);
          
          if (game.world.contains(tilePosition)) {
            if ((tilePosition * Tile.size + new Zei.Vector2(8, 8)).distanceTo(targetPosition) <= Tile.size * 4) {
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
  
  void onMouseEvent(evt) {}
  
  void onKeyEvent(evt) {}
}