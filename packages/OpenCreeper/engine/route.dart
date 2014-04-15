part of creeper;

/**
 * The Route class manages all logic related to A* pathfinding
 */

class Route {
  double distanceTravelled = 0.0, distanceRemaining = 0.0;
  List nodes = new List();
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
  bool contains(Node node) {
    for (int i = 0; i < nodes.length; i++) {
      if (node.position == nodes[i].position) {
        return true;
      }
    }
    return false;
  }
  
  /**
   * Main function of A*, finds a path to the target node for the packet.
   */
  static Route find(Node currentTarget, Node target) {
    // A* using Branch and Bound with dynamic programming and underestimates, thanks to: http://ai-depot.com/Tutorial/PathFinding-Optimal.html
    
     // this holds all routes
     List<Route> routes = new List<Route>();
    
     // create a new route and add the current node as first element
     Route route = new Route();
     route.nodes.add(currentTarget);
     routes.add(route);
    
     /*
       As long as there is any route AND
       the last node of the route is not the end node try to get to the end node
    
       If there is no route the packet will be removed
      */
     while (routes.length > 0) {
    
       if (routes[0].nodes[routes[0].nodes.length - 1] == target) {
         break;
       }
    
       // remove the first route from the list of routes
       Route oldRoute = routes.removeAt(0);
    
       // get the last node of the route
       Node lastNode = oldRoute.nodes[oldRoute.nodes.length - 1];
    
       // find all neighbours of this node
       List neighbours = lastNode.getNeighbours(target);
    
       int newRoutes = 0;
       // extend the old route with each neighbour creating a new route each
       for (int i = 0; i < neighbours.length; i++) {
    
         // if the neighbour is not already in the list..
         if (!oldRoute.contains(neighbours[i])) {
    
           newRoutes++;
    
           // create new route
           Route newRoute = oldRoute.clone();
    
           // add the new node to the new route
           newRoute.nodes.add(neighbours[i]);
    
           // increase distance travelled
           Vector centerA = newRoute.nodes[newRoute.nodes.length - 1].position;
           Vector centerB = newRoute.nodes[newRoute.nodes.length - 2].position;
           newRoute.distanceTravelled += centerA.distanceTo(centerB);
    
           // update underestimate of distance remaining
           Vector centerC = target.position;
           newRoute.distanceRemaining = centerA.distanceTo(centerC);
    
           // finally push the new route to the list of routes
           routes.add(newRoute);
         }
    
       }
    
       // find routes that end at the same node, remove those with the longer distance travelled
       for (int i = 0; i < routes.length; i++) {
         for (int j = 0; j < routes.length; j++) {
           if (i != j) {
             if (routes[i].nodes[routes[i].nodes.length - 1] == routes[j].nodes[routes[j].nodes.length - 1]) {
               if (routes[i].distanceTravelled < routes[j].distanceTravelled) {
                 routes[j].remove = true;
               } else if (routes[i].distanceTravelled > routes[j].distanceTravelled) {
                 routes[i].remove = true;
               }
    
             }
           }
         }
       }
       for (int i = routes.length - 1; i >= 0; i--) {
         if (routes[i].remove)
           routes.removeAt(i);
       }
    
       // sort routes by total underestimate so that the possibly shortest route gets checked first
       routes.sort((Route a, Route b) {
         return ((a.distanceTravelled + a.distanceRemaining) - (b.distanceTravelled + b.distanceRemaining)).compareTo(0);
       });
     }
     
     if (routes.length > 0)
       return routes[0];
     else
       return null;
  }
}