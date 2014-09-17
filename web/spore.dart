part of creeper;

class Spore extends GameObject {
  Vector targetPosition, speed = new Vector(0, 0);
  bool remove = false;
  num health = 500;
  int trailCounter = 0;
  Sprite sprite;
  static final int baseSpeed = 1;

  Spore(position, this.targetPosition) {   
    sprite = new Sprite("buffer", "spore", Zei.images["spore"], position, 32, 32, anchor: new Vector(0.5, 0.5));
  }
   
  static void add(Vector position, Vector targetPosition) {
    Spore spore = new Spore(position, targetPosition);
    Zei.addGameObject(spore);
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
  
  static void damage(Building building) {  
    // find spore in range
    for (var spore in Zei.gameObjects) {
      if (spore is Spore) {      
        if (building.sprite.position.distanceTo(spore.sprite.position) <= building.weaponRadius * game.tileSize) {
          building.weaponTargetPosition = spore.sprite.position;
          building.energy -= .05;
          building.operating = true;
          spore.health -= 2;
          if (spore.health <= 0) {
            spore.remove = true;
            Zei.playSound("explosion", game.real2tiled(spore.sprite.position), game.scroll, game.zoom);
            Explosion.add(spore.sprite.position);
          }
        }
      }
    }
  }

  void move() {
    trailCounter++;
    if (trailCounter == 10) {
      trailCounter = 0;
      Smoke.add(new Vector(sprite.position.x, sprite.position.y - 16));
    }
    sprite.rotate(10);

    sprite.position += Zei.calculateVelocity(sprite.position, targetPosition, Spore.baseSpeed * game.speed);

    if (sprite.position == targetPosition) {
      // if the target is reached explode and remove
      remove = true;
      Vector targetPositionTiled = game.real2tiled(targetPosition);
      Zei.playSound("explosion", targetPosition, game.scroll, game.zoom);

      for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
          
          Vector tilePosition = targetPositionTiled + new Vector(i, j);
          
          if (game.world.contains(tilePosition)) {
            if ((tilePosition * game.tileSize + new Vector(8, 8)).distanceTo(targetPosition) <= game.tileSize * 2) {
              Tile tile = game.world.getTile(tilePosition * game.tileSize);             
              tile.creep += .5;
            }
          }
        }
      }
      World.creeperDirty = true;
    }
  }
}