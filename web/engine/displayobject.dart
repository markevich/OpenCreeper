part of zengine;

abstract class DisplayObject {
  Layer layer;
  bool visible = true;
}

class Rect extends DisplayObject {
  Vector position, size;
  int lineWidth;
  String fillColor, strokeColor;
  num rotation = 0;
  Vector anchor;
  Vector scale;
  String rendererName;

  Rect(rendererName, layer, this.position, this.size, this.lineWidth, this.fillColor, this.strokeColor, {bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    anchor = new Vector.empty();
    scale = new Vector(1.0, 1.0);
    engine.renderer[rendererName].addDisplayObject(this);
    this.rendererName = rendererName;
  }
  
  bool isHovered() {
    Vector relativePosition = engine.renderer[rendererName].relativePosition(this.position);
    return (engine.renderer[rendererName].mouse.position.x >= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * engine.renderer[rendererName].zoom &&
            engine.renderer[rendererName].mouse.position.x <= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * engine.renderer[rendererName].zoom + this.size.x * this.scale.x  * engine.renderer[rendererName].zoom &&
            engine.renderer[rendererName].mouse.position.y >= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * engine.renderer[rendererName].zoom &&
            engine.renderer[rendererName].mouse.position.y <= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * engine.renderer[rendererName].zoom + this.size.y * this.scale.y * engine.renderer[rendererName].zoom);
  }
}

class Circle extends DisplayObject {
  Vector position;
  num radius;
  int lineWidth;
  String fillColor, strokeColor;
  num rotation = 0;
  int degrees = 360;
  num scale;
  String rendererName;

  Circle(rendererName, layer, this.position, this.radius, this.lineWidth, this.fillColor, this.strokeColor, {bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    scale = 1.0;
    engine.renderer[rendererName].addDisplayObject(this);
    this.rendererName = rendererName;
  }
  
  bool isHovered() {
    Vector relativePosition = engine.renderer[rendererName].relativePosition(this.position);
    return (engine.renderer[rendererName].mouse.position.distanceTo(relativePosition) <= this.radius * engine.renderer[rendererName].zoom);
  }
}

class Line extends DisplayObject {
  String color;
  Vector from, to;
  int lineWidth;

  Line(rendererName, layer, this.from, this.to, this.lineWidth, this.color, {bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    engine.renderer[rendererName].addDisplayObject(this);
  }
  
  String toString() {
    return "$from - $to";
  }
}

class Sprite extends DisplayObject {
  int frame = 0;
  ImageElement image;
  Vector anchor, scale, position, size;
  num rotation = 0, alpha = 1.0;
  bool animated = false;
  String rendererName;

  Sprite(rendererName, layer, this.image, this.position, width, height, {bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    anchor = new Vector.empty();
    scale = new Vector(1.0, 1.0);
    size = new Vector(width, height);
    engine.renderer[rendererName].addDisplayObject(this);
    this.rendererName = rendererName;
  }
  
  bool isHovered() {
    Vector relativePosition = engine.renderer[rendererName].relativePosition(this.position);
    return (engine.renderer[rendererName].mouse.position.x >= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * engine.renderer[rendererName].zoom &&
            engine.renderer[rendererName].mouse.position.x <= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * engine.renderer[rendererName].zoom + this.size.x * this.scale.x  * engine.renderer[rendererName].zoom &&
            engine.renderer[rendererName].mouse.position.y >= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * engine.renderer[rendererName].zoom &&
            engine.renderer[rendererName].mouse.position.y <= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * engine.renderer[rendererName].zoom + this.size.y * this.scale.y * engine.renderer[rendererName].zoom);
  }
}

// Layer Enum: http://stackoverflow.com/questions/15854549/how-can-i-build-an-enum-with-dart

/**
 * These layers define the order in which displayobjects are drawn.
 * -- Change this for every project --
 */
class Layer {
  final int _value;
  const Layer._internal(this._value);

  int operator -(Layer other) => _value - other._value;

  static const ENERGYBAR = const Layer._internal(10);
  
  static const BUILDINGGUNFLYING = const Layer._internal(9);

  static const SPORE = const Layer._internal(8);
  static const SHELL = const Layer._internal(8);
  static const SHIP = const Layer._internal(8);
  static const BUILDINGFLYING = const Layer._internal(8);
  
  static const SMOKE = const Layer._internal(7);
  static const EXPLOSION = const Layer._internal(7);
  
  static const PACKET = const Layer._internal(6);
  
  static const BUILDINGGUN = const Layer._internal(5);

  static const PROJECTILE = const Layer._internal(4);

  static const EMITTER = const Layer._internal(3);
  static const SPORETOWER = const Layer._internal(3);
  static const BUILDING = const Layer._internal(3);
  
  static const CONNECTION = const Layer._internal(2);
  
  static const CONNECTIONBORDER = const Layer._internal(1);
  
  static const TARGETSYMBOL = const Layer._internal(0);
  static const SELECTEDCIRCLE = const Layer._internal(0);
  static const TERRAFORM = const Layer._internal(0);
}