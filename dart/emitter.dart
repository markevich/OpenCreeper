part of creeper;

class Emitter {
  Sprite sprite;
  int strength;
  Building analyzer;
  static int counter;
  static List<Emitter> emitters = new List<Emitter>();

  Emitter(position, this.strength) {
    sprite = new Sprite(Layer.EMITTER, engine.images["emitter"], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addDisplayObject(sprite);
  }
  
  static void clear() {
    emitters.clear();
    counter = 0;
  }
  
  static Emitter add(Vector position, int strength) {
    Emitter emitter = new Emitter(position, strength);
    emitters.add(emitter);
    return emitter;
  }
  
  static void update() {
    counter++;
    if (counter >= (25 / game.speed)) {
      counter = 0;
      
      for (int i = 0; i < emitters.length; i++) {
        // only spawn creeper if not targeted by an analyzer
        if (emitters[i].analyzer == null) {
          game.world.getTile(emitters[i].sprite.position).creep += emitters[i].strength; //game.world.tiles[sprite.position.x + 1][sprite.position.y + 1].creep += strength;
          game.creeperDirty = true;
        }
      }
    }
  }
  
  static void find(Building building) {
    Vector center = building.sprite.position;
    
    if (building.weaponTargetPosition == null) {
      for (int i = 0; i < emitters.length; i++) {
        Vector emitterCenter = emitters[i].sprite.position;

        num distance = pow(emitterCenter.x - center.x, 2) + pow(emitterCenter.y - center.y, 2);

        if (distance <= pow(building.weaponRadius * game.tileSize, 2)) {
          if (emitters[i].analyzer == null) {
            emitters[i].analyzer = building;
            building.weaponTargetPosition = emitters[i].sprite.position;
            break;
          }
        }

      }
    }
    else {
      if (building.energyCounter > 20) {
        building.energyCounter = 0;
        building.energy -= 1;
      }

      building.operating = true;
    }
  }
  
  static void checkWinningCondition() {
    int emittersChecked = 0;
    for (int i = 0; i < emitters.length; i++) {
      if (emitters[i].analyzer != null)
        emittersChecked++;
    }
    if (emittersChecked == emitters.length) {
      // TODO: 10 seconds countdown
      querySelector('#win').style.display = "block";
      game.stopwatch.stop();
      game.stop();
    } 
  }
}