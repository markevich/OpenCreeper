part of zei;

abstract class DisplayObject {
  String layer;
  bool visible = true;
}

class Text extends DisplayObject {
  Vector2 position;
  String sizeUnit, text, font, align, verticalAlign;
  num size, rotation = 0;
  Color fillColor, strokeColor;
  String rendererName;
  
  Text(rendererName, layer, this.position, this.size, this.sizeUnit, this.font, this.fillColor, this.strokeColor, this.text, {String align: "left", String verticalAlign: "alphabetic", bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    this.align = align;
    this.verticalAlign = verticalAlign;
    renderer[rendererName].addDisplayObject(this);
    this.rendererName = rendererName;
  }
  
  void rotate(num angle) {
    rotation += angle;
    if (rotation >= 360)
      rotation -= 360;
    else if (rotation < 0)
      rotation += 360; 
  }
  
  bool isHovered() {
    return false;
  }
}

class Rect extends DisplayObject {
  Vector2 position, size;
  int lineWidth;
  Color fillColor, strokeColor;
  num rotation = 0;
  Vector2 anchor = new Vector2.empty();
  Vector2 scale = new Vector2(1.0, 1.0);
  String rendererName;

  Rect(rendererName, layer, this.position, this.size, this.lineWidth, this.fillColor, this.strokeColor, {bool visible: true, Vector2 anchor}) {
    super.layer = layer;
    super.visible = visible;
    if (anchor != null) this.anchor = anchor;
    renderer[rendererName].addDisplayObject(this);
    this.rendererName = rendererName;
  }
  
  void rotate(num angle) {
    rotation += angle;
    if (rotation >= 360)
      rotation -= 360;
    else if (rotation < 0)
      rotation += 360; 
  }
  
  bool isHovered() {
    Vector2 relativePosition = renderer[rendererName].relativePosition(this.position);
    return (renderer[rendererName].mouse.position.x >= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * renderer[rendererName].zoom &&
            renderer[rendererName].mouse.position.x <= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * renderer[rendererName].zoom + this.size.x * this.scale.x * renderer[rendererName].zoom &&
            renderer[rendererName].mouse.position.y >= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * renderer[rendererName].zoom &&
            renderer[rendererName].mouse.position.y <= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * renderer[rendererName].zoom + this.size.y * this.scale.y * renderer[rendererName].zoom);
  }
}

class Circle extends DisplayObject {
  Vector2 position;
  num radius;
  int lineWidth;
  Color fillColor, strokeColor;
  num rotation = 0;
  int degrees = 360;
  num scale;
  String rendererName;

  Circle(rendererName, layer, this.position, this.radius, this.lineWidth, this.fillColor, this.strokeColor, {bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    scale = 1.0;
    renderer[rendererName].addDisplayObject(this);
    this.rendererName = rendererName;
  }
  
  void rotate(num angle) {
    rotation += angle;
    if (rotation >= 360)
      rotation -= 360;
    else if (rotation < 0)
      rotation += 360; 
  }
  
  bool isHovered() {
    Vector2 relativePosition = renderer[rendererName].relativePosition(this.position);
    return (renderer[rendererName].mouse.position.distanceTo(relativePosition) <= this.radius * renderer[rendererName].zoom);
  }
}

class Line extends DisplayObject {
  Color color;
  Vector2 from, to;
  int lineWidth;

  Line(rendererName, layer, this.from, this.to, this.lineWidth, this.color, {bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    renderer[rendererName].addDisplayObject(this);
  }
  
  String toString() {
    return "$from - $to";
  }
}

class Sprite extends DisplayObject {
  int frame;
  ImageElement image;
  Vector2 anchor = new Vector2.empty(), position, size;
  Vector2 scale = new Vector2(1.0, 1.0);
  num rotation, alpha;
  bool animated; // animated sprites should be in 8 columns in the spritesheet
  String rendererName;
  Timer animationTimer;
  int animationFPS;

  Sprite(rendererName, layer, this.image, this.position, width, height, {int frame: 0, bool animated: false, animationFPS: 30, bool visible: true, Vector2 anchor, num alpha: 1.0, num rotation: 0, Vector2 scale}) {
    super.layer = layer;
    super.visible = visible;
    this.alpha = alpha;
    this.rotation = rotation;
    this.animated = animated;
    this.frame = frame;
    this.animationFPS = animationFPS;
    if (anchor != null) this.anchor = anchor;
    if (scale != null) this.scale = scale;
    size = new Vector2(width, height);
    renderer[rendererName].addDisplayObject(this);
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
  
  void rotate(num angle) {
    rotation += angle;
    if (rotation >= 360)
      rotation -= 360;
    else if (rotation < 0)
      rotation += 360; 
  }
  
  bool isHovered() {
    Vector2 relativePosition = renderer[rendererName].relativePosition(this.position);
    return (renderer[rendererName].mouse.position.x >= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * renderer[rendererName].zoom &&
            renderer[rendererName].mouse.position.x <= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * renderer[rendererName].zoom + this.size.x * this.scale.x * renderer[rendererName].zoom &&
            renderer[rendererName].mouse.position.y >= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * renderer[rendererName].zoom &&
            renderer[rendererName].mouse.position.y <= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * renderer[rendererName].zoom + this.size.y * this.scale.y * renderer[rendererName].zoom);
  }
}