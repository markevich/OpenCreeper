part of creeper;

class Game {
  int seed, terraformingHeight = 0, speed = 1;
  double zoom = 1.0;
  String mode;
  bool paused = false, won = false;
  List<Zei.Vector2> ghosts = new List<Zei.Vector2>();
  World world;
  Zei.Vector2 oldHoveredTile = new Zei.Vector2.empty(), hoveredTile = new Zei.Vector2.empty();
  Stopwatch stopwatch = new Stopwatch();
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
     
    var music = new AudioElement("sounds/music.ogg");
    music.loop = true;
    music.volume = 0.25;
    music.onCanPlay.listen((event) => music.play()); // TODO: find out why this is not working
     
    reset();
    world.drawTiles();
    world.copyTiles();
    setupEventHandler();
    Zei.run();
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
    
    mode = "DEFAULT";
    speed = 1;
    won = false;
    
    world = new World(seed);
    world.create();
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
    
    Ship.init();
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
 
  void restart() {
    querySelector('#lose').style.display = 'none';
    Zei.stop();
    reset();
    world.drawTiles();
    world.copyTiles();
    Zei.run();
  }

  void toggleTerraform() {
    if (mode == "TERRAFORM") {
      mode = "DEFAULT";
      querySelector("#terraform").attributes['value'] = "Terraform Off";
      world.tfNumber.visible = false;
    } else {
      mode = "TERRAFORM";
      querySelector("#terraform").attributes['value'] = "Terraform On";
      world.tfNumber.visible = true;
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
      world.copyTiles();
      world.drawCollection();
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
      world.copyTiles();
      world.drawCollection();
      World.creeperDirty = true;
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

  void updateVariousInfo() {
    if (hoveredTile != oldHoveredTile) {
               
      // recalculate ghosts (semi-transparent building when placing a new building)
      ghosts.clear();
           
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
        game.world.hideRangeBoxes();
        // create new ghost sprites
        for (var i = 0; i < ghosts.length; i++) {
          
          game.updateRangeBoxes(ghosts[i], UISymbol.activeSymbol.building);
          
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
          
          if (ghostCanBePlaced) {
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
}