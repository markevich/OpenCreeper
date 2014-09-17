library zei;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'renderer.dart';
part 'displayobject.dart';
part 'mouse.dart';
part 'vector.dart';
part 'route.dart';
part 'gameobject.dart';
part 'color.dart';

class Zei {
  static num animationRequest;
  static int TPS = 60; // ticks per second
  static Timer resizeTimer;
  static Map<String, Renderer> renderer = new Map();
  static Map<String, List> sounds = new Map();
  static Map<String, ImageElement> images = new Map();
  static List<GameObject> gameObjects = new List<GameObject>();
  static bool debug = false;

  static void init({int TPS: 60, bool debug: false}) {
    TPS = TPS;
    debug = debug;
  }
  
  static void addGameObject(GameObject gameObject) {
    gameObjects.add(gameObject);
    if (debug) {
      print("Added ${gameObject.runtimeType}");
      print("# GameObjects: ${gameObjects.length}");
    }
  }
  
  static void removeGameObject(GameObject gameObject) {
    gameObjects.remove(gameObject);
    if (debug) {
      print("Removed ${gameObject.runtimeType}");
      print("# GameObjects: ${gameObjects.length}");
    }
  }
  
  static void update() {
    for (int i = gameObjects.length - 1; i >= 0; i--) {
      gameObjects[i].update();
    }
  }
  
  static void clear() {
    gameObjects.clear();
    renderer.forEach((k, v) => v.removeAllDisplayObjects());
  }
  
  /**
   * Creates a renderer with a [name], [width], [height] and optionally adds it to a [container] in the DOM
   */
  static Renderer createRenderer(String name, int width, int height, [String container]) {
    renderer[name] = new Renderer(new CanvasElement(), width, height);
    if (container != null)
      querySelector(container).children.add(renderer[name].view);
    renderer[name].updateRect(width, height);
    return renderer[name];
  }
  
  /**
   * Loads all images.
   *
   * Uses a future to indicate when all images have been loaded.
   */
  static Future loadImages(List filenames) {
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

  static void loadSounds(List filenames) {   
    filenames.forEach((filename) {
      var name = filename.split(".")[0];
      sounds[name] = new List();
      for (int j = 0; j < 5; j++) {
        sounds[name].add(new AudioElement("sounds/" + filename));
      }
    });
  }

  static void playSound(String name, [Vector position, Vector center, double zoom]) { // position is in real coordinates
    num volume = 1;
    
    // given a position adjust sound volume based on it and the current zoom
    if (position != null && center != null && zoom != null) {
      num distance = position.distanceTo(center * 16);
      volume = (zoom / pow(distance / 200, 2)).clamp(0, 1);
    }

    for (int i = 0; i < 5; i++) {
      if (sounds[name][i].ended == true || sounds[name][i].currentTime == 0) {
        sounds[name][i].volume = volume;
        sounds[name][i].play();
        return;
      }
    }
  }
  
  /**
   * Calculates the velocity between [position] and [targetPosition] with a given [multiplier]
   */
  static Vector calculateVelocity(Vector position, Vector targetPosition, num multiplier) {
    Vector delta = targetPosition - position;
    num distance = position.distanceTo(targetPosition);

    Vector velocity = new Vector(
        (delta.x / distance) * multiplier,
        (delta.y / distance) * multiplier);

    if (velocity.x.abs() > delta.x.abs())
      velocity.x = delta.x;
    if (velocity.y.abs() > delta.y.abs())
      velocity.y = delta.y;
    
    return velocity;
  }
  
  static void stopAnimations() {
    renderer.forEach((k, v) {
      for (int i = 0; i < v.layers.length; i++) {
        for (int j = 0; j < v.layers[i].displayObjects.length; j++) {
          if (v.layers[i].displayObjects[j] is Sprite && v.layers[i].displayObjects[j].animated) {
            v.layers[i].displayObjects[j].stopAnimation();
          }
        }
      }
    });
  }
  
  static void startAnimations() {
    renderer.forEach((k, v) {
      for (int i = 0; i < v.layers.length; i++) {
        for (int j = 0; j < v.layers[i].displayObjects.length; j++) {
          if (v.layers[i].displayObjects[j] is Sprite && v.layers[i].displayObjects[j].animated) {
            v.layers[i].displayObjects[j].startAnimation();
          }
        }
      }
    });
  }
  
  static int randomInt(num from, num to, [num seed]) {
    var random = new Random(seed);
    return (random.nextInt(to - from + 1) + from);
  }
  
  static num rad2deg(num angle) {
    return angle * 57.29577951308232;
  }
  
  static num deg2rad(num angle) {
    return angle * .017453292519943295;
  }
}