part of creeper;

class Spore extends Zei.GameObject {
  Zei.Vector2 targetPosition;
  bool flagRemove = false;
  num health = 500;
  int trailCounter = 0;
  Zei.Sprite sprite;
  static final int baseSpeed = 1;

  Spore(position, this.targetPosition) {   
    sprite = new Zei.Sprite("buffer", "spore", Zei.images["spore"], position, 32, 32, anchor: new Zei.Vector2(0.5, 0.5));
  }
   
  static void add(Zei.Vector2 position, Zei.Vector2 targetPosition) {
    Spore spore = new Spore(position, targetPosition);
    Zei.GameObject.add(spore);
  }
  
  void update() {
    if (!game.paused) {
      if (flagRemove) {
        Zei.renderer["buffer"].removeDisplayObject(sprite);
        Zei.GameObject.remove(this);
      }
      else
        move();
    }
  }
  
  static void damage(Building building) {  
    // find spore in range
    //for (var spore in Zei.GameObject.gameObjects) {
    for (var i = Zei.GameObject.gameObjects.length - 1; i >= 0; i--) {
      var spore = Zei.GameObject.gameObjects[i];
      if (spore is Spore) {      
        if (building.sprite.position.distanceTo(spore.sprite.position) <= building.radius * Tile.size) {
          building.weaponTargetPosition = spore.sprite.position;
          building.beamLineInner.to = spore.sprite.position;
          building.beamLineOuter.to = spore.sprite.position;
          building.beamLineInner.visible = true;
          building.beamLineOuter.visible = true;
          building.energy -= .05;
          building.operating = true;
          spore.health -= 2;
          if (spore.health <= 0) {
            spore.flagRemove = true;
            Zei.Audio.play("explosion", Tile.position(spore.sprite.position), game.scroll, game.zoom);
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
      Smoke.add(new Zei.Vector2(sprite.position.x, sprite.position.y - 16));
    }
    sprite.rotate(10);

    sprite.position += ((targetPosition - sprite.position).normalize() * Spore.baseSpeed * game.speed).clamp(targetPosition - sprite.position);

    if (sprite.position == targetPosition) {
      // if the target is reached explode and remove
      flagRemove = true;
      Zei.Vector2 targetPositionTiled = Tile.position(targetPosition);
      Zei.Audio.play("explosion", targetPosition, game.scroll, game.zoom);

      for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
          
          Zei.Vector2 tilePosition = targetPositionTiled + new Zei.Vector2(i, j);
          
          if (game.world.contains(tilePosition)) {
            if ((tilePosition * Tile.size + new Zei.Vector2(8, 8)).distanceTo(targetPosition) <= Tile.size * 2) {
              Tile tile = game.world.getTile(tilePosition * Tile.size);             
              tile.creep += .5;
            }
          }
        }
      }
      World.creeperDirty = true;
    }
  }
}