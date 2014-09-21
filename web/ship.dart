part of creeper;

class Ship extends GameObject {
  Vector velocity = new Vector(0, 0), targetPosition = new Vector(0, 0);
  String type, status = "IDLE"; // ATTACKING, RETURNING, RISING, FALLING
  bool remove = false, hovered = false, selected = false;
  int maxEnergy = 15, energy = 0, trailCounter = 0, weaponCounter = 0, flightCounter = 0;
  Building home;
  Sprite sprite, targetSymbol;
  Circle selectedCircle;
  Rect energyRect;
  static final int baseSpeed = 1;

  Ship(position, imageID, this.type, this.home) {
    sprite = new Sprite("buffer", "ship", Zei.images[imageID], position, 48, 48, anchor: new Vector(0.5, 0.5));
    selectedCircle = new Circle("buffer", "selectedcircle", position, 24, 2, null, new Color.white(), visible: false);
    targetSymbol = new Sprite("buffer", "targetsymbol", Zei.images["targetcursor"], position, 48, 48, visible: false, anchor: new Vector(0.5, 0.5), alpha: 0.5);
    energyRect = new Rect("buffer", "energybar", new Vector(position.x - 22, position.y - 20), new Vector(44 / maxEnergy * energy, 3), 1, new Color.red(), null);
  }
   
  static Ship add(Vector position, String imageID, String type, Building home) {
    Ship ship = new Ship(position, imageID, type, home);
    Zei.addGameObject(ship);
    return ship;
  }
  
  void update() {
    if (!game.paused) {
      move();
    }
    hovered = sprite.isHovered();
  }
  
  static void select() {
    // select a ship if hovered
    for (var ship in Zei.gameObjects) {
      if (ship is Ship) {
        if (ship.hovered) {
          ship.selected = true;
          ship.selectedCircle.visible = true;
          game.targetCursor.visible = true;
        }
      }
    }
  }
  
  static void deselect() {
    for (var ship in Zei.gameObjects) {
      if (ship is Ship) {
        ship.selected = false;
        ship.selectedCircle.visible = false;
      }
      game.targetCursor.visible = false;
    }
  }
  
  void turnToTarget() {
    double angleToTarget = sprite.position.angleTo(targetPosition);

    num shipRotation = 1.5;
    num absoluteDelta = (angleToTarget - sprite.rotation).abs();
  
    shipRotation = Zei.clamp(shipRotation, 0, absoluteDelta);

    if (absoluteDelta <= 180) // facing target
      if (angleToTarget < sprite.rotation)
        sprite.rotation -= shipRotation;
      else
        sprite.rotation += shipRotation;
    else // not facing target
      if (angleToTarget < sprite.rotation)
        sprite.rotation += shipRotation;
      else
        sprite.rotation -= shipRotation;

    if (sprite.rotation > 180)
      sprite.rotation -= 360;
    if (sprite.rotation < -180)
      sprite.rotation += 360; 
  }

  void calculateSpeed() {
    velocity = Zei.convertToVector(sprite.rotation) * Ship.baseSpeed * game.speed;
  }
  
  static void control(Vector position) {
    position = position * game.tileSize;
    position += new Vector(8, 8);
    
    select();
    
    for (var ship in Zei.gameObjects) {
      if (ship is Ship) {
           
        // control if selected
        if (ship.selected) {
          game.mode = "SHIP_SELECTED";
    
          if (ship.status == "IDLE") {
            if (position != ship.home.position) {         
              // leave home
              // get energy from home
              int delta = ship.maxEnergy - ship.energy;
              if (ship.home.energy >= delta) {
                ship.energy += delta;
                ship.home.energy -= delta;
              } else {
                ship.energy += ship.home.energy;
                ship.home.energy = 0;
              }
              ship.targetPosition = position;
              ship.targetSymbol.position = ship.targetPosition;
              ship.status = "RISING";
            }
          }
          
          if (ship.status == "ATTACKING" || ship.status == "RETURNING") {      
            if (position == ship.home.position) {
              // return home
              ship.targetPosition = position;
              ship.status = "RETURNING";
            }
            else {
              // attack again
              ship.targetPosition = position;
              ship.targetSymbol.position = ship.targetPosition;
              ship.status = "ATTACKING";
            }
          }
    
        }
      }
    }
  }

  void move() { 
    // update energy rect
    energyRect.size = new Vector(44 / maxEnergy * energy, 3);
    
    if (status == "ATTACKING" || status == "RETURNING") {
      trailCounter++;
      if (trailCounter == 10) {
        trailCounter = 0;
        Smoke.add(new Vector(sprite.position.x, sprite.position.y - 16));
      }
    }

    if (status == "RISING") {
      if (flightCounter < 25) {
        flightCounter++;
        sprite.scale = sprite.scale * 1.01;
        selectedCircle.scale *= 1.01;
        energyRect.scale *= 1.01;
      }
      if (flightCounter == 25) {
        status = "ATTACKING";
      }
    }
    
    else if (status == "FALLING") {
      if (flightCounter > 0) {
        flightCounter--;
        sprite.scale = sprite.scale / 1.01;
        selectedCircle.scale /= 1.01;
        energyRect.scale /= 1.01;
      }
      if (flightCounter == 0) {
        status = "IDLE";
        targetPosition = new Vector.empty();
        sprite.scale = new Vector(1.0, 1.0);
        selectedCircle.scale = 1.0;
        energyRect.scale = new Vector(1.0, 1.0);
      }
    }
    
    else if (status == "ATTACKING") {
      weaponCounter++;

      turnToTarget();
      calculateSpeed();
      
      sprite.position += velocity;
      selectedCircle.position += velocity;
      energyRect.position += velocity;

      if (sprite.position.x > targetPosition.x - 2 && sprite.position.x < targetPosition.x + 2 && sprite.position.y > targetPosition.y - 2 && sprite.position.y < targetPosition.y + 2) {
        if (weaponCounter >= 10) {
          weaponCounter = 0;
          energy -= 1;

          Vector targetPositionTiled = game.real2tiled(targetPosition);
          Explosion.add(targetPosition);
          Zei.playSound("explosion", targetPosition, game.scroll, game.zoom);

          for (int i = -3; i <= 3; i++) {
            for (int j = -3; j <= 3; j++) {

              Vector tilePosition = targetPositionTiled + new Vector(i, j);

              if (game.world.contains(tilePosition)) {
                if ((tilePosition * game.tileSize + new Vector(8, 8)).distanceTo(targetPosition) <= game.tileSize * 3) {
                  Tile tile = game.world.getTile(tilePosition * game.tileSize);

                  tile.creep -= 5;
                  if (tile.creep < 0)
                    tile.creep = 0;
                  World.creeperDirty = true;
                }
              }
            }
          }

          if (energy == 0) {
            // return to base
            status = "RETURNING";
            targetPosition = home.position;
          }
        }
      }
    }
    
    else if (status == "RETURNING") {
      turnToTarget();
      calculateSpeed();

      sprite.position += velocity;
      selectedCircle.position += velocity;
      energyRect.position += velocity;

      if (sprite.position.x > targetPosition.x - 2 && sprite.position.x < targetPosition.x + 2 && sprite.position.y > targetPosition.y - 2 && sprite.position.y < targetPosition.y + 2) {
        sprite.position = home.position;
        status = "FALLING";
      }
    }

    targetSymbol.visible = ((status == "ATTACKING" || status == "RISING") && selected);
  }
}