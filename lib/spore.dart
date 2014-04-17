part of creeper;

class Spore extends GameObject {
  Vector targetPosition, speed = new Vector(0, 0);
  bool remove = false;
  num health = 500;
  int trailCounter = 0;
  Sprite sprite;
  static final int baseSpeed = 1;

  Spore(position, this.targetPosition) {   
    sprite = new Sprite(Layer.SPORE, game.engine.images["spore"], position, 32, 32);
    sprite.anchor = new Vector(0.5, 0.5);  
    game.engine.renderer["buffer"].addDisplayObject(sprite);
  }
   
  static void add(Vector position, Vector targetPosition) {
    Spore spore = new Spore(position, targetPosition);
    game.engine.gameObjects.add(spore);
  }
  
  void update() {
    if (remove) {
      game.engine.renderer["buffer"].removeDisplayObject(sprite);
      game.engine.gameObjects.remove(this);
    }
    else
      move();
  }
  
  static void damage(Building building) {
    Vector center = building.sprite.position;
    
    // find spore in range
    for (var spore in game.engine.gameObjects.length) {
      if (spore is Spore) {  
        Vector sporeCenter = spore.sprite.position;
        var distance = pow(sporeCenter.x - center.x, 2) + pow(sporeCenter.y - center.y, 2);
    
        if (distance <= pow(building.weaponRadius * game.tileSize, 2)) {
          building.weaponTargetPosition = sporeCenter;
          building.energy -= .05;
          building.operating = true;
          spore.health -= 2;
          if (spore.health <= 0) {
            spore.remove = true;
            game.engine.playSound("explosion", game.real2tiled(spore.sprite.position), game.scroll, game.zoom);
            Explosion.add(sporeCenter);
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
    sprite.rotation += 10;
    if (sprite.rotation > 359)
      sprite.rotation -= 359;

    sprite.position += game.engine.calculateVelocity(sprite.position, targetPosition, Spore.baseSpeed * game.speed);

    if (sprite.position == targetPosition) {
      // if the target is reached explode and remove
      remove = true;
      Vector targetPositionTiled = game.real2tiled(targetPosition);
      game.engine.playSound("explosion", targetPosition, game.scroll, game.zoom);

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