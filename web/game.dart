part of creeper;

class Game {
  int seed, speed;
  String mode;
  bool paused, won, friendly;
  World world;
  UserInterface ui;
  Zei.Mouse mouse;
  Timer resizeTimer;
  bool debug = true;

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
    List images = ["selectionCircle", "analyzer", "numbers", "level0", "level1", "level2", "level3", "level4", "level5", "level6", "level7", "level8", "level9", "borders", "mask", "cannon",
                       "cannongun", "base", "collector", "reactor", "storage", "terp", "packet_collection", "packet_energy", "packet_health", "relay", "emitter", "creeper",
                       "mortar", "shell", "beam", "spore", "bomber", "bombership", "smoke", "explosion", "targetcursor", "sporetower", "forcefield", "shield", "projectile", "disabledSprite"];
    Zei.loadImages(images).then((results) => init());
    return this;
  }

  void init() {
    // create renderer
    int width = window.innerWidth;
    int height = window.innerHeight;

    var main = Zei.Renderer.create("main", width, height, container: "body", zoomable: true);
    main.view.style.zIndex = "1";
    main.setLayers(["terraform", "targetsymbol", "connectionborder", "connection", "building", "selectedcircle", "buildinginfo", "sporetower", "emitter", "projectile", "buildinggun", "packet",
                    "shield", "explosion", "smoke", "buildingflying", "buildinginfoflying", "ship", "shell", "spore", "buildinggunflying", "energybar"]);

    Zei.enableMouse("url('images/Normal.cur') 2 2, pointer");
    Zei.enableScroller(Zei.renderer["main"], Tile.size);
    Zei.enableZoomer(1.0, 0.4, 2.0);

    var music = new AudioElement("sounds/music.ogg");
    music.loop = true;
    music.volume = 0.25;
    music.onCanPlay.listen((event) => music.play()); // TODO: find out why this is not working

    reset();

    window.onResize.listen((event) => onResize(event));

    Zei.run();
  }

  void onResize(evt) {
    // delay the resizing to avoid it being called multiple times
    if (resizeTimer != null)
      resizeTimer.cancel();

    resizeTimer = new Timer(new Duration(milliseconds: 250), () {
      var width = window.innerWidth;
      var height = window.innerHeight;

      Zei.renderer["main"].updateRect(width, height);
      Zei.renderer["levelfinal"].updateRect(width, height);
      Zei.renderer["collection"].updateRect(width, height);
      Zei.renderer["creeper"].updateRect(width, height);
      Zei.renderer["gui"].updateRect(Zei.renderer["gui"].view.width, Zei.renderer["gui"].view.height);

      world.copyTiles();
      world.drawCollection();
      world.drawCreeper();
    });
  }

  void reset() {
    Zei.clear();

    mode = "DEFAULT";
    speed = 1;
    paused = false;
    won = false;

    world = new World(seed);
    world.create();
    world.drawTiles();
    world.copyTiles();

    ui = new UserInterface();

    Ship.init();
  }

  void pause() {
    print("paused");
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
    Zei.run();
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

}