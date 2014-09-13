part of creeper;

class Connection {
  Building from, to;
  Line line, line2;
  static List<Connection> connections = new List<Connection>();
  
  Connection(this.from, this.to) {
    line = new Line("buffer", Layer.CONNECTIONBORDER, this.from.position, this.to.position, 3, "#000");

    var color = '#777';
    if (from.built && to.built)
      color = '#fff';

    line2 = new Line("buffer", Layer.CONNECTION, this.from.position, this.to.position, 2, color);
  }
  
  static void clear() {
    connections.clear();
  }
  
  static void add(Building building2) {  
    for (var building in game.engine.gameObjects) {
      if (building is Building) {
        if (Building != building2 && building.status == "IDLE" &&
            (building2.type == "collector" || building2.type == "relay" || building.type == "collector" || building.type == "relay" || building.type == "base")) {
  
          num allowedDistance = 10 * game.tileSize;
          if (building.type == "relay" && building2.type == "relay") {
            allowedDistance = 20 * game.tileSize;
          }
  
          if (building2.position.distanceTo(building.position) <= allowedDistance) {
            if (!exists(building2, building)) {
              Connection connection = new Connection(building2, building);
              connections.add(connection);
            }
          }
        }
      }   
    }
  }
  
  static void remove(Building building) {
    for (int i = connections.length - 1; i >= 0; i--) {
      if (connections[i].from == building || connections[i].to == building) {
        game.engine.renderer["buffer"].removeDisplayObject(connections[i].line);
        game.engine.renderer["buffer"].removeDisplayObject(connections[i].line2);
        connections.removeAt(i);
      }
    }
  }
  
  static bool exists(Building from, Building to) {
    for (var connection in connections) {
      if ((connection.from == from && connection.to == to) || (connection.from == to && connection.to == from)) {
        return true;
      }
    }
    return false;
  }
  
  static void activate(Building building) {
    for (var connection in connections) {
      if ((connection.from == building || connection.to == building) && (connection.from.built && connection.to.built)) {
        connection.line2.color = '#fff';
      }
    }
  }
}