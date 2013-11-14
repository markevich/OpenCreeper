part of creeper;

class Packet {
  Vector speed = new Vector(0, 0);
  String type;
  bool remove = false;
  num speedMultiplier = 1;
  Building target, currentTarget;
  Sprite sprite;
  static num baseSpeed = 3;

  Packet(position, imageID, this.type) {
    sprite = new Sprite(2, engine.images[imageID], position, 16, 16);
    sprite.anchor = new Vector(0.5, 0.5);

    if (type == "collection")
      sprite.scale = new Vector(1.5, 1.5);

    engine.canvas["buffer"].addDisplayObject(sprite);
  }

  void move() {
    calculateVector();
    
    sprite.position += speed;

    Vector centerTarget = currentTarget.getCenter();
    if (sprite.position.x > centerTarget.x - 1 && sprite.position.x < centerTarget.x + 1 && sprite.position.y > centerTarget.y - 1 && sprite.position.y < centerTarget.y + 1) {
      sprite.position = centerTarget;

      // if the final node was reached deliver and remove
      if (currentTarget == target) {
        remove = true;
        // deliver package
        if (type == "health") {
          target.health += 1;
          target.healthRequests--;
          if (target.health >= target.maxHealth) {
            target.health = target.maxHealth;
            if (!target.built) {
              target.built = true;
              if (target.imageID == "collector") {
                game.updateCollection(target, "add");
                engine.playSound("energy", target.position);
              }
              if (target.imageID == "storage")
                game.maxEnergy += 20;
              if (target.imageID == "speed")
                Packet.baseSpeed *= 1.01;
              if (target.imageID == "bomber") {
                Ship ship = new Ship(new Vector(target.position.x * game.tileSize + 24, target.position.y * game.tileSize + 24), "bombership", "Bomber", target);
                target.ship = ship;
                game.ships.add(ship);
              }
            }
          }
        } else if (type == "energy") {
          target.energy += 4;
          target.energyRequests -= 4;
          if (target.energy > target.maxEnergy)
            target.energy = target.maxEnergy;
        } else if (type == "collection") {
          game.currentEnergy += 1;
          if (game.currentEnergy > game.maxEnergy)
            game.currentEnergy = game.maxEnergy;
          game.updateEnergyElement();
        }
      } else {
        findRoute();
      }
    }
  }

  void calculateVector() {
    Vector targetPosition = currentTarget.getCenter();
    Vector delta = targetPosition - sprite.position;
    num distance = sprite.position.distanceTo(targetPosition);

    speed.x = (delta.x / distance) * Packet.baseSpeed * game.speed * speedMultiplier;
    speed.y = (delta.y / distance) * Packet.baseSpeed * game.speed * speedMultiplier;

    if (speed.x.abs() > delta.x.abs())
      speed.x = delta.x;
    if (speed.y.abs() > delta.y.abs())
      speed.y = delta.y;
  }

  /**
   * Main function of A*, finds a path to the target node for the packet.
   */
  bool findRoute() {
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
      Building lastNode = oldRoute.nodes[oldRoute.nodes.length - 1];

      // find all neighbours of this node
      List neighbours = game.getNeighbours(lastNode, target);

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
          Vector centerA = newRoute.nodes[newRoute.nodes.length - 1].getCenter();
          Vector centerB = newRoute.nodes[newRoute.nodes.length - 2].getCenter();
          newRoute.distanceTravelled += centerA.distanceTo(centerB);

          // update underestimate of distance remaining
          Vector centerC = target.getCenter();
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
        return (a.distanceTravelled + a.distanceRemaining) - (b.distanceTravelled + b.distanceRemaining);
      });
    }

    // if a route is left set the second element as the next node for the packet
    if (routes.length > 0) {

      // adjust speed if packet is travelling between relays
      if (routes[0].nodes[1].imageID == "relay") {
        speedMultiplier = 2;
      } else {
        speedMultiplier = 1;
      }

      // reduce speed for collection
      if (type == "collection")
        speedMultiplier /= 4;

      currentTarget = routes[0].nodes[1];
      return true;
    } else {

      currentTarget = null;

      // reduce target requests
      if (type == "energy") {
        target.energyRequests -= 4;
        if (target.energyRequests < 0)
          target.energyRequests = 0;
      } else if (type == "health") {
        target.healthRequests--;
        if (target.healthRequests < 0)
          target.healthRequests = 0;
      }
      remove = true;
      return false;
    }
  }
}