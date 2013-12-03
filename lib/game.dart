part of creeper;

class Game {
  final int tileSize = 16;
  int seed, terraformingHeight = 0, speed = 1;
  double zoom = 1.0;
  Timer running;
  String mode;
  bool paused = false, won = false;
  List<Vector> ghosts = new List<Vector>();
  World world;
  Vector scroll = new Vector.empty(), mouseScrolling = new Vector.empty(), keyScrolling = new Vector.empty(), oldHoveredTile = new Vector.empty(), hoveredTile = new Vector.empty();
  Stopwatch stopwatch = new Stopwatch();
  Line tfLine1, tfLine2, tfLine3, tfLine4;
  Sprite tfNumber;
  Sprite targetCursor;
  
  Game() {
    seed = engine.randomInt(0, 10000);
    init();
  }

  Game.withSeed(this.seed) {
    init();
  }

  void init() {
    querySelector("#seed").innerHtml = "Seed: $seed";

    world = new World(seed);

    reset();
    setupUI();
    
    var music = new AudioElement("sounds/music.ogg");
    music.loop = true;
    music.volume = 0.25;
    music.onCanPlay.listen((event) => music.play());

    // create terraform lines
    tfLine1 = new Line(Layer.TERRAFORM, new Vector.empty(), new Vector.empty(), 1, "#fff");
    tfLine1.visible = false;
    engine.renderer["buffer"].addDisplayObject(tfLine1);
    tfLine2 = new Line(Layer.TERRAFORM, new Vector.empty(), new Vector.empty(), 1, "#fff");
    tfLine2.visible = false;
    engine.renderer["buffer"].addDisplayObject(tfLine2);
    tfLine3 = new Line(Layer.TERRAFORM, new Vector.empty(), new Vector.empty(), 1, "#fff");
    tfLine3.visible = false;
    engine.renderer["buffer"].addDisplayObject(tfLine3);
    tfLine4 = new Line(Layer.TERRAFORM, new Vector.empty(), new Vector.empty(), 1, "#fff");
    tfLine4.visible = false;
    engine.renderer["buffer"].addDisplayObject(tfLine4);
    
    tfNumber = new Sprite(Layer.TERRAFORM, engine.images["numbers"], new Vector.empty(), 16, 16);
    tfNumber.visible = false;
    tfNumber.animated = true;
    tfNumber.frame = terraformingHeight;
    engine.renderer["buffer"].addDisplayObject(tfNumber);
    
    targetCursor = new Sprite(Layer.TARGETSYMBOL, engine.images["targetcursor"], new Vector.empty(), 48, 48);
    targetCursor.anchor = new Vector(0.5, 0.5);
    targetCursor.visible = false;
    engine.renderer["buffer"].addDisplayObject(targetCursor);
    
    drawTerrain();
    copyTerrain();
    engine.setupEventHandler();
    run();
  }

  void reset() {
    Building.clear();
    Packet.clear();
    Shell.clear();
    Spore.clear();
    Ship.clear();
    Smoke.clear();
    Explosion.clear();
    Emitter.clear();
    Sporetower.clear();
    Projectile.clear();
    UISymbol.reset();

    mode = "DEFAULT";
    speed = 1;
    won = false;
    
    createWorld();
    
    stopwatch.reset();
    stopwatch.start();
    var oneSecond = new Duration(seconds:1);
    new Timer.periodic(oneSecond, updateTime);
    //querySelector('#lose').style.display = 'none';
    querySelector('#win').style.display = 'none';
    updateEnergyElement();
    updateSpeedElement();
    querySelector('#time').innerHtml = 'Time: 00:00';
  }
  
  void updateTime(Timer _) {
    var s = game.stopwatch.elapsedMilliseconds~/1000;
    var m = 0;
    
    if (s >= 60) { m = s ~/ 60; s = s % 60; }
    
    String minute = (m <= 9) ? '0$m' : '$m';
    String second = (s <= 9) ? '0$s' : '$s';
    querySelector('#time').innerHtml = 'Time: $minute:$second';
  }

  void pause() {
    querySelector('#paused').style.display = 'block';
    paused = true;
    stopwatch.stop();
  }

  void resume() {
    querySelector('#paused').style.display = 'none';
    querySelector('#win').style.display = 'none';
    paused = false;
    stopwatch.start();
  }

  void stop() {
    running.cancel();
  }

  void run() {
    running = new Timer.periodic(new Duration(milliseconds: (1000 / engine.TPS).floor()), (Timer timer) => updateAll());
    engine.animationRequest = window.requestAnimationFrame(draw);
  }
  
  void updateAll() {
    game.update();
  }

  void restart() {
    querySelector('#lose').style.display = 'none';
    stop();
    reset();
    drawTerrain();
    copyTerrain();
    run();
  }

  void toggleTerraform() {
    if (mode == "TERRAFORM") {
      mode = "DEFAULT";
      querySelector("#terraform").attributes['value'] = "Terraform Off";
      tfNumber.visible = false;
    } else {
      mode = "TERRAFORM";
      querySelector("#terraform").attributes['value'] = "Terraform On";
      tfNumber.visible = true;
    }
  }

  void faster() {
    //query('#slower').style.display = 'inline';
    //query('#faster').style.display = 'none';
    if (speed < 2) {
      speed *= 2;
      updateSpeedElement();
    }
  }

  void slower() {
    //query('#slower').style.display = 'none';
    //query('#faster').style.display = 'inline';
    if (speed > 1) {
      speed = speed ~/ 2;
      updateSpeedElement();
    }
  }

  void zoomIn() {
    if (zoom < 1.6) {
      zoom += .2;
      zoom = double.parse(zoom.toStringAsFixed(2));
      copyTerrain();
      drawCollection();
      World.creeperDirty = true;
    }
  }

  void zoomOut() {
    if (zoom > .4) {
      zoom -= .2;
      zoom = double.parse(zoom.toStringAsFixed(2));
      copyTerrain();
      drawCollection();
      World.creeperDirty = true;
    }
  }

  /**
   * Creates a random world with base, emitters and sporetowers.
   */
  void createWorld() {
    world.tiles = new List(world.size.x);
    for (int i = 0; i < world.size.x; i++) {
      world.tiles[i] = new List<Tile>(world.size.y);
      for (int j = 0; j < world.size.y; j++) {
        world.tiles[i][j] = new Tile();
      }
    }

    var heightmap = new HeightMap(seed, 129, 0, 90);
    heightmap.run();

    for (int i = 0; i < world.size.x; i++) {
      for (int j = 0; j < world.size.y; j++) {
        int height = (heightmap.map[i][j] / 10).round();
        if (height > 10)
          height = 10;
        world.tiles[i][j].height = height;
      }
    }

    // create base
    Vector randomPosition = new Vector(
        engine.randomInt(4, world.size.x - 5, seed + 1),
        engine.randomInt(4, world.size.y - 5, seed + 1));

    scroll = randomPosition;

    Building building = Building.add(randomPosition, "base");

    int height = this.world.getTile(building.position).height;
    if (height < 0)
      height = 0;
    for (int i = -4; i <= 4; i++) {
      for (int j = -4; j <= 4; j++) {
        this.world.getTile(building.position + new Vector(i * tileSize, j * tileSize)).height = height;
      }
    }

    // create emitters
    int number = engine.randomInt(2, 3, seed);
    for (var l = 0; l < number; l++) {    
      randomPosition = new Vector(
          engine.randomInt(1, world.size.x - 2, seed + engine.randomInt(1, 1000, seed + l)) * tileSize + 8,
          engine.randomInt(1, world.size.y - 2, seed + engine.randomInt(1, 1000, seed + 1 + l)) * tileSize + 8);
  
      Emitter emitter = Emitter.add(randomPosition, 25);
  
      height = world.getTile(emitter.sprite.position).height;
      if (height < 0)
        height = 0;
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          world.getTile(emitter.sprite.position + new Vector(i * tileSize, j * tileSize)).height = height;
        }
      }
    }

    // create sporetowers
    number = engine.randomInt(1, 2, seed + 1);
    for (var l = 0; l < number; l++) {
      randomPosition = new Vector(
          engine.randomInt(1, world.size.x - 2, seed + 3 + engine.randomInt(1, 1000, seed + 2 + l)) * tileSize + 8,
          engine.randomInt(1, world.size.y - 2, seed + 3 + engine.randomInt(1, 1000, seed + 3 + l)) * tileSize + 8);
  
      Sporetower sporetower = Sporetower.add(randomPosition);
  
      height = world.getTile(sporetower.sprite.position).height;
      if (height < 0)
        height = 0;
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          world.getTile(sporetower.sprite.position + new Vector(i * tileSize, j * tileSize)).height = height;
        }
      }
    }
  }

  void setupUI() {
    UISymbol.add(new Vector(0, 0), new Building.template("cannon"), KeyCode.Q);
    UISymbol.add(new Vector(81, 0), new Building.template("collector"), KeyCode.W);
    UISymbol.add(new Vector(2 * 81, 0), new Building.template("reactor"), KeyCode.E);
    UISymbol.add(new Vector(3 * 81, 0), new Building.template("storage"), KeyCode.R);
    UISymbol.add(new Vector(4 * 81, 0), new Building.template("shield"), KeyCode.T);
    UISymbol.add(new Vector(5 * 81, 0), new Building.template("analyzer"), KeyCode.Z);
    UISymbol.add(new Vector(0, 56), new Building.template("relay"), KeyCode.A);
    UISymbol.add(new Vector(81, 56), new Building.template("mortar"), KeyCode.S);
    UISymbol.add(new Vector(2 * 81, 56), new Building.template("beam"), KeyCode.D);
    UISymbol.add(new Vector(3 * 81, 56), new Building.template("bomber"), KeyCode.F);
    UISymbol.add(new Vector(4 * 81, 56), new Building.template("terp"), KeyCode.G);
  }

  /**
   * Draws the complete terrain.
   * This method is only called ONCE at the start of the game.
   */
  void drawTerrain() {
    /*for (int i = 0; i < 10; i++) {
      engine.renderer["level$i"].clear();
    }*/

    // 1st pass - draw masks
    for (int i = 0; i < world.size.x; i++) {
      for (int j = 0; j < world.size.y; j++) {
        int indexAbove = -1;
        for (int k = 9; k > -1; k--) {
        
          if (k <= world.tiles[i][j].height) {

            // calculate index
            int up = 0, down = 0, left = 0, right = 0;
            if (j - 1 < 0)
              up = 0;
            else if (world.tiles[i][j - 1].height >= k)
              up = 1;
            if (j + 1 > world.size.y - 1)
              down = 0;
            else if (world.tiles[i][j + 1].height >= k)
              down = 1;
            if (i - 1 < 0)
              left = 0;
            else if (world.tiles[i - 1][j].height >= k)
              left = 1;
            if (i + 1 > world.size.x - 1)
              right = 0;
            else if (world.tiles[i + 1][j].height >= k)
              right = 1;

            // save index
            int index = (8 * down) + (4 * left) + (2 * up) + right;
            if (k == world.tiles[i][j].height)
              world.tiles[i][j].index = index;
            
            if (k < 9) {
              // skip tiles that are identical to the one above
              if (index == indexAbove)
                continue;
              // skip tiles that are not visible
              if (indexAbove == 5 || indexAbove == 7 || indexAbove == 10 || indexAbove == 11 ||
                  indexAbove == 13 || indexAbove == 14 || indexAbove == 15)
                continue;
            }
            
            indexAbove = index;
           
            engine.renderer["level$k"].context.drawImageScaledFromSource(engine.images["mask"], index * (tileSize + 6) + 3, (tileSize + 6) + 3, tileSize, tileSize, i * tileSize, j * tileSize, tileSize, tileSize);
          }
        }
      }
    }

    // 2nd pass - draw textures
    for (int i = 0; i < 10; i++) {
      CanvasPattern pattern = engine.renderer["level$i"].context.createPatternFromImage(engine.images["level$i"], 'repeat');
      engine.renderer["level$i"].context.globalCompositeOperation = 'source-in';
      engine.renderer["level$i"].context.fillStyle = pattern;
      engine.renderer["level$i"].context.fillRect(0, 0, engine.renderer["level$i"].view.width, engine.renderer["level$i"].view.height);
      engine.renderer["level$i"].context.globalCompositeOperation = 'source-over';
    }

    // 3rd pass - draw borders
    for (int i = 0; i < world.size.x; i++) {
      for (int j = 0; j < world.size.y; j++) {
        int indexAbove = -1;
        for (int k = 9; k > -1; k--) {
           
          if (k <= world.tiles[i][j].height) {

            // calculate index
            int up = 0, down = 0, left = 0, right = 0;
            if (j - 1 < 0)
              up = 0;
            else if (world.tiles[i][j - 1].height >= k)
              up = 1;
            if (j + 1 > world.size.y - 1)
              down = 0;
            else if (world.tiles[i][j + 1].height >= k)
              down = 1;
            if (i - 1 < 0)
              left = 0;
            else if (world.tiles[i - 1][j].height >= k)
              left = 1;
            if (i + 1 > world.size.x - 1)
              right = 0;
            else if (world.tiles[i + 1][j].height >= k)
              right = 1;
            
            int index = (8 * down) + (4 * left) + (2 * up) + right;
          
            if (k < 9) {
              // skip tiles that are identical to the one above
              if (index == indexAbove)
                continue;
              // skip tiles that are not visible
              if (indexAbove == 5 || indexAbove == 7 || indexAbove == 10 || indexAbove == 11 ||
                  indexAbove == 13 || indexAbove == 14 || indexAbove == 15)
                continue;
            }
            
            indexAbove = index;
  
            engine.renderer["level$k"].context.drawImageScaledFromSource(engine.images["borders"], index * (tileSize + 6) + 2, 2, tileSize + 2, tileSize + 2, i * tileSize, j * tileSize, (tileSize + 2), (tileSize + 2));       
          }
        }
      }
    }

    engine.renderer["levelbuffer"].clear();
    for (int k = 0; k < 10; k++) {
      engine.renderer["levelbuffer"].context.drawImage(engine.renderer["level$k"].view, 0, 0);
    }
    querySelector('#loading').style.display = 'none';
  }

  /**
   * After scrolling, zooming, or tile redrawing the terrain is copied
   * to the visible buffer.
   */
  void copyTerrain() {
    engine.renderer["levelfinal"].clear();

    var targetLeft = 0;
    var targetTop = 0;
    var sourceLeft = scroll.x * tileSize - engine.halfWidth / zoom;
    var sourceTop = scroll.y * tileSize - engine.halfHeight / zoom;
    if (sourceLeft < 0) {
      targetLeft = -sourceLeft * zoom;
      sourceLeft = 0;
    }
    if (sourceTop < 0) {
      targetTop = -sourceTop * zoom;
      sourceTop = 0;
    }

    var targetWidth = engine.width;
    var targetHeight = engine.height;
    var sourceWidth = engine.width / zoom;
    var sourceHeight = engine.height / zoom;
    if (sourceLeft + sourceWidth > world.size.x * tileSize) {
      targetWidth -= (sourceLeft + sourceWidth - world.size.x * tileSize) * zoom;
      sourceWidth = world.size.x * tileSize - sourceLeft;
    }
    if (sourceTop + sourceHeight > world.size.y * tileSize) {
      targetHeight -= (sourceTop + sourceHeight - world.size.y * tileSize) * zoom;
      sourceHeight = world.size.y * tileSize - sourceTop;
    }
    engine.renderer["levelfinal"].context.drawImageScaledFromSource(engine.renderer["levelbuffer"].view, sourceLeft, sourceTop, sourceWidth, sourceHeight, targetLeft, targetTop, targetWidth, targetHeight);
  }

  /**
   * Takes a list of [tiles] and redraws them.
   * This is used when the terrain height of a tile has been changed by a Terp.
   */
  void redrawTerrain(List tiles) {
    List tempCanvas = [];
    List tempContext = [];
    for (int t = 0; t < 10; t++) {
      tempCanvas.add(new CanvasElement());
      tempCanvas[t].width = tileSize;
      tempCanvas[t].height = tileSize;
      tempContext.add(tempCanvas[t].getContext('2d'));
    }

    for (int i = 0; i < tiles.length; i++) {

      int iS = tiles[i].x;
      int jS = tiles[i].y;

      if (world.contains(new Vector(iS, jS))) {
        // recalculate index
        int index = -1;
        int indexAbove = -1;
        for (int t = 9; t > -1; t--) {
          if (t <= world.tiles[iS][jS].height) {
    
            int up = 0, down = 0, left = 0, right = 0;
            if (jS - 1 < 0)
              up = 0;
            else if (world.tiles[iS][jS - 1].height >= t)
              up = 1;
            if (jS + 1 > world.size.y - 1)
              down = 0;
            else if (world.tiles[iS][jS + 1].height >= t)
              down = 1;
            if (iS - 1 < 0)
              left = 0;
            else if (world.tiles[iS - 1][jS].height >= t)
              left = 1;
            if (iS + 1 > world.size.x - 1)
              right = 0;
            else if (world.tiles[iS + 1][jS].height >= t)
              right = 1;
    
            // save index for later use
            index = (8 * down) + (4 * left) + (2 * up) + right;
          }
              
          //if (index > -1) {
            tempContext[t].clearRect(0, 0, tileSize, tileSize);
            
            // redraw mask          
            if (t < 9) {
              // skip tiles that are identical to the one above
              if (index == indexAbove)
                continue;
              // skip tiles that are not visible
              if (indexAbove == 5 || indexAbove == 7 || indexAbove == 10 || indexAbove == 11 ||
                  indexAbove == 13 || indexAbove == 14 || indexAbove == 15)
                continue;
            }
            
            tempContext[t].drawImageScaledFromSource(engine.images["mask"], index * (tileSize + 6) + 3, (tileSize + 6) + 3, tileSize, tileSize, 0, 0, tileSize, tileSize);
  
            // redraw pattern
            var pattern = tempContext[t].createPatternFromImage(engine.images["level$t"], 'repeat');
  
            tempContext[t].globalCompositeOperation = 'source-in';
            tempContext[t].fillStyle = pattern;
  
            tempContext[t].save();
            Vector translation = new Vector((iS * tileSize).floor(), (jS * tileSize).floor());
            tempContext[t].translate(-translation.x, -translation.y);
  
            tempContext[t].fillRect(translation.x, translation.y, tileSize, tileSize);
            tempContext[t].restore();
  
            tempContext[t].globalCompositeOperation = 'source-over';
  
            // redraw borders
            if (t < 9) {
              // skip tiles that are identical to the one above
              if (index == indexAbove)
                continue;
              // skip tiles that are not visible
              if (indexAbove == 5 || indexAbove == 7 || indexAbove == 10 || indexAbove == 11 ||
                  indexAbove == 13 || indexAbove == 14 || indexAbove == 15)
                continue;
            }
            
            tempContext[t].drawImageScaledFromSource(engine.images["borders"], index * (tileSize + 6) + 2, 2, tileSize + 2, tileSize + 2, 0, 0, (tileSize + 2), (tileSize + 2));         
          //}
          
          // set above index
          indexAbove = index;
        }
  
        engine.renderer["levelbuffer"].context.clearRect(iS * tileSize, jS * tileSize, tileSize, tileSize);
        for (int t = 0; t < 10; t++) {
          engine.renderer["levelbuffer"].context.drawImageScaledFromSource(tempCanvas[t], 0, 0, tileSize, tileSize, iS * tileSize, jS * tileSize, tileSize, tileSize);
        }
      }
    }
    copyTerrain();
  }

  /**
   * Checks if a [building] can be placed on a given [position]. // tileposition
   */
  bool canBePlaced(Vector position, Building building) {

    if (game.world.contains(position)) {
      int height = game.world.tiles[position.x][position.y].height;
      
      Rectangle currentRect = new Rectangle(position.x * tileSize + 8 - building.size * tileSize / 2,
                                            position.y * tileSize + 8 - building.size * tileSize / 2,
                                            building.size * tileSize - 1,
                                            building.size * tileSize - 1);  
          
      // TODO: check for ghost collision
      if (Building.collision(currentRect, building) ||
          Emitter.collision(currentRect) ||
          Sporetower.collision(currentRect)) return false;
           
      // check if all tiles have the same height and are not corners
      for (int i = position.x - (building.size ~/ 2); i <= position.x + (building.size ~/ 2); i++) {
        for (int j = position.y - (building.size ~/ 2); j <= position.y + (building.size ~/ 2); j++) {
          if (world.contains(new Vector(i, j))) {
            int tileHeight = game.world.tiles[i][j].height;
            if (tileHeight < 0 || tileHeight != height) {
              return false;
            }
            if (!(world.tiles[i][j].index == 7 || world.tiles[i][j].index == 11 || world.tiles[i][j].index == 13 || world.tiles[i][j].index == 14 || world.tiles[i][j].index == 15)) {
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
  
  void updateEnergyElement() {
    if (Building.base != null)
      querySelector('#energy').innerHtml = "Energy: ${Building.base.energy.toString()}/${Building.base.maxEnergy.toString()}";
  }

  void updateSpeedElement() {
    querySelector("#speed").innerHtml = "Speed: ${speed.toString()}x";
  }

  /**
   * Main update function which calls all other update functions.
   * Is called by a periodic timer.
   */ 
  void update() {
    Building.updateHoverState();
    Ship.updateHoverState();

    if (!paused) {
      Emitter.update();
      Spore.update();
      Shell.update();
      World.update();      
      Projectile.update();
      Building.update();
      Packet.update();
      Smoke.update();
      Explosion.update();
      Ship.update();
      Sporetower.update();
    }

    // scroll left or right   
    scroll.x += mouseScrolling.x + keyScrolling.x;
    if (scroll.x < 0) scroll.x = 0;
    else if (scroll.x > world.size.x) scroll.x = world.size.x;

    // scroll up or down
    scroll.y += mouseScrolling.y + keyScrolling.y;
    if (scroll.y < 0) scroll.y = 0;
    else if (scroll.y > world.size.y) scroll.y = world.size.y;

    if (mouseScrolling.x != 0 || mouseScrolling.y != 0 || keyScrolling.x != 0 || keyScrolling.y != 0) {
      copyTerrain();
      drawCollection();
      updateVariousInfo();
      World.creeperDirty = true;
    }
  }

  /**
   * Draws the range boxes around the [position] of a building.
   */
  void drawRangeBoxes(Vector position, Building building) {
    CanvasRenderingContext2D context = engine.renderer["buffer"].context;
    
    if (canBePlaced(position, building) && (building.type == "collector" || building.type == "cannon" || building.type == "mortar" || building.type == "shield" || building.type == "beam" || building.type == "terp" || building.type == "analyzer")) {

      Vector positionCenter = new Vector(position.x * tileSize + (tileSize / 2), position.y * tileSize + (tileSize / 2));
      int positionHeight = game.world.tiles[position.x][position.y].height;
      
      context.save();
      context.globalAlpha = .35;

      for (int i = -building.weaponRadius; i <= building.weaponRadius; i++) {
        for (int j = -building.weaponRadius; j <= building.weaponRadius; j++) {

          Vector positionCurrent = position + new Vector(i, j);

          if (world.contains(positionCurrent)) {
            Vector positionCurrentCenter = new Vector(positionCurrent.x * tileSize + (tileSize / 2), positionCurrent.y * tileSize + (tileSize / 2));
            Vector drawPositionCurrent = positionCurrent.tiled2screen();
            
            int positionCurrentHeight = game.world.tiles[positionCurrent.x][positionCurrent.y].height;

            if (positionCenter.distanceTo(positionCurrentCenter) < building.weaponRadius * tileSize) {
              context.fillStyle = "#fff";
              if ((building.type == "collector" && positionCurrentHeight != positionHeight) ||
                  (building.type == "cannon" && positionCurrentHeight > positionHeight))
                context.fillStyle = "#f00";
              context.fillRect(drawPositionCurrent.x, drawPositionCurrent.y, tileSize * zoom, tileSize * zoom);
            }

          }
        }
      }
      context.restore();
    }
  }

  /**
   * Draws the green collection areas of collectors.
   */
  void drawCollection() {
    engine.renderer["collection"].clear();
    engine.renderer["collection"].context.save();
    engine.renderer["collection"].context.globalAlpha = .5;

    int timesX = (engine.halfWidth / tileSize / zoom).ceil();
    int timesY = (engine.halfHeight / tileSize / zoom).ceil();

    for (int i = -timesX; i <= timesX; i++) {
      for (int j = -timesY; j <= timesY; j++) {

        Vector position = new Vector(i + scroll.x, j + scroll.y);

        if (world.contains(position)) {
          if (world.tiles[position.x][position.y].collector != null) {
            int up = 0, down = 0, left = 0, right = 0;
            if (position.y - 1 < 0)
              up = 0;
            else
              up = world.tiles[position.x][position.y - 1].collector != null ? 1 : 0;
            if (position.y + 1 > world.size.y - 1)
              down = 0;
            else
              down = world.tiles[position.x][position.y + 1].collector != null ? 1 : 0;
            if (position.x - 1 < 0)
              left = 0;
            else
              left = world.tiles[position.x - 1][position.y].collector != null ? 1 : 0;
            if (position.x + 1 > world.size.x - 1)
              right = 0;
            else
              right = world.tiles[position.x + 1][position.y].collector != null ? 1 : 0;

            int index = (8 * down) + (4 * left) + (2 * up) + right;
            engine.renderer["collection"].context.drawImageScaledFromSource(engine.images["mask"], index * (tileSize + 6) + 3, (tileSize + 6) + 3, tileSize, tileSize, engine.halfWidth + i * tileSize * zoom, engine.halfHeight + j * tileSize * zoom, tileSize * zoom, tileSize * zoom);
          }
        }
      }
    }
    engine.renderer["collection"].context.restore();
  }

  void drawCreeper() {
    engine.renderer["creeperbuffer"].clear();

    int timesX = (engine.halfWidth / tileSize / zoom).ceil();
    int timesY = (engine.halfHeight / tileSize / zoom).ceil();

    for (int i = -timesX; i <= timesX; i++) {
      for (int j = -timesY; j <= timesY; j++) {

        Vector position = new Vector(i + scroll.x, j + scroll.y);
        
        if (world.contains(position)) {
          
          int height = world.tiles[position.x][position.y].height;
          
          // TODO: don't redraw everything each frame
          for (var t = 0; t <= 9; t++) {

            if (world.tiles[position.x][position.y].creep > t) {
              
              int up = 0, down = 0, left = 0, right = 0;
              if (position.y - 1 < 0)
                up = 0;
              else if (world.tiles[position.x][position.y - 1].creep > t || world.tiles[position.x][position.y - 1].height > height)
                up = 1;
              if (position.y + 1 > world.size.y - 1)
                down = 0;
              else if (world.tiles[position.x][position.y + 1].creep > t || world.tiles[position.x][position.y + 1].height > height)
                down = 1;
              if (position.x - 1 < 0)
                left = 0;
              else if (world.tiles[position.x - 1][position.y].creep > t || world.tiles[position.x - 1][position.y].height > height)
                left = 1;
              if (position.x + 1 > world.size.x - 1)
                right = 0;
              else if (world.tiles[position.x + 1][position.y].creep > t || world.tiles[position.x + 1][position.y].height > height)
                right = 1;
  
              int index = (8 * down) + (4 * left) + (2 * up) + right;
              engine.renderer["creeperbuffer"].context.drawImageScaledFromSource(engine.images["creeper"], index * tileSize, 0, tileSize, tileSize, engine.halfWidth + i * tileSize * zoom, engine.halfHeight + j * tileSize * zoom, tileSize * zoom, tileSize * zoom);
              continue;
            }
            
            if (t < 9) {
              int ind = world.tiles[position.x][position.y].index;
              bool indexOk = (ind != 5 && ind != 7 && ind != 10 && ind != 11 && ind != 13 && ind != 14 && ind != 14);
              int up = 0, down = 0, left = 0, right = 0;
              if (position.y - 1 < 0)
                up = 0;
              else if (world.tiles[position.x][position.y - 1].creep > t && indexOk && world.tiles[position.x][position.y - 1].height < height)
                up = 1;
              if (position.y + 1 > world.size.y - 1)
                down = 0;
              else if (world.tiles[position.x][position.y + 1].creep > t && indexOk && world.tiles[position.x][position.y + 1].height < height)
                down = 1;
              if (position.x - 1 < 0)
                left = 0;
              else if (world.tiles[position.x - 1][position.y].creep > t && indexOk && world.tiles[position.x - 1][position.y].height < height)
                left = 1;
              if (position.x + 1 > world.size.x - 1)
                right = 0;
              else if (world.tiles[position.x + 1][position.y].creep > t && indexOk && world.tiles[position.x + 1][position.y].height < height)
                right = 1;
  
              int index = (8 * down) + (4 * left) + (2 * up) + right;
              if (index != 0)
                engine.renderer["creeperbuffer"].context.drawImageScaledFromSource(engine.images["creeper"], index * tileSize, 0, tileSize, tileSize, engine.halfWidth + i * tileSize * zoom, engine.halfHeight + j * tileSize * zoom, tileSize * zoom, tileSize * zoom);
            }
          }
        }
        
      }
    }
    
    engine.renderer["creeper"].clear();
    engine.renderer["creeper"].context.drawImage(engine.renderer["creeperbuffer"].view, 0, 0);
  }
  
  void updateVariousInfo() {
    if (hoveredTile != oldHoveredTile) {
      
      // update terraform info
      if (world.contains(hoveredTile)) {   
        if (mode == "TERRAFORM") {
          Vector drawPosition = hoveredTile * tileSize;
          tfLine1
            ..from = new Vector(0, drawPosition.y)
            ..to = new Vector(world.size.y * tileSize, drawPosition.y)
            ..visible = true;
          tfLine2
            ..from = new Vector(0, drawPosition.y + tileSize)
            ..to = new Vector(world.size.y * tileSize, drawPosition.y + tileSize)
            ..visible = true;
          tfLine3
            ..from = new Vector(drawPosition.x, 0)
            ..to = new Vector(drawPosition.x, world.size.y * tileSize)
            ..visible = true;
          tfLine4
            ..from = new Vector(drawPosition.x + tileSize, 0)
            ..to = new Vector(drawPosition.x + tileSize, world.size.y * tileSize)
            ..visible = true;
          tfNumber
            ..position = hoveredTile * tileSize
            ..visible = true;       
        } else {
          tfLine1.visible = false;
          tfLine2.visible = false;
          tfLine3.visible = false;
          tfLine4.visible = false;
          tfNumber.visible = false;
        }      
        targetCursor.position = (hoveredTile * tileSize) + new Vector(8, 8);
      } else {
        tfLine1.visible = false;
        tfLine2.visible = false;
        tfLine3.visible = false;
        tfLine4.visible = false;
        tfNumber.visible = false;
      }
      
      // recalculate ghosts (semi-transparent building when placing a new building)
      ghosts.clear(); // ghosts are all the placeholders to build
      
      // calculate multiple ghosts when dragging
      if (engine.mouse.dragStart != null) {
        
        Vector start = engine.mouse.dragStart;
        Vector end = hoveredTile;
        Vector delta = end - start;
        num distance = start.distanceTo(end);
        
        num buildingDistance = 3;
        if (UISymbol.activeSymbol.building.type == "collector")
          buildingDistance = 9;
        else if (UISymbol.activeSymbol.building.type == "relay")
          buildingDistance = 18;
        
        num times = distance ~/ buildingDistance + 1;
        
        ghosts.add(start);
        
        for (int i = 1; i < times; i++) {
          Vector ghostPosition = new Vector(
              (start.x + (delta.x / distance) * i * buildingDistance).floor(),
              (start.y + (delta.y / distance) * i * buildingDistance).floor());
          
          if (world.contains(ghostPosition)) {
            ghosts.add(ghostPosition);
          }
        }
        if (world.contains(end)) {
          ghosts.add(end);
        }
      } else { // single ghost at cursor position
        if (engine.mouse.active) {
          if (world.contains(game.hoveredTile)) {
            ghosts.add(game.hoveredTile);
          }
        }
      }
    }
  }

  /**
   * When a building from the GUI is selected this draws some info
   * whether it can be build on the current tile, the range as
   * white boxes and connections to other buildings
   */
  void drawGhosts() {
    if (UISymbol.activeSymbol != null) {
      CanvasRenderingContext2D context = engine.renderer["buffer"].context;
       
      for (int i = 0; i < ghosts.length; i++) {
        Vector drawPosition = ghosts[i].tiled2screen();
        Vector ghostICenter = drawPosition + new Vector(8 * zoom, 8 * zoom);
  
        drawRangeBoxes(ghosts[i], UISymbol.activeSymbol.building);
  
        if (world.contains(ghosts[i])) {
          context.save();
          context.globalAlpha = .5;
  
          // draw building
          context.drawImageScaled(engine.images[UISymbol.activeSymbol.building.type], drawPosition.x - tileSize * zoom, drawPosition.y - tileSize * zoom, UISymbol.activeSymbol.building.size * tileSize * zoom, UISymbol.activeSymbol.building.size * tileSize * zoom);
          if (UISymbol.activeSymbol.building.type == "cannon")
            context.drawImageScaled(engine.images["cannongun"], drawPosition.x - tileSize * zoom, drawPosition.y - tileSize * zoom, 48 * zoom, 48 * zoom);
  
          // draw green or red box
          // make sure there isn't a building on this tile yet
          bool ghostCanBePlaced = canBePlaced(ghosts[i], UISymbol.activeSymbol.building);

          if (ghostCanBePlaced) {
            context.strokeStyle = "#0f0";
          } else {
            context.strokeStyle = "#f00";
          }
          context.lineWidth = 4 * zoom;
          context.strokeRect(drawPosition.x - tileSize * zoom, drawPosition.y - tileSize * zoom, tileSize * UISymbol.activeSymbol.building.size * zoom, tileSize * UISymbol.activeSymbol.building.size * zoom);
  
          context.restore();

          if (ghostCanBePlaced) {
            // draw lines to other buildings
            for (int j = 0; j < Building.buildings.length; j++) {
              if (UISymbol.activeSymbol.building.type == "collector" || UISymbol.activeSymbol.building.type == "relay" ||
                  Building.buildings[j].type == "collector" || Building.buildings[j].type == "relay" || Building.buildings[j].type == "base") {
                Vector buildingCenter = Building.buildings[j].position.real2screen();

                int allowedDistance = 10 * tileSize;
                if (Building.buildings[j].type == "relay" && UISymbol.activeSymbol.building.type == "relay") {
                  allowedDistance = 20 * tileSize;
                }

                if (buildingCenter.distanceTo(ghostICenter) <= allowedDistance * zoom) {
                  context
                    ..strokeStyle = '#000'
                    ..lineWidth = 3 * game.zoom
                    ..beginPath()
                    ..moveTo(buildingCenter.x, buildingCenter.y)
                    ..lineTo(ghostICenter.x, ghostICenter.y)
                    ..stroke()
                    ..strokeStyle = '#0f0'
                    ..lineWidth = 2 * game.zoom
                    ..stroke();
                }
              }
            }
            // draw lines to other ghosts
            for (int j = 0; j < ghosts.length; j++) {
              if (j != i) {
                if (UISymbol.activeSymbol.building.type == "collector" || UISymbol.activeSymbol.building.type == "relay") {
                  Vector ghostKCenter = ghosts[j].tiled2screen() + new Vector(8 * game.zoom, 8 * game.zoom);

                  int allowedDistance = 10 * tileSize;
                  if (UISymbol.activeSymbol.building.type == "relay") {
                    allowedDistance = 20 * tileSize;
                  }

                  Vector ghostJCenter = drawPosition + new Vector(8 * game.zoom, 8 * game.zoom);
                  if (ghostKCenter.distanceTo(ghostJCenter) <= allowedDistance * zoom) {
                    context
                      ..strokeStyle = '#000'
                      ..lineWidth = 2 * game.zoom
                      ..beginPath()
                      ..moveTo(ghostKCenter.x, ghostKCenter.y)
                      ..lineTo(ghostJCenter.x, ghostJCenter.y)
                      ..stroke()
                      ..strokeStyle = '#fff'
                      ..lineWidth = 1 * game.zoom
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

  /**
   * Draws the GUI with symbols, height and creep meter.
   */
  void drawGUI() {
    CanvasRenderingContext2D context = engine.renderer["gui"].context;
    
    engine.renderer["gui"].clear();
    for (int i = 0; i < UISymbol.symbols.length; i++) {
      UISymbol.symbols[i].draw();
    }

    if (world.contains(game.hoveredTile)) {

      num total = world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep;

      // draw height and creep meter
      context
        ..fillStyle = '#fff'
        ..font = '9px'
        ..textAlign = 'right'
        ..strokeStyle = '#fff'
        ..lineWidth = 1
        ..fillStyle = "rgba(205, 133, 63, 1)"
        ..fillRect(555, 110, 25, -game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height * 10 - 10)
        ..fillStyle = "rgba(100, 150, 255, 1)"
        ..fillRect(555, 110 - game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height * 10 - 10, 25, -total * 10)
        ..fillStyle = "rgba(255, 255, 255, 1)";
      for (int i = 1; i < 11; i++) {
        context
          ..fillText(i.toString(), 550, 120 - i * 10)
          ..beginPath()
          ..moveTo(555, 120 - i * 10)
          ..lineTo(580, 120 - i * 10)
          ..stroke();
      }
      context.textAlign = 'left';
      context.fillText(total.toStringAsFixed(2), 605, 10);
    }
  }
  
  /**
   * Main drawing function which calls all other drawing functions.
   * Is called by requestAnimationFrame every frame.
   */
  void draw(num _) {
    CanvasRenderingContext2D context = engine.renderer["buffer"].context;
    
    drawGUI();
    
    engine.renderer["buffer"].clear();
    engine.renderer["buffer"].draw();
    Building.draw();
    if (World.creeperDirty) {
      drawCreeper();
      World.creeperDirty = false;
    }

    if (engine.mouse.active) {

      Building.drawRepositionInfo();
      drawGhosts();
          
      /*Vector tp = game.getHoveredTilePosition();
      Vector tp2 = tp.tiled2screen();
      engine.renderer["buffer"].context.strokeStyle = '#f0f';
      engine.renderer["buffer"].context.strokeRect(tp2.x, tp2.y, tileSize * zoom, tileSize * zoom);*/
    }

    engine.renderer["main"].clear();
    engine.renderer["main"].context.drawImage(engine.renderer["buffer"].view, 0, 0);

    window.requestAnimationFrame(draw);
  }
}