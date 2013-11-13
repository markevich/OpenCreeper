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