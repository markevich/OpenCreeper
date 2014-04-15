part of creeper;

class Engine {
  num animationRequest, TPS; // TPS = ticks per second
  int width, height, halfWidth, halfHeight;
  Mouse mouse = new Mouse();
  Map renderer = new Map(), sounds = new Map(), images = new Map();
  Timer resizeTimer;

  Engine({int TPS: 60}) {
    this.TPS = TPS;
    width = window.innerWidth;
    height = window.innerHeight;
    halfWidth = (width / 2).floor();
    halfHeight = (height / 2).floor();

    // main
    renderer["main"] = new Renderer(new CanvasElement(), width, height);
    querySelector('#canvasContainer').children.add(renderer["main"].view);
    renderer["main"].top = renderer["main"].view.offsetTop;
    renderer["main"].left = renderer["main"].view.offsetLeft;
    renderer["main"].right = renderer["main"].view.offset.right;
    renderer["main"].bottom = renderer["main"].view.offset.bottom;
    renderer["main"].view.style.zIndex = "1";

    // buffer
    renderer["buffer"] = new Renderer(new CanvasElement(), width, height);

    // gui
    renderer["gui"] = new Renderer(new CanvasElement(), 780, 110);
    querySelector('#gui').children.add(renderer["gui"].view);
    renderer["gui"].top = renderer["gui"].view.offsetTop;
    renderer["gui"].left = renderer["gui"].view.offsetLeft;

    for (int i = 0; i < 10; i++) {
      renderer["level$i"] = new Renderer(new CanvasElement(), 128 * 16, 128 * 16);
    }

    renderer["levelbuffer"] = new Renderer(new CanvasElement(), 128 * 16, 128 * 16);
    renderer["levelfinal"] = new Renderer(new CanvasElement(), width, height);
    querySelector('#canvasContainer').children.add(renderer["levelfinal"].view);

    // collection
    renderer["collection"] = new Renderer(new CanvasElement(), width, height);
    querySelector('#canvasContainer').children.add(renderer["collection"].view);

    // creeper
    renderer["creeperbuffer"] = new Renderer(new CanvasElement(), width, height);
    renderer["creeper"] = new Renderer(new CanvasElement(), width, height);
    querySelector('#canvasContainer').children.add(renderer["creeper"].view);
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

    renderer["main"].view
      ..onMouseMove.listen((event) => onMouseMove(event))
      ..onDoubleClick.listen((event) => onDoubleClick(event))
      ..onMouseDown.listen((event) => onMouseDown(event))
      ..onMouseUp.listen((event) => onMouseUp(event))
      ..onMouseWheel.listen((event) => onMouseScroll(event))
      ..onMouseEnter.listen((event) => onEnter(event))
      ..onMouseLeave.listen((event) => onLeave(event));

    renderer["gui"].view
      ..onMouseMove.listen((event) => onMouseMoveGUI(event))
      ..onClick.listen((event) => onClickGUI(event))
      ..onMouseLeave.listen((event) => onLeaveGUI);

    document
      ..onKeyDown.listen((event) => onKeyDown(event))
      ..onKeyUp.listen((event) => onKeyUp(event))
      ..onContextMenu.listen((event) => event.preventDefault());

    window
      ..onResize.listen((event) => onResize(event));
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
    // adjust sound volume based on the current zoom as well as the position

    num volume = 1;
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