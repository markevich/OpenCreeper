part of zei;

/**
 * The Route class manages all logic related to A* pathfinding
 */

class Route {
 
  Route();

  /*
 * Adds or updates a node with the position [x] and [y] and sets the [parent].
 */
  static void addOrUpdateNode(var gameObject, ZNode parent, GameObject end, open, closed) {

    // return if its already in the closed list
    for (var i = 0; i < closed.length; i++) {
      if (closed[i].gameObject.position.x == gameObject.position.x && closed[i].gameObject.position.y == gameObject.position.y) {
        return;
      }
    }

    // update and return if its already in the open list
    for (var i = 0; i < open.length; i++) {
      if (open[i].gameObject.position.x == gameObject.position.x && open[i].gameObject.position.y == gameObject.position.y) {
        if (parent.g + 10 < open[i].g) {
          open[i].parent = parent;
          open[i].g = parent.g + 10;
          open[i].f = open[i].g + open[i].h;
        }
        return;
      }
    }

    // else add it to open list
    open.add(new ZNode(gameObject, end, parent));
  }

  /**
   * Main function of A*, finds a path to the target node for the packet.
   */
  static ZNode find(GameObject start, GameObject end) {
    List<ZNode> open = new List();
    List<ZNode> closed = new List();
    GameObject starto = start;

    ZNode startNode = new ZNode(start, end);
    ZNode endNode;

    open.add(startNode);

    while (open.length > 0) {

      // take first node from open list
      ZNode currentNode = open.removeAt(0);

      // first check if its the end point
      if (currentNode.gameObject == currentNode.target) {
        endNode = currentNode;
        break;
      }

      // add neighbours
      List neighbours = currentNode.gameObject.getNeighbours(end);

      for (var neighbour in neighbours) {
        addOrUpdateNode(neighbour, currentNode, end, open, closed);
      }

      // add node to closed list
      closed.add(currentNode);

      // sort open list
      open.sort((ZNode a, ZNode b) {
        return (a.f - b.f);
      });
    }

    // if a route has been found set the nodes
    if (endNode != null) {
      return getNode(endNode, starto);
    } else {
      return null;
    }

  }

  /*
 * Sets the individual nodes after a path has been found
 */
  static ZNode getNode(ZNode node, starto) {
    // continue with parent node
    if (node.parent != null) {
      if (node.parent.gameObject == starto)
        return node;
      else
        return getNode(node.parent, starto);
    }
    return null;
  }
}

/**
 * Node used for A*
 */
class ZNode {
  Vector2 position;
  ZNode parent;
  int g = 0, h = 0, f = 0;
  var gameObject, target;

  ZNode(this.gameObject, this.target, [ZNode parent]) {
    if (parent != null) {
      this.parent = parent;
      g = parent.g + 10; // current movement cost
    }
    h = (gameObject.position.x - target.position.x).abs() + (gameObject.position.y - target.position.y).abs(); // heuristic movement cost to target (manhattan distance)
    f = g + h; // total movement cost
  }

}