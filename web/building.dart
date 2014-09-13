part of creeper;

class Building extends GameObject {
  Vector position, scale = new Vector(1, 1), moveTargetPosition, weaponTargetPosition, speed = new Vector(0, 0);
  String type, status = "IDLE"; // MOVING, RISING, FALLING
  bool operating = false, selected = false, hovered = false, built = false, active = true, canMove = false, needsEnergy = false, rotating = false;
  num health, maxHealth = 0, energy, maxEnergy = 0, healthRequests = 0, energyRequests = 0, rotation = 0;
  int targetAngle, weaponRadius = 0, size, collectedEnergy = 0, flightCounter = 0, requestCounter = 0, energyCounter = 0;
  Ship ship;
  Sprite sprite, cannon;
  Circle selectedCircle;
  Rect targetSymbol;
  static final double baseSpeed = .5;
  int damageCounter = 0, collectCounter = 0;
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
      weaponRadius = 10;
    }
    else if (type == "terp") {
      maxHealth = 60;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      weaponRadius = 20;
    }
    else if (type == "shield") {
      maxHealth = 75;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      weaponRadius = 10;
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
    }
    else if (type == "relay") {
      maxHealth = 10;
    }
    else if (type == "cannon") {
      maxHealth = 25;
      maxEnergy = 40;
      weaponRadius = 10;
      canMove = true;
      needsEnergy = true;
      energyCounter = 15;
    }
    else if (type == "mortar") {
      maxHealth = 40;
      maxEnergy = 20;
      weaponRadius = 14;
      canMove = true;
      needsEnergy = true;
      energyCounter = 200;
    }
    else if (type == "beam") {
      maxHealth = 20;
      maxEnergy = 10;
      weaponRadius = 20;
      canMove = true;
      needsEnergy = true;
    }
  }
  
  Building(position, imageID) {
    type = imageID;
    this.position = position;
    sprite = new Sprite("buffer", Layer.BUILDING, game.engine.images[imageID], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    sprite.alpha = 0.5;

    selectedCircle = new Circle("buffer", Layer.SELECTEDCIRCLE, position, 24, 2, "#fff");
    selectedCircle.visible = false;
      
    health = 0;
    size = 3;
    energy = 0;
    
    if (type == "base") {
      sprite.size = new Vector(144, 144);
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
      weaponRadius = 10;
    }
    else if (type == "terp") {
      maxHealth = game.debug == true ? 1 : 60;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      weaponRadius = 20;
    }
    else if (type == "shield") {
      maxHealth = game.debug == true ? 1 : 75;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      weaponRadius = 10;
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
    }
    else if (type == "relay") {
      maxHealth = game.debug == true ? 1 : 10;
    }
    else if (type == "cannon") {
      maxHealth = game.debug == true ? 1 : 25;
      maxEnergy = 40;
      weaponRadius = 10;
      canMove = true;
      needsEnergy = true;
      energyCounter = 15;
      
      cannon = new Sprite("buffer", Layer.BUILDINGGUN, game.engine.images["cannongun"], position, 48, 48);
      cannon.anchor = new Vector(0.5, 0.5);
      cannon.alpha = 0.5;
    }
    else if (type == "mortar") {
      maxHealth = game.debug == true ? 1 : 40;
      maxEnergy = 20;
      weaponRadius = 14;
      canMove = true;
      needsEnergy = true;
      energyCounter = 200;
    }
    else if (type == "beam") {
      maxHealth = game.debug == true ? 1 : 20;
      maxEnergy = 10;
      weaponRadius = 20;
      canMove = true;
      needsEnergy = true;
    }
    
    targetSymbol = new Rect("buffer", Layer.TARGETSYMBOL, new Vector.empty(), new Vector(size * game.tileSize, size * game.tileSize), 1, '#0f0');
    targetSymbol.visible = false;
    targetSymbol.anchor = new Vector(0.5, 0.5);
    
    Connection.add(this);
  }
     
  /**
   * Adds a building of a given [type] at the given [position].
   */
  static Building add(Vector position, String type) {
    position = position * 16 + new Vector(8, 8);
    Building building = new Building(position, type);
    if (type == "base") base = building;
    game.engine.addGameObject(building);
    return building;
  }
  
  /**
   * Removes a [building].
   */
  static void remove(Building building) {

    // only explode building when it has been built
    if (building.built) {
      Explosion.add(building.position);
      game.engine.playSound("explosion", building.position, game.scroll, game.zoom);
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

    game.engine.renderer["buffer"].removeDisplayObject(building.sprite);
    game.engine.renderer["buffer"].removeDisplayObject(building.selectedCircle);
    game.engine.renderer["buffer"].removeDisplayObject(building.targetSymbol);
    if (building.cannon != null)
      game.engine.renderer["buffer"].removeDisplayObject(building.cannon);

    game.engine.gameObjects.remove(building);
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
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
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
      for (var building in game.engine.gameObjects) {
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
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
        building.selected = false;
        building.selectedCircle.visible = false;
      }
    }
    querySelector('#deactivate').style.display = "none";
    querySelector('#activate').style.display = "none";
  }
  
  void updateHoverState() {
    Vector realPosition = game.real2screen(position);
    hovered = (game.mouse.position.x > realPosition.x - (game.tileSize * size * game.zoom / 2) &&
        game.mouse.position.x < realPosition.x + (game.tileSize * size * game.zoom / 2) &&
        game.mouse.position.y > realPosition.y - (game.tileSize * size * game.zoom / 2) &&
        game.mouse.position.y < realPosition.y + (game.tileSize * size * game.zoom / 2));
  }
  
  void update() {
    updateHoverState();
    
    if (!game.paused) {
      move();
      checkOperating();
      shield();
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
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
        if (building.selected)
          building.active = true;
      }
    }
  }
  
  static void deactivate() {
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
        if (building.selected) {
          building.active = false;
          
          if (building.type == "analyzer") {
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
    }
  }
  
  static void reposition(Vector position) { 
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
        if (building.built && building.selected && building.canMove) {
          // check if it can be placed
          if (game.canBePlaced(position, building)) {
            game.engine.renderer["main"].view.style.cursor = "url('images/Normal.cur') 2 2, pointer";
            building.operating = false;
            building.rotating = false;
            building.weaponTargetPosition = null;
            building.status = "RISING";
            building.moveTargetPosition = (position * game.tileSize) + new Vector(8, 8);
            building.targetSymbol.visible = true;
            building.targetSymbol.position = (position * game.tileSize) + new Vector(8, 8);
            Connection.remove(building);
          }
        }
      }
    }
  }
  
  static bool intersect(Rectangle rectangle, [Building building2]) {  
    // check stationary buildings
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
        if (building2 != null && building2 == building)
          continue;
        
        Rectangle buildingRect = null;
        // check flying buildings
        if (building.status != "IDLE") {
          buildingRect = new Rectangle(building.moveTargetPosition.x - building.size * game.tileSize / 2,
                                       building.moveTargetPosition.y - building.size * game.tileSize / 2,
                                       building.size * game.tileSize - 1,
                                       building.size * game.tileSize - 1);  
        } 
        // check stationary buildings
        else { 
          buildingRect = new Rectangle(building.position.x - building.size * game.tileSize / 2,
                                       building.position.y - building.size * game.tileSize / 2,
                                       building.size * game.tileSize - 1,
                                       building.size * game.tileSize - 1);  
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
    
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
        // must not be the same building
        if (building.position != position) {
          // must be idle
          if (building.status == "IDLE") {
            // it must either be the target or be built
            if (building == target || (building.built && (building.type == "collector" || building.type == "relay"))) {
  
                int allowedDistance = 10 * game.tileSize;
                if (type == "relay" && building.type == "relay") {
                  allowedDistance = 20 * game.tileSize;
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
        game.engine.renderer["buffer"].switchLayer(sprite, Layer.BUILDINGFLYING);
        if (cannon != null)
          game.engine.renderer["buffer"].switchLayer(cannon, Layer.BUILDINGGUNFLYING);
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
        scale = new Vector(1.0, 1.0);
        targetSymbol.visible = false;
        updateDisplayObjects();
        Connection.add(this);
        game.engine.renderer["buffer"].switchLayer(sprite, Layer.BUILDING);
        if (cannon != null)
          game.engine.renderer["buffer"].switchLayer(cannon, Layer.BUILDINGGUN);
      }
    }

    if (status == "MOVING") {
      if (moveTargetPosition.x != position.x || moveTargetPosition.y != position.y) {
        position += game.engine.calculateVelocity(position, moveTargetPosition, Building.baseSpeed * game.speed);
      }    
      
      if (position.x > moveTargetPosition.x - 1 &&
          position.x < moveTargetPosition.x + 1 &&
          position.y > moveTargetPosition.y - 1 &&
          position.y < moveTargetPosition.y + 1) {
        position = moveTargetPosition;
        status = "FALLING";
      }
      
      updateDisplayObjects();
    }
  }

  void takeDamage() {
    // buildings can only be damaged while not moving
    if (status == "IDLE") {

      for (int i = -(size ~/ 2); i <= (size ~/ 2); i++) {
        for (int j = -(size ~/ 2); j <= -(size ~/ 2); j++) {
          Vector tempPosition = position + new Vector(i * game.tileSize, j * game.tileSize);
          Tile tile = game.world.getTile(tempPosition);
          if (tile.creep > 0) {
            health -= tile.creep / 10;
          }
        }
      }

      if (health < 0) {
        Building.remove(this);
      }
    }
  }
  
  void shield() {
    if (built && operating && type == "shield" && status == "IDLE") {

      for (int i = -weaponRadius; i <= weaponRadius; i++) {
        for (int j = -weaponRadius; j <= weaponRadius; j++) {
          Vector tempPosition = position + new Vector(i * game.tileSize, j * game.tileSize);
          if (game.world.contains(tempPosition / game.tileSize)) {  
            var distance = position.distanceTo(tempPosition + new Vector(8, 8));
            if (distance < game.tileSize * 10) {
              Tile tile = game.world.getTile(tempPosition);
              if (tile.creep > 0) {
                tile.creep -= distance / game.tileSize * .1; // the closer to the shield the more creep is removed
                if (tile.creep < 0) {
                  tile.creep = 0;
                }
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
    if (type == "collector" && built) {
      int height = game.world.getTile(position).height;

      for (int i = -5; i < 7; i++) {
        for (int j = -5; j < 7; j++) {
          Vector tempPosition = position + new Vector(i * game.tileSize, j * game.tileSize);
          if (game.world.contains(tempPosition / game.tileSize)) {
            int tileHeight = game.world.getTile(tempPosition).height;

            if (position.distanceTo(tempPosition + new Vector(8, 8)) < game.tileSize * 6) {
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
          game.engine.renderer["buffer"].removeDisplayObject(packet.sprite);
      }
      if (type == "reactor" || type == "base") {
        Building.base.energy += 1;
        if (Building.base.energy > Building.base.maxEnergy)
          Building.base.energy = Building.base.maxEnergy;
        game.updateEnergyElement();
      }
    }
  }

/**
   * Updates the collector property of each tile when a [collector]
   * is added or removed which is defined by the [action].
   */
  void updateCollection(String action) {
    int height = game.world.getTile(position).height;

    for (int i = -5; i < 7; i++) {
      for (int j = -5; j < 7; j++) {

        var tiledPosition = game.real2tiled(position);
        Vector positionCurrent = new Vector(tiledPosition.x + i, tiledPosition.y + j);

        if (game.world.contains(positionCurrent)) {
          Vector positionCurrentCenter = new Vector(positionCurrent.x * game.tileSize + (game.tileSize / 2), positionCurrent.y * game.tileSize + (game.tileSize / 2));
          int tileHeight = game.world.tiles[positionCurrent.x][positionCurrent.y].height;

          if (position.distanceTo(positionCurrentCenter) < game.tileSize * 6) {
            if (tileHeight == height) {
              if (action == "add") {
                game.world.tiles[positionCurrent.x][positionCurrent.y].collector = this;
              } else if (action == "remove") {
                game.world.tiles[positionCurrent.x][positionCurrent.y].collector = null;

                // check if another collector can take this tile
                for (var building in game.engine.gameObjects) {
                  if (building is Building) {
                    if (building != this && building.type == "collector") {
                      int heightK = game.world.getTile(building.position).height;
                      Vector centerBuildingK = building.position;
                      if (centerBuildingK.distanceTo(positionCurrentCenter) < game.tileSize * 6) {
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
          int lowestTile = 10;
          
          var positionTiled = game.real2tiled(position);
          for (int i = -weaponRadius; i <= weaponRadius; i++) {
            for (int j = -weaponRadius; j <= weaponRadius; j++) {

              Vector tilePosition = positionTiled + new Vector(i, j);
              
              if (game.world.contains(tilePosition) && game.world.tiles[tilePosition.x][tilePosition.y].terraformTarget > -1 && game.world.tiles[tilePosition.x][tilePosition.y].creep == 0) {
                int tileHeight = game.world.tiles[tilePosition.x][tilePosition.y].height;
                
                if (tileHeight <= lowestTile && (tilePosition * game.tileSize + new Vector(8, 8)).distanceTo(position) <= weaponRadius * game.tileSize) {
                  lowestTile = tileHeight;
                  weaponTargetPosition = new Vector(tilePosition.x, tilePosition.y);
                }
              }
            }
          }
        } else {
          if (energyCounter >= 20) {
            energyCounter -=20;
            energy -= 1;
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
                ..add(new Vector3(weaponTargetPosition.x, weaponTargetPosition.y, height + 1))
                ..add(new Vector3(weaponTargetPosition.x - 1, weaponTargetPosition.y, height + 1))
                ..add(new Vector3(weaponTargetPosition.x, weaponTargetPosition.y - 1, height + 1))
                ..add(new Vector3(weaponTargetPosition.x + 1, weaponTargetPosition.y, height + 1))
                ..add(new Vector3(weaponTargetPosition.x, weaponTargetPosition.y + 1, height + 1));
            } else {
              game.world.tiles[weaponTargetPosition.x][weaponTargetPosition.y].height--;
              tilesToRedraw
                ..add(new Vector3(weaponTargetPosition.x, weaponTargetPosition.y, height))
                ..add(new Vector3(weaponTargetPosition.x - 1, weaponTargetPosition.y, height))
                ..add(new Vector3(weaponTargetPosition.x, weaponTargetPosition.y - 1, height))
                ..add(new Vector3(weaponTargetPosition.x + 1, weaponTargetPosition.y, height))
                ..add(new Vector3(weaponTargetPosition.x, weaponTargetPosition.y + 1, height));
            }

            game.redrawTerrain(tilesToRedraw);

            if (height == game.world.tiles[weaponTargetPosition.x][weaponTargetPosition.y].terraformTarget) {
              game.world.tiles[weaponTargetPosition.x][weaponTargetPosition.y].unflagTerraform();
            }

            weaponTargetPosition = null;
            operating = false;
          }
        }
      }

      else if (type == "shield" && energy > 0) {
        if (energyCounter >= 20) {
          energyCounter -= 20;
          energy -= 1;
        }
        operating = true;
      }

      else if (type == "cannon" && energy > 0 && energyCounter >= 15) {
        if (!rotating) {

          energyCounter = 0;

          int height = game.world.getTile(position).height;

          num closestDistance = 1000;
          List targets = new List();

          // find closest random target
          var targetPositionTiled = game.real2tiled(position);
          for (int i = -weaponRadius; i <= weaponRadius; i++) {
            for (int j = -weaponRadius; j <= weaponRadius; j++) {

              Vector tilePosition = targetPositionTiled + new Vector(i, j);

              // cannons can only shoot at tiles not higher than themselves
              if (game.world.contains(tilePosition) && game.world.tiles[tilePosition.x][tilePosition.y].creep > 0) {
                int tileHeight = game.world.tiles[tilePosition.x][tilePosition.y].height;
                if (tileHeight <= height) {

                  num distance = (tilePosition * game.tileSize + new Vector(8, 8)).distanceTo(position);

                  if (distance <= pow(weaponRadius * game.tileSize, 2) && distance <= closestDistance) {
                    closestDistance = distance;
                    targets.add(tilePosition);
                  }
                }
              }
            }
          }

          if (targets.length > 0) {
            targets.shuffle();

            var dx = targets[0].x * game.tileSize + game.tileSize / 2 - position.x;
            var dy = targets[0].y * game.tileSize + game.tileSize / 2 - position.y;

            targetAngle = Engine.rad2deg(atan2(dy, dx)).floor();
            weaponTargetPosition = new Vector(targets[0].x, targets[0].y);
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
            Projectile.add(position, new Vector(weaponTargetPosition.x * game.tileSize + game.tileSize / 2, weaponTargetPosition.y * game.tileSize + game.tileSize / 2), targetAngle);
            game.engine.playSound("laser", position, game.scroll, game.zoom);
          }
        }
      }

      else if (type == "mortar" && energy > 0 && energyCounter >= 200) {
        energyCounter =- 200;

          // find most creep in range
          Vector target = null;
          var highestCreep = 0;
          var tiledPosition = game.real2tiled(position);
          for (int i = tiledPosition.x - weaponRadius; i <= tiledPosition.x + weaponRadius; i++) {
            for (int j = tiledPosition.y - weaponRadius; j <= tiledPosition.y + weaponRadius; j++) {
              if (game.world.contains(new Vector(i, j))) {
                var distance = pow((i * game.tileSize + game.tileSize / 2) - position.x, 2) + pow((j * game.tileSize + game.tileSize / 2) - position.y, 2);

                if (distance <= pow(weaponRadius * game.tileSize, 2) && game.world.tiles[i][j].creep > 0 && game.world.tiles[i][j].creep >= highestCreep) {
                  highestCreep = game.world.tiles[i][j].creep;
                  target = new Vector(i, j);
                }
              }
            }
          }
          if (target != null) {
            game.engine.playSound("shot", position, game.scroll, game.zoom);
            Shell.add(position, new Vector(target.x * game.tileSize + game.tileSize / 2, target.y * game.tileSize + game.tileSize / 2));
            energy -= 1;
          }
        }

      else if (type == "beam" && energy > 0 && energyCounter > 0) {
        energyCounter = 0;

        Spore.damage(this);
      }
    }
  }
  
  static void drawRepositionInfo() {
    CanvasRenderingContext2D context = game.engine.renderer["buffer"].context;
        
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
        if (building.built && building.selected && building.canMove) {
          game.engine.renderer["main"].view.style.cursor = "none";
          
          Vector positionI = game.tiled2screen(game.hoveredTile) + new Vector(8 * game.zoom, 8 * game.zoom);
     
          game.drawRangeBoxes(game.hoveredTile, building);
    
          bool canBePlaced = game.canBePlaced(game.hoveredTile, building);
  
          if (canBePlaced) {
            // draw lines to other buildings
            for (var building2 in game.engine.gameObjects) {
              if (building2 is Building) {
                if (building != building2) {
                  if (building.type == "base" || building2.type == "collector" || building2.type == "relay" || building2.type == "base") {
                    Vector positionJ = game.real2screen(building2.position);
    
                    int allowedDistance = 10 * game.tileSize;
                    if (building2.type == "relay" && building.type == "relay") {
                      allowedDistance = 20 * game.tileSize;
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

  static void draw() {
    CanvasRenderingContext2D context = game.engine.renderer["buffer"].context;
    
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
        Vector realPosition = game.real2screen(building.position);
    
        if (game.engine.renderer["buffer"].isVisible(building.sprite)) {
          // draw energy bar
          if (building.needsEnergy) {
            context.fillStyle = '#f00';
            context.fillRect(realPosition.x - (building.size * game.tileSize / 2 - 2) * game.zoom,
                             realPosition.y - (building.size * game.tileSize / 2 - 4) * game.zoom,
                             ((building.size * game.tileSize * game.zoom - 4) / building.maxEnergy) * building.energy,
                             3 * game.zoom);
          }
    
          // draw health bar (only if health is below maxHealth)
          if (building.health < building.maxHealth) {
            context.fillStyle = '#0f0';
            context.fillRect(realPosition.x - (building.size * game.tileSize / 2 - 2) * game.zoom,
                             realPosition.y + (building.size * game.tileSize / 2 - 4) * game.zoom,
                             ((building.size * game.tileSize * game.zoom - 4) / building.maxHealth) * building.health,
                             3 * game.zoom);
          }
    
          // draw inactive sign
          if (!building.active) {
            context.strokeStyle = "#F00";
            context.lineWidth = 2 * game.zoom;
    
            context.beginPath();
            context.arc(realPosition.x, realPosition.y, (game.tileSize / 2) * building.size, 0, PI * 2, true);
            context.closePath();
            context.stroke();
    
            context.beginPath();
            context.moveTo(realPosition.x - (game.tileSize * building.size / 3), realPosition.y + (game.tileSize * building.size / 3));
            context.lineTo(realPosition.x + (game.tileSize * building.size / 3), realPosition.y - (game.tileSize * building.size / 3));
            context.stroke();
          }
        }
    
        // draw various stuff when operating
        if (building.operating) {
          if (building.type == "analyzer") {
            Vector targetPosition = game.real2screen(building.weaponTargetPosition);
            context
              ..strokeStyle = '#00f'
              ..lineWidth = 5 * game.zoom
              ..beginPath()
              ..moveTo(realPosition.x, realPosition.y)
              ..lineTo(targetPosition.x, targetPosition.y)
              ..stroke()
              ..strokeStyle = '#fff'
              ..lineWidth = 3 * game.zoom
              ..stroke();
          }
          else if (building.type == "beam") {
            Vector targetPosition = game.real2screen(building.weaponTargetPosition);
            context
              ..strokeStyle = '#f00'
              ..lineWidth = 5 * game.zoom
              ..beginPath()
              ..moveTo(realPosition.x, realPosition.y)
              ..lineTo(targetPosition.x, targetPosition.y)
              ..stroke()
              ..strokeStyle = '#fff'
              ..lineWidth = 3 * game.zoom
              ..stroke();
          }
          else if (building.type == "shield") {
            context
              ..save()
              ..globalAlpha = .5
              ..drawImageScaled(game.engine.images["forcefield"], realPosition.x - 168 * game.zoom, realPosition.y - 168 * game.zoom, 336 * game.zoom, 336 * game.zoom)
              ..restore();
          }
          else if (building.type == "terp") {
            Vector targetPosition = game.tiled2screen(building.weaponTargetPosition);
    
            context
              ..strokeStyle = '#f00'
              ..lineWidth = 4 * game.zoom
              ..beginPath()
              ..moveTo(realPosition.x, realPosition.y)
              ..lineTo(targetPosition.x + 8, targetPosition.y + 8)
              ..stroke()
              ..strokeStyle = '#fff'
              ..lineWidth = 2 * game.zoom
              ..stroke();
          }
        }
      }
    }

  }
}