part of creeper;

class Game {
  int seed, speed = 1;
  double zoom = 1.0;
  String mode;
  bool paused = false, won = false;
  World world;
  UserInterface ui;
  List zoomableRenderers;
  Zei.Mouse mouse;
  Scroller scroller;
  var debug = true;
  bool friendly;
  
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
    main.setLayers(["terraform", "selectedcircle", "targetsymbol", "connectionborder", "connection", "building", "buildinginfo", "sporetower", "emitter", "projectile", "buildinggun", "packet",
                    "shield", "explosion", "smoke", "buildingflying", "buildinginfoflying", "ship", "shell", "spore", "buildinggunflying", "energybar"]);
    
    mouse = main.mouse;
    mouse.setCursor("url('images/Normal.cur') 2 2, pointer");
    
    scroller = new Scroller();
             
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
    window
      ..onResize.listen((event) => onResize(event));
  }

  void reset() {
    Zei.clear();
    
    mode = "DEFAULT";
    speed = 1;
    won = false;
    
    world = new World(seed);
    world.create();
    Zei.GameObject.add(world);
    Zei.GameObject.add(game.scroller);
          
    // create UI
    ui = new UserInterface();
       
    Ship.init();
  }

  void pause() {
    querySelector('#paused').style.display = 'block';
    paused = true;
    ui.stopwatch.stop();
    Zei.Renderer.stopAnimations();
  }

  void resume() {
    querySelector('#paused').style.display = 'none';
    querySelector('#win').style.display = 'none';
    paused = false;
    ui.stopwatch.start();
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
    if (speed < 2) {
      speed *= 2;
      ui.updateElement("speed");
    }
  }

  void slower() {
    if (speed > 1) {
      speed = speed ~/ 2;
      ui.updateElement("speed");
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

}