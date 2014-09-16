part of zengine;

abstract class DisplayObject {
  String layer;
  bool visible = true;
}

class Rect extends DisplayObject {
  Vector position, size;
  int lineWidth;
  String fillColor, strokeColor;
  num rotation = 0;
  Vector anchor = new Vector.empty();
  Vector scale = new Vector(1.0, 1.0);
  String rendererName;

  Rect(rendererName, layer, this.position, this.size, this.lineWidth, this.fillColor, this.strokeColor, {bool visible: true, Vector anchor}) {
    super.layer = layer;
    super.visible = visible;
    if (anchor != null) this.anchor = anchor;
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
  int frame;
  ImageElement image;
  Vector anchor = new Vector.empty(), position, size;
  Vector scale = new Vector(1.0, 1.0);
  num rotation, alpha;
  bool animated; // animated sprites should be in 8 columns in the spritesheet
  String rendererName;
  Timer animationTimer;
  int animationFPS;

  Sprite(rendererName, layer, this.image, this.position, width, height, {int frame: 0, bool animated: false, animationFPS: 30, bool visible: true, Vector anchor, num alpha: 1.0, num rotation: 0, Vector scale}) {
    super.layer = layer;
    super.visible = visible;
    this.alpha = alpha;
    this.rotation = rotation;
    this.animated = animated;
    this.frame = frame;
    this.animationFPS = animationFPS;
    if (anchor != null) this.anchor = anchor;
    if (scale != null) this.scale = scale;
    size = new Vector(width, height);
    engine.renderer[rendererName].addDisplayObject(this);
    this.rendererName = rendererName;
    if (animated)
      startAnimation();
  }
  
  void stopAnimation() {
    animationTimer.cancel();
  }
  
  void startAnimation() {
    animationTimer = new Timer.periodic(new Duration(milliseconds: (1000 / animationFPS).floor()), (Timer timer) => animate());
  }
  
  void animate() {
    frame++;    
  }
  
  void rotate(int angle) {
    rotation += angle;
    if (rotation > 359)
      rotation -= 359;
  }
  
  bool isHovered() {
    Vector relativePosition = engine.renderer[rendererName].relativePosition(this.position);
    return (engine.renderer[rendererName].mouse.position.x >= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * engine.renderer[rendererName].zoom &&
            engine.renderer[rendererName].mouse.position.x <= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * engine.renderer[rendererName].zoom + this.size.x * this.scale.x  * engine.renderer[rendererName].zoom &&
            engine.renderer[rendererName].mouse.position.y >= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * engine.renderer[rendererName].zoom &&
            engine.renderer[rendererName].mouse.position.y <= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * engine.renderer[rendererName].zoom + this.size.y * this.scale.y * engine.renderer[rendererName].zoom);
  }
}