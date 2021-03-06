part of zei;

class Renderer {
  CanvasElement view;
  CanvasRenderingContext2D context;
  int top, left, bottom, right;
  double zoom = 1.0;
  Vector2 position = new Vector2.empty();
  List<Layer> layers = new List();
  bool redraw = false;
  bool autodraw = true;
  bool zoomable = false;
  bool reactOnResize = true; // whether to update boundaries when the browser window is resized
  bool fixedSize = false; // whether to update the size when updating the boundaries
  static List<Renderer> renderers = new List();
  Vector2 relativeMousePosition = new Vector2.empty();
  bool isHovered = false;
  Scroller scroller;

  Renderer(this.view, width, height) {
    updateRect(width, height);
    view.style.position = "absolute";
    context = view.getContext('2d');
    this.autodraw = autodraw;
    renderers.add(this);
  }

  /**
   * Creates a renderer with a [name], [width], [height] and optionally adds it to a [container] in the DOM
   */
  static Renderer create(String name, int width, int height, {container: null, autodraw: true, zoomable: false, reactOnResize: true, fixedSize: false}) {
    renderer[name] = new Renderer(new CanvasElement(), width, height);
    if (container != null)
      querySelector(container).children.add(renderer[name].view);
    renderer[name].autodraw = autodraw;
    renderer[name].zoomable = zoomable;
    renderer[name].reactOnResize = reactOnResize;
    renderer[name].fixedSize = fixedSize;
    renderer[name].updateRect(width, height);


    return renderer[name];
  }

  /**
   * Sets the relative position of the mouse relative to each renderer].
   */
  static void setRelativeMousePosition() {
    renderer.forEach((k, v) {
      v.relativeMousePosition = new Vector2((mouse.position.x - v.view.getBoundingClientRect().left).toInt(),
                                            (mouse.position.y - v.view.getBoundingClientRect().top).toInt());
      if (v.relativeMousePosition.x >= 0 && v.relativeMousePosition.x < v.view.offset.width &&
          v.relativeMousePosition.y >= 0 && v.relativeMousePosition.y < v.view.offset.height) {
        v.isHovered = true;
      } else {
        v.isHovered = false;
      }
    });
  }

  static void clearDisplayObjects() {
    renderer.forEach((k, v) => v.removeAllDisplayObjects());
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

  /**
   * Apply a [zoom] value to all zoomable renderers.
   */
  static void setZoom(num zoom) {
    renderer.forEach((k, v) {
      if (v.zoomable) {
        v.updateZoom(zoom);
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

  void clear([Color color]) {
    if (color != null) {
      context.fillStyle = color.rgba;
      context.fillRect(0, 0, view.width, view.height);
    } else {
      context.clearRect(0, 0, view.width, view.height);
    }
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

  void updatePosition(Vector2 position) {
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
      if (layer.name == displayObject.layer) {
        var index = layer.displayObjects.indexOf(displayObject);
        if (index != -1)
          layer.displayObjects.removeAt(index);
      }
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
      Rectangle object = new Rectangle(displayObject.position.x - (displayObject.size.x * displayObject.anchor.x * displayObject.scale.x / 2),
                                       displayObject.position.y - (displayObject.size.y * displayObject.anchor.y * displayObject.scale.y / 2),
                                       displayObject.size.x,
                                       displayObject.size.y);
      return renderer.intersects(object);
    } else if (displayObject is Rect) {
      Rectangle object = new Rectangle(displayObject.position.x - (displayObject.size.x * displayObject.anchor.x * displayObject.scale.x / 2),
                                       displayObject.position.y - (displayObject.size.y * displayObject.anchor.y * displayObject.scale.y / 2),
                                       displayObject.size.x,
                                       displayObject.size.y);
      return renderer.intersects(object);
    } else if (displayObject is Circle) {
      Vector2 size = new Vector2(displayObject.radius * displayObject.scale, displayObject.radius * displayObject.scale);
      Rectangle object = new Rectangle(displayObject.position.x - (size.x / 2),
                                       displayObject.position.y - (size.y / 2),
                                       size.x,
                                       size.y);
      return renderer.intersects(object);
    } else if (displayObject is Line) {
      return (renderer.containsPoint(new Point(displayObject.from.x, displayObject.from.y)) ||
              renderer.containsPoint(new Point(displayObject.to.x, displayObject.to.y)) ||
              LiangBarsky(renderer.left, renderer.left + renderer.width, renderer.top, renderer.top + renderer.height,
                         displayObject.from.x, displayObject.from.y, displayObject.to.x, displayObject.to.y));
    } else if (displayObject is Text) {
      context.font = "${displayObject.size * zoom}${displayObject.sizeUnit} ${displayObject.font}";
      context.textAlign = displayObject.align;
      context.textBaseline = displayObject.verticalAlign;
      var width = context.measureText(displayObject.text).width;

      Rectangle object = new Rectangle(displayObject.position.x - width,
                                       displayObject.position.y - displayObject.size,
                                       width * 2,
                                       width * 2);
      return renderer.intersects(object);
    }

    return false;
  }

  Vector2 relativePosition(Vector2 vector) {
   return new Vector2(
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
              Vector2 relativePos = relativePosition(displayObject.position);

              if (displayObject.alpha != 1.0)
                context.globalAlpha = displayObject.alpha;

              if (displayObject.rotation != 0) {
                context.save();
                context.translate(relativePos.x, relativePos.y);
                context.rotate(degToRad(displayObject.rotation));
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
              Vector2 relativePos = relativePosition(displayObject.position);

              context.lineWidth = displayObject.lineWidth * zoom;
              if (displayObject.rotation != 0) {
                context.save();
                context.translate(relativePos.x, relativePos.y);
                context.rotate(degToRad(displayObject.rotation));
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
              Vector2 relativePos = relativePosition(displayObject.position);

              context.lineWidth = displayObject.lineWidth * zoom;
              if (displayObject.rotation != 0) {
                context.save();
                context.translate(relativePos.x, relativePos.y);
                context.rotate(degToRad(displayObject.rotation));
                if (displayObject.fillColor != null) {
                  context.fillStyle = displayObject.fillColor.rgba;
                  context.beginPath();
                  context.arc(0, 0, displayObject.radius * displayObject.scale * zoom, 0, degToRad(displayObject.degrees), true);
                  context.closePath();
                  context.fill();
                }
                if (displayObject.strokeColor != null) {
                  context.strokeStyle = displayObject.strokeColor.rgba;
                  context.beginPath();
                  context.arc(0, 0, displayObject.radius * displayObject.scale * zoom, 0, degToRad(displayObject.degrees), true);
                  context.closePath();
                  context.stroke();
                }
                context.restore();
              } else {
                if (displayObject.fillColor != null) {
                  context.fillStyle = displayObject.fillColor.rgba;
                  context.beginPath();
                  context.arc(relativePos.x, relativePos.y, displayObject.radius * displayObject.scale * zoom, 0, degToRad(displayObject.degrees), true);
                  context.closePath();
                  context.fill();
                }
                if (displayObject.strokeColor != null) {
                  context.strokeStyle = displayObject.strokeColor.rgba;
                  context.beginPath();
                  context.arc(relativePos.x, relativePos.y, displayObject.radius * displayObject.scale * zoom, 0, degToRad(displayObject.degrees), true);
                  context.closePath();
                  context.stroke();
                }
              }
            }

            // render text
            else if (displayObject is Text) {
              Vector2 relativePos = relativePosition(displayObject.position);
              context.font = "${displayObject.size * zoom}${displayObject.sizeUnit} ${displayObject.font}";
              context.textAlign = displayObject.align;
              context.textBaseline = displayObject.verticalAlign;

              if (displayObject.rotation != 0) {
                context.save();
                context.translate(relativePos.x, relativePos.y);
                context.rotate(degToRad(displayObject.rotation));
                if (displayObject.strokeColor != null) {
                  context.strokeStyle = displayObject.strokeColor.rgba;
                  context.strokeText(displayObject.text, 0, 0);
                }
                if (displayObject.fillColor != null) { // FIXME: fillColor not working?
                  context.fillStyle = displayObject.fillColor.rgba;
                  context.fillText(displayObject.text, 0, 0);
                }
                context.restore();
              } else {
                if (displayObject.strokeColor != null){
                  context.strokeStyle = displayObject.strokeColor.rgba;
                  context.strokeText(displayObject.text, relativePos.x, relativePos.y);
                }
                if (displayObject.fillColor != null) {
                  context.fillStyle = displayObject.fillColor.rgba;
                  context.fillText(displayObject.text, relativePos.x, relativePos.y);
                }
              }
            }

            // render line
            else if (displayObject is Line) {
              Vector2 relativePosFrom = relativePosition(displayObject.from);
              Vector2 relativePosTo = relativePosition(displayObject.to);

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