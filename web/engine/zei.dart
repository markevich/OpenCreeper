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
part 'audio.dart';

num animationRequest;
int TPS = 60; // ticks per second
Timer resizeTimer;
Map<String, Renderer> renderer = new Map();
Map<String, ImageElement> images = new Map();
List<GameObject> gameObjects = new List<GameObject>();
bool debug = false;

void init({int TPS: 60, bool debug: false}) {
  TPS = TPS;
  debug = debug;
}

void addGameObject(GameObject gameObject) {
  gameObjects.add(gameObject);
  if (debug) {
    print("Added ${gameObject.runtimeType}");
    print("# GameObjects: ${gameObjects.length}");
  }
}

void removeGameObject(GameObject gameObject) {
  gameObjects.remove(gameObject);
  if (debug) {
    print("Removed ${gameObject.runtimeType}");
    print("# GameObjects: ${gameObjects.length}");
  }
}

void update() {
  for (int i = gameObjects.length - 1; i >= 0; i--) {
    gameObjects[i].update();
  }
}

void clear() {
  gameObjects.clear();
  renderer.forEach((k, v) => v.removeAllDisplayObjects());
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

void stopAnimations() {
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

void startAnimations() {
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

Object randomElementOfList(List list) {
  return list[randomInt(0, list.length - 1)];
}

num clamp(num value, num min, num max) {
  return (value < min ? min : (value > max) ? max : value);
}

int randomInt(int from, int to, [int seed]) {
  var random = new Random(seed);
  return (random.nextInt(to - from + 1) + from);
}

int randomDouble(double from, double to, [int seed]) {
    var random = new Random(seed);
    return (random.nextDouble() * (to - from) + from);
  }

num radToDeg(num angle) {
  return angle * 57.29577951308232;
}

num degToRad(num angle) {
  return angle * .017453292519943295;
}

// converts an angle (in degrees) to a Vector
Vector2 convertToVector(num angle) {
  return new Vector2(cos(degToRad(angle)), sin(degToRad(angle)));
}