part of zengine;

/**
 * Used for A*
 * Every class acting as a A* node will have to implement this.
 */
abstract class ZNode {
  Vector position;
  
  ZNode();

  /**
   * Used for A*, finds all neighbouring nodes.
   * The [target] node is also passed as it is a valid neighbour.
   */
  getNeighbours(ZNode target) {   
    // loop through all nodes and determine if neighbour, example below
        
    /*List neighbours = new List();
    for (int i = 0; i < nodes.length; i++) {
      // must not be the same node
      if (nodes[i].position != position) {
        // it must either be the target or be built
        if (nodes[i] == target || nodes[i].built) {
          neighbours.add(nodes[i]);
        }
      }
    }
    return neighbours;*/
  }

}