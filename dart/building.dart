part of creeper;

class Building {
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
  static int damageCounter = 0, collectCounter = 0;
  static List<Building> buildings = new List<Building>();

  Building(position, imageID) {
    type = imageID;
    this.position = position;
    sprite = new Sprite(Layer.BUILDING, engine.images[imageID], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    sprite.alpha = 0.5;
    engine.renderer["buffer"].addDisplayObject(sprite);

    selectedCircle = new Circle(Layer.SELECTEDCIRCLE, position, 24, 2, "#fff");
    selectedCircle.visible = false;
    engine.renderer["buffer"].addDisplayObject(selectedCircle);
    
    targetSymbol = new Rect(Layer.TARGETSYMBOL, new Vector.empty(), new Vector(48, 48), 1, '#0f0');
    targetSymbol.visible = false;
    targetSymbol.anchor = new Vector(0.5, 0.5);
    engine.renderer["buffer"].addDisplayObject(targetSymbol);
    
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
    }   
    else if (type == "analyzer") {
      maxHealth = 1; // 80
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      weaponRadius = 10;
    }
    else if (type == "terp") {
      maxHealth = 1; // 60
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      weaponRadius = 20;
    }
    else if (type == "shield") {
      maxHealth = 1; // 75
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      weaponRadius = 10;
    }
    else if (type == "bomber") {
      maxHealth = 1; // 75
      maxEnergy = 15;
      needsEnergy = true;
    }
    else if (type == "storage") {
      maxHealth = 1; // 8
    }
    else if (type == "reactor") {
      maxHealth = 1; // 50
    }
    else if (type == "collector") {
      maxHealth = 1; // 50
    }
    else if (type == "relay") {
      maxHealth = 1; // 10
    }
    else if (type == "cannon") {
      maxHealth = 1; // 25
      maxEnergy = 40;
      weaponRadius = 10;
      canMove = true;
      needsEnergy = true;
      energyCounter = 10;
      
      cannon = new Sprite(Layer.BUILDINGGUN, engine.images["cannongun"], position, 48, 48);
      cannon.anchor = new Vector(0.5, 0.5);
      cannon.alpha = 0.5;
      engine.renderer["buffer"].addDisplayObject(cannon);
    }
    else if (type == "mortar") {
      maxHealth = 1; //40
      maxEnergy = 20;
      weaponRadius = 14;
      canMove = true;
      needsEnergy = true;
      energyCounter = 200;
    }
    else if (type == "beam") {
      maxHealth = 1; // 20
      maxEnergy = 10;
      weaponRadius = 20;
      canMove = true;
      needsEnergy = true;
    }
    
    Connection.add(this);
  }
  
  static void clear() {
    buildings.clear();
    damageCounter = 0;
  }
    
  /**
   * Adds a building of a given [type] at the given [position].
   */
  static Building add(Vector position, String type) {
    position = position * 16 + new Vector(8, 8);
    Building building = new Building(position, type);
    buildings.add(building);
    return building;
  }
  
  /**
   * Removes a [building].
   */
  static void remove(Building building) {

    // only explode building when it has been built
    if (building.built) {
      Explosion.add(building.position);
      engine.playSound("explosion", building.position.real2tiled());
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
      game.maxEnergy -= 10;
      game.updateEnergyElement();
    }
    if (building.type == "speed") {
      Packet.baseSpeed /= 1.01;
    }

    // find all packets with this building as target and remove them
    Packet.removeWithTarget(building);
    
    Connection.remove(building);

    engine.renderer["buffer"].removeDisplayObject(building.sprite);
    engine.renderer["buffer"].removeDisplayObject(building.selectedCircle);
    engine.renderer["buffer"].removeDisplayObject(building.targetSymbol);
    if (building.cannon != null)
      engine.renderer["buffer"].removeDisplayObject(building.cannon);

    buildings.removeAt(buildings.indexOf(building));
  }
  
  static void removeSelected() {
    for (int i = 0; i < buildings.length; i++) {
      if (buildings[i].selected) {
        if (buildings[i].type != "base")
          Building.remove(buildings[i]);
      }
    }
  }
  
  static void select() {
    if (game.mode == "DEFAULT") {
      Building buildingSelected = null;
      for (int i = 0; i < buildings.length; i++) {
        buildings[i].selected = buildings[i].hovered;
        if (buildings[i].selected) {
          buildingSelected = buildings[i];
          buildings[i].selectedCircle.visible = true;
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
    for (int i = 0; i < buildings.length; i++) {
      buildings[i].selected = false;
      buildings[i].selectedCircle.visible = false;
    }
    querySelector('#deactivate').style.display = "none";
    querySelector('#activate').style.display = "none";
  }
  
  static void updateHoverState() {
    for (int i = 0; i < buildings.length; i++) {
      Vector realPosition = buildings[i].position.real2screen();
      buildings[i].hovered = (engine.mouse.position.x > realPosition.x - (game.tileSize * buildings[i].size * game.zoom / 2) &&
          engine.mouse.position.x < realPosition.x + (game.tileSize * buildings[i].size * game.zoom / 2) &&
          engine.mouse.position.y > realPosition.y - (game.tileSize * buildings[i].size * game.zoom / 2) &&
          engine.mouse.position.y < realPosition.y + (game.tileSize * buildings[i].size * game.zoom / 2));
    }
  }
  
  static void update() {
    for (int i = 0; i < buildings.length; i++) {
      buildings[i].move();
      buildings[i].checkOperating();
      buildings[i].shield();
      buildings[i].requestPacket();
    }

    // take damage
    damageCounter += 1 * game.speed;
    if (damageCounter > 10) {
      damageCounter -= 10;
      for (int i = 0; i < buildings.length; i++) {
        buildings[i].takeDamage();
      }
    }

    // collect energy
    collectCounter += 1 * game.speed;
    if (collectCounter > 250) {
      collectCounter -= 250;
      for (int i = 0; i < buildings.length; i++) {
        buildings[i].collectEnergy();
      }
    }
  }
  
  static void activate() {
    for (int i = 0; i < buildings.length; i++) {
      if (buildings[i].selected)
        buildings[i].active = true;
    }
  }
  
  static void deactivate() {
    for (int i = 0; i < buildings.length; i++) {
      if (buildings[i].selected) {
        buildings[i].active = false;
        
        if (buildings[i].type == "analyzer") {
          for (int j = 0; j < Emitter.emitters.length; j++) {
            if (buildings[i].weaponTargetPosition == Emitter.emitters[j].sprite.position) {
              Emitter.emitters[j].analyzer = null;
              buildings[i].weaponTargetPosition = null;
              break;
            }
          }
        }
        
      }
    }
  }
  
  static void reposition(Vector position) { 
    for (int i = 0; i < buildings.length; i++) {
      if (buildings[i].built && buildings[i].selected && buildings[i].canMove) {
        // check if it can be placed
        if (game.canBePlaced(position, buildings[i].size, buildings[i])) {
          engine.renderer["main"].view.style.cursor = "url('images/Normal.cur') 2 2, pointer";
          buildings[i].operating = false;
          buildings[i].rotating = false;
          buildings[i].weaponTargetPosition = null;
          buildings[i].status = "RISING";
          buildings[i].moveTargetPosition = (position * game.tileSize) + new Vector(8, 8);
          buildings[i].targetSymbol.visible = true;
          buildings[i].targetSymbol.position = (position * game.tileSize) + new Vector(8, 8);
          Connection.remove(buildings[i]);
        }
      }
    }
  }
  
  /**
   * Used for A*, finds all neighbouring buildings.
   * The [target] node is also passed as it is a valid neighbour.
   */
  List getNeighbours(Building target) {
    List neighbours = new List();
    
    for (int i = 0; i < buildings.length; i++) {
      // must not be the same building
      if (buildings[i].position != position) {
        // must be idle
        if (buildings[i].status == "IDLE") {
          // it must either be the target or be built
          if (buildings[i] == target || (buildings[i].built && (buildings[i].type == "collector" || buildings[i].type == "relay"))) {

              int allowedDistance = 10 * game.tileSize;
              if (type == "relay" && buildings[i].type == "relay") {
                allowedDistance = 20 * game.tileSize;
              }
              
              if (position.distanceTo(buildings[i].position) <= allowedDistance) {
                neighbours.add(buildings[i]);
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
        engine.renderer["buffer"].switchLayer(sprite, Layer.BUILDINGFLYING);
        if (cannon != null)
          engine.renderer["buffer"].switchLayer(cannon, Layer.BUILDINGGUNFLYING);
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
        engine.renderer["buffer"].switchLayer(sprite, Layer.BUILDING);
        if (cannon != null)
          engine.renderer["buffer"].switchLayer(cannon, Layer.BUILDINGGUN);
      }
    }

    if (status == "MOVING") {
      calculateVector();
      
      position += speed;
      
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

  void calculateVector() {
    if (moveTargetPosition.x != position.x || moveTargetPosition.y != position.y) {
      Vector targetPosition = new Vector(moveTargetPosition.x, moveTargetPosition.y);
      Vector ownPosition = new Vector(position.x, position.y);
      Vector delta = targetPosition - ownPosition;
      num distance = ownPosition.distanceTo(targetPosition);

      speed.x = (delta.x / distance) * Building.baseSpeed * game.speed;
      speed.y = (delta.y / distance) * Building.baseSpeed * game.speed;
      
      if (speed.x.abs() > delta.x.abs())
        speed.x = delta.x;
      if (speed.y.abs() > delta.y.abs())
        speed.y = delta.y;
    }
  }

  void takeDamage() {
    // buildings can only be damaged while not moving
    if (status == "IDLE") {

      for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
          Tile tile = game.world.getTile(position + new Vector(i * game.tileSize, j * game.tileSize));
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
      Vector center = position;
      var tiledPosition = position.real2tiled();

      for (int i = tiledPosition.x - weaponRadius; i <= tiledPosition.x + weaponRadius; i++) {
        for (int j = tiledPosition.y - weaponRadius; j <= tiledPosition.y + weaponRadius; j++) {
          //if (game.withinWorld(i, j)) {
          if (game.world.contains(new Vector(i, j))) {  
            num distance = pow((i * game.tileSize + game.tileSize / 2) - center.x, 2) + pow((j * game.tileSize + game.tileSize / 2) - center.y, 2);
            if (distance < pow(game.tileSize * 10, 2)) {
              if (game.world.tiles[i][j].creep > 0) {
                game.world.tiles[i][j].creep -= distance / game.tileSize * .1; // the closer to the shield the more creep is removed
                if (game.world.tiles[i][j].creep < 0) {
                  game.world.tiles[i][j].creep = 0;
                }
                game.creeperDirty = true;
              }
            }
          }
        }
      }

    }
  }

  void requestPacket() {
    if (active && status == "IDLE") {
      requestCounter += 1 * game.speed;
      if (requestCounter >= 50) {
        // request health
        if (type != "base") {
          num healthAndRequestDelta = maxHealth - health - healthRequests;
          if (healthAndRequestDelta > 0) {
            requestCounter -= 50;
            Packet.queuePacket(this, "health");
          }
        }
        // request energy
        if (needsEnergy && built) {
          num energyAndRequestDelta = maxEnergy - energy - energyRequests;
          if (energyAndRequestDelta > 0) {
            requestCounter -= 50;
            Packet.queuePacket(this, "energy");
          }
        }
      }
    }
  }

  void collectEnergy() {
    if (type == "collector" && built) {
      int height = game.world.getTile(position).height;
      Vector centerBuilding = position;

      for (int i = -5; i < 7; i++) {
        for (int j = -5; j < 7; j++) {
          var tiledPosition = position.real2tiled();
          Vector positionCurrent = new Vector(tiledPosition.x + i, tiledPosition.y + j);

          if (game.world.contains(positionCurrent)) {
            Vector positionCurrentCenter = new Vector(positionCurrent.x * game.tileSize + (game.tileSize / 2), positionCurrent.y * game.tileSize + (game.tileSize / 2));
            int tileHeight = game.world.tiles[positionCurrent.x][positionCurrent.y].height;

            if (pow(positionCurrentCenter.x - centerBuilding.x, 2) + pow(positionCurrentCenter.y - centerBuilding.y, 2) < pow(game.tileSize * 6, 2)) {
              if (tileHeight == height) {
                if (game.world.tiles[positionCurrent.x][positionCurrent.y].collector == this)
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

    if (collectedEnergy >= 100) {
      collectedEnergy -= 100;
      if (type == "collector") {
        Packet packet = new Packet(position, "packet_collection", "collection");
        packet.target = game.base;
        packet.currentTarget = this;
        if (packet.findRoute())
          Packet.add(packet);
        else
          engine.renderer["buffer"].removeDisplayObject(packet.sprite);
      }
      if (type == "reactor") {
        game.currentEnergy += 1;
        if (game.currentEnergy > game.maxEnergy)
          game.currentEnergy = game.maxEnergy;
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
    Vector centerBuilding = position;

    for (int i = -5; i < 7; i++) {
      for (int j = -5; j < 7; j++) {

        var tiledPosition = position.real2tiled();
        Vector positionCurrent = new Vector(tiledPosition.x + i, tiledPosition.y + j);

        if (game.world.contains(positionCurrent)) {
          Vector positionCurrentCenter = new Vector(positionCurrent.x * game.tileSize + (game.tileSize / 2), positionCurrent.y * game.tileSize + (game.tileSize / 2));
          int tileHeight = game.world.tiles[positionCurrent.x][positionCurrent.y].height;

          if (action == "add") {
            if (pow(positionCurrentCenter.x - centerBuilding.x, 2) + pow(positionCurrentCenter.y - centerBuilding.y, 2) < pow(game.tileSize * 6, 2)) {
              if (tileHeight == height) {
                game.world.tiles[positionCurrent.x][positionCurrent.y].collector = this;
              }
            }
          } else if (action == "remove") {
            if (pow(positionCurrentCenter.x - centerBuilding.x, 2) + pow(positionCurrentCenter.y - centerBuilding.y, 2) < pow(game.tileSize * 6, 2)) {
              if (tileHeight == height) {
                game.world.tiles[positionCurrent.x][positionCurrent.y].collector = null;
              }
            }

            for (int k = 0; k < Building.buildings.length; k++) {
              if (Building.buildings[k] != this && Building.buildings[k].type == "collector") {
                int heightK = game.world.getTile(Building.buildings[k].position).height;
                Vector centerBuildingK = Building.buildings[k].position;
                if (pow(positionCurrentCenter.x - centerBuildingK.x, 2) + pow(positionCurrentCenter.y - centerBuildingK.y, 2) < pow(game.tileSize * 6, 2)) {
                  if (tileHeight == heightK) {
                    game.world.tiles[positionCurrent.x][positionCurrent.y].collector = Building.buildings[k];
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
    if (needsEnergy && active && status == "IDLE") {

      energyCounter += 1 * game.speed;

      if (type == "analyzer") {
        Emitter.find(this);
      }

      if (type == "terp" && energy > 0) {
        // find lowest tile
        if (weaponTargetPosition == null) {
          int lowestTile = 10;
          
          var positionTiled = position.real2tiled();
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

      else if (type == "cannon" && energy > 0 && energyCounter >= 10) {
        if (!rotating) {

          energyCounter -= 10;

          int height = game.world.getTile(position).height;

          num closestDistance = 1000;
          List targets = new List();

          // find closest random target
          var targetPositionTiled = position.real2tiled();
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

            targetAngle = engine.rad2deg(atan2(dy, dx)).floor();
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
            engine.playSound("laser", position.real2tiled());
          }
        }
      }

      else if (type == "mortar" && energy > 0 && energyCounter >= 200) {
        energyCounter =- 200;

          // find most creep in range
          Vector target = null;
          var highestCreep = 0;
          var tiledPosition = position.real2tiled();
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
            engine.playSound("shot", position.real2tiled());
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
    CanvasRenderingContext2D context = engine.renderer["buffer"].context;
    
    for (int i = 0; i < buildings.length; i++) {
      if (buildings[i].built && buildings[i].selected && buildings[i].canMove) {
        engine.renderer["main"].view.style.cursor = "none";
        
        Vector hoveredTilePosition = game.getHoveredTilePosition();
        Vector positionI = hoveredTilePosition.tiled2screen() + new Vector(8 * game.zoom, 8 * game.zoom);
   
        game.drawRangeBoxes(hoveredTilePosition, buildings[i].type, buildings[i].weaponRadius, buildings[i].size);
  
        bool canBePlaced = game.canBePlaced(hoveredTilePosition, buildings[i].size, buildings[i]);

        if (canBePlaced)
          context.fillStyle = "rgba(0,255,0,0.5)";
        else
          context.fillStyle = "rgba(255,0,0,0.5)";
  
        // draw rectangle
        context.fillRect(positionI.x - game.tileSize * buildings[i].size * game.zoom / 2,
                         positionI.y - game.tileSize * buildings[i].size * game.zoom / 2,
                         game.tileSize * buildings[i].size * game.zoom,
                         game.tileSize * buildings[i].size * game.zoom);

        if (canBePlaced) {
          // draw lines to other buildings
          for (int j = 0; j < buildings.length; j++) {
            if (i != j) {
              if (buildings[j].type == "collector" || buildings[j].type == "relay" || buildings[j].type == "base") {
                Vector positionJ = buildings[j].position.real2screen();

                int allowedDistance = 10 * game.tileSize;
                if (buildings[j].type == "relay" && buildings[i].type == "relay") {
                  allowedDistance = 20 * game.tileSize;
                }

                if (positionJ.distanceTo(positionI) <= allowedDistance) {
                  context
                    ..strokeStyle = '#000'
                    ..lineWidth = 3 * game.zoom
                    ..beginPath()
                    ..moveTo(positionJ.x, positionJ.y)
                    ..lineTo(positionI.x, positionI.y)
                    ..stroke();

                  context
                    ..strokeStyle = '#0f0'
                    ..lineWidth = 2 * game.zoom
                    ..beginPath()
                    ..moveTo(positionJ.x, positionJ.y)
                    ..lineTo(positionI.x, positionI.y)
                    ..stroke();
                }
              }
            }
          }
        }

      }
    }
  }

  static void draw() {
    //drawNodeConnections();
    CanvasRenderingContext2D context = engine.renderer["buffer"].context;
    
    for (int i = 0; i < buildings.length; i++) {
      Vector realPosition = buildings[i].position.real2screen();
      Vector center = buildings[i].position.real2screen();
  
      if (engine.renderer["buffer"].isVisible(realPosition, new Vector(engine.images[buildings[i].type].width * game.zoom, engine.images[buildings[i].type].height * game.zoom))) { 
        // draw energy bar
        if (buildings[i].needsEnergy) {
          context.fillStyle = '#f00';
          context.fillRect(realPosition.x - 22 * game.zoom, realPosition.y - 21 * game.zoom, (44 * game.zoom / buildings[i].maxEnergy) * buildings[i].energy, 3);
        }
  
        // draw health bar (only if health is below maxHealth)
        if (buildings[i].health < buildings[i].maxHealth) {
          context.fillStyle = '#0f0';
          context.fillRect(realPosition.x - 22 * game.zoom, realPosition.y - 22 + game.tileSize * game.zoom * buildings[i].size - 3, ((game.tileSize * game.zoom * buildings[i].size - 8) / buildings[i].maxHealth) * buildings[i].health, 3);
        }
  
        // draw inactive sign
        if (!buildings[i].active) {
          context.strokeStyle = "#F00";
          context.lineWidth = 2 * game.zoom;
  
          context.beginPath();
          context.arc(center.x, center.y, (game.tileSize / 2) * buildings[i].size, 0, PI * 2, true);
          context.closePath();
          context.stroke();
  
          context.beginPath();
          context.moveTo(realPosition.x - (game.tileSize * buildings[i].size / 3), realPosition.y + (game.tileSize * buildings[i].size / 3));
          context.lineTo(realPosition.x + (game.tileSize * buildings[i].size / 3), realPosition.y - (game.tileSize * buildings[i].size / 3));
          context.stroke();
        }
      }
  
      // draw various stuff when operating
      if (buildings[i].operating) {
        if (buildings[i].type == "analyzer") {
          Vector targetPosition = buildings[i].weaponTargetPosition.real2screen();
          context
            ..strokeStyle = '#00f'
            ..lineWidth = 5 * game.zoom
            ..beginPath()
            ..moveTo(center.x, center.y)
            ..lineTo(targetPosition.x, targetPosition.y)
            ..stroke();
  
          context
            ..strokeStyle = '#fff'
            ..lineWidth = 3 * game.zoom
            ..beginPath()
            ..moveTo(center.x, center.y)
            ..lineTo(targetPosition.x, targetPosition.y)
            ..stroke();
        }
        else if (buildings[i].type == "beam") {
          Vector targetPosition = buildings[i].weaponTargetPosition.real2screen();
          context
            ..strokeStyle = '#f00'
            ..lineWidth = 5 * game.zoom
            ..beginPath()
            ..moveTo(center.x, center.y)
            ..lineTo(targetPosition.x, targetPosition.y)
            ..stroke();
  
          context
            ..strokeStyle = '#fff'
            ..lineWidth = 3 * game.zoom
            ..beginPath()
            ..moveTo(center.x, center.y)
            ..lineTo(targetPosition.x, targetPosition.y)
            ..stroke();
        }
        else if (buildings[i].type == "shield") {
          context
            ..save()
            ..globalAlpha = .5
            ..drawImageScaled(engine.images["forcefield"], center.x - 168 * game.zoom, center.y - 168 * game.zoom, 336 * game.zoom, 336 * game.zoom)
            ..restore();
        }
        else if (buildings[i].type == "terp") {
          Vector targetPosition = buildings[i].weaponTargetPosition.tiled2screen();
  
          context
            ..strokeStyle = '#f00'
            ..lineWidth = 4 * game.zoom
            ..beginPath()
            ..moveTo(center.x, center.y)
            ..lineTo(targetPosition.x + 8, targetPosition.y + 8)
            ..stroke();
  
          context
            ..strokeStyle = '#fff'
            ..lineWidth = 2 * game.zoom
            ..beginPath()
            ..moveTo(center.x, center.y)
            ..lineTo(targetPosition.x + 8, targetPosition.y + 8)
            ..stroke();
        }
      }
    }

  }
}