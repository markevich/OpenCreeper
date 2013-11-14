part of creeper;

class Ship {
  Vector speed = new Vector(0, 0), targetPosition = new Vector(0, 0);
  String type, status = "IDLE"; // ATTACKING, RETURNING, RISING, FALLING
  bool remove = false, hovered = false, selected = false;
  int maxEnergy = 15, energy = 0, trailCounter = 0, weaponCounter = 0, flightCounter = 0;
  Building home;
  Sprite sprite, targetSymbol;
  Circle hoverCircle, selectedCircle;
  static final int baseSpeed = 1;

  Ship(position, imageID, this.type, this.home) {
    sprite = new Sprite(4, engine.images[imageID], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addDisplayObject(sprite);

    hoverCircle = new Circle(5, position, 24, 2, "#f00");
    engine.canvas["buffer"].addDisplayObject(hoverCircle);

    selectedCircle = new Circle(5, position, 24, 2, "#fff");
    selectedCircle.visible = false;
    engine.canvas["buffer"].addDisplayObject(selectedCircle);

    targetSymbol = new Sprite(0, engine.images["targetcursor"], position, 48, 48);
    targetSymbol.anchor = new Vector(0.5, 0.5);
    targetSymbol.alpha = 0.5;
    targetSymbol.visible = false;
    engine.canvas["buffer"].addDisplayObject(targetSymbol);
  }

  bool updateHoverState() {
    Vector realPosition = sprite.position.real2screen();
    hovered = (engine.mouse.x > realPosition.x - 24 && engine.mouse.x < realPosition.x + 24 && engine.mouse.y > realPosition.y - 24 && engine.mouse.y < realPosition.y + 24);
    hoverCircle.visible = hovered;
    return hovered;
  }

  void turnToTarget() {
    Vector delta = targetPosition - sprite.position;
    double angleToTarget = engine.rad2deg(atan2(delta.y, delta.x));

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
    num x = cos(engine.deg2rad(sprite.rotation));
    num y = sin(engine.deg2rad(sprite.rotation));

    speed.x = x * Ship.baseSpeed * game.speed;
    speed.y = y * Ship.baseSpeed * game.speed;
  }
  
  void control(Vector position) {
    // select ship
    if (hovered) {
      selected = true;
      selectedCircle.visible = true;
    }
    
    // control if selected
    if (selected) {
      game.mode = "SHIP_SELECTED";

      if (status == "IDLE") {
        if (position.x - 1 != home.position.x && position.y - 1 != home.position.y) {         
          // leave home
          energy = home.energy;
          home.energy = 0;
          targetPosition = position * game.tileSize;
          targetSymbol.position = targetPosition;
          status = "RISING";
        }
      }
      
      if (status == "ATTACKING" || status == "RETURNING") {      
        if (position.x - 1 == home.position.x && position.y - 1 == home.position.y) {
          // return home
          targetPosition.x = (position.x - 1) * game.tileSize;
          targetPosition.y = (position.y - 1) * game.tileSize;
          status = "RETURNING";
        }
        else {
          // attack again
          targetPosition.x = (position.x - 1) * game.tileSize;
          targetPosition.y = (position.y - 1) * game.tileSize;
          targetSymbol.position = targetPosition;
          status = "ATTACKING";
        }
      }

    }
  }

  void move() {
    if (status == "ATTACKING" || status == "RETURNING") {
      trailCounter++;
      if (trailCounter == 10) {
        trailCounter = 0;
        Smoke.add(new Smoke(new Vector(sprite.position.x, sprite.position.y - 16)));
      }
    }

    if (status == "RISING") {
      if (flightCounter < 25) {
        flightCounter++;
        sprite.scale = sprite.scale * 1.01;
        hoverCircle.scale *= 1.01;
        selectedCircle.scale *= 1.01;
      }
      if (flightCounter == 25) {
        status = "ATTACKING";
      }
    }
    
    else if (status == "FALLING") {
      if (flightCounter > 0) {
        flightCounter--;
        sprite.scale = sprite.scale / 1.01;
        hoverCircle.scale /= 1.01;
        selectedCircle.scale *= 1.01;
      }
      if (flightCounter == 0) {
        status = "IDLE";
        sprite.position.x = home.position.x * game.tileSize + 24;
        sprite.position.y = home.position.y * game.tileSize + 24;
        targetPosition.x = 0;
        targetPosition.y = 0;
        energy = 5;
        sprite.scale = new Vector(1.0, 1.0);
        hoverCircle.scale = 1.0;
        selectedCircle.scale = 1.0;
      }
    }
    
    else if (status == "ATTACKING") {
      weaponCounter++;

      turnToTarget();
      calculateVector();

      sprite.position += speed;
      hoverCircle.position += speed;
      selectedCircle.position += speed;

      if (sprite.position.x > targetPosition.x - 2 && sprite.position.x < targetPosition.x + 2 && sprite.position.y > targetPosition.y - 2 && sprite.position.y < targetPosition.y + 2) {
        if (weaponCounter >= 10) {
          weaponCounter = 0;
          Explosion.add(new Explosion(targetPosition));
          energy -= 1;

          for (int i = (targetPosition.x / game.tileSize).floor() - 3; i < (targetPosition.x / game.tileSize).floor() + 5; i++) {
            for (int j = (targetPosition.y / game.tileSize).floor() - 3; j < (targetPosition.y / game.tileSize).floor() + 5; j++) {
              if (game.world.contains(new Vector(i, j))) {
                num distance = pow((i * game.tileSize + game.tileSize / 2) - (targetPosition.x + game.tileSize), 2) + pow((j * game.tileSize + game.tileSize / 2) - (targetPosition.y + game.tileSize), 2);
                if (distance < pow(game.tileSize * 3, 2)) {
                  game.world.tiles[i][j].creep -= 5;
                  if (game.world.tiles[i][j].creep < 0) {
                    game.world.tiles[i][j].creep = 0;
                  }
                }
              }
            }
          }

          if (energy == 0) {
            // return to base
            status = "RETURNING";
            targetPosition.x = home.position.x * game.tileSize + 24;
            targetPosition.y = home.position.y * game.tileSize + 24;
          }
        }
      }
    }
    
    else if (status == "RETURNING") {
      turnToTarget();
      calculateVector();

      sprite.position += speed;
      hoverCircle.position += speed;
      selectedCircle.position += speed;

      if (sprite.position.x > targetPosition.x - 2 && sprite.position.x < targetPosition.x + 2 && sprite.position.y > targetPosition.y - 2 && sprite.position.y < targetPosition.y + 2) {
        status = "FALLING";
      }
    }

    targetSymbol.visible = ((status == "ATTACKING" || status == "RISING") && selected);
  }
}