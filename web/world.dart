part of creeper;

class World extends Zei.GameObject {
  List<List<Tile>> tiles;
  Zei.Vector2 size;
  int creeperCounter;
  static bool creeperDirty = true;
  
  World(int seed) {
    size = new Zei.Vector2(Zei.randomInt(64, 127, seed), Zei.randomInt(64, 127, seed));
    creeperCounter = 0;
  }
  
  /**
  * Creates a random world with base, emitters and sporetowers.
  */
  void create() {
    createRandomLandscape();

    // create random base
    Zei.Vector2 randomPosition = new Zei.Vector2(
      Zei.randomInt(4, size.x - 5, game.seed + 1),
      Zei.randomInt(4, size.y - 5, game.seed + 1));

    game.scroll = randomPosition;
    for (var renderer in game.zoomableRenderers) {
      Zei.renderer[renderer].updatePosition(new Zei.Vector2(game.scroll.x * Tile.size, game.scroll.y * Tile.size));
    }

    Building building = Building.add(randomPosition, "base");
    makeFlatSurface(building.position, 9);

    if (!game.friendly) {
      // create random emitters
      int amount = Zei.randomInt(2, 3, game.seed);
      for (var i = 0; i < amount; i++) {    
         randomPosition = new Zei.Vector2(
             Zei.randomInt(1, size.x - 2, game.seed + Zei.randomInt(1, 1000, game.seed + i)) * Tile.size + 8,
             Zei.randomInt(1, size.y - 2, game.seed + Zei.randomInt(1, 1000, game.seed + 1 + i)) * Tile.size + 8);
   
        Emitter emitter = Emitter.add(randomPosition, 25);
        makeFlatSurface(emitter.sprite.position, 3);    
      }
 
      // create random sporetowers
      amount = Zei.randomInt(1, 2, game.seed + 1);
      for (var i = 0; i < amount; i++) {
        randomPosition = new Zei.Vector2(
           Zei.randomInt(1, size.x - 2, game.seed + 3 + Zei.randomInt(1, 1000, game.seed + 2 + i)) * Tile.size + 8,
           Zei.randomInt(1, size.y - 2, game.seed + 3 + Zei.randomInt(1, 1000, game.seed + 3 + i)) * Tile.size + 8);
   
        Sporetower sporetower = Sporetower.add(randomPosition);
        makeFlatSurface(sporetower.sprite.position, 3);
      }
    }
  }
  
  void createRandomLandscape() {
    tiles = new List(size.x);
    for (int i = 0; i < size.x; i++) {
      tiles[i] = new List<Tile>(size.y);
      for (int j = 0; j < size.y; j++) {
        tiles[i][j] = new Tile(i, j);
      }
    }

    var heightmap = new HeightMap(game.seed, 129, 0, 90);
    heightmap.run();

    for (int i = 0; i < size.x; i++) {
      for (int j = 0; j < size.y; j++) {
        int height = (heightmap.map[i][j] / 10).round();
        if (height > 10)
          height = 10;
        tiles[i][j].height = height;
      }
    }
  }
  
  // makes a flat surface for base, emitters and spore towers when creating the world
  void makeFlatSurface(position, size) {
    int height = game.world.getTile(position).height;
    if (height < 0)
      height = 0;
    for (int i = -size ~/ 2; i <= size ~/ 2; i++) {
      for (int j = -size ~/ 2; j <= size ~/ 2; j++) {
        game.world.getTile(position + new Zei.Vector2(i * Tile.size, j * Tile.size)).height = height;
      }
    }
  }
  
  void hideRangeBoxes() {
    for (int i = 0; i < size.x; i++) {
      for (int j = 0; j < size.y; j++) {
        tiles[i][j].rangeBox.visible = false;
      }
    }
  }
  
  /**
   * Checks if a given [position] in world coordinates is contained within the world
   */
  bool contains(Zei.Vector2 position) {
    return (position.x > -1 && position.x < size.x && position.y > -1 && position.y < size.y);
  }
  
  Tile getTile(Zei.Vector2 position) {
    return tiles[position.x ~/ Tile.size][position.y ~/ Tile.size];
  }  
  
  void update() {
    // update creeper
    creeperCounter += 1 * game.speed;
    if (creeperCounter >= 25) {
      creeperCounter -= 25;
      creeperDirty = true;
      
      // synchronize new creep with old creep
      for (int i = 0; i < size.x; i++) {
        for (int j = 0; j < size.y; j++) {
          tiles[i][j].newcreep = tiles[i][j].creep;
        }
      }

      for (int i = 0; i < size.x; i++) {
        for (int j = 0; j < size.y; j++) {

          // right neighbour
          if (i + 1 < size.x) {
            transferCreeper(tiles[i][j], tiles[i + 1][j]);
          }
          // left neighbour
          if (i - 1 > -1) {
            transferCreeper(tiles[i][j], tiles[i - 1][j]);
          }
          // bottom neighbour
          if (j + 1 < size.y) {
            transferCreeper(tiles[i][j], tiles[i][j + 1]);
          }
          // top neighbour
          if (j - 1 > -1) {
            transferCreeper(tiles[i][j], tiles[i][j - 1]);
          }

        }
      }
      
      // clamp creeper
      for (int i = 0; i < size.x; i++) {
        for (int j = 0; j < size.y; j++) {
          if (tiles[i][j].newcreep > 10)
            tiles[i][j].newcreep = 10;
          else if (tiles[i][j].newcreep < .01)
            tiles[i][j].newcreep = 0;
          tiles[i][j].creep = tiles[i][j].newcreep;
        }
      }

    }
    
    if (creeperDirty) {
      game.drawCreeper();
      creeperDirty = false;
    }
  }

  /**
   * Transfers creeper from one tile to another.
   */ 
  static void transferCreeper(Tile source, Tile target) {
    num transferRate = .2;

    if (source.height > -1 && target.height > -1) {
      num sourceCreeper = source.creep;     
      //num targetCreeper = target.creep;
      if (sourceCreeper > 0 /*|| targetCreeper > 0*/) {
        num sourceTotal = source.height + source.creep;
        num targetTotal = target.height + target.creep;
        num delta = 0;
        if (sourceTotal > targetTotal) {
          delta = sourceTotal - targetTotal;
          if (delta > sourceCreeper)
            delta = sourceCreeper;
          num adjustedDelta = delta * transferRate;
          source.newcreep -= adjustedDelta;
          target.newcreep += adjustedDelta;
        }
      }
    }
  }
}