part of creeper;

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
    route.distanceTravelled = distanceTravelled;
    route.distanceRemaining = distanceRemaining;
    for (int i = 0; i < nodes.length; i++) {
      route.nodes.add(nodes[i]);
    }
    return route;
  }
  
  /**
   * Check if a [node] is in the list of nodes.
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