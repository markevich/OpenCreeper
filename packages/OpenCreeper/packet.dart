part of creeper;

class Packet {
  Vector speed = new Vector(0, 0);
  String type;
  bool remove = false;
  num speedMultiplier = 1;
  Building target, currentTarget;
  Sprite sprite;
  static num baseSpeed = 3;
  static List<Packet> packets = new List<Packet>();
  static List<Packet> queue = new List<Packet>();

  Packet(this.currentTarget, this.target, imageID, this.type) {
    sprite = new Sprite(Layer.PACKET, game.engine.images[imageID], currentTarget.position, 16, 16);
    sprite.anchor = new Vector(0.5, 0.5);
    sprite.visible = false;

    if (type == "collection")
      sprite.scale = new Vector(1.5, 1.5);

    game.engine.renderer["buffer"].addDisplayObject(sprite);
  }
  
  static void clear() {
    packets.clear();
    queue.clear();
  }
  
  static void add(Packet packet) {
    packet.sprite.visible = true;
    packets.add(packet);
  }
  
  static void addQueue(Packet packet) {
    queue.add(packet);
  }
  
  static void update() {
    for (int i = packets.length - 1; i >= 0; i--) {
      if (packets[i].remove) {
        game.engine.renderer["buffer"].removeDisplayObject(packets[i].sprite);
        packets.removeAt(i);
      }
      else
        packets[i].move();
    }
    
    /**
     * Updates the packet queue of the base.
     * 
     * If the base has energy the first packet is removed from
     * the queue and sent to its target (FIFO).
     */
    for (int i = queue.length - 1; i >= 0; i--) {
      if (Building.base.energy > 0) {
        Building.base.energy--;
        game.updateEnergyElement();
        Packet packet = queue.removeAt(0);
        Packet.add(packet);
      }
    }
  }
  
  static void removeWithTarget(building) {
    for (int i = packets.length - 1; i >= 0; i--) {
      if (packets[i].currentTarget == building || packets[i].target == building) {
        packets[i].remove = true;
      }
    }
    for (int i = queue.length - 1; i >= 0; i--) {
      if (queue[i].currentTarget == building || queue[i].target == building) {
        queue[i].remove = true;
      }
    }
  }
  
  /**
   * Creates a new requested packet with its [target]
   * and [type] and queues it.
   */
  static void queuePacket(Building target, String type) {
    String img = "packet_" + type;
    Packet packet = new Packet(Building.base, target, img, type);
    if (packet.findRoute()) {
      if (packet.type == "health")
        packet.target.healthRequests++;
      else if (packet.type == "energy")
        packet.target.energyRequests += 4;
      Packet.addQueue(packet);
    } else {
      game.engine.renderer["buffer"].removeDisplayObject(packet.sprite);
    }
  }

  void move() {
    calculateVector();
    
    sprite.position += speed;

    if (sprite.position == currentTarget.position) {
      
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
              target.sprite.alpha = 1.0;
              Connection.activate(target);
              if (target.cannon != null)
                target.cannon.alpha = 1.0;
              if (target.type == "collector") {
                target.updateCollection("add");
                game.engine.playSound("energy", target.position.real2tiled());
              }
              if (target.type == "storage")
                Building.base.maxEnergy += 20;
              if (target.type == "speed")
                Packet.baseSpeed *= 1.01;
              if (target.type == "bomber") {
                target.ship = Ship.add(target.position, "bombership", "Bomber", target);           
              }
            }
          }
        } else if (type == "energy") {
          target.energy += 4;
          target.energyRequests -= 4;
          if (target.energy > target.maxEnergy)
            target.energy = target.maxEnergy;
        } else if (type == "collection") {
          Building.base.energy += 1;
          if (Building.base.energy > Building.base.maxEnergy)
            Building.base.energy = Building.base.maxEnergy;
          game.updateEnergyElement();
        }
      } else {
        findRoute();
      }
    }
  }

  void calculateVector() {
    Vector targetPosition = currentTarget.position;
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
   * Find a route for this packet
   */
  bool findRoute() {
    Route route = Route.find(currentTarget, target);

    // if a route is left set the second element as the next node for the packet
    if (route != null) {

      // adjust speed if packet is travelling between relays
      if (route.nodes[1].type == "relay") {
        speedMultiplier = 2;
      } else {
        speedMultiplier = 1;
      }

      // reduce speed for collection
      if (type == "collection")
        speedMultiplier /= 4;

      currentTarget = route.nodes[1];
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