part of creeper;

class Ship {
  Vector speed = new Vector(0, 0), targetPosition = new Vector(0, 0);
  String type, status = "IDLE"; // ATTACKING, RETURNING, RISING, FALLING
  bool remove = false, hovered = false, selected = false;
  int maxEnergy = 15, energy = 0, trailCounter = 0, weaponCounter = 0, flightCounter = 0;
  Building home;
  Sprite sprite, targetSymbol;
  Circle selectedCircle;
  Rect energyRect;
  static final int baseSpeed = 1;
  static List<Ship> ships = new List<Ship>();

  Ship(position, imageID, this.type, this.home) {
    sprite = new Sprite(Layer.SHIP, game.engine.images[imageID], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    game.engine.renderer["buffer"].addDisplayObject(sprite);

    selectedCircle = new Circle(Layer.SELECTEDCIRCLE, position, 24, 2, "#fff");
    selectedCircle.visible = false;
    game.engine.renderer["buffer"].addDisplayObject(selectedCircle);

    targetSymbol = new Sprite(Layer.TARGETSYMBOL, game.engine.images["targetcursor"], position, 48, 48);
    targetSymbol.anchor = new Vector(0.5, 0.5);
    targetSymbol.alpha = 0.5;
    targetSymbol.visible = false;
    game.engine.renderer["buffer"].addDisplayObject(targetSymbol);
    
    energyRect = new Rect(Layer.ENERGYBAR, new Vector(position.x - 22, position.y - 20), new Vector(44 / maxEnergy * energy, 3), 1, '#f00');
    game.engine.renderer["buffer"].addDisplayObject(energyRect);
  }
  
  static void clear() {
    ships.clear();
  }
  
  static Ship add(Vector position, String imageID, String type, Building home) {
    Ship ship = new Ship(position, imageID, type, home);
    ships.add(ship);
    return ship;
  }
  
  static void update() {
    for (int i = 0; i < ships.length; i++) {
      ships[i].move();
    }
  }
  
  static void select() {
    // select a ship if hovered
    for (int i = 0; i < ships.length; i++) {
      if (ships[i].hovered) {
        ships[i].selected = true;
        ships[i].selectedCircle.visible = true;
        game.targetCursor.visible = true;
      }
    }
  }
  
  static void deselect() {
    for (int i = 0; i < ships.length; i++) {
      ships[i].selected = false;
      ships[i].selectedCircle.visible = false;
    }
    game.targetCursor.visible = false;
  }
  
  static void updateHoverState() {
    for (int i = 0; i < ships.length; i++) {
      Vector realPosition = ships[i].sprite.position.real2screen();
      ships[i].hovered = (game.engine.mouse.position.x > realPosition.x - 24 && game.engine.mouse.position.x < realPosition.x + 24 && game.engine.mouse.position.y > realPosition.y - 24 && game.engine.mouse.position.y < realPosition.y + 24);
    }
  }

  void turnToTarget() {
    Vector delta = targetPosition - sprite.position;
    double angleToTarget = game.engine.rad2deg(atan2(delta.y, delta.x));

    num turnRate = 1.5;
    num absoluteDelta = (angleToTarget - sprite.rotation).abs();

    if (absoluteDelta < turnRate)
      turnRate = absoluteDelta;

    if (absoluteDelta <= 180)
      if (angleToTarget < sprite.rotation)
        sprite.rotation -= turnRate;
      else
        sprite.rotation += turnRate;
    else
      if (angleToTarget < sprite.rotation)
        sprite.rotation += turnRate;
      else
        sprite.rotation -= turnRate;

    if (sprite.rotation > 180)
      sprite.rotation -= 360;
    if (sprite.rotation < -180)
      sprite.rotation += 360;
  }

  void calculateVector() {
    num x = cos(game.engine.deg2rad(sprite.rotation));
    num y = sin(game.engine.deg2rad(sprite.rotation));

    speed.x = x * Ship.baseSpeed * game.speed;
    speed.y = y * Ship.baseSpeed * game.speed;
  }
  
  static void control(Vector position) {
    position = position * game.tileSize;
    position += new Vector(8, 8);
    
    select();
    
    for (int i = 0; i < ships.length; i++) {
           
      // control if selected
      if (ships[i].selected) {
        game.mode = "SHIP_SELECTED";
  
        if (ships[i].status == "IDLE") {
          if (position != ships[i].home.position) {         
            // leave home
            // get energy from home
            int delta = ships[i].maxEnergy - ships[i].energy;
            if (ships[i].home.energy >= delta) {
              ships[i].energy += delta;
              ships[i].home.energy -= delta;
            } else {
              ships[i].energy += ships[i].home.energy;
              ships[i].home.energy = 0;
            }
            ships[i].targetPosition = position;
            ships[i].targetSymbol.position = ships[i].targetPosition;
            ships[i].status = "RISING";
          }
        }
        
        if (ships[i].status == "ATTACKING" || ships[i].status == "RETURNING") {      
          if (position == ships[i].home.position) {
            // return home
            ships[i].targetPosition = position;
            ships[i].status = "RETURNING";
          }
          else {
            // attack again
            ships[i].targetPosition = position;
            ships[i].targetSymbol.position = ships[i].targetPosition;
            ships[i].status = "ATTACKING";
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
      calculateVector();

      sprite.position += speed;
      selectedCircle.position += speed;
      energyRect.position += speed;

      if (sprite.position.x > targetPosition.x - 2 && sprite.position.x < targetPosition.x + 2 && sprite.position.y > targetPosition.y - 2 && sprite.position.y < targetPosition.y + 2) {
        if (weaponCounter >= 10) {
          weaponCounter = 0;
          energy -= 1;

          Vector targetPositionTiled = targetPosition.real2tiled();
          Explosion.add(targetPosition);
          game.engine.playSound("explosion", targetPositionTiled);

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
      calculateVector();

      sprite.position += speed;
      selectedCircle.position += speed;
      energyRect.position += speed;

      if (sprite.position.x > targetPosition.x - 2 && sprite.position.x < targetPosition.x + 2 && sprite.position.y > targetPosition.y - 2 && sprite.position.y < targetPosition.y + 2) {
        sprite.position = home.position;
        status = "FALLING";
      }
    }

    targetSymbol.visible = ((status == "ATTACKING" || status == "RISING") && selected);
  }
}