part of zei;

class Renderer {
  CanvasElement view;
  CanvasRenderingContext2D context;
  int top, left, bottom, right;
  double zoom = 1.0;
  Vector position = new Vector.empty();
  List<Layer> layers = new List();
  Mouse mouse;

  Renderer(this.view, width, height) {
    updateRect(width, height);
    view.style.position = "absolute";
    context = view.getContext('2d');
  }

  void clear([Color color]) {
    if (color != null) {
      context.fillStyle = color.rgba;
      context.fillRect(0, 0, view.width, view.height);
    } else {
      context.clearRect(0, 0, view.width, view.height);
    }
  }
  
  void enableMouse() {
    this.mouse = new Mouse(this);
  }
  
  // FIXME: doesn't seem to work atm
  void disableImageSmoothing() {
    context.imageSmoothingEnabled = false;
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
  
  void updatePosition(Vector position) {
    this.position = position;
  }
  
  /**
   * Sets the layers, first layers in the list are drawn first later
   */
  void setLayers(List layersList) {
    for (String layerName in layersList) {
      layers.add(new Layer(layerName));
    }
  }

  void addDisplayObject(DisplayObject displayObject) {
    for (Layer layer in layers) {
      if (layer.name == displayObject.layer)
        layer.displayObjects.add(displayObject);      
    }
  }
  
  void removeDisplayObject(DisplayObject displayObject) {
    for (Layer layer in layers) {
      if (layer.name == displayObject.layer)
        layer.displayObjects.removeAt(layer.displayObjects.indexOf(displayObject));
    }
  }
  
  void removeAllDisplayObjects() {
    for (int i = 0; i < layers.length; i++) {
      layers[i].displayObjects.clear();
    }
  }
  
  void switchLayer(DisplayObject displayObject, String layer) {
    removeDisplayObject(displayObject);
    displayObject.layer = layer;
    addDisplayObject(displayObject);
  }
  
  /**
   * Checks if a [displayObject] is within the renderer view. Returns true or false.
   */
  bool isVisible(DisplayObject displayObject) {
    Rectangle renderer = new Rectangle(this.position.x - (view.width / zoom / 2),
                                       this.position.y - (view.height / zoom / 2),
                                       view.width / zoom,
                                       view.height / zoom);
  
    if (displayObject is Sprite) {     
      Rectangle object = new Rectangle(displayObject.position.x - (displayObject.size.x * 16 / 2),
                                       displayObject.position.y - (displayObject.size.y * 16 / 2),
                                       displayObject.size.x * 16,
                                       displayObject.size.y * 16);        
      return renderer.intersects(object);       
    } else if (displayObject is Rect) {    
      Rectangle object = new Rectangle(displayObject.position.x - (displayObject.size.x * 16 / 2),
                                       displayObject.position.y - (displayObject.size.y * 16 / 2),
                                       displayObject.size.x * 16,
                                       displayObject.size.y * 16);       
      return renderer.intersects(object); 
    } else if (displayObject is Circle) {    
      Vector size = new Vector(displayObject.radius * displayObject.scale, displayObject.radius * displayObject.scale);     
      Rectangle object = new Rectangle(displayObject.position.x - (size.x * 16 / 2),
                                       displayObject.position.y - (size.y * 16 / 2),
                                       size.x * 16,
                                       size.y * 16);          
      return renderer.intersects(object);
    } else if (displayObject is Line) {   
      // FIXME: a line might be partially visible although neither start nor end are visible
      return (renderer.containsPoint(new Point(displayObject.from.x, displayObject.from.y)) ||
              renderer.containsPoint(new Point(displayObject.to.x, displayObject.to.y)));
    }
    
    return false;
  }
  
  Vector relativePosition(Vector vector) {
   return new Vector(
       view.width / 2 + (vector.x - position.x) * zoom,
       view.height / 2 + (vector.y - position.y) * zoom);
  }
  
  void draw() {
    for (var layer in layers) {
      for (var displayObject in layer.displayObjects) {
        if (displayObject.visible) {

          if (isVisible(displayObject)) {

            // render sprite
            if (displayObject is Sprite) {
              Vector relativePos = relativePosition(displayObject.position);

              if (displayObject.alpha != 1.0)
                context.globalAlpha = displayObject.alpha;

              if (displayObject.rotation != 0) {
                context.save();
                context.translate(relativePos.x, relativePos.y);
                context.rotate(Zei.degToRad(displayObject.rotation));
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
                  relativePos.x - displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                  relativePos.y - displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                  displayObject.size.x * displayObject.scale.x * zoom,
                  displayObject.size.y * displayObject.scale.y * zoom);
                else
                  context.drawImageScaled(displayObject.image,
                  relativePos.x - displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                  relativePos.y - displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                  displayObject.size.x * displayObject.scale.x * zoom,
                  displayObject.size.y * displayObject.scale.y * zoom);
              }

              if (displayObject.alpha != 1.0)
                context.globalAlpha = 1.0;
            }

            // render rectangle
            else if (displayObject is Rect) {
              Vector relativePos = relativePosition(displayObject.position);

              context.lineWidth = displayObject.lineWidth * zoom;
              if (displayObject.rotation != 0) {
                context.save();
                context.translate(relativePos.x, relativePos.y);
                context.rotate(Zei.degToRad(displayObject.rotation));
                if (displayObject.fillColor != null) {
                  context.fillStyle = displayObject.fillColor.rgba;
                  context.fillRect(-displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                                   -displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                                   displayObject.size.x * displayObject.scale.x * zoom,
                                   displayObject.size.y * displayObject.scale.y * zoom);
                }
                if (displayObject.strokeColor != null) {
                  context.strokeStyle = displayObject.strokeColor.rgba;
                  context.strokeRect(-displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                                   -displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                                   displayObject.size.x * displayObject.scale.x * zoom,
                                   displayObject.size.y * displayObject.scale.y * zoom);
                }
                context.restore();
              } else {
                if (displayObject.fillColor != null) {
                  context.fillStyle = displayObject.fillColor.rgba;
                  context.fillRect(relativePos.x - displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                                   relativePos.y - displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                                   displayObject.size.x * displayObject.scale.x * zoom,
                                   displayObject.size.y * displayObject.scale.y * zoom);
                }
                if (displayObject.strokeColor != null) {
                  context.strokeStyle = displayObject.strokeColor.rgba;
                  context.strokeRect(relativePos.x - displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * zoom,
                                   relativePos.y - displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * zoom,
                                   displayObject.size.x * displayObject.scale.x * zoom,
                                   displayObject.size.y * displayObject.scale.y * zoom);
                }
              }
            }

            // render circle
            else if (displayObject is Circle) {
              Vector relativePos = relativePosition(displayObject.position);

              context.lineWidth = displayObject.lineWidth * zoom;
              if (displayObject.rotation != 0) {
                context.save();
                context.translate(relativePos.x, relativePos.y);
                context.rotate(Zei.degToRad(displayObject.rotation));
                if (displayObject.fillColor != null) {
                  context.fillStyle = displayObject.fillColor.rgba;
                  context.beginPath();
                  context.arc(0, 0, displayObject.radius * displayObject.scale * zoom, 0, Zei.degToRad(displayObject.degrees), true);
                  context.closePath();
                  context.fill();
                }
                if (displayObject.strokeColor != null) {
                  context.strokeStyle = displayObject.strokeColor.rgba;
                  context.beginPath();
                  context.arc(0, 0, displayObject.radius * displayObject.scale * zoom, 0, Zei.degToRad(displayObject.degrees), true);
                  context.closePath();
                  context.stroke();
                }
                context.restore();
              } else {
                if (displayObject.fillColor != null) {
                  context.fillStyle = displayObject.fillColor.rgba;
                  context.beginPath();
                  context.arc(relativePos.x, relativePos.y, displayObject.radius * displayObject.scale * zoom, 0, Zei.degToRad(displayObject.degrees), true);
                  context.closePath();
                  context.fill();
                }
                if (displayObject.strokeColor != null) {
                  context.strokeStyle = displayObject.strokeColor.rgba;
                  context.beginPath();
                  context.arc(relativePos.x, relativePos.y, displayObject.radius * displayObject.scale * zoom, 0, Zei.degToRad(displayObject.degrees), true);
                  context.closePath();
                  context.stroke();
                }
              }
            }

            // render line
            else if (displayObject is Line) {
              Vector relativePosFrom = relativePosition(displayObject.from);
              Vector relativePosTo = relativePosition(displayObject.to);

              context.lineCap = 'round';
              context.lineWidth = displayObject.lineWidth * zoom;
              context.strokeStyle = displayObject.color.rgba;

              context.beginPath();
              context.moveTo(relativePosFrom.x, relativePosFrom.y);
              context.lineTo(relativePosTo.x, relativePosTo.y);
              context.stroke();
            }

          }
        }
      }
    }
  }
}

/**
 * Layers define the order in which displayobjects are drawn.
 */
class Layer {
  String name;
  List<DisplayObject> displayObjects = new List();
  
  Layer(this.name);
}