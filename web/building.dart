part of creeper;

class Building extends Zei.GameObject {
  Zei.Vector2 position, scale = new Zei.Vector2(1, 1), moveTargetPosition, weaponTargetPosition, speed = new Zei.Vector2(0, 0);
  String type, status = "IDLE"; // MOVING, RISING, FALLING
  bool operating = false, selected = false, hovered = false, built = false, active = true, canMove = false, needsEnergy = false, rotating = false;
  num health, maxHealth = 0, energy, maxEnergy = 0, healthRequests = 0, energyRequests = 0, rotation = 0;
  int targetAngle, radius = 0, size, collectedEnergy = 0, flightCounter = 0, requestCounter = 0, energyCounter = 0;
  Ship ship;
  Zei.Sprite sprite, cannon, shield, inactiveSprite;
  Zei.Circle selectedCircle;
  Zei.Rect targetSymbol, energyBar, healthBar;
  Zei.Line analyzerLineInner, analyzerLineOuter, beamLineInner, beamLineOuter, terpLineInner, terpLineOuter;
  int damageCounter = 0, collectCounter = 0;
  Spore beamTarget;
  static final double baseVelocity = .5;
  static Building base;
  static List<Packet> queue = new List<Packet>();

  Building.template(imageID) {
    type = imageID;  
    
    health = 0;
    size = 3;
    energy = 0;
    
    if (type == "analyzer") {
      maxHealth = 80;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      radius = 10;
    }
    else if (type == "terp") {
      maxHealth = 60;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      radius = 20;
    }
    else if (type == "shield") {
      maxHealth = 75;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      radius = 10;
    }
    else if (type == "bomber") {
      maxHealth = 75;
      maxEnergy = 15;
      needsEnergy = true;
    }
    else if (type == "storage") {
      maxHealth = 8;
    }
    else if (type == "reactor") {
      maxHealth = 50;
    }
    else if (type == "collector") {
      maxHealth = 5;
      radius = 6;
    }
    else if (type == "relay") {
      maxHealth = 10;
    }
    else if (type == "cannon") {
      maxHealth = 25;
      maxEnergy = 40;
      radius = 10;
      canMove = true;
      needsEnergy = true;
      energyCounter = 15;
    }
    else if (type == "mortar") {
      maxHealth = 40;
      maxEnergy = 20;
      radius = 14;
      canMove = true;
      needsEnergy = true;
      energyCounter = 200;
    }
    else if (type == "beam") {
      maxHealth = 20;
      maxEnergy = 10;
      radius = 20;
      canMove = true;
      needsEnergy = true;
    }
  }
  
  Building(position, imageID) {
    type = imageID;
    this.position = position;
    sprite = new Zei.Sprite("buffer", "building", Zei.images[imageID], position, 48, 48, anchor: new Zei.Vector2(0.5, 0.5), alpha: 0.5);

    selectedCircle = new Zei.Circle("buffer", "selectedcircle", position, 24, 2, null, new Zei.Color.white(), visible: false);

    health = 0;
    size = 3;
    energy = 0;
        
    if (type == "base") {
      sprite.size = new Zei.Vector2(144, 144);
      sprite.alpha = 1.0;
      selectedCircle.radius = 72;
      health = 40;
      maxHealth = 40;
      built = true;
      size = 9;
      canMove = true;
      energy = 20;
      maxEnergy = 20;
      needsEnergy = true;
    }   
    else if (type == "analyzer") {
      maxHealth = game.debug == true ? 1 : 80;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      radius = 10;
      
      analyzerLineOuter = new Zei.Line("buffer", "projectile", position, new Zei.Vector2.empty(), 5, new Zei.Color.blue(), visible: false);
      analyzerLineInner = new Zei.Line("buffer", "projectile", position, new Zei.Vector2.empty(), 3, new Zei.Color.white(), visible: false);      
    }
    else if (type == "terp") {
      maxHealth = game.debug == true ? 1 : 60;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      radius = 20;
      
      terpLineOuter = new Zei.Line("buffer", "projectile", position, new Zei.Vector2.empty(), 5, new Zei.Color.green(), visible: false);
      terpLineInner = new Zei.Line("buffer", "projectile", position, new Zei.Vector2.empty(), 3, new Zei.Color.white(), visible: false);  
    }
    else if (type == "shield") {
      maxHealth = game.debug == true ? 1 : 75;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      radius = 10;
      
      shield = new Zei.Sprite("buffer", "shield", Zei.images["forcefield"], position, 336, 336, anchor: new Zei.Vector2(0.5, 0.5), alpha: 0.5, visible: false);
    }
    else if (type == "bomber") {
      maxHealth = game.debug == true ? 1 : 75;
      maxEnergy = 15;
      needsEnergy = true;
    }
    else if (type == "storage") {
      maxHealth = game.debug == true ? 1 : 8;
    }
    else if (type == "reactor") {
      maxHealth = game.debug == true ? 1 : 50;
    }
    else if (type == "collector") {
      maxHealth = game.debug == true ? 1 : 5;
      radius = 6;
    }
    else if (type == "relay") {
      maxHealth = game.debug == true ? 1 : 10;
    }
    else if (type == "cannon") {
      maxHealth = game.debug == true ? 1 : 25;
      maxEnergy = 40;
      radius = 10;
      canMove = true;
      needsEnergy = true;
      energyCounter = 15;
      
      cannon = new Zei.Sprite("buffer", "buildinggun", Zei.images["cannongun"], position, 48, 48, anchor: new Zei.Vector2(0.5, 0.5), alpha: 0.5);
    }
    else if (type == "mortar") {
      maxHealth = game.debug == true ? 1 : 40;
      maxEnergy = 20;
      radius = 14;
      canMove = true;
      needsEnergy = true;
      energyCounter = 200;
    }
    else if (type == "beam") {
      maxHealth = game.debug == true ? 1 : 20;
      maxEnergy = 10;
      radius = 20;
      canMove = true;
      needsEnergy = true;
      
      beamLineOuter = new Zei.Line("buffer", "projectile", position, new Zei.Vector2.empty(), 5, new Zei.Color.red(), visible: false);
      beamLineInner = new Zei.Line("buffer", "projectile", position, new Zei.Vector2.empty(), 3, new Zei.Color.white(), visible: false); 
    }
    
    targetSymbol = new Zei.Rect("buffer", "targetsymbol", new Zei.Vector2.empty(), new Zei.Vector2(size * Tile.size, size * Tile.size), 1, new Zei.Color.green(), null, visible: false, anchor: new Zei.Vector2(0.5, 0.5));
     
    if (needsEnergy) {
      energyBar = new Zei.Rect("buffer", "buildinginfo", 
                               position - new Zei.Vector2(size * Tile.size / 2 - 2, size * Tile.size / 2 - 4),
                               new Zei.Vector2(((size * Tile.size - 4) / maxEnergy) * energy, 3),
                               0, new Zei.Color.red(), null);
    }
    healthBar = new Zei.Rect("buffer", "buildinginfo", 
                                   position - new Zei.Vector2(size * Tile.size / 2 - 2, -size * Tile.size / 2 + 7),
                                   new Zei.Vector2(((size * Tile.size - 4) / maxHealth) * health, 3),
                                   0, new Zei.Color.green(), null, visible: false); 
    
    inactiveSprite = new Zei.Sprite("buffer", "buildinginfo", Zei.images["inactive"], position, 144, 144, anchor: new Zei.Vector2(0.5, 0.5), visible: false, scale: new Zei.Vector2(1.0 / 9 * size, 1.0 / 9 * size));
    
    Connection.add(this);
  }
     
  /**
   * Adds a building of a given [type] at the given [position].
   */
  static Building add(Zei.Vector2 position, String type) {
    position = position * 16 + new Zei.Vector2(8, 8);
    Building building = new Building(position, type);
    if (type == "base") base = building;
    Zei.GameObject.add(building);
    return building;
  }
  
  /**
   * Removes a [building].
   */
  static void remove(Building building) {

    // only explode building when it has been built
    if (building.built) {
      Explosion.add(building.position);
      Zei.Audio.play("explosion", building.position, game.scroll, game.zoom);
    }

    if (building.type == "base") {
      querySelector('#lose').style.display = "block";
      game.stopwatch.stop();
      game.stop();
    }
    if (building.type == "collector") {
      if (building.built)
        building.updateCollection("remove");
    }
    if (building.type == "storage") {
      Building.base.maxEnergy -= 10;
      game.updateEnergyElement();
    }
    if (building.type == "speed") {
      Packet.baseSpeed /= 1.01;
    }

    // find all packets with this building as target and remove them
    Packet.removeWithTarget(building);
    
    Connection.remove(building);

    Zei.renderer["buffer"].removeDisplayObject(building.sprite);
    Zei.renderer["buffer"].removeDisplayObject(building.selectedCircle);
    Zei.renderer["buffer"].removeDisplayObject(building.targetSymbol);
    if (building.cannon != null)
      Zei.renderer["buffer"].removeDisplayObject(building.cannon);

    Zei.GameObject.remove(building);
  }
  
  static void addToQueue(Packet packet) {
    queue.add(packet);
  }
  
  /**
   * Updates the packet queue of the base.
   * 
   * If the base has energy the first packet is removed from
   * the queue and sent to its target (FIFO).
   */
  static void updateQueue() {
    for (int i = queue.length - 1; i >= 0; i--) {
      if (base.energy > 0) {
        base.energy--;
        game.updateEnergyElement();
        Packet packet = queue.removeAt(0);
        packet.send();
      }
    }
  }
  
  static void removeSelected() {
    for (var i = Zei.GameObject.gameObjects.length - 1; i >= 0; i--) {
      if (Zei.GameObject.gameObjects[i] is Building) {
        Building building = Zei.GameObject.gameObjects[i];
        if (building.selected) {
          if (building.type != "base")
            Building.remove(building);
        }
      }
    }
  }
  
  static void select() {
    if (game.mode == "DEFAULT") {
      Building buildingSelected = null;
      for (var building in Zei.GameObject.gameObjects) {
        if (building is Building) {
          building.selected = building.hovered;
          if (building.selected) {
            buildingSelected = building;
            building.selectedCircle.visible = true;
          } else {
            building.selectedCircle.visible = false;
          }
        }
      }
      if (buildingSelected != null) {
        if (buildingSelected.active) {
          querySelector('#deactivate').style.display = "block";
          querySelector('#activate').style.display = "none";
        } else {
          querySelector('#deactivate').style.display = "none";
          querySelector('#activate').style.display = "block";
        }
      } else {
        querySelector('#deactivate').style.display = "none";
        querySelector('#activate').style.display = "none";
      }
    }
  }
  
  static void deselect() {
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building) {
        building.selected = false;
        building.selectedCircle.visible = false;
      }
    }
    game.world.hideRangeBoxes();
    querySelector('#deactivate').style.display = "none";
    querySelector('#activate').style.display = "none";
  }
   
  void update() {
    hovered = this.sprite.isHovered();
    
    if (!game.paused) {
      move();
      checkOperating();
      shieldAction();
      requestPacket();
      
      // take damage
      damageCounter += 1 * game.speed;
      if (damageCounter > 10) {
        damageCounter -= 10;
        takeDamage();
      }

      // collect energy
      collectCounter += 1 * game.speed;
      if (collectCounter > 250) {
        collectCounter -= 250;
        collectEnergy();
      }
    }
  }
  
  static void activate() {
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building) {
        if (building.selected)
          building.active = true;
          building.inactiveSprite.visible = false;
        
          if (building.type == "shield") {
            building.shield.visible = true;
          }
          
          if (building.type == "analyzer") {
            building.analyzerLineInner.visible = true;
            building.analyzerLineOuter.visible = true;
          }
      }
    }
  }
  
  static void deactivate() {
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building) {
        if (building.selected) {
          building.active = false;
          building.inactiveSprite.visible = true;
          
          if (building.type == "analyzer") {
            building.analyzerLineInner.visible = false;
            building.analyzerLineOuter.visible = false;
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
          
          if (building.type == "shield") {
            building.shield.visible = false;
          }
          
        }
      }
    }
  }
  
  static void reposition(Zei.Vector2 position) { 
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building) {
        if (building.built && building.selected && building.canMove) {
          // check if it can be placed
          if (game.canBePlaced(position, building)) {
            game.mouse.showCursor();
            building.operating = false;
            building.rotating = false;
            building.weaponTargetPosition = null;
            building.status = "RISING";
            building.moveTargetPosition = (position * Tile.size) + new Zei.Vector2(8, 8);
            building.targetSymbol.visible = true;
            building.targetSymbol.position = (position * Tile.size) + new Zei.Vector2(8, 8);
            Connection.remove(building);
          }
        }
      }
    }
  }
  
  static bool intersect(Rectangle rectangle, [Building building2]) {  
    // check stationary buildings
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building) {
        if (building2 != null && building2 == building)
          continue;
        
        Rectangle buildingRect = null;
        // check flying buildings
        if (building.status != "IDLE") {
          buildingRect = new Rectangle(building.moveTargetPosition.x - building.size * Tile.size / 2,
                                       building.moveTargetPosition.y - building.size * Tile.size / 2,
                                       building.size * Tile.size - 1,
                                       building.size * Tile.size - 1);  
        } 
        // check stationary buildings
        else { 
          buildingRect = new Rectangle(building.position.x - building.size * Tile.size / 2,
                                       building.position.y - building.size * Tile.size / 2,
                                       building.size * Tile.size - 1,
                                       building.size * Tile.size - 1);  
        }
        if (rectangle.intersects(buildingRect)) {
          return true;
        }
      }
    }
    return false;
  }
  
  /**
   * Used for A*, finds all neighbouring buildings.
   * The [target] node is also passed as it is a valid neighbour.
   */
  List getNeighbours(Building target) {
    List neighbours = new List();
    
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building) {
        // must not be the same building
        if (building.position != position) {
          // must be idle
          if (building.status == "IDLE") {
            // it must either be the target or be built
            if (building == target || (building.built && (building.type == "collector" || building.type == "relay"))) {
  
                int allowedDistance = 10 * Tile.size;
                if (type == "relay" && building.type == "relay") {
                  allowedDistance = 20 * Tile.size;
                }
                
                if (position.distanceTo(building.position) <= allowedDistance) {
                  neighbours.add(building);
                }
            }
          }
        }
      }
    }
    return neighbours;
  }
  
  void updateDisplayObjects() {
    sprite.position = position;
    sprite.scale = scale;
    
    selectedCircle.position = position;
    selectedCircle.scale = scale.x;
    
    if (cannon != null) {
      cannon.position = position;
      cannon.scale = scale;
    }
  }
  
  void move() {
    if (status == "RISING") {
      if (flightCounter < 25) {
        flightCounter += 1 * game.speed;
        scale = scale * 1.01;
        updateDisplayObjects();
      }
      if (flightCounter >= 25) {
        flightCounter = 25;
        status = "MOVING";
        Zei.renderer["buffer"].switchLayer(sprite, "buildingflying");
        if (cannon != null)
          Zei.renderer["buffer"].switchLayer(cannon, "buildinggunflying");
        if (energyBar != null) {
          Zei.renderer["buffer"].switchLayer(energyBar, "buildinginfoflying");
        }
        Zei.renderer["buffer"].switchLayer(healthBar, "buildinginfoflying");
      }
    }
    
    else if (status == "FALLING") {
      if (flightCounter > 0) {
        flightCounter -= 1 * game.speed;
        scale = scale / 1.01;
        updateDisplayObjects();
      }
      if (flightCounter <= 0) {
        flightCounter = 0;
        status = "IDLE";
        scale = new Zei.Vector2(1.0, 1.0);
        targetSymbol.visible = false;
        updateDisplayObjects();
        Connection.add(this);
        Zei.renderer["buffer"].switchLayer(sprite, "building");
        if (cannon != null)
          Zei.renderer["buffer"].switchLayer(cannon, "buildinggun");
        if (energyBar != null) {
          Zei.renderer["buffer"].switchLayer(energyBar, "buildinginfo");
        }
        Zei.renderer["buffer"].switchLayer(healthBar, "buildinginfo");
      }
    }

    if (status == "MOVING") {
      if (moveTargetPosition.x != position.x || moveTargetPosition.y != position.y) {
        position += ((moveTargetPosition - position).normalize() * Building.baseVelocity * game.speed).clamp(moveTargetPosition - position);
        if (energyBar != null) {
          energyBar.position = position - new Zei.Vector2(size * Tile.size / 2 - 2, size * Tile.size / 2 - 4);
        }
        healthBar.position = position - new Zei.Vector2(size * Tile.size / 2 - 2, -size * Tile.size / 2 + 7);
      }    
      
      if (position.x > moveTargetPosition.x - 1 &&
          position.x < moveTargetPosition.x + 1 &&
          position.y > moveTargetPosition.y - 1 &&
          position.y < moveTargetPosition.y + 1) {
        position = moveTargetPosition;
        if (energyBar != null) {
          energyBar.position = position - new Zei.Vector2(size * Tile.size / 2 - 2, size * Tile.size / 2 - 4);
        }
        healthBar.position = position - new Zei.Vector2(size * Tile.size / 2 - 2, -size * Tile.size / 2 + 7);
        status = "FALLING";
      }
      
      updateDisplayObjects();
    }
  }

  void takeDamage() {
    // buildings can only be damaged while not moving
    if (status == "IDLE") {

      var oldHealth = health;
      for (int i = -(size ~/ 2); i <= (size ~/ 2); i++) {
        for (int j = -(size ~/ 2); j <= -(size ~/ 2); j++) {
          Zei.Vector2 tempPosition = position + new Zei.Vector2(i * Tile.size, j * Tile.size);
          Tile tile = game.world.getTile(tempPosition);
          if (tile.creep > 0) {
            health -= tile.creep / 10;
          }
        }
      }
      
      if (health != oldHealth) {
        healthBar.visible = true;    
        healthBar.size.x = ((size * Tile.size - 4) / maxHealth) * health;
      }

      if (health < 0) {
        Building.remove(this);
      }
    }
  }
  
  void shieldAction() {
    if (built && operating && type == "shield" && status == "IDLE") {

      for (int i = -radius; i <= radius; i++) {
        for (int j = -radius; j <= radius; j++) {
          Zei.Vector2 tempPosition = position + new Zei.Vector2(i * Tile.size, j * Tile.size);
          if (game.world.contains(tempPosition / Tile.size)) {  
            var distance = position.distanceTo(tempPosition + new Zei.Vector2(8, 8));
            if (distance < Tile.size * 10) {
              Tile tile = game.world.getTile(tempPosition);
              if (tile.creep > 0) {
                tile.creep -= distance / Tile.size * .1; // the closer to the shield the more creep is removed
                tile.creep = Zei.clamp(tile.creep, 0, 1000);
                World.creeperDirty = true;
              }
            }
          }
        }
      }

    }
  }

  void requestPacket() {
    if (active && status == "IDLE" && type != "base") {
      requestCounter += 1 * game.speed;
      if (requestCounter >= 50) {
        // request health
        num healthAndRequestDelta = maxHealth - health - healthRequests;
        if (healthAndRequestDelta > 0) {
          requestCounter -= 50;
          queuePacket("health");
        }
        // request energy
        if (needsEnergy && built) {
          num energyAndRequestDelta = maxEnergy - energy - energyRequests;
          if (energyAndRequestDelta > 0) {
            requestCounter -= 50;
            queuePacket("energy");
          }
        }
      }
    }
  }
  
  /**
   * Creates a new requested packet with its [target]
   * and [type] and queues it.
   */
  void queuePacket(String type) {
    Packet packet = new Packet(Building.base, this, type);
    if (packet.findRoute()) {
      if (packet.type == "health")
        packet.target.healthRequests++;
      else if (packet.type == "energy")
        packet.target.energyRequests += 4;
      Building.addToQueue(packet);
    }
  }

  void collectEnergy() {
    if (active) {
      if (type == "collector" && built) {
        int height = game.world.getTile(position).height;
  
        for (int i = -5; i < 7; i++) {
          for (int j = -5; j < 7; j++) {
            Zei.Vector2 tempPosition = position + new Zei.Vector2(i * Tile.size, j * Tile.size);
            if (game.world.contains(tempPosition / Tile.size)) {
              int tileHeight = game.world.getTile(tempPosition).height;
  
              if (position.distanceTo(tempPosition + new Zei.Vector2(8, 8)) < Tile.size * 6) {
                if (tileHeight == height) {
                  if (game.world.getTile(tempPosition).collector == this)
                    collectedEnergy += 1;
                }
              }
            }
          }
        }
      }
      
      if (type == "reactor" && built) {
        collectedEnergy += 50;
      }
      
      if (type == "base") {
        collectedEnergy += 100;
      }
  
      if (collectedEnergy >= 100) {
        collectedEnergy -= 100;
        if (type == "collector") {
          Packet packet = new Packet(this, Building.base, "collection");
          if (packet.findRoute())
            packet.send();
          else
            Zei.renderer["buffer"].removeDisplayObject(packet.sprite);
        }
        if (type == "reactor" || type == "base") {
          Building.base.energy += 1;
          if (Building.base.energy > Building.base.maxEnergy)
            Building.base.energy = Building.base.maxEnergy;
          game.updateEnergyElement();
        }
      }
    }
  }

/**
   * Updates the collector property of each tile when a [collector]
   * is added or removed which is defined by the [action].
   */
  void updateCollection(String action) {
    int height = game.world.getTile(position).height;

    for (int i = -radius; i <= radius; i++) {
      for (int j = -radius; j <= radius; j++) {

        var tiledPosition = Tile.position(position);
        Zei.Vector2 positionCurrent = new Zei.Vector2(tiledPosition.x + i, tiledPosition.y + j);

        if (game.world.contains(positionCurrent)) {
          Zei.Vector2 positionCurrentCenter = new Zei.Vector2(positionCurrent.x * Tile.size + (Tile.size / 2), positionCurrent.y * Tile.size + (Tile.size / 2));
          int tileHeight = game.world.tiles[positionCurrent.x][positionCurrent.y].height;

          if (position.distanceTo(positionCurrentCenter) < Tile.size * 6) {
            if (tileHeight == height) {
              if (action == "add") {
                game.world.tiles[positionCurrent.x][positionCurrent.y].collector = this;
              } else if (action == "remove") {
                game.world.tiles[positionCurrent.x][positionCurrent.y].collector = null;

                // check if another collector can take this tile
                for (var building in Zei.GameObject.gameObjects) {
                  if (building is Building) {
                    if (building != this && building.type == "collector") {
                      int heightK = game.world.getTile(building.position).height;
                      Zei.Vector2 centerBuildingK = building.position;
                      if (centerBuildingK.distanceTo(positionCurrentCenter) < Tile.size * 6) {
                        if (tileHeight == heightK) {
                          game.world.tiles[positionCurrent.x][positionCurrent.y].collector = building;
                          break;
                        }
                      }
                    }
                  }
                }
              }
            }
          }

        }

      }
    }

    game.drawCollection();
  }

  void checkOperating() {
    operating = false;
    if (built && needsEnergy && active && status == "IDLE") {

      energyCounter += 1 * game.speed;

      if (type == "analyzer") {
        Emitter.find(this);
      }

      if (type == "terp" && energy > 0) {
        // find lowest tile
        if (weaponTargetPosition == null) {
          terpLineInner.visible = false;
          terpLineOuter.visible = false;
          int lowestTile = 10;
          
          var positionTiled = Tile.position(position);
          for (int i = -radius; i <= radius; i++) {
            for (int j = -radius; j <= radius; j++) {

              Zei.Vector2 tilePosition = positionTiled + new Zei.Vector2(i, j);
              
              if (game.world.contains(tilePosition) && game.world.tiles[tilePosition.x][tilePosition.y].terraformTarget > -1 && game.world.tiles[tilePosition.x][tilePosition.y].creep == 0) {
                int tileHeight = game.world.tiles[tilePosition.x][tilePosition.y].height;
                
                if (tileHeight <= lowestTile && (tilePosition * Tile.size + new Zei.Vector2(8, 8)).distanceTo(position) <= radius * Tile.size) {
                  lowestTile = tileHeight;
                  weaponTargetPosition = new Zei.Vector2(tilePosition.x, tilePosition.y);
                  terpLineInner.to = weaponTargetPosition * Tile.size + new Zei.Vector2(8, 8);
                  terpLineOuter.to = weaponTargetPosition * Tile.size + new Zei.Vector2(8, 8);
                }
              }
            }
          }
        } else {
          if (energyCounter >= 20) {
            energyCounter -=20;
            energy -= 1;
            terpLineInner.visible = true;
            terpLineOuter.visible = true;
          }

          operating = true;
          Tile terraformElement = game.world.tiles[weaponTargetPosition.x][weaponTargetPosition.y];
          terraformElement.terraformProgress += 1;
          if (terraformElement.terraformProgress == 100) {
            terraformElement.terraformProgress = 0;

            int height = game.world.tiles[weaponTargetPosition.x][weaponTargetPosition.y].height;
            List tilesToRedraw = new List();

            if (height < terraformElement.terraformTarget) {
              game.world.tiles[weaponTargetPosition.x][weaponTargetPosition.y].height++;
              tilesToRedraw
                ..add(new Zei.Vector3(weaponTargetPosition.x, weaponTargetPosition.y, height + 1))
                ..add(new Zei.Vector3(weaponTargetPosition.x - 1, weaponTargetPosition.y, height + 1))
                ..add(new Zei.Vector3(weaponTargetPosition.x, weaponTargetPosition.y - 1, height + 1))
                ..add(new Zei.Vector3(weaponTargetPosition.x + 1, weaponTargetPosition.y, height + 1))
                ..add(new Zei.Vector3(weaponTargetPosition.x, weaponTargetPosition.y + 1, height + 1));
            } else {
              game.world.tiles[weaponTargetPosition.x][weaponTargetPosition.y].height--;
              tilesToRedraw
                ..add(new Zei.Vector3(weaponTargetPosition.x, weaponTargetPosition.y, height))
                ..add(new Zei.Vector3(weaponTargetPosition.x - 1, weaponTargetPosition.y, height))
                ..add(new Zei.Vector3(weaponTargetPosition.x, weaponTargetPosition.y - 1, height))
                ..add(new Zei.Vector3(weaponTargetPosition.x + 1, weaponTargetPosition.y, height))
                ..add(new Zei.Vector3(weaponTargetPosition.x, weaponTargetPosition.y + 1, height));
            }

            game.redrawTerrain(tilesToRedraw);

            if (height == game.world.tiles[weaponTargetPosition.x][weaponTargetPosition.y].terraformTarget) {
              game.world.tiles[weaponTargetPosition.x][weaponTargetPosition.y].unflagTerraform();
            }

            weaponTargetPosition = null;
            //operating = false;
          }
        }
      }

      else if (type == "shield") {
        shield.visible = false;
        if (energy > 0) {
          shield.visible = false;
          if (energyCounter >= 20) {
            energyCounter -= 20;
            energy -= 1;
          }
          operating = true;
          shield.visible = true;
        }
      }

      else if (type == "cannon" && energy > 0 && energyCounter >= 15) {
        if (!rotating) {

          energyCounter = 0;

          int height = game.world.getTile(position).height;

          num closestDistance = 1000;
          List targets = new List();

          // find closest random target
          var targetPositionTiled = Tile.position(position);
          for (int i = -radius; i <= radius; i++) {
            for (int j = -radius; j <= radius; j++) {

              Zei.Vector2 tilePosition = targetPositionTiled + new Zei.Vector2(i, j);

              // cannons can only shoot at tiles not higher than themselves
              if (game.world.contains(tilePosition) && game.world.tiles[tilePosition.x][tilePosition.y].creep > 0) {
                int tileHeight = game.world.tiles[tilePosition.x][tilePosition.y].height;
                if (tileHeight <= height) {

                  num distance = (tilePosition * Tile.size + new Zei.Vector2(8, 8)).distanceTo(position);

                  if (distance <= pow(radius * Tile.size, 2) && distance <= closestDistance) {
                    closestDistance = distance;
                    targets.add(tilePosition);
                  }
                }
              }
            }
          }

          if (targets.length > 0) {
            var target = Zei.randomElementOfList(targets);
            targetAngle = position.angleTo(new Zei.Vector2(target.x * Tile.size + Tile.size / 2, target.y * Tile.size + Tile.size / 2)).floor();
            weaponTargetPosition = new Zei.Vector2(target.x, target.y);
            rotating = true;
          }
        }
        else {
          if (rotation != targetAngle) {
            // rotate to target
            int turnRate = 5;
            int absoluteDelta = (targetAngle - rotation).abs();

            if (absoluteDelta < turnRate)
              turnRate = absoluteDelta;

            if (absoluteDelta <= 180)
              if (targetAngle < rotation)
                rotation -= turnRate;
              else
                rotation += turnRate;
            else
              if (targetAngle < rotation)
                rotation += turnRate;
              else
                rotation -= turnRate;

            if (rotation > 180)
              rotation -= 360;
            if (rotation < -180)
              rotation += 360;

            if (cannon != null)
              cannon.rotation = rotation;
          }
          else {
            // fire projectile
            rotating = false;
            energy -= 1;
            operating = true;
            Projectile.add(position, new Zei.Vector2(weaponTargetPosition.x * Tile.size + Tile.size / 2, weaponTargetPosition.y * Tile.size + Tile.size / 2), targetAngle);
            Zei.Audio.play("laser", position, game.scroll, game.zoom);
          }
        }
      }

      else if (type == "mortar" && energy > 0 && energyCounter >= 200) {
        energyCounter =- 200;

        // find most creep in range
        Zei.Vector2 target = null;
          var highestCreep = 0;
          var tiledPosition = Tile.position(position);
          for (int i = tiledPosition.x - radius; i <= tiledPosition.x + radius; i++) {
            for (int j = tiledPosition.y - radius; j <= tiledPosition.y + radius; j++) {
              if (game.world.contains(new Zei.Vector2(i, j))) {
                var distance = pow((i * Tile.size + Tile.size / 2) - position.x, 2) + pow((j * Tile.size + Tile.size / 2) - position.y, 2);

                if (distance <= pow(radius * Tile.size, 2) && game.world.tiles[i][j].creep > 0 && game.world.tiles[i][j].creep >= highestCreep) {
                  highestCreep = game.world.tiles[i][j].creep;
                  target = new Zei.Vector2(i, j);
                }
              }
            }
          }
          if (target != null) {
            Zei.Audio.play("shot", position, game.scroll, game.zoom);
            Shell.add(position, new Zei.Vector2(target.x * Tile.size + Tile.size / 2, target.y * Tile.size + Tile.size / 2));
            energy -= 1;
          }
        }

      else if (type == "beam") {
        beamLineInner.visible = false;
        beamLineOuter.visible = false;
        if (energy > 0 && energyCounter > 0) {
          energyCounter = 0;  
          Spore.damage(this);
        }
      }
      
      energyBar.size.x = ((size * Tile.size - 4) / maxEnergy) * energy;
    }
  }
  
  static void drawRepositionInfo() {
    CanvasRenderingContext2D context = Zei.renderer["buffer"].context;
        
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building) {
        if (building.built && building.selected && building.canMove) {
          game.mouse.hideCursor();
          
          Zei.Vector2 positionI = game.convertToView("main", game.hoveredTile * Tile.size + new Zei.Vector2(Tile.size / 2 * game.zoom, Tile.size / 2 * game.zoom));
          
          game.world.hideRangeBoxes();
          game.updateRangeBoxes(game.hoveredTile, building);
     
          if (game.canBePlaced(game.hoveredTile, building)) {
            // draw lines to other buildings
            for (var building2 in Zei.GameObject.gameObjects) {
              if (building2 is Building) {
                if (building != building2) {
                  if (building.type == "base" || building2.type == "collector" || building2.type == "relay" || building2.type == "base") {
                    Zei.Vector2 positionJ = game.convertToView("main", building2.position);
    
                    int allowedDistance = 10 * Tile.size;
                    if (building2.type == "relay" && building.type == "relay") {
                      allowedDistance = 20 * Tile.size;
                    }
    
                    if (positionJ.distanceTo(positionI) <= allowedDistance * game.zoom) {
                      context
                        ..strokeStyle = '#000'
                        ..lineWidth = 3 * game.zoom
                        ..beginPath()
                        ..moveTo(positionJ.x, positionJ.y)
                        ..lineTo(positionI.x, positionI.y)
                        ..stroke()
                        ..strokeStyle = '#0f0'
                        ..lineWidth = 2 * game.zoom
                        ..stroke();
                    }
                  }
                }
              }
            }
          }
  
        }
      }
    }
  }
}