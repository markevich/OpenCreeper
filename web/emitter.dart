part of creeper;

class Emitter extends Zei.GameObject {
  Zei.Sprite sprite;
  int strength;
  Building analyzer;
  int counter = 0;
  static int numberOfEmitters = 0;
  static List<Emitter> deadEmitters = new List();

  Emitter(position, this.strength) {
    sprite = Zei.Sprite.create("main", "emitter", Zei.images["emitter"], position, 48, 48, anchor: new Zei.Vector2(0.5, 0.5));
    numberOfEmitters++;
  }
  
  static Emitter add(Zei.Vector2 position, int strength) {
    Emitter emitter = new Emitter(position, strength);
    Zei.GameObject.add(emitter);
    return emitter;
  }
   
  void update() {
    if (!game.paused) {
      counter += 1 * game.speed;
      
      if (counter >= 25) {
        counter -= 25;
        if (analyzer == null) {
          game.world.getTile(sprite.position).creep += strength; //game.world.tiles[sprite.position.x + 1][sprite.position.y + 1].creep += strength;
          World.creeperDirty = true;
        }
      }
      
      // check winning condition
      if (!game.won)  {
        // get current amount of dead emitters
        if (analyzer != null) {
          if (deadEmitters.indexOf(this) == -1)
            deadEmitters.add(this);
        } else {
          if (deadEmitters.indexOf(this) != -1)
            deadEmitters.removeAt(deadEmitters.indexOf(this));
        }
        
        // if all emitters are dead the game is won!
        if (deadEmitters.length == numberOfEmitters) {
          // TODO: 10 seconds countdown
          querySelector('#win').style.display = "block";
          game.stopwatch.stop();
          //game.stop();
          game.paused = true;
          game.won = true;
        } 
      }
    }
  }
  
  static void find(Building building) {   
    // if building has no target find target
    if (building.weaponTargetPosition == null && building.energy > 0) {
      for (var emitter in Zei.GameObject.gameObjects) {
        if (emitter is Emitter) { 
          if (emitter.sprite.position.distanceTo(building.sprite.position) <= building.radius * Tile.size) {
            if (emitter.analyzer == null) {
              emitter.analyzer = building;
              building.weaponTargetPosition = emitter.sprite.position;
              building.analyzerLineInner.to = emitter.sprite.position;
              building.analyzerLineOuter.to = emitter.sprite.position;
              break;
            }
          }
        }
      }
    }
    // else if it already has a target
    else {
      // if it has energy operate
      if (building.energy > 0) {
        if (building.energyCounter > 20) {
          building.energyCounter = 0;
          building.energy -= 1;
        }
        building.operating = true;
        building.analyzerLineInner.visible = true;
        building.analyzerLineOuter.visible = true;  
      }
      // else stop operating
      else {
        building.operating = false;
        building.analyzerLineInner.visible = false;
        building.analyzerLineOuter.visible = false;
        // clear target
        for (var emitter in Zei.GameObject.gameObjects) {
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
  
  static bool intersect(Rectangle rectangle) {  
    for (var emitter in Zei.GameObject.gameObjects) {
      if (emitter is Emitter) {
        Rectangle emitterRect = new Rectangle(emitter.sprite.position.x - 3 * Tile.size / 2,
                                              emitter.sprite.position.y - 3 * Tile.size / 2,
                                              3 * Tile.size - 1,
                                              3 * Tile.size - 1);        
        if (rectangle.intersects(emitterRect)) {
          return true;
        }
      }
    }
    return false;
  }
}