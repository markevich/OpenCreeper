part of creeper;

class Game {
  int seed, terraformingHeight = 0, speed = 1;
  double zoom = 1.0;
  Timer running;
  String mode;
  bool paused = false, won = false;
  List<Zei.Vector2> ghosts = new List<Zei.Vector2>();
  World world;
  Zei.Vector2 oldHoveredTile = new Zei.Vector2.empty(), hoveredTile = new Zei.Vector2.empty();
  Stopwatch stopwatch = new Stopwatch();
  Zei.Line tfLine1, tfLine2, tfLine3, tfLine4;
  Zei.Sprite tfNumber;
  Zei.Sprite targetCursor;
  Zei.Rect repositionRect;
  UserInterface ui;
  List zoomableRenderers;
  Zei.Mouse mouse;
  Scroller scroller;
  var debug = true;
  bool friendly;
  static List<Zei.DisplayObject> ghostDisplayObjects = new List<Zei.DisplayObject>();
  
  Game() {
    Zei.init(TPS: 60, debug: false);
  }

  Game start({int seed: null, bool friendly: false}) {
    if (seed == null)
      this.seed = Zei.randomInt(0, 10000);
    else
      this.seed = seed;
    
    this.friendly = friendly;
       
    Zei.Audio.setChannels(5);
    List sounds = ["shot.wav", "click.wav", "explosion.wav", "failure.wav", "energy.wav", "laser.wav"];
    Zei.Audio.load(sounds);
    List images = ["analyzer", "numbers", "level0", "level1", "level2", "level3", "level4", "level5", "level6", "level7", "level8", "level9", "borders", "mask", "cannon",
                       "cannongun", "base", "collector", "reactor", "storage", "terp", "packet_collection", "packet_energy", "packet_health", "relay", "emitter", "creeper",
                       "mortar", "shell", "beam", "spore", "bomber", "bombership", "smoke", "explosion", "targetcursor", "sporetower", "forcefield", "shield", "projectile", "inactive"];  
    Zei.loadImages(images).then((results) => init());    
    return this;
  }

  void init() {  
    querySelector("#seed").innerHtml = "Seed: $seed";

    // create renderer
    int width = window.innerWidth;
    int height = window.innerHeight;
    
    var main = Zei.Renderer.create("main", width, height, container: "body");
    main.view.style.zIndex = "1";   
    main.enableMouse();
    mouse = main.mouse;
    mouse.setCursor("url('images/Normal.cur') 2 2, pointer");
    game.scroller = new Scroller();
       
    main.setLayers(["terraform", "selectedcircle", "targetsymbol", "connectionborder", "connection", "building", "buildinginfo", "sporetower", "emitter", "projectile", "buildinggun", "packet",
                    "shield", "explosion", "smoke", "buildingflying", "buildinginfoflying", "ship", "shell", "spore", "buildinggunflying", "energybar"]);
   
    for (int i = 0; i < 10; i++) {
      Zei.Renderer.create("level$i", 128 * 16, 128 * 16, autodraw: false);
    }
    Zei.Renderer.create("levelbuffer", 128 * 16, 128 * 16, autodraw: false);
    Zei.Renderer.create("levelfinal", width, height, container: "body", autodraw: false);
    
    Zei.Renderer.create("collection", width, height, container: "body", autodraw: false);
    
    Zei.Renderer.create("creeper", width, height, container: "body", autodraw: false);
    
    var guiRenderer = Zei.Renderer.create("gui", 780, 110, container: "#gui");
    guiRenderer.setLayers(["default"]);
    guiRenderer.updatePosition(new Zei.Vector2(390, 55));
       
    // renderes affected when zooming
    zoomableRenderers = ["main", "collection"];
    
    world = new World(seed);
  
    var music = new AudioElement("sounds/music.ogg");
    music.loop = true;
    music.volume = 0.25;
    music.onCanPlay.listen((event) => music.play()); // TODO: find out why this is not working
     
    reset();
    drawTerrain();
    copyTerrain();
    setupEventHandler();
    run();
  }
  
  void setupEventHandler() {
    querySelector('#terraform').onClick.listen((event) => game.toggleTerraform());
    //query('#slower').onClick.listen((event) => game.slower());
    //query('#faster').onClick.listen((event) => game.faster());
    //query('#pause').onClick.listen((event) => game.pause());
    querySelector('#continue').onClick.listen((event) => game.resume());
    querySelector('#restart').onClick.listen((event) => game.restart());
    querySelector('#restart2').onClick.listen((event) => game.restart());
    querySelector('#deactivate').onClick.listen((event) => Building.deactivate());
    querySelector('#activate').onClick.listen((event) => Building.activate());
  
    Zei.renderer["main"].view
      ..onMouseMove.listen((event) => onMouseMove(event))
      ..onDoubleClick.listen((event) => onDoubleClick(event))
      ..onMouseDown.listen((event) => onMouseDown(event))
      ..onMouseUp.listen((event) => onMouseUp(event))
      ..onMouseWheel.listen((event) => onMouseScroll(event))
      ..onMouseEnter.listen((event) => onEnter(event))
      ..onMouseLeave.listen((event) => onLeave(event));

    Zei.renderer["gui"].view
      ..onMouseMove.listen((event) => onMouseMoveGUI(event))
      ..onClick.listen((event) => onClickGUI(event))
      ..onMouseLeave.listen((event) => onLeaveGUI);

    document
      ..onKeyDown.listen((event) => onKeyDown(event))
      //..onKeyUp.listen((event) => onKeyUp(event))
      ..onContextMenu.listen((event) => event.preventDefault());

    window
      ..onResize.listen((event) => onResize(event));
  }

  void reset() {
    Zei.clear();
    UISymbol.reset();
    Building.queue.clear();
    
    mode = "DEFAULT";
    speed = 1;
    won = false;
    
    world.create();
    drawCollection();
    
    Zei.GameObject.add(world);
    Zei.GameObject.add(game.scroller);
    
    stopwatch.reset();
    stopwatch.start();
    var oneSecond = new Duration(seconds:1);
    new Timer.periodic(oneSecond, updateTime);
    //querySelector('#lose').style.display = 'none';
    querySelector('#win').style.display = 'none';
    updateEnergyElement();
    updateSpeedElement();
    querySelector('#time').innerHtml = 'Time: 00:00';
    
    // create UI
    ui = new UserInterface(Zei.renderer["gui"]);
    
    // create terraform lines and number used when terraforming is enabled
    tfLine1 = Zei.Line.create("main", "terraform", new Zei.Vector2.empty(), new Zei.Vector2.empty(), 1, new Zei.Color.white(), visible: false);
    tfLine2 = Zei.Line.create("main", "terraform", new Zei.Vector2.empty(), new Zei.Vector2.empty(), 1, new Zei.Color.white(), visible: false);
    tfLine3 = Zei.Line.create("main", "terraform", new Zei.Vector2.empty(), new Zei.Vector2.empty(), 1, new Zei.Color.white(), visible: false);
    tfLine4 = Zei.Line.create("main", "terraform", new Zei.Vector2.empty(), new Zei.Vector2.empty(), 1, new Zei.Color.white(), visible: false);
    
    tfNumber = Zei.Sprite.create("main", "terraform", Zei.images["numbers"], new Zei.Vector2.empty(), 16, 16, animated: true, frame: terraformingHeight, visible: false);
    tfNumber.stopAnimation();
    
    // create target cursor used when a ship is selected
    targetCursor = Zei.Sprite.create("main", "targetsymbol", Zei.images["targetcursor"], new Zei.Vector2.empty(), 48, 48, visible: false, anchor: new Zei.Vector2(0.5, 0.5));
    
    // rectangle that is drawn when repositioning a building
    repositionRect = Zei.Rect.create("main", "targetsymbol", new Zei.Vector2(0, 0), new Zei.Vector2(32, 32), 10, new Zei.Color.red(), null, visible: false);
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
    Zei.Renderer.stopAnimations();

  }

  void resume() {
    querySelector('#paused').style.display = 'none';
    querySelector('#win').style.display = 'none';
    paused = false;
    stopwatch.start();
    Zei.Renderer.startAnimations();
  }

  void stop() {
    running.cancel();
    Zei.stop();
  }

  void run() {
    running = new Timer.periodic(new Duration(milliseconds: (1000 / Zei.TPS).floor()), (Timer timer) => updateAll());
    Zei.run();
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
      
      for (var renderer in zoomableRenderers) {
        Zei.renderer[renderer].updateZoom(zoom);
      }
      copyTerrain();
      drawCollection();
      World.creeperDirty = true;
    }
  }

  void zoomOut() {
    if (zoom > .4) {
      zoom -= .2;
      zoom = double.parse(zoom.toStringAsFixed(2));
      for (var renderer in zoomableRenderers) {
        Zei.renderer[renderer].updateZoom(zoom);
      }
      copyTerrain();
      drawCollection();
      World.creeperDirty = true;
    }
  }

  /**
   * Draws the complete terrain.
   * This method is only called ONCE at the start of the game.
   */
  void drawTerrain() {
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
           
            Zei.renderer["level$k"].context.drawImageScaledFromSource(Zei.images["mask"], index * (Tile.size + 6) + 3, (Tile.size + 6) + 3, Tile.size, Tile.size, i * Tile.size, j * Tile.size, Tile.size, Tile.size);
          }
        }
      }
    }

    // 2nd pass - draw textures
    for (int i = 0; i < 10; i++) {
      CanvasPattern pattern = Zei.renderer["level$i"].context.createPatternFromImage(Zei.images["level$i"], 'repeat');
      Zei.renderer["level$i"].context.globalCompositeOperation = 'source-in';
      Zei.renderer["level$i"].context.fillStyle = pattern;
      Zei.renderer["level$i"].context.fillRect(0, 0, Zei.renderer["level$i"].view.width, Zei.renderer["level$i"].view.height);
      Zei.renderer["level$i"].context.globalCompositeOperation = 'source-over';
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
  
            Zei.renderer["level$k"].context.drawImageScaledFromSource(Zei.images["borders"], index * (Tile.size + 6) + 2, 2, Tile.size + 2, Tile.size + 2, i * Tile.size, j * Tile.size, (Tile.size + 2), (Tile.size + 2));       
          }
        }
      }
    }

    Zei.renderer["levelbuffer"].clear();
    for (int k = 0; k < 10; k++) {
      Zei.renderer["levelbuffer"].context.drawImage(Zei.renderer["level$k"].view, 0, 0);
    }
    querySelector('#loading').style.display = 'none';
  }

  /**
   * After scrolling, zooming, or tile redrawing the terrain is copied
   * to the "main" renderer.
   */
  void copyTerrain() {
    Zei.renderer["levelfinal"].clear();

    var targetLeft = 0;
    var targetTop = 0;
    var sourceLeft = scroller.scroll.x * Tile.size - Zei.renderer["main"].view.width / 2 / zoom;
    var sourceTop = scroller.scroll.y * Tile.size - Zei.renderer["main"].view.height / 2 / zoom;
    if (sourceLeft < 0) {
      targetLeft = -sourceLeft * zoom;
      sourceLeft = 0;
    }
    if (sourceTop < 0) {
      targetTop = -sourceTop * zoom;
      sourceTop = 0;
    }

    var targetWidth = Zei.renderer["main"].view.width;
    var targetHeight = Zei.renderer["main"].view.height;
    var sourceWidth = Zei.renderer["main"].view.width / zoom;
    var sourceHeight = Zei.renderer["main"].view.height / zoom;
    if (sourceLeft + sourceWidth > world.size.x * Tile.size) {
      targetWidth -= (sourceLeft + sourceWidth - world.size.x * Tile.size) * zoom;
      sourceWidth = world.size.x * Tile.size - sourceLeft;
    }
    if (sourceTop + sourceHeight > world.size.y * Tile.size) {
      targetHeight -= (sourceTop + sourceHeight - world.size.y * Tile.size) * zoom;
      sourceHeight = world.size.y * Tile.size - sourceTop;
    }
    Zei.renderer["levelfinal"].context.drawImageScaledFromSource(Zei.renderer["levelbuffer"].view, sourceLeft, sourceTop, sourceWidth, sourceHeight, targetLeft, targetTop, targetWidth, targetHeight);
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
      tempCanvas[t].width = Tile.size;
      tempCanvas[t].height = Tile.size;
      tempContext.add(tempCanvas[t].getContext('2d'));
    }

    for (int i = 0; i < tiles.length; i++) {

      int iS = tiles[i].x;
      int jS = tiles[i].y;

      if (world.contains(new Zei.Vector2(iS, jS))) {
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
            tempContext[t].clearRect(0, 0, Tile.size, Tile.size);
            
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
            
            tempContext[t].drawImageScaledFromSource(Zei.images["mask"], index * (Tile.size + 6) + 3, (Tile.size + 6) + 3, Tile.size, Tile.size, 0, 0, Tile.size, Tile.size);
  
            // redraw pattern
            var pattern = tempContext[t].createPatternFromImage(Zei.images["level$t"], 'repeat');
  
            tempContext[t].globalCompositeOperation = 'source-in';
            tempContext[t].fillStyle = pattern;
  
            tempContext[t].save();
            Zei.Vector2 translation = new Zei.Vector2((iS * Tile.size).floor(), (jS * Tile.size).floor());
            tempContext[t].translate(-translation.x, -translation.y);
  
            tempContext[t].fillRect(translation.x, translation.y, Tile.size, Tile.size);
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
            
            tempContext[t].drawImageScaledFromSource(Zei.images["borders"], index * (Tile.size + 6) + 2, 2, Tile.size + 2, Tile.size + 2, 0, 0, (Tile.size + 2), (Tile.size + 2));         
          //}
          
          // set above index
          indexAbove = index;
        }
  
        Zei.renderer["levelbuffer"].context.clearRect(iS * Tile.size, jS * Tile.size, Tile.size, Tile.size);
        for (int t = 0; t < 10; t++) {
          Zei.renderer["levelbuffer"].context.drawImageScaledFromSource(tempCanvas[t], 0, 0, Tile.size, Tile.size, iS * Tile.size, jS * Tile.size, Tile.size, Tile.size);
        }
      }
    }
    copyTerrain();
  }

  /**
   * Checks if a [building] can be placed on a given [position]. // tileposition
   */
  bool canBePlaced(Zei.Vector2 position, Building building) {

    if (game.world.contains(position)) {
      int height = game.world.tiles[position.x][position.y].height;
      
      Rectangle currentRect = new Rectangle(position.x * Tile.size + 8 - building.size * Tile.size / 2,
                                            position.y * Tile.size + 8 - building.size * Tile.size / 2,
                                            building.size * Tile.size - 1,
                                            building.size * Tile.size - 1);  
          
      // TODO: check for ghost collision
      if (Building.intersect(currentRect, building) ||
          Emitter.intersect(currentRect) ||
          Sporetower.intersect(currentRect)) return false;
           
      // check if all tiles have the same height and are not corners
      for (int i = position.x - (building.size ~/ 2); i <= position.x + (building.size ~/ 2); i++) {
        for (int j = position.y - (building.size ~/ 2); j <= position.y + (building.size ~/ 2); j++) {
          if (world.contains(new Zei.Vector2(i, j))) {
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
    Zei.GameObject.updateAll();
    
    if (!paused) { 
      Building.updateQueue();
    }
  }

  /**
   * Updates the range boxes around the [position] of a building.
   */
  void updateRangeBoxes(Zei.Vector2 position, Building building) {
       
    if (canBePlaced(position, building) && (building.type == "collector" || building.type == "cannon" || building.type == "mortar" || building.type == "shield" || building.type == "beam" || building.type == "terp" || building.type == "analyzer")) {

      Zei.Vector2 positionCenter = new Zei.Vector2(position.x * Tile.size + (Tile.size / 2), position.y * Tile.size + (Tile.size / 2));
      int positionHeight = game.world.tiles[position.x][position.y].height;
      
      for (int i = -building.radius; i <= building.radius; i++) {
        for (int j = -building.radius; j <= building.radius; j++) {

          Zei.Vector2 positionCurrent = position + new Zei.Vector2(i, j);

          if (world.contains(positionCurrent)) {
            Zei.Vector2 positionCurrentCenter = new Zei.Vector2(positionCurrent.x * Tile.size + (Tile.size / 2), positionCurrent.y * Tile.size + (Tile.size / 2));
            
            int positionCurrentHeight = game.world.tiles[positionCurrent.x][positionCurrent.y].height;

            if (positionCenter.distanceTo(positionCurrentCenter) < building.radius * Tile.size) {
              Tile tile = game.world.getTile(positionCurrent * Tile.size);
              tile.rangeBox.visible = true;            

              if ((building.type == "collector" && positionCurrentHeight != positionHeight) ||
                  (building.type == "cannon" && positionCurrentHeight > positionHeight))
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
   * Draws the green collection areas of collectors.
   */
  void drawCollection() {
    Zei.renderer["collection"].clear();
    Zei.renderer["collection"].context.save();
    Zei.renderer["collection"].context.globalAlpha = .5;

    int timesX = (Zei.renderer["main"].view.width / 2 / Tile.size / zoom).ceil();
    int timesY = (Zei.renderer["main"].view.height / 2 / Tile.size / zoom).ceil();

    for (int i = -timesX; i <= timesX; i++) {
      for (int j = -timesY; j <= timesY; j++) {

        Zei.Vector2 position = new Zei.Vector2(i + scroller.scroll.x, j + scroller.scroll.y);

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
            Zei.renderer["collection"].context.drawImageScaledFromSource(Zei.images["mask"], index * (Tile.size + 6) + 3, (Tile.size + 6) + 3, Tile.size, Tile.size, Zei.renderer["main"].view.width / 2 + i * Tile.size * zoom, Zei.renderer["main"].view.height / 2 + j * Tile.size * zoom, Tile.size * zoom, Tile.size * zoom);
          }
        }
      }
    }
    Zei.renderer["collection"].context.restore();
  }

  void drawCreeper() {
    Zei.renderer["creeper"].clear();

    int timesX = (Zei.renderer["creeper"].view.width / 2 / Tile.size / zoom).ceil();
    int timesY = (Zei.renderer["creeper"].view.height / 2 / Tile.size / zoom).ceil();

    for (int i = -timesX; i <= timesX; i++) {
      for (int j = -timesY; j <= timesY; j++) {

        Zei.Vector2 position = new Zei.Vector2(i + scroller.scroll.x, j + scroller.scroll.y);
        
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
              Zei.renderer["creeper"].context.drawImageScaledFromSource(Zei.images["creeper"], index * Tile.size, 0, Tile.size, Tile.size, Zei.renderer["main"].view.width / 2 + i * Tile.size * zoom, Zei.renderer["main"].view.height / 2 + j * Tile.size * zoom, Tile.size * zoom, Tile.size * zoom);
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
                Zei.renderer["creeper"].context.drawImageScaledFromSource(Zei.images["creeper"], index * Tile.size, 0, Tile.size, Tile.size, Zei.renderer["main"].view.width / 2 + i * Tile.size * zoom, Zei.renderer["main"].view.height / 2 + j * Tile.size * zoom, Tile.size * zoom, Tile.size * zoom);
            }
          }
        }
        
      }
    }
  }
  
  void updateVariousInfo() {
    if (hoveredTile != oldHoveredTile) {
      
      // set visibility of reposition rect
      game.repositionRect.visible = false;
      for (var building in Zei.GameObject.gameObjects) {
        if (building is Building) {
          if (building.built && building.selected && building.canMove) {
            mouse.hideCursor();
            
            bool canBePlaced = game.canBePlaced(game.hoveredTile, building);
  
            repositionRect.visible = true;
             
            repositionRect.position = new Zei.Vector2(hoveredTile.x * Tile.size - (building.size * Tile.size / 2) + 8, hoveredTile.y * Tile.size - (building.size * Tile.size / 2) + 8);
            repositionRect.size = new Zei.Vector2(building.size * Tile.size, building.size * Tile.size);
            if (canBePlaced)
              repositionRect.fillColor = new Zei.Color(0, 255, 0, 0.5);
            else
              repositionRect.fillColor = new Zei.Color(255, 0, 0, 0.5);
          }
        }
      }
         
      // update terraform info
      if (world.contains(hoveredTile)) {   
        if (mode == "TERRAFORM") {
          Zei.Vector2 drawPosition = hoveredTile * Tile.size;
          tfLine1
            ..from = new Zei.Vector2(0, drawPosition.y)
            ..to = new Zei.Vector2(world.size.y * Tile.size, drawPosition.y)
            ..visible = true;
          tfLine2
            ..from = new Zei.Vector2(0, drawPosition.y + Tile.size)
            ..to = new Zei.Vector2(world.size.y * Tile.size, drawPosition.y + Tile.size)
            ..visible = true;
          tfLine3
            ..from = new Zei.Vector2(drawPosition.x, 0)
            ..to = new Zei.Vector2(drawPosition.x, world.size.y * Tile.size)
            ..visible = true;
          tfLine4
            ..from = new Zei.Vector2(drawPosition.x + Tile.size, 0)
            ..to = new Zei.Vector2(drawPosition.x + Tile.size, world.size.y * Tile.size)
            ..visible = true;
          tfNumber
            ..position = hoveredTile * Tile.size
            ..visible = true;       
        } else {
          tfLine1.visible = false;
          tfLine2.visible = false;
          tfLine3.visible = false;
          tfLine4.visible = false;
          tfNumber.visible = false;
        }      
        targetCursor.position = (hoveredTile * Tile.size) + new Zei.Vector2(8, 8);
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
      if (mouse.dragStart != null && UISymbol.activeSymbol != null) {
        
        Zei.Vector2 start = mouse.dragStart;
        Zei.Vector2 end = hoveredTile;
        Zei.Vector2 delta = end - start;
        num distance = start.distanceTo(end);
        
        num buildingDistance = 3;
        if (UISymbol.activeSymbol.building.type == "collector")
          buildingDistance = 9;
        else if (UISymbol.activeSymbol.building.type == "relay")
          buildingDistance = 18;
        
        num times = distance ~/ buildingDistance + 1;
        
        ghosts.add(start);
        
        for (int i = 1; i < times; i++) {
          Zei.Vector2 ghostPosition = new Zei.Vector2(
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
        if (mouse.overCanvas) {
          if (world.contains(game.hoveredTile)) {
            ghosts.add(game.hoveredTile);
          }
        }
      }
      
      // remove current ghost display objects
      for (var i = 0; i < ghostDisplayObjects.length; i++) {
        Zei.renderer["main"].removeDisplayObject(ghostDisplayObjects[i]);
      }
      ghostDisplayObjects.clear();
      
      if (UISymbol.activeSymbol != null) {
        // create new ghost sprites
        for (var i = 0; i < ghosts.length; i++) {
          
          Zei.Vector2 ghostCenter = ghosts[i] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2);
          
          ghostDisplayObjects.add(Zei.Sprite.create("main", "terraform", Zei.images[UISymbol.activeSymbol.building.type], ghosts[i] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2), UISymbol.activeSymbol.building.size * Tile.size, UISymbol.activeSymbol.building.size * Tile.size, alpha: 0.5, anchor: new Zei.Vector2(0.5, 0.5)));
          if (UISymbol.activeSymbol.building.type == "cannon")
            ghostDisplayObjects.add(Zei.Sprite.create("main", "terraform", Zei.images["cannongun"], ghosts[i] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2), UISymbol.activeSymbol.building.size * Tile.size, UISymbol.activeSymbol.building.size * Tile.size, alpha: 0.5, anchor: new Zei.Vector2(0.5, 0.5)));
        
          // create colored red or green box
          bool ghostCanBePlaced = canBePlaced(ghosts[i], UISymbol.activeSymbol.building);
  
          Zei.Color color;
          if (ghostCanBePlaced) {
            color = new Zei.Color(0, 255, 0, 0.5);
          } else {
            color = new Zei.Color(255, 0, 0, 0.5);
          }
          ghostDisplayObjects.add(Zei.Rect.create("main", "terraform", ghosts[i] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2), new Zei.Vector2(UISymbol.activeSymbol.building.size * Tile.size, UISymbol.activeSymbol.building.size * Tile.size), 4, null, color, anchor: new Zei.Vector2(0.5, 0.5)));
          
          // create lines to other buildings
          for (var building in Zei.GameObject.gameObjects) {
            if (building is Building) {
              if (UISymbol.activeSymbol.building.type == "collector" || UISymbol.activeSymbol.building.type == "relay" ||
                building.type == "collector" || building.type == "relay" || building.type == "base") {
  
                int allowedDistance = 10 * Tile.size;
                if (building.type == "relay" && UISymbol.activeSymbol.building.type == "relay") {
                  allowedDistance = 20 * Tile.size;
                }
  
                if (ghostCenter.distanceTo(building.position) <= allowedDistance) {
                  ghostDisplayObjects.add(Zei.Line.create("main", "connection", ghostCenter, building.position, 3, new Zei.Color(0, 0, 0, 0.5)));
                  ghostDisplayObjects.add(Zei.Line.create("main", "connection", ghostCenter, building.position, 2, new Zei.Color(0, 255, 0, 0.5)));
                }
              }
            }
          }
          
          // create lines to other ghosts
          for (int j = 0; j < ghosts.length; j++) {
            if (j != i) {
              if (UISymbol.activeSymbol.building.type == "collector" || UISymbol.activeSymbol.building.type == "relay") {
  
                int allowedDistance = 10 * Tile.size;
                if (UISymbol.activeSymbol.building.type == "relay") {
                  allowedDistance = 20 * Tile.size;
                }
  
                Zei.Vector2 ghostJCenter = ghosts[j] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2);
                if (ghostCenter.distanceTo(ghostJCenter) <= allowedDistance) {
                  ghostDisplayObjects.add(Zei.Line.create("main", "connection", ghostCenter, ghostJCenter, 2, new Zei.Color(0, 0, 0, 0.5)));
                  ghostDisplayObjects.add(Zei.Line.create("main", "connection", ghostCenter, ghostJCenter, 1, new Zei.Color(255, 255, 255, 0.5)));
                }
              }
            }
          }
          
        }
      }
    }
  }
}