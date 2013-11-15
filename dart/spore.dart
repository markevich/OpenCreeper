part of creeper;

class Spore {
  Vector targetPosition, speed = new Vector(0, 0);
  bool remove = false;
  num health = 100;
  int trailCounter = 0;
  Sprite sprite;
  static final int baseSpeed = 1;
  static List<Spore> spores = new List<Spore>();

  Spore(position, this.targetPosition) {   
    sprite = new Sprite(2, engine.images["spore"], position, 32, 32);
    sprite.anchor = new Vector(0.5, 0.5);  
    engine.canvas["buffer"].addDisplayObject(sprite);
  }
  
  static void clear() {
    spores.clear();
  }
  
  static void add(Spore spore) {
    spores.add(spore);
  }
  
  static void update() {
    for (int i = spores.length - 1; i >= 0; i--) {
      if (spores[i].remove) {
        engine.canvas["buffer"].removeDisplayObject(spores[i].sprite);
        spores.removeAt(i);
      }
      else
        spores[i].move();
    }
  }
  
  static void damage(Building building) {
    Vector center = building.getCenter();
    
    // find spore in range
    for (int i = 0; i < spores.length; i++) {
      Vector sporeCenter = spores[i].sprite.position;
      var distance = pow(sporeCenter.x - center.x, 2) + pow(sporeCenter.y - center.y, 2);
  
      if (distance <= pow(building.weaponRadius * game.tileSize, 2)) {
        building.weaponTargetPosition = sporeCenter;
        building.energy -= .1;
        building.operating = true;
        spores[i].health -= 2;
        if (spores[i].health <= 0) {
          spores[i].remove = true;
          engine.playSound("explosion", spores[i].sprite.position.real2tiled());
          Explosion.add(new Explosion(sporeCenter));
        }
      }
    }
  }

  void calculateVector() {
    Vector delta = targetPosition - sprite.position;
    num distance = sprite.position.distanceTo(targetPosition);

    speed.x = (delta.x / distance) * Spore.baseSpeed * game.speed;
    speed.y = (delta.y / distance) * Spore.baseSpeed * game.speed;

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
              game.world.tiles[i][j].creep += .5;
              game.creeperDirty = true;
            }
          }
        }
      }
    }
  }
}