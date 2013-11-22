part of creeper;

class Game {
  final int tileSize = 16;
  int seed, terraformingHeight = 0, speed = 1, creeperCounter = 0;
  double zoom = 1.0;
  Timer running;
  String mode;
  bool paused = false, creeperDirty = true;
  List<Vector> ghosts = new List<Vector>();
  World world;
  Vector scroll = new Vector.empty(), mouseScrolling = new Vector.empty(), keyScrolling = new Vector.empty();
  Stopwatch stopwatch = new Stopwatch();
  Line tfLine1, tfLine2, tfLine3, tfLine4;
  Sprite tfNumber;
  Sprite targetCursor;
  
  Game() {
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
    creeperCounter = 0;
    speed = 1;
    
    updateEnergyElement();
    updateSpeedElement();
    updateZoomElement();
    createWorld();
    
    stopwatch.reset();
    stopwatch.start();
    var oneSecond = new Duration(seconds:1);
    new Timer.periodic(oneSecond, updateTime);
    querySelector('#lose').style.display = 'none';
    querySelector('#win').style.display = 'none';
  }
  
  void updateTime(Timer _) {
    var s = game.stopwatch.elapsedMilliseconds~/1000;
    var m = 0;
    
    if (s >= 60) { m = s ~/ 60; s = s % 60; }
    
    String minute = (m <= 9) ? '0$m' : '$m';
    String second = (s <= 9) ? '0$s' : '$s';
    querySelector('#time').innerHtml = 'Time: $minute:$second';
  }

  /**
   *  Returns the position of the tile the mouse is hovering above
   */
  Vector getHoveredTilePosition() {
    return new Vector(
        ((engine.mouse.position.x - engine.halfWidth) / (tileSize * zoom)).floor() + scroll.x,
        ((engine.mouse.position.y - engine.halfHeight) / (tileSize * zoom)).floor() + scroll.y);
  }

  void pause() {
    querySelector('#paused').style.display = 'block';
    paused = true;
    stopwatch.stop();
  }

  void resume() {
    querySelector('#paused').style.display = 'none';
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
      updateZoomElement();
      creeperDirty = true;
    }
  }

  void zoomOut() {
    if (zoom > .4) {
      zoom -= .2;
      zoom = double.parse(zoom.toStringAsFixed(2));
      copyTerrain();
      drawCollection();
      updateZoomElement();
      creeperDirty = true;
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
          engine.randomInt(0, world.size.x - 3, seed + engine.randomInt(1, 1000, seed + l)),
          engine.randomInt(0, world.size.y - 3, seed + engine.randomInt(1, 1000, seed + 1 + l)));
  
      Emitter emitter = Emitter.add(new Vector(randomPosition.x * tileSize + 24, randomPosition.y * tileSize + 24), 25);
  
      height = world.getTile(emitter.sprite.position).height; //this.world.tiles[emitter.sprite.position.x + 1][emitter.sprite.position.y + 1].height;
      if (height < 0)
        height = 0;
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          world.getTile(emitter.sprite.position + new Vector(i * tileSize, j * tileSize)).height = height; //world.tiles[emitter.sprite.position.x + i][emitter.sprite.position.y + j].height = height;
        }
      }
    }

    // create sporetowers
    number = engine.randomInt(1, 2, seed + 1);
    for (var l = 0; l < number; l++) {
      randomPosition = new Vector(
          engine.randomInt(0, world.size.x - 3, seed + 3 + engine.randomInt(1, 1000, seed + 2 + l)),
          engine.randomInt(0, world.size.y - 3, seed + 3 + engine.randomInt(1, 1000, seed + 3 + l)));
  
      Sporetower sporetower = Sporetower.add(new Vector(randomPosition.x * tileSize + 24, randomPosition.y * tileSize + 24));
  
      height = world.getTile(sporetower.sprite.position).height; //this.world.tiles[sporetower.position.x + 1][sporetower.position.y + 1].height;
      if (height < 0)
        height = 0;
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          world.getTile(sporetower.sprite.position + new Vector(i * tileSize, j * tileSize)).height = height; //world.tiles[sporetower.position.x + i][sporetower.position.y + j].height = height;
        }
      }
    }
  }

  void setupUI() {
    UISymbol.add(new Vector(0, 0), "cannon", KeyCode.Q, 3, 25, 10);
    UISymbol.add(new Vector(81, 0), "collector", KeyCode.W, 3, 5, 6);
    UISymbol.add(new Vector(2 * 81, 0), "reactor", KeyCode.E, 3, 50, 0);
    UISymbol.add(new Vector(3 * 81, 0), "storage", KeyCode.R, 3, 8, 0);
    UISymbol.add(new Vector(4 * 81, 0), "shield", KeyCode.T, 3, 75, 10);
    UISymbol.add(new Vector(5 * 81, 0), "analyzer", KeyCode.Z, 3, 80, 10);
    UISymbol.add(new Vector(0, 56), "relay", KeyCode.A, 3, 10, 8);
    UISymbol.add(new Vector(81, 56), "mortar", KeyCode.S, 3, 40, 14);
    UISymbol.add(new Vector(2 * 81, 56), "beam", KeyCode.D, 3, 20, 20);
    UISymbol.add(new Vector(3 * 81, 56), "bomber", KeyCode.F, 3, 75, 0);
    UISymbol.add(new Vector(4 * 81, 56), "terp", KeyCode.G, 3, 60, 20);
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
   * Checks if a [building] with its [size] can be placed on a given [position]. // tileposition
   */
  bool canBePlaced(Vector position, num size, [Building building]) {

    if (game.world.contains(position)) {
      int height = game.world.tiles[position.x][position.y].height;
      
      Rectangle currentRect = new Rectangle(position.x * tileSize + 8 - size * tileSize / 2,
                                            position.y * tileSize + 8 - size * tileSize / 2,
                                            size * tileSize - 1,
                                            size * tileSize - 1);  
          
      if (Building.collision(currentRect, building) ||
          Emitter.collision(currentRect) ||
          Sporetower.collision(currentRect)) return false;
           
      // check if all tiles have the same height and are not corners
      for (int i = position.x - 1; i <= position.x + 1; i++) {
        for (int j = position.y - 1; j <= position.y + 1; j++) {
          if (world.contains(new Vector(i, j))) {
            int tileHeight = game.world.tiles[i][j].height;
            if (tileHeight < 0 || tileHeight != height) {
              return false;
            }
            if (!(world.tiles[i][j].index == 7 || world.tiles[i][j].index == 11 || world.tiles[i][j].index == 13 || world.tiles[i][j].index == 14 || world.tiles[i][j].index == 15)) {
              return false;
            }
          }
        }
      }
      
      return true;      
    } else {
      return false;
    }
  }
  
  void updateCreeper() {
    Emitter.update();

    creeperCounter += 1 * game.speed;
    if (creeperCounter >= 25) {
      creeperCounter -= 25;
      creeperDirty = true;

      for (int i = 0; i < world.size.x; i++) {
        for (int j = 0; j < world.size.y; j++) {

          // right neighbour
          if (i + 1 < world.size.x) {
            transferCreeper(world.tiles[i][j], world.tiles[i + 1][j]);
          }
          // left neighbour
          if (i - 1 > -1) {
            transferCreeper(world.tiles[i][j], world.tiles[i - 1][j]);
          }
          // bottom neighbour
          if (j + 1 < world.size.y) {
            transferCreeper(world.tiles[i][j], world.tiles[i][j + 1]);
          }
          // top neighbour
          if (j - 1 > -1) {
            transferCreeper(world.tiles[i][j], world.tiles[i][j - 1]);
          }

        }
      }
      
      // clamp creeper
      for (int i = 0; i < world.size.x; i++) {
        for (int j = 0; j < world.size.y; j++) {
          if (world.tiles[i][j].newcreep > 10)
            world.tiles[i][j].newcreep = 10;
          else if (world.tiles[i][j].newcreep < .01)
            world.tiles[i][j].newcreep = 0;
          world.tiles[i][j].creep = world.tiles[i][j].newcreep;
        }
      }

    }
  }

  /**
   * Transfers creeper from one tile to another.
   */ 
  void transferCreeper(Tile source, Tile target) {
    num transferRate = .2;

    if (source.height > -1 && target.height > -1) {
      num sourceCreeper = source.creep;     
      //num targetCreeper = target.creep;
      if (sourceCreeper > 0 /*|| targetCreeper > 0*/) {
        num sourceTotal = source.height + source.creep;
        num targetTotal = target.height + target.creep;
        num delta = 0;
        if (sourceTotal > targetTotal) {
          delta = sourceTotal - targetTotal;
          if (delta > sourceCreeper)
            delta = sourceCreeper;
          num adjustedDelta = delta * transferRate;
          source.newcreep -= adjustedDelta;
          target.newcreep += adjustedDelta;
        }
      }
    }
  }
  
  void updateEnergyElement() {
    if (Building.base != null)
      querySelector('#energy').innerHtml = "Energy: ${Building.base.energy.toString()}/${Building.base.maxEnergy.toString()}";
  }

  void updateSpeedElement() {
    querySelector("#speed").innerHtml = "Speed: ${speed.toString()}x";
  }

  void updateZoomElement() {
    querySelector("#speed").innerHtml = "Zoom: ${zoom.toString()}x";
  }

  /**
   * Main update function which calls all other update functions.
   * Is called by a periodic timer.
   */ 
  void update() {
    Building.updateHoverState();
    Ship.updateHoverState();

    if (!paused) {
      Emitter.checkWinningCondition(); 
      Spore.update();
      Shell.update();
      updateCreeper();      
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
      updateTerraformInfo();
      creeperDirty = true;
    }
  }

  /**
   * Draws the range boxes around the [position] of a building
   * with a given [type], [radius] and [size].
   */
  void drawRangeBoxes(Vector position, String type, num radius, num size) {
    CanvasRenderingContext2D context = engine.renderer["buffer"].context;
    
    if (canBePlaced(position, size, null) && (type == "collector" || type == "cannon" || type == "mortar" || type == "shield" || type == "beam" || type == "terp" || type == "analyzer")) {

      Vector positionCenter = new Vector(position.x * tileSize + (tileSize / 2), position.y * tileSize + (tileSize / 2));
      int positionHeight = game.world.tiles[position.x][position.y].height;
      
      context.save();
      context.globalAlpha = .35;

      for (int i = -radius; i <= radius; i++) {
        for (int j = -radius; j <= radius; j++) {

          Vector positionCurrent = position + new Vector(i, j);

          if (world.contains(positionCurrent)) {
            Vector positionCurrentCenter = new Vector(positionCurrent.x * tileSize + (tileSize / 2), positionCurrent.y * tileSize + (tileSize / 2));
            Vector drawPositionCurrent = positionCurrent.tiled2screen();
            
            int positionCurrentHeight = game.world.tiles[positionCurrent.x][positionCurrent.y].height;

            if (positionCenter.distanceTo(positionCurrentCenter) < radius * tileSize) {
              context.fillStyle = "#fff";
              if ((type == "collector" && positionCurrentHeight != positionHeight) ||
                  (type == "cannon" && positionCurrentHeight > positionHeight))
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

        int iS = i + scroll.x;
        int jS = j + scroll.y;

        if (world.contains(new Vector(iS, jS))) {

          //for (int k = 0 ; k < 10; k++) {
            if (world.tiles[iS][jS].collector != null) {
              int up = 0, down = 0, left = 0, right = 0;
              if (jS - 1 < 0)
                up = 0;
              else
                up = world.tiles[iS][jS - 1].collector != null ? 1 : 0;
              if (jS + 1 > world.size.y - 1)
                down = 0;
              else
                down = world.tiles[iS][jS + 1].collector != null ? 1 : 0;
              if (iS - 1 < 0)
                left = 0;
              else
                left = world.tiles[iS - 1][jS].collector != null ? 1 : 0;
              if (iS + 1 > world.size.x - 1)
                right = 0;
              else
                right = world.tiles[iS + 1][jS].collector != null ? 1 : 0;

              int index = (8 * down) + (4 * left) + (2 * up) + right;
              engine.renderer["collection"].context.drawImageScaledFromSource(engine.images["mask"], index * (tileSize + 6) + 3, (tileSize + 6) + 3, tileSize, tileSize, engine.halfWidth + i * tileSize * zoom, engine.halfHeight + j * tileSize * zoom, tileSize * zoom, tileSize * zoom);
            }
          //}
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

        int iS = i + scroll.x;
        int jS = j + scroll.y;

        if (world.contains(new Vector(iS, jS))) {
          
          int height = world.tiles[iS][jS].height;
          
          // TODO: don't redraw everything each frame
          for (var t = 0; t <= 9; t++) {

            if (world.tiles[iS][jS].creep > t) {
              
              int up = 0, down = 0, left = 0, right = 0;
              if (jS - 1 < 0)
                up = 0;
              else if (world.tiles[iS][jS - 1].creep > t || world.tiles[iS][jS - 1].height > height)
                up = 1;
              if (jS + 1 > world.size.y - 1)
                down = 0;
              else if (world.tiles[iS][jS + 1].creep > t || world.tiles[iS][jS + 1].height > height)
                down = 1;
              if (iS - 1 < 0)
                left = 0;
              else if (world.tiles[iS - 1][jS].creep > t || world.tiles[iS - 1][jS].height > height)
                left = 1;
              if (iS + 1 > world.size.x - 1)
                right = 0;
              else if (world.tiles[iS + 1][jS].creep > t || world.tiles[iS + 1][jS].height > height)
                right = 1;
  
              int index = (8 * down) + (4 * left) + (2 * up) + right;
              engine.renderer["creeperbuffer"].context.drawImageScaledFromSource(engine.images["creeper"], index * tileSize, 0, tileSize, tileSize, engine.halfWidth + i * tileSize * zoom, engine.halfHeight + j * tileSize * zoom, tileSize * zoom, tileSize * zoom);
              continue;
            }
            
            if (t < 9) {
              int ind = world.tiles[iS][jS].index;
              bool indexOk = (ind != 5 && ind != 7 && ind != 10 && ind != 11 && ind != 13 && ind != 14 && ind != 14);
              int up = 0, down = 0, left = 0, right = 0;
              if (jS - 1 < 0)
                up = 0;
              else if (world.tiles[iS][jS - 1].creep > t && indexOk && world.tiles[iS][jS - 1].height < height)
                up = 1;
              if (jS + 1 > world.size.y - 1)
                down = 0;
              else if (world.tiles[iS][jS + 1].creep > t && indexOk && world.tiles[iS][jS + 1].height < height)
                down = 1;
              if (iS - 1 < 0)
                left = 0;
              else if (world.tiles[iS - 1][jS].creep > t && indexOk && world.tiles[iS - 1][jS].height < height)
                left = 1;
              if (iS + 1 > world.size.x - 1)
                right = 0;
              else if (world.tiles[iS + 1][jS].creep > t && indexOk && world.tiles[iS + 1][jS].height < height)
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
  
  void updateTerraformInfo() {
    Vector position = getHoveredTilePosition();
    if (world.contains(position)) {   
      if (mode == "TERRAFORM") {
        Vector drawPosition = position * tileSize;
        tfLine1.from = new Vector(0, drawPosition.y);
        tfLine1.to = new Vector(world.size.y * tileSize, drawPosition.y);
        tfLine2.from = new Vector(0, drawPosition.y + tileSize);
        tfLine2.to = new Vector(world.size.y * tileSize, drawPosition.y + tileSize);
        tfLine3.from = new Vector(drawPosition.x, 0);
        tfLine3.to = new Vector(drawPosition.x, world.size.y * tileSize);
        tfLine4.from = new Vector(drawPosition.x + tileSize, 0);
        tfLine4.to = new Vector(drawPosition.x + tileSize, world.size.y * tileSize); 
        tfLine1.visible = true;
        tfLine2.visible = true;
        tfLine3.visible = true;
        tfLine4.visible = true;
        tfNumber.visible = true;
        tfNumber.position = position * tileSize;
      } else {
        tfLine1.visible = false;
        tfLine2.visible = false;
        tfLine3.visible = false;
        tfLine4.visible = false;
        tfNumber.visible = false;
      }
      
      targetCursor.position = (position * tileSize) + new Vector(8, 8);
    } else {
      tfLine1.visible = false;
      tfLine2.visible = false;
      tfLine3.visible = false;
      tfLine4.visible = false;
      tfNumber.visible = false;
    }
  }

  /**
   * When a building from the GUI is selected this draws some info
   * whether it can be build on the current tile, the range as
   * white boxes and connections to other buildings
   */
  void drawPositionInfo() {
    if (UISymbol.activeSymbol != null) {
      CanvasRenderingContext2D context = engine.renderer["buffer"].context;
      
      ghosts = new List(); // ghosts are all the placeholders to build
      
      // calculate multiple ghosts when dragging
      if (engine.mouse.dragStart != null) {
  
        Vector start = engine.mouse.dragStart;
        Vector end = engine.mouse.dragEnd;
        Vector delta = end - start;
        num distance = start.distanceTo(end);
        
        num buildingDistance = 3;
        if (UISymbol.activeSymbol.imageID == "collector")
          buildingDistance = 9;
        else if (UISymbol.activeSymbol.imageID == "relay")
          buildingDistance = 18;
      
        num times = (distance / buildingDistance).floor() + 1;
  
        ghosts.add(start);
  
        for (int i = 1; i < times; i++) {
          num newX = (start.x + (delta.x / distance) * i * buildingDistance).floor();
          num newY = (start.y + (delta.y / distance) * i * buildingDistance).floor();
  
          if (world.contains(new Vector(newX, newY))) {
            Vector ghost = new Vector(newX, newY);
            ghosts.add(ghost);
          }
        }
        if (world.contains(end)) {
          ghosts.add(end);
        }
      } else { // single ghost at cursor position
        if (engine.mouse.active) {
          Vector position = getHoveredTilePosition();
          if (world.contains(position)) {
            ghosts.add(position);
          }
        }
      }
  
      for (int i = 0; i < ghosts.length; i++) {
        Vector positionScrolled = new Vector(ghosts[i].x, ghosts[i].y);
        Vector drawPosition = positionScrolled.tiled2screen();
        Vector ghostICenter = drawPosition + new Vector(8 * zoom, 8 * zoom); //new Vector(positionScrolled.x * tileSize + 8 * zoom, positionScrolled.y * tileSize + 8 * zoom);
  
        drawRangeBoxes(positionScrolled, UISymbol.activeSymbol.imageID, UISymbol.activeSymbol.radius, UISymbol.activeSymbol.size);
  
        if (world.contains(positionScrolled)) {
          context.save();
          context.globalAlpha = .5;
  
          // draw building
          context.drawImageScaled(engine.images[UISymbol.activeSymbol.imageID], drawPosition.x - tileSize * zoom, drawPosition.y - tileSize * zoom, UISymbol.activeSymbol.size * tileSize * zoom, UISymbol.activeSymbol.size * tileSize * zoom);
          if (UISymbol.activeSymbol.imageID == "cannon")
            context.drawImageScaled(engine.images["cannongun"], drawPosition.x - tileSize * zoom, drawPosition.y - tileSize * zoom, 48 * zoom, 48 * zoom);
  
          // draw green or red box
          // make sure there isn't a building on this tile yet
          bool ghostCanBePlaced = canBePlaced(positionScrolled, UISymbol.activeSymbol.size, null);

          if (ghostCanBePlaced) {
            context.strokeStyle = "#0f0";
          } else {
            context.strokeStyle = "#f00";
          }
          context.lineWidth = 4 * zoom;
          context.strokeRect(drawPosition.x - tileSize * zoom, drawPosition.y - tileSize * zoom, tileSize * UISymbol.activeSymbol.size * zoom, tileSize * UISymbol.activeSymbol.size * zoom);
  
          context.restore();

          if (ghostCanBePlaced) {
            // draw lines to other buildings
            for (int j = 0; j < Building.buildings.length; j++) {
              if (Building.buildings[j].type == "collector" || Building.buildings[j].type == "relay" || Building.buildings[j].type == "base") {
                Vector buildingCenter = Building.buildings[j].position.real2screen();

                int allowedDistance = 10 * tileSize;
                if (Building.buildings[j].type == "relay" && UISymbol.activeSymbol.imageID == "relay") {
                  allowedDistance = 20 * tileSize;
                }

                if (buildingCenter.distanceTo(ghostICenter) <= allowedDistance * zoom) {
                  context
                    ..strokeStyle = '#000'
                    ..lineWidth = 3 * game.zoom
                    ..beginPath()
                    ..moveTo(buildingCenter.x, buildingCenter.y)
                    ..lineTo(ghostICenter.x, ghostICenter.y)
                    ..stroke();

                  context
                    ..strokeStyle = '#0f0'
                    ..lineWidth = 2 * game.zoom
                    ..beginPath()
                    ..moveTo(buildingCenter.x, buildingCenter.y)
                    ..lineTo(ghostICenter.x, ghostICenter.y)
                    ..stroke();
                }
              }
            }
            // draw lines to other ghosts
            for (int j = 0; j < ghosts.length; j++) {
              if (j != i) {
                if (UISymbol.activeSymbol.imageID == "collector" || UISymbol.activeSymbol.imageID == "relay") {
                  Vector ghostKCenter = ghosts[j].tiled2screen() + new Vector(8 * game.zoom, 8 * game.zoom);

                  int allowedDistance = 10 * tileSize;
                  if (UISymbol.activeSymbol.imageID == "relay") {
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
                      ..stroke();

                    context
                      ..strokeStyle = '#fff'
                      ..lineWidth = 1 * game.zoom
                      ..beginPath()
                      ..moveTo(ghostKCenter.x, ghostKCenter.y)
                      ..lineTo(ghostJCenter.x, ghostJCenter.y)
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
    
    Vector position = getHoveredTilePosition();

    engine.renderer["gui"].clear();
    for (int i = 0; i < UISymbol.symbols.length; i++) {
      UISymbol.symbols[i].draw();
    }

    if (world.contains(position)) {

      num total = world.tiles[position.x][position.y].creep;

      // draw height and creep meter
      context.fillStyle = '#fff';
      context.font = '9px';
      context.textAlign = 'right';
      context.strokeStyle = '#fff';
      context.lineWidth = 1;
      context.fillStyle = "rgba(205, 133, 63, 1)";
      context.fillRect(555, 110, 25, -game.world.tiles[getHoveredTilePosition().x][getHoveredTilePosition().y].height * 10 - 10);
      context.fillStyle = "rgba(100, 150, 255, 1)";
      context.fillRect(555, 110 - game.world.tiles[getHoveredTilePosition().x][getHoveredTilePosition().y].height * 10 - 10, 25, -total * 10);
      context.fillStyle = "rgba(255, 255, 255, 1)";
      for (int i = 1; i < 11; i++) {
        context.fillText(i.toString(), 550, 120 - i * 10);
        context.beginPath();
        context.moveTo(555, 120 - i * 10);
        context.lineTo(580, 120 - i * 10);
        context.stroke();
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
    if (creeperDirty) {
      drawCreeper();
      creeperDirty = false;
    }

    if (engine.mouse.active) {

      // if a building is built and selected draw a green box and a line to the mouse position as the reposition target
      Building.drawRepositionInfo();
      drawPositionInfo();
          
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