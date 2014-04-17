part of creeper;

class Emitter extends GameObject {
  Sprite sprite;
  int strength;
  Building analyzer;
  int counter = 0;

  Emitter(position, this.strength) {
    sprite = new Sprite(Layer.EMITTER, game.engine.images["emitter"], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    game.engine.renderer["buffer"].addDisplayObject(sprite);
  }
  
  static Emitter add(Vector position, int strength) {
    Emitter emitter = new Emitter(position, strength);
    game.engine.gameObjects.add(emitter);
    return emitter;
  }
   
  void update() {
    counter += 1 * game.speed;
    
    if (counter >= 25) {
      counter -= 25;
      if (analyzer == null) {
        game.world.getTile(sprite.position).creep += strength; //game.world.tiles[sprite.position.x + 1][sprite.position.y + 1].creep += strength;
        World.creeperDirty = true;
      }
    }
  }
  
  static void find(Building building) {
    Vector center = building.sprite.position;
    
    if (building.weaponTargetPosition == null && building.energy > 0) {
      for (var emitter in game.engine.gameObjects) {
        if (emitter is Emitter) {
          Vector emitterCenter = emitter.sprite.position;
  
          num distance = pow(emitterCenter.x - center.x, 2) + pow(emitterCenter.y - center.y, 2);
  
          if (distance <= pow(building.weaponRadius * game.tileSize, 2)) {
            if (emitter.analyzer == null) {
              emitter.analyzer = building;
              building.weaponTargetPosition = emitter.sprite.position;
              break;
            }
          }
  
        }
      }
    }
    else {
      if (building.energy > 0) {
        if (building.energyCounter > 20) {
          building.energyCounter = 0;
          building.energy -= 1;
        }
        building.operating = true;
      } else {
        building.operating = false;
        for (var emitter in game.engine.gameObjects) {
          if (emitter is Emitter) {
            if (building.weaponTargetPosition == emitter.sprite.position) {
              emitter.analyzer = null;
              building.weaponTargetPosition = null;
              break;
            }
          }
        }
      }
    }
  }
  
  static void checkWinningCondition() {
    if (!game.won) {
      int emittersChecked = 0;
      List emitters = [];
      for (var emitter in game.engine.gameObjects) {
        if (emitter is Emitter) {
          emitters.add(emitter);        
        }
      }
      for (int i = 0; i < emitters.length; i++) {
        if (emitters[i].analyzer != null)
          emittersChecked++;
      }
      if (emittersChecked == emitters.length) {
        // TODO: 10 seconds countdown
        querySelector('#win').style.display = "block";
        game.stopwatch.stop();
        //game.stop();
        game.paused = true;
        game.won = true;
      } 
    }
  }
  
  static bool intersect(Rectangle rectangle) {  
    for (var emitter in game.engine.gameObjects) {
      if (emitter is Emitter) {
        Rectangle emitterRect = new Rectangle(emitter.sprite.position.x - 3 * game.tileSize / 2,
                                              emitter.sprite.position.y - 3 * game.tileSize / 2,
                                              3 * game.tileSize - 1,
                                              3 * game.tileSize - 1);        
        if (rectangle.intersects(emitterRect)) {
          return true;
        }
      }
    }
    return false;
  }
}