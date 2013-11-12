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
  
  Tile getTile(Vector position) {
    return tiles[position.x ~/ 16][position.y ~/ 16];
  }  
}

class Emitter {
  Sprite sprite;
  int strength;
  Building analyzer;
  static int counter;

  Emitter(position, this.strength) {
    sprite = new Sprite(0, engine.images["emitter"], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addSprite(sprite); 
  }

  void spawn() {
    // only spawn creeper if not targeted by an analyzer
    if (analyzer == null)
      game.world.getTile(sprite.position + new Vector(1, 1)).creep += strength; //game.world.tiles[sprite.position.x + 1][sprite.position.y + 1].creep += strength;
  }
}

class Sporetower {
  Sprite sprite;
  int sporeCounter = 0;

  Sporetower(position) {
    sprite = new Sprite(0, engine.images["sporetower"], position, 48, 48);
    sprite.anchor = new Vector(0.5, 0.5);  
    engine.canvas["buffer"].addSprite(sprite);  
    reset();
  }

  void reset() {
    sporeCounter = engine.randomInt(7500, 12500);
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
    game.spores.add(new Spore(sprite.position, target.getCenter()));
  }
}

class Smoke {
  Sprite sprite;
  static int counter = 0;

  Smoke(Vector position) {
    sprite = new Sprite(1, engine.images["smoke"], position, 128, 128);
    sprite.animated = true;
    sprite.anchor = new Vector(0.5, 0.5);  
    sprite.scale = new Vector(0.5, 0.5);
    engine.canvas["buffer"].addSprite(sprite);    
  }
}

class Explosion {
  Sprite sprite;
  static int counter = 0;

  Explosion(Vector position) {
    sprite = new Sprite(3, engine.images["explosion"], position, 64, 64);
    sprite.animated = true;
    sprite.rotation = engine.randomInt(0, 359);
    sprite.anchor = new Vector(0.5, 0.5);  
    engine.canvas["buffer"].addSprite(sprite); 
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
 * Renderer class
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
          
          if (sprite.alpha != 1.0)
            context.globalAlpha = sprite.alpha;
          
          if (sprite.rotation != 0) {     
            context.save();   
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
          }
          
          if (sprite.alpha != 1.0)
            context.globalAlpha = 1.0;
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