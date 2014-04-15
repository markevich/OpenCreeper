part of creeper;

class World {
  List tiles;
  Vector size;
  static int creeperCounter;
  static bool creeperDirty = true;
  
  World(int seed) {
    size = new Vector(game.engine.randomInt(64, 127, seed), game.engine.randomInt(64, 127, seed));
    creeperCounter = 0;
  }
  
  void createRandomLandscape() {
    tiles = new List(size.x);
    for (int i = 0; i < size.x; i++) {
      tiles[i] = new List<Tile>(size.y);
      for (int j = 0; j < size.y; j++) {
        tiles[i][j] = new Tile();
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
  
  /**
   * Checks if a given [position] in world coordinates is contained within the world
   */
  bool contains(Vector position) {
    return (position.x > -1 && position.x < size.x && position.y > -1 && position.y < size.y);
  }
  
  Tile getTile(Vector position) {
    return tiles[position.x ~/ game.tileSize][position.y ~/ game.tileSize];
  }  
  
  static void update() {
    // update creeper
    creeperCounter += 1 * game.speed;
    if (creeperCounter >= 25) {
      creeperCounter -= 25;
      creeperDirty = true;
      
      // synchronize new creep with old creep
      for (int i = 0; i < game.world.size.x; i++) {
        for (int j = 0; j < game.world.size.y; j++) {
          game.world.tiles[i][j].newcreep = game.world.tiles[i][j].creep;
        }
      }

      for (int i = 0; i < game.world.size.x; i++) {
        for (int j = 0; j < game.world.size.y; j++) {

          // right neighbour
          if (i + 1 < game.world.size.x) {
            transferCreeper(game.world.tiles[i][j], game.world.tiles[i + 1][j]);
          }
          // left neighbour
          if (i - 1 > -1) {
            transferCreeper(game.world.tiles[i][j], game.world.tiles[i - 1][j]);
          }
          // bottom neighbour
          if (j + 1 < game.world.size.y) {
            transferCreeper(game.world.tiles[i][j], game.world.tiles[i][j + 1]);
          }
          // top neighbour
          if (j - 1 > -1) {
            transferCreeper(game.world.tiles[i][j], game.world.tiles[i][j - 1]);
          }

        }
      }
      
      // clamp creeper
      for (int i = 0; i < game.world.size.x; i++) {
        for (int j = 0; j < game.world.size.y; j++) {
          if (game.world.tiles[i][j].newcreep > 10)
            game.world.tiles[i][j].newcreep = 10;
          else if (game.world.tiles[i][j].newcreep < .01)
            game.world.tiles[i][j].newcreep = 0;
          game.world.tiles[i][j].creep = game.world.tiles[i][j].newcreep;
        }
      }

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