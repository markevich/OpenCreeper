part of creeper;

class Renderer {
  CanvasElement view;
  CanvasRenderingContext2D context;
  int top, left, bottom, right;
  double zoom = 1.0;
  List<List<DisplayObject>> layers = new List<List<DisplayObject>>(20);

  Renderer(this.view, width, height) {
    updateRect(width, height);
    view.style.position = "absolute";
    context = view.getContext('2d');
    
    for (int i = 0; i < layers.length; i++) {
      layers[i] = new List<DisplayObject>();
    }
  }

  void clear() {
    context.clearRect(0, 0, view.width, view.height);
  }

  /**
   * Updates the boundaries of the renderer (eg. after resizing the window)
   */
  void updateRect(int width, int height) {
    view.width = width;
    view.height = height;
    top = view.offset.top;
    left = view.offset.left;
    bottom = view.offset.top + view.offset.height;
    right = view.offset.left + view.offset.width;
  }
  
  void updateZoom(double zoom) {
    this.zoom = zoom;
  }

  void addDisplayObject(DisplayObject displayObject) {
    layers[displayObject.layer._value].add(displayObject);
  }
  
  void removeDisplayObject(DisplayObject displayObject) {
    layers[displayObject.layer._value].removeAt(layers[displayObject.layer._value].indexOf(displayObject));
  }
  
  void removeAllDisplayObjects() {
    for (int i = 0; i < layers.length; i++) {
      layers[i].clear();
    }
  }
  
  void switchLayer(DisplayObject displayObject, Layer layer) {
    removeDisplayObject(displayObject);
    displayObject.layer = layer;
    addDisplayObject(displayObject);
  }
  
  /**
   * Checks if an object with a given [position] and [size]
   * is visible in the renderer view. Returns true or false.
   */
  bool isVisible(Vector position, Vector size) {
    Rectangle object = new Rectangle(position.x - (size.x * game.tileSize * zoom / 2),
                                     position.y - (size.y * game.tileSize * zoom / 2),
                                     size.x * game.tileSize * zoom,
                                     size.y * game.tileSize * zoom);    
    Rectangle myview = new Rectangle(0, 0, view.width, view.height);   
    return myview.intersects(object);
  }

  void draw() {   
    
    for (var layer in layers) {
      for (var displayObject in layer) {
        if (displayObject.visible) {
  
          // render sprite
          if (displayObject is Sprite) {
            Vector realPosition = displayObject.position.real2screen();
  
            if (isVisible(realPosition, displayObject.size)) {
  
              if (displayObject.alpha != 1.0)
                context.globalAlpha = displayObject.alpha;
  
              if (displayObject.rotation != 0) {
                context.save();
                context.translate(realPosition.x, realPosition.y);
                context.rotate(game.engine.deg2rad(displayObject.rotation));
                if (displayObject.animated)
                  context.drawImageScaledFromSource(displayObject.image,
                  (displayObject.frame % 8) * displayObject.size.x,
                  (displayObject.frame ~/ 8) * displayObject.size.y,
                  displayObject.size.x,
                  displayObject.size.y,
                  -displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                  -displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                  displayObject.size.x * displayObject.scale.x * zoom,
                  displayObject.size.y * displayObject.scale.y * zoom);
                else
                  context.drawImageScaled(displayObject.image,
                  -displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                  -displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                  displayObject.size.x * displayObject.scale.x * zoom,
                  displayObject.size.y * displayObject.scale.y * zoom);
                context.restore();
              } else {
                if (displayObject.animated)
                  context.drawImageScaledFromSource(displayObject.image,
                  (displayObject.frame % 8) * displayObject.size.x,
                  (displayObject.frame ~/ 8) * displayObject.size.y,
                  displayObject.size.x,
                  displayObject.size.y,
                  realPosition.x - displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                  realPosition.y - displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                  displayObject.size.x * displayObject.scale.x * zoom,
                  displayObject.size.y * displayObject.scale.y * zoom);
                else
                  context.drawImageScaled(displayObject.image,
                  realPosition.x - displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                  realPosition.y - displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                  displayObject.size.x * displayObject.scale.x * zoom,
                  displayObject.size.y * displayObject.scale.y * zoom);
              }
  
              if (displayObject.alpha != 1.0)
                context.globalAlpha = 1.0;
            }
          }
  
          // render rectangle
          else if (displayObject is Rect) {
            Vector realPosition = displayObject.position.real2screen();
  
            if (isVisible(realPosition, displayObject.size * zoom)) {
              //context.lineWidth = displayObject.lineWidth;
              context.fillStyle = displayObject.color;
              context.fillRect(realPosition.x - displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                               realPosition.y - displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                               displayObject.size.x * displayObject.scale.x * zoom,
                               displayObject.size.y * displayObject.scale.y * zoom);
            }
          }
  
          // render circle
          else if (displayObject is Circle) {
            Vector realPosition = displayObject.position.real2screen();
  
            if (isVisible(realPosition, new Vector(displayObject.radius * displayObject.scale * zoom, displayObject.radius * displayObject.scale * zoom))) {
              context.lineWidth = displayObject.lineWidth * zoom;
              context.strokeStyle = displayObject.color;
              context.beginPath();
              context.arc(realPosition.x, realPosition.y, displayObject.radius * displayObject.scale * zoom, 0, PI * 2, true);
              context.closePath();
              context.stroke();
            }
          }
  
          // render line
          else if (displayObject is Line) {
            Rectangle myview = new Rectangle(0, 0, view.width, view.height);   
            
            Vector realPositionFrom = displayObject.from.real2screen();
            Vector realPositionTo = displayObject.to.real2screen();
            
            // check if line is visible
            if (myview.containsPoint(new Point(realPositionFrom.x, realPositionFrom.y)) ||
                myview.containsPoint(new Point(realPositionTo.x, realPositionTo.y))) {
              context.lineWidth = displayObject.lineWidth * zoom;
              context.strokeStyle = displayObject.color;
    
              context.beginPath();
              context.moveTo(realPositionFrom.x, realPositionFrom.y);
              context.lineTo(realPositionTo.x, realPositionTo.y);
              context.stroke();
            }
          }
        }
      }
    }
    
  }
}