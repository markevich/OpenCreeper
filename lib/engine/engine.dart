part of creeper;

class Engine {
  num animationRequest, TPS; // TPS = ticks per second
  Mouse mouse = new Mouse();
  Map renderer = new Map(), sounds = new Map(), images = new Map();
  Timer resizeTimer;
  var game;

  Engine({int TPS: 60}) {
    this.TPS = TPS;
  }
  
  /**
   * Creates a renderer with a [name], [width], [height] and optionally adds it to a [container] in the DOM
   */
  void createRenderer(String name, int width, int height, [String container]) {
    renderer[name] = new Renderer(new CanvasElement(), width, height);
    if (container != null)
      querySelector(container).children.add(renderer[name].view);
    renderer[name].updateRect(width, height);
  }
  
  /**
   * Loads all images.
   *
   * Uses a future to indicate when all images have been loaded.
   */
  Future loadImages(List filenames) {
    var completer = new Completer();
     
    int loadedImages = 0;

    filenames.forEach((filename) {
      images[filename] = new ImageElement(src: "images/" + filename + ".png");
      images[filename].onLoad.listen((event) {
        if (++loadedImages == filenames.length) {
          completer.complete();
        }
      });
    });
    return completer.future; 
  }

  void loadSounds(List filenames) {   
    filenames.forEach((filename) {
      var name = filename.split(".")[0];
      sounds[name] = new List();
      for (int j = 0; j < 5; j++) {
        sounds[name].add(new AudioElement("sounds/" + filename));
      }
    });
  }

  void playSound(String name, [Vector position]) {
    num volume = 1;
    
    // given a position adjust sound volume based on it and the current zoom
    if (position != null) {
      Vector screenCenter = new Vector(game.scroll.x, game.scroll.y);
      /*Vector screenCenter = new Vector(
          (halfWidth ~/ (game.tileSize * game.zoom)) + game.scroll.x,
          (halfHeight ~/ (game.tileSize * game.zoom)) + game.scroll.y);*/
      num distance = position.distanceTo(screenCenter);
      volume = (game.zoom / pow(distance / 20, 2)).clamp(0, 1);
    }

    for (int i = 0; i < 5; i++) {
      if (sounds[name][i].ended == true || sounds[name][i].currentTime == 0) {
        sounds[name][i].volume = volume;
        sounds[name][i].play();
        return;
      }
    }
  }

  int randomInt(num from, num to, [num seed]) {
    var random = new Random(seed);
    return (random.nextInt(to - from + 1) + from);
  }
  
  num rad2deg(num angle) {
    return angle * 57.29577951308232;
  }
  
  num deg2rad(num angle) {
    return angle * .017453292519943295;
  }
}