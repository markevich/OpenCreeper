part of creeper;

class Building extends Zei.GameObject {
  Zei.Vector2 position, scale = new Zei.Vector2(1, 1), moveTargetPosition, weaponTargetPosition, speed = new Zei.Vector2(0, 0);
  String type, status = "IDLE"; // MOVING, RISING, FALLING
  bool operating = false, selected = false, hovered = false, built = false, enabled = true, canMove = false, needsEnergy = false, rotating = false;
  num health, maxHealth = 0, energy, maxEnergy = 0, healthRequests = 0, energyRequests = 0, rotation = 0;
  int targetAngle, radius = 0, size, collectedEnergy = 0, flightCounter = 0, requestCounter = 0, energyCounter = 0;
  Ship ship;
  Zei.Sprite sprite, cannon, shield, selectedCircle, disabledSprite;
  Zei.Rect targetSymbol, energyBar, healthBar, repositionRect;
  Zei.Line analyzerLineInner, analyzerLineOuter, beamLineInner, beamLineOuter, terpLineInner, terpLineOuter;
  int damageCounter = 0, collectCounter = 0;
  Spore beamTarget;
  double movementCost;
  static final double baseVelocity = .5;
  static Building base;
  List<Packet> queue; // only used for base
  static List<Zei.Line> repositionLines = new List<Zei.Line>();

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
    active = false;
  }

  Building(position, imageID) {
    type = imageID;
    this.position = position;
    sprite = Zei.Sprite.create("main", "building", Zei.images[imageID], position, 48, 48, anchor: new Zei.Vector2(0.5, 0.5), alpha: 0.5);

    health = 0;
    size = 3;
    energy = 0;
    movementCost = 1.0;

    if (type == "base") {
      sprite.size = new Zei.Vector2(144, 144);
      sprite.alpha = 1.0;
      health = 40;
      maxHealth = 40;
      built = true;
      size = 9;
      canMove = true;
      energy = 20;
      maxEnergy = 20;
      needsEnergy = true;
      queue = new List();
    }
    else if (type == "analyzer") {
      maxHealth = game.debug == true ? 1 : 80;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      radius = 10;

      analyzerLineOuter = Zei.Line.create("main", "projectile", position, new Zei.Vector2.empty(), 5, new Zei.Color.blue(), visible: false);
      analyzerLineInner = Zei.Line.create("main", "projectile", position, new Zei.Vector2.empty(), 3, new Zei.Color.white(), visible: false);
    }
    else if (type == "terp") {
      maxHealth = game.debug == true ? 1 : 60;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      radius = 20;

      terpLineOuter = Zei.Line.create("main", "projectile", position, new Zei.Vector2.empty(), 5, new Zei.Color.green(), visible: false);
      terpLineInner = Zei.Line.create("main", "projectile", position, new Zei.Vector2.empty(), 3, new Zei.Color.white(), visible: false);
    }
    else if (type == "shield") {
      maxHealth = game.debug == true ? 1 : 75;
      maxEnergy = 20;
      canMove = true;
      needsEnergy = true;
      radius = 10;

      shield = Zei.Sprite.create("main", "shield", Zei.images["forcefield"], position, 336, 336, anchor: new Zei.Vector2(0.5, 0.5), alpha: 0.5, visible: false);
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
      movementCost = 0.5;
    }
    else if (type == "cannon") {
      maxHealth = game.debug == true ? 1 : 25;
      maxEnergy = 40;
      radius = 10;
      canMove = true;
      needsEnergy = true;
      energyCounter = 15;

      cannon = Zei.Sprite.create("main", "buildinggun", Zei.images["cannongun"], position, 48, 48, anchor: new Zei.Vector2(0.5, 0.5), alpha: 0.5);
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

      beamLineOuter = Zei.Line.create("main", "projectile", position, new Zei.Vector2.empty(), 5, new Zei.Color.red(), visible: false);
      beamLineInner = Zei.Line.create("main", "projectile", position, new Zei.Vector2.empty(), 3, new Zei.Color.white(), visible: false);
    }

    targetSymbol = Zei.Rect.create("main", "targetsymbol", new Zei.Vector2.empty(), new Zei.Vector2(size * Tile.size, size * Tile.size), 1, new Zei.Color.green(), null, visible: false, anchor: new Zei.Vector2(0.5, 0.5));
    repositionRect = Zei.Rect.create("main", "targetsymbol", new Zei.Vector2.empty(), new Zei.Vector2(size * Tile.size, size * Tile.size), 10, new Zei.Color.red(), null, visible: false, anchor: new Zei.Vector2(0.5, 0.5));

    if (needsEnergy) {
      energyBar = Zei.Rect.create("main", "buildinginfo",
                               position - new Zei.Vector2(size * Tile.size / 2 - 2, size * Tile.size / 2 - 4),
                               new Zei.Vector2(((size * Tile.size - 4) / maxEnergy) * energy, 3),
                               0, new Zei.Color.red(), null);
    }
    healthBar = Zei.Rect.create("main", "buildinginfo",
                                   position - new Zei.Vector2(size * Tile.size / 2 - 2, -size * Tile.size / 2 + 7),
                                   new Zei.Vector2(((size * Tile.size - 4) / maxHealth) * health, 3),
                                   0, new Zei.Color.green(), null, visible: false);

    disabledSprite = Zei.Sprite.create("main", "buildinginfo", Zei.images["disabledSprite"], position, 144, 144, anchor: new Zei.Vector2(0.5, 0.5), visible: false, scale: new Zei.Vector2(1.0 / 9 * size, 1.0 / 9 * size));
    selectedCircle = Zei.Sprite.create("main", "selectedcircle", Zei.images["selectionCircle"], position, 144, 144, anchor: new Zei.Vector2(0.5, 0.5), visible: false, scale: new Zei.Vector2(1.0 / 9 * size, 1.0 / 9 * size));

    Connection.add(this);
  }

  /**
   * Adds a building of a given [type] at the given [position].
   */
  static Building add(Zei.Vector2 position, String type) {
    position = position * 16 + new Zei.Vector2(8, 8);
    Building building = new Building(position, type);
    if (type == "base") base = building;

    // clear terraforming below position
    for (int i = -building.size ~/ 2; i <= building.size ~/ 2; i++) {
      for (int j = -building.size ~/ 2; j <= building.size ~/ 2; j++) {
        game.world.getTile(position + new Zei.Vector2(i * Tile.size, j * Tile.size)).unflagTerraform();
      }
    }

    return building;
  }

  /**
   * Removes a [building].
   */
  static void remove(Building building) {

    // only explode building when it has been built
    if (building.built) {
      Explosion.add(building.position);
      Zei.Audio.play("explosion", building.position);
    }

    if (building.type == "base") {
      querySelector('#lose').style.display = "block";
      game.ui.stopwatch.stop();
      Zei.stop();
    }
    if (building.type == "collector") {
      if (building.built)
        building.updateCollection("remove");
    }
    if (building.type == "storage") {
      Building.base.maxEnergy -= 10;
      game.ui.updateElement("energy");
    }
    if (building.type == "speed") {
      Packet.baseSpeed /= 1.01;
    }

    // find all packets with this building as target and remove them
    Packet.removeWithTarget(building);

    Connection.remove(building);

    Zei.renderer["main"].removeDisplayObject(building.sprite);
    Zei.renderer["main"].removeDisplayObject(building.selectedCircle);
    Zei.renderer["main"].removeDisplayObject(building.targetSymbol);
    if (building.cannon != null)
      Zei.renderer["main"].removeDisplayObject(building.cannon);

    Zei.GameObject.remove(building);
  }

  static void addToQueue(Packet packet) {
    base.queue.add(packet);
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
      querySelector('#disable').style.display = "none";
      querySelector('#enable').style.display = "none";
      for (var building in Zei.GameObject.gameObjects) {
        if (building is Building && building.active) {
          building.selected = building.hovered;
          if (building.selected) {
            building.selectedCircle.visible = true;
            if (building.canMove)
              building.repositionRect.visible = true;
            if (building.enabled) {
              if (building.built) {
                querySelector('#disable').style.display = "block";
              }
            } else {
              querySelector('#enable').style.display = "block";
            }
          } else {
            building.selectedCircle.visible = false;
            building.repositionRect.visible = false;
            building.clearRepositionLines();
          }
        }
      }
    }
  }

  static void deselect() {
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building && building.active) {
        building.selected = false;
        building.selectedCircle.visible = false;
        building.repositionRect.visible = false;
        building.clearRepositionLines();
      }
    }
    game.world.hideRangeBoxes();
    querySelector('#disable').style.display = "none";
    querySelector('#enable').style.display = "none";
  }

  void update() {
    hovered = sprite.isHovered();
    selectedCircle.rotate(1);

    if (!game.paused) {
      move();
      checkOperating();
      shieldAction();
      requestPacket();
      checkReposition();

      // take damage
      damageCounter += 1 * game.speed;
      if (damageCounter > 10) {
        damageCounter -= 10;
        takeDamage();
      }

      // collect energy
      collectCounter += 1 * game.speed;
      if (collectCounter > 25) {
        collectCounter -= 25;
        collectEnergy();
      }

      // Updates the packet queue of the base.
      // If the base has energy the first packet is removed from
      // the queue and sent to its target (FIFO).
      if (queue != null) { // base
        for (int i = queue.length - 1; i >= 0; i--) {
          if (energy > 0) {
            energy--;
            game.ui.updateElement("energy");
            Packet packet = queue.removeAt(0);
            packet.send();
          }
        }
      }

    }
  }

  static void enable() {
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building && building.active) {
        if (building.selected)
          building.enabled = true;
          building.disabledSprite.visible = false;

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

  static void disable() {
    for (var building in Zei.GameObject.gameObjects) {
      if (building is Building && building.active) {
        if (building.built && building.selected) {
          building.enabled = false;
          building.disabledSprite.visible = true;

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
          if (building.canBePlaced(position)) {
            Zei.mouse.showCursor();
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
      if (building is Building && building.active) {
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
      if (building is Building && building.active) {
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
    selectedCircle.scale = scale;

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
        Zei.renderer["main"].switchLayer(sprite, "buildingflying");
        if (cannon != null)
          Zei.renderer["main"].switchLayer(cannon, "buildinggunflying");
        if (energyBar != null) {
          Zei.renderer["main"].switchLayer(energyBar, "buildinginfoflying");
        }
        Zei.renderer["main"].switchLayer(healthBar, "buildinginfoflying");
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
        Zei.renderer["main"].switchLayer(sprite, "building");
        if (cannon != null)
          Zei.renderer["main"].switchLayer(cannon, "buildinggun");
        if (energyBar != null) {
          Zei.renderer["main"].switchLayer(energyBar, "buildinginfo");
        }
        Zei.renderer["main"].switchLayer(healthBar, "buildinginfo");
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
    if (enabled && status == "IDLE" && type != "base") {
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

  void updateCollectorFields() {
    for (int i = -radius; i <= radius; i++) {
      for (int j = -radius; j <= radius; j++) {
        Zei.Vector2 tempPosition = position + new Zei.Vector2(i * Tile.size, j * Tile.size);
        if (game.world.contains(tempPosition / Tile.size)) {
          if (game.world.getTile(tempPosition).collector == this) {
            game.world.getTile(tempPosition).collectionAlpha = .25 + Zei.clamp(collectedEnergy / 2000, 0, 0.5);
          }
        }
      }
    }
  }

  void collectEnergy() {
    if (enabled) {
      if (type == "collector" && built) {
        int height = game.world.getTile(position).height;

        for (int i = -radius; i <= radius; i++) {
          for (int j = -radius; j <= radius; j++) {
            Zei.Vector2 tempPosition = position + new Zei.Vector2(i * Tile.size, j * Tile.size);
            if (game.world.contains(tempPosition / Tile.size)) {
              int tileHeight = game.world.getTile(tempPosition).height;

              if (position.distanceTo(tempPosition + new Zei.Vector2(8, 8)) <= radius * Tile.size) {
                if (tileHeight == height) {
                  if (game.world.getTile(tempPosition).collector == this) {
                    collectedEnergy += 1;
                  }
                }
              }
            }
          }
        }

        updateCollectorFields();
      }

      if (type == "reactor" && built) {
        collectedEnergy += 500;
      }

      if (type == "base") {
        collectedEnergy += 1000;
      }

      if (collectedEnergy >= 1000) {
        collectedEnergy = 0;
        updateCollectorFields();
        if (type == "collector") {
          Packet packet = new Packet(this, Building.base, "collection");
          if (packet.findRoute())
            packet.send();
          else
            Zei.renderer["main"].removeDisplayObject(packet.sprite);
        }
        if (type == "reactor" || type == "base") {
          Building.base.energy += 1;
          if (Building.base.energy > Building.base.maxEnergy)
            Building.base.energy = Building.base.maxEnergy;
          game.ui.updateElement("energy");
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
                  if (building is Building && building.active && building.enabled) {
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

    game.world.drawCollection();
  }

  void checkOperating() {
    operating = false;
    if (built && needsEnergy && enabled && status == "IDLE") {

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

            game.world.redrawTiles(tilesToRedraw);

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
          if (energyCounter >= 40) {
            energyCounter -= 40;
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
            Zei.Audio.play("laser", position);
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
            Zei.Audio.play("shot", position);
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

  void clearRepositionLines() {
    // remove current reposition lines
    for (var i = 0; i < repositionLines.length; i++) {
      Zei.renderer["main"].removeDisplayObject(repositionLines[i]);
    }
    repositionLines.clear();
  }

  void checkReposition() {
    if (selected && built && canMove) {
      //if (game.hoveredTile != game.oldHoveredTile) { // FIXME: repositionLines not always updated
      game.world.hideRangeBoxes();
      updateRangeBoxes(game.world.hoveredTile);

      // get drawing center of hovered tile
      Zei.Vector2 tileCenter = game.world.hoveredTile * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2);

      repositionRect.visible = true;
      repositionRect.position = tileCenter;

      clearRepositionLines();

      if (canBePlaced(game.world.hoveredTile)) {
        // set reposition rect to green
        repositionRect.fillColor = new Zei.Color(0, 255, 0, 0.5);
        // create new reposition lines
        for (var building in Zei.GameObject.gameObjects) {
          if (building is Building && building.active) {
            if (this != building) {
              if (type == "base" || building.type == "collector" || building.type == "relay" || building.type == "base") {

                int allowedDistance = 10 * Tile.size;
                if (building.type == "relay" && type == "relay") {
                  allowedDistance = 20 * Tile.size;
                }

                if (tileCenter.distanceTo(building.position) <= allowedDistance) {
                  repositionLines.add(Zei.Line.create("main", "connection", tileCenter, building.position, 3, new Zei.Color.black()));
                  repositionLines.add(Zei.Line.create("main", "connection", tileCenter, building.position, 2, new Zei.Color.green()));
                }
              }
            }
          }
        }
      } else {
        // set reposition rect to red
        repositionRect.fillColor = new Zei.Color(255, 0, 0, 0.5);
      }
      //}
    }
  }

  /**
   * Updates the range boxes around the [position] of the building.
   */
  void updateRangeBoxes(Zei.Vector2 position) {

    if (canBePlaced(position) && (type == "collector" || type == "cannon" || type == "mortar" || type == "shield" || type == "beam" || type == "terp" || type == "analyzer")) {

      Zei.Vector2 positionCenter = new Zei.Vector2(position.x * Tile.size + (Tile.size / 2), position.y * Tile.size + (Tile.size / 2));
      int positionHeight = game.world.tiles[position.x][position.y].height;

      for (int i = -radius; i <= radius; i++) {
        for (int j = -radius; j <= radius; j++) {

          Zei.Vector2 positionCurrent = position + new Zei.Vector2(i, j);

          if (game.world.contains(positionCurrent)) {
            Zei.Vector2 positionCurrentCenter = new Zei.Vector2(positionCurrent.x * Tile.size + (Tile.size / 2), positionCurrent.y * Tile.size + (Tile.size / 2));

            int positionCurrentHeight = game.world.tiles[positionCurrent.x][positionCurrent.y].height;

            if (positionCenter.distanceTo(positionCurrentCenter) < radius * Tile.size) {
              Tile tile = game.world.getTile(positionCurrent * Tile.size);
              tile.rangeBox.visible = true;

              if ((type == "collector" && positionCurrentHeight != positionHeight) ||
                  (type == "cannon" && positionCurrentHeight > positionHeight))
                tile.rangeBox.fillColor = new Zei.Color(255, 0, 0, 0.35);
              else {
                tile.rangeBox.fillColor = new Zei.Color(255, 255, 255, 0.35);
              }
            }
          }
        }
      }
    }
  }

  /**
   * Checks if a the building can be placed on a given [position]. // tileposition
   */
  bool canBePlaced(Zei.Vector2 position) {

    if (game.world.contains(position)) {
      int height = game.world.tiles[position.x][position.y].height;

      Rectangle currentRect = new Rectangle(position.x * Tile.size + 8 - size * Tile.size / 2,
                                            position.y * Tile.size + 8 - size * Tile.size / 2,
                                            size * Tile.size - 1,
                                            size * Tile.size - 1);

      // TODO: check for ghost collision
      if (Building.intersect(currentRect, this) ||
          Emitter.intersect(currentRect) ||
          Sporetower.intersect(currentRect)) return false;

      // check if all tiles have the same height and are not corners
      for (int i = position.x - (size ~/ 2); i <= position.x + (size ~/ 2); i++) {
        for (int j = position.y - (size ~/ 2); j <= position.y + (size ~/ 2); j++) {
          if (game.world.contains(new Zei.Vector2(i, j))) {
            int tileHeight = game.world.tiles[i][j].height;
            if (tileHeight < 0 || tileHeight != height) {
              return false;
            }
            if (!(game.world.tiles[i][j].index == 7 || game.world.tiles[i][j].index == 11 || game.world.tiles[i][j].index == 13 || game.world.tiles[i][j].index == 14 || game.world.tiles[i][j].index == 15)) {
              return false;
            }
          } else {
            return false;
          }
        }
      }

      return true;
    } else {
      return false;
    }
  }

  void onMouseEvent(evt) {}

  void onKeyEvent(evt, String type) {
    if (evt.keyCode == KeyCode.DELETE) {
      Building.removeSelected();
    }
  }

}