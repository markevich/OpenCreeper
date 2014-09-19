part of zei;

class Vector {
  num x, y;

  Vector(this.x, this.y);
  Vector.empty() : this(0, 0);

  Vector operator +(Vector other) => new Vector(x + other.x, y + other.y);
  Vector operator -(Vector other) => new Vector(x - other.x, y - other.y);
  Vector operator *(num other) => new Vector(x * other, y * other);
  Vector operator /(num other) => new Vector(x / other, y / other);
  bool operator ==(Vector other) => (x == other.x && y == other.y);

  String toString() {
    return "$x/$y";
  }

  num distanceTo(Vector other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }
  
  num magnitude() {
    return new Vector.empty().distanceTo(this);
  }
  
  // returns absolute angle to another vector in degrees
  num angleTo(Vector other) {   
    return Zei.radToDeg(atan2(other.y - y, other.x - x));
  }
  
  Vector normalize() {   
    var mag = magnitude();
    return new Vector(x / mag, y / mag);
  }
   
  Vector clamp(Vector max) {
    if (x.abs() > max.x.abs())
      x = max.x;
    if (y.abs() > max.y.abs())
      y = max.y;
    return this;
  }
  
  // 2 vectors facing same direction > 0, perpendicular = 0, different direction < 0
  num dotProduct(Vector other) {
    return (x * other.x + y * other.y);
  }
  
  // calculates a perpendicular vector
  Vector getNormal() {
    return new Vector(y, -x);    
  }
  
  Vector negate() {
   return new Vector(-x, -y);
  }
}

class Vector3 {
  num x, y, z;

  Vector3(this.x, this.y, this.z);

  Vector3 operator +(Vector3 other) => new Vector3(x + other.x, y + other.y, z + other.z);
}