part of creeper;

class Connection {
  Building from, to;
  Line line, line2;
  static List<Connection> connections = new List<Connection>();
  
  Connection(this.from, this.to) {
    line = new Line(1, this.from.position, this.to.position, 3, "#000");
    engine.canvas["buffer"].addDisplayObject(line);
    line2 = new Line(2, this.from.position, this.to.position, 2, "#777");
    engine.canvas["buffer"].addDisplayObject(line2);
  }
  
  static void clear() {
    connections.clear();
  }
  
  static void add(Building building) {  
    for (int i = 0; i < Building.buildings.length; i++) {
      if (Building.buildings[i] != building && Building.buildings[i].status == "IDLE") {

        num allowedDistance = 10 * game.tileSize;
        if (Building.buildings[i].type == "relay" && building.type == "relay") {
          allowedDistance = 20 * game.tileSize;
        }

        if (building.position.distanceTo(Building.buildings[i].position) <= allowedDistance) {
          if (!exists(building, Building.buildings[i])) {
            Connection connection = new Connection(building, Building.buildings[i]);
            connections.add(connection);
          }
        }
      }
    }    
  }
  
  static void remove(Building building) {
    for (int i = connections.length - 1; i >= 0; i--) {
      if (connections[i].from == building || connections[i].to == building) {
        engine.canvas["buffer"].removeDisplayObject(connections[i].line);
        engine.canvas["buffer"].removeDisplayObject(connections[i].line2);
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