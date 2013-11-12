part of creeper;

class World {
  List tiles;
  Vector size;
  
  World(int seed) {
    size = new Vector(engine.randomInt(64, 127, seed), engine.randomInt(64, 127, seed));
  }
  
  /**
   * Checks if a given [position] in world coordinates is contained within the world
   */
  bool contains(Vector position) {
    return (position.x > -1 && position.x < size.x && position.y > -1 && position.y < size.y);
  }
}

class Emitter {
  Vector position;
  String imageID;
  int strength;
  Building building;
  static int counter;

  Emitter(this.position, this.strength) {
    imageID = "emitter";
  }
  
  Vector getCenter() {
    return new Vector(position.x * game.tileSize + 24, position.y * game.tileSize + 24);
  }

  void spawn() {
    // only spawn creeper if not targeted by an analyzer
    if (building == null)
      game.world.tiles[position.x + 1][position.y + 1].creep += strength;
  }
  
  void draw() {
    Vector realPosition = position.tiled2screen();
    if (engine.isVisible(realPosition, new Vector(48 * game.zoom, 48 * game.zoom))) {
      engine.canvas["buffer"].context.drawImageScaled(engine.images[imageID], realPosition.x, realPosition.y, 48 * game.zoom, 48 * game.zoom);
    }
  }
}

/**
 * Sporetower
 */

class Sporetower {
  Vector position;
  String imageID;
  int sporeCounter = 0;

  Sporetower(this.position) {
    imageID = "sporetower";
    reset();
  }

  void reset() {
    sporeCounter = engine.randomInt(7500, 12500);
  }

  Vector getCenter() {
    return new Vector(position.x * game.tileSize + 24, position.y * game.tileSize + 24);
  }

  void update() {
    sporeCounter -= 1;
    if (sporeCounter <= 0) {
      reset();
      spawn();
    }
  }

  void spawn() {
    Building target = null;
    do {
      target = game.buildings[engine.randomInt(0, game.buildings.length - 1)];
    } while (!target.built);
    Spore spore = new Spore(getCenter(), target.getCenter());
    game.spores.add(spore);
  }
  
  void draw() {
    Vector realPosition = position.tiled2screen();
    if (engine.isVisible(realPosition, new Vector(48 * game.zoom, 48 * game.zoom))) {
      engine.canvas["buffer"].context.drawImageScaled(engine.images[imageID], realPosition.x, realPosition.y, 48 * game.zoom, 48 * game.zoom);
    }
  }
}

class Smoke {
  Sprite sprite;
  static int counter;

  Smoke(Vector position) {
    sprite = new Sprite(0, engine.images["smoke"], position, 128, 128);
    sprite.animated = true;
    sprite.anchor = new Vector(0.5, 0.5);  
    sprite.scale = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addSprite(sprite);    
  }
}

class Explosion {
  Vector position;
  int frame;
  String imageID;
  static int counter;

  Explosion(Vector position) {
    this.position = new Vector(position.x, position.y);
    frame = 0;
    imageID = "explosion";
    counter = 0;
  }

  void draw() {
    Vector realPosition = position.real2screen();
    if (engine.isVisible(realPosition, new Vector(64 * game.zoom, 64 * game.zoom))) {
      engine.canvas["buffer"].context.drawImageScaledFromSource(engine.images[imageID], (frame % 8) * 64, (frame / 8).floor() * 64, 64, 64, realPosition.x - 32 * game.zoom, realPosition.y - 32 * game.zoom, 64 * game.zoom, 64 * game.zoom);
    }
  }
}

class Tile {
  num creep, newcreep;
  Building collector;
  int height, index, terraformTarget, terraformProgress;

  Tile() {
    index = -1;
    creep = 0;
    newcreep = 0;
    collector = null;
    terraformTarget = -1;
    terraformProgress = 0;
  }
}

class Vector {
  num x, y;

  Vector(this.x, this.y);
  Vector.empty() : this(0, 0);

  Vector operator +(Vector other) => new Vector(x + other.x, y + other.y);
  bool operator ==(Vector other) => (x == other.x && y == other.y);
  
  String toString() {
    return "$x/$y";
  }
  
  num distanceTo(Vector other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }
  
  // converts tile coordinates to canvas coordinates
  Vector tiled2screen() {
    return new Vector(
        engine.halfWidth + (x - game.scroll.x) * game.tileSize * game.zoom,
        engine.halfHeight + (y - game.scroll.y) * game.tileSize * game.zoom);
  }
  
  // converts full coordinates to canvas coordinates
  Vector real2screen() {
    return new Vector(
        engine.halfWidth + (x - game.scroll.x * game.tileSize) * game.zoom,
        engine.halfHeight + (y - game.scroll.y * game.tileSize) * game.zoom);
  }
  
  // converts full coordinates to tile coordinates
  Vector real2tiled() {
    return new Vector(
        x ~/ game.tileSize,
        y ~/ game.tileSize);
  }
}

class Vector3 {
  num x, y, z;

  Vector3(this.x, this.y, this.z);

  Vector3 operator +(Vector3 other) => new Vector3(x + other.x, y + other.y, z + other.z);
}

/**
 * Route object used in A*
 */

class Route {
  num distanceTravelled = 0, distanceRemaining = 0;
  List<Building> nodes = new List<Building>();
  bool remove = false;
  
  Route();
  
  Route clone() {
    Route route = new Route();
    route.distanceTravelled = this.distanceTravelled;
    route.distanceRemaining = this.distanceRemaining;
    for (int i = 0; i < this.nodes.length; i++) {
      route.nodes.add(this.nodes[i]);
    }
    return route;
  }
  
  /**
   * Used for A*, checks if a [node] is in the list of nodes.
   */
  bool contains(Building node) {
    for (int i = 0; i < nodes.length; i++) {
      if (node.position == nodes[i].position) {
        return true;
      }
    }
    return false;
  }
}

/**
 * Object to store canvas information
 */

class Renderer {
  CanvasElement view;
  CanvasRenderingContext2D context;
  int top, left, bottom, right;
  List<Sprite> sprites = new List<Sprite>();

  Renderer(this.view, width, height) {
    updateRect(width, height);
    view.style.position = "absolute";
    context = view.getContext('2d');
  }

  void clear() {
    context.clearRect(0, 0, view.width, view.height);
  }
  
  void updateRect(int width, int height) {
    view.width = width;
    view.height = height;
    top = view.offset.top;
    left = view.offset.left;
    bottom = view.offset.top + view.offset.height;
    right = view.offset.left + view.offset.width;
  }
  
  void addSprite(Sprite sprite) {
    sprites.add(sprite);
    sprites.sort((Sprite a, Sprite b) {
      return a.layer - b.layer;
    });
  }

  void removeSprite(Sprite sprite) {
    sprites.removeAt(sprites.indexOf(sprite));  
  }
  
  void draw() {
    for (var sprite in sprites) {
      if (sprite.visible) {
        Vector realPosition = sprite.position.real2screen();
    
        if (engine.isVisible(realPosition, new Vector(sprite.size.x * game.zoom, sprite.size.y * game.zoom))) {
          
          if (sprite.rotation != 0) {     
            context.save();
            
            if (sprite.alpha != 1.0)
              context.globalAlpha = sprite.alpha;
            
            context.translate(realPosition.x, realPosition.y);
            context.rotate(engine.deg2rad(sprite.rotation));             
            if (sprite.animated)
              context.drawImageScaledFromSource(sprite.image,
                                                (sprite.frame % 8) * sprite.size.x,
                                                (sprite.frame ~/ 8) * sprite.size.y,
                                                sprite.size.x,
                                                sprite.size.y,
                                                -sprite.size.x * sprite.anchor.x * sprite.scale.x * game.zoom,
                                                -sprite.size.y * sprite.anchor.y * sprite.scale.y * game.zoom,
                                                sprite.size.x * sprite.scale.x * game.zoom,
                                                sprite.size.y * sprite.scale.y * game.zoom);
            else
              context.drawImageScaled(sprite.image,
                                      -sprite.size.x * sprite.anchor.x * game.zoom, 
                                      -sprite.size.y * sprite.anchor.y * game.zoom, 
                                      sprite.size.x * game.zoom, 
                                      sprite.size.y * game.zoom);
            context.restore();
          } else {                  
            if (sprite.alpha != 1.0) {
              context.save();
              context.globalAlpha = sprite.alpha;              
            }          
            if (sprite.animated)
              context.drawImageScaledFromSource(sprite.image,
                                                (sprite.frame % 8) * sprite.size.x,
                                                (sprite.frame ~/ 8) * sprite.size.y,
                                                sprite.size.x,
                                                sprite.size.y,
                                                realPosition.x - sprite.size.x * sprite.anchor.x * sprite.scale.x * game.zoom,
                                                realPosition.y - sprite.size.y * sprite.anchor.y * sprite.scale.y * game.zoom,
                                                sprite.size.x * sprite.scale.x * game.zoom,
                                                sprite.size.y * sprite.scale.y * game.zoom);
            else
              context.drawImageScaled(sprite.image,
                                      realPosition.x - sprite.size.x * sprite.anchor.x * game.zoom,
                                      realPosition.y - sprite.size.y * sprite.anchor.y * game.zoom,
                                      sprite.size.x * game.zoom,
                                      sprite.size.y * game.zoom);   
            if (sprite.alpha != 1.0) {
              context.restore;              
            } 
          }
        }
      }
    }
  }
}

class Sprite {
  int layer, frame = 0;
  ImageElement image;
  Vector anchor, scale, position, size;
  num rotation = 0, alpha = 1.0;
  bool animated = false, visible = true;

  Sprite(this.layer, this.image, this.position, width, height) {
    anchor = new Vector(0.0, 0.0);
    scale = new Vector(1.0, 1.0);
    size = new Vector(width, height);
  }
}