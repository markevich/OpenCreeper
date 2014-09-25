part of zei;

class Vector2 {
  num x, y;

  Vector2(this.x, this.y);
  Vector2.empty() : this(0, 0);

  Vector2 operator +(Vector2 other) => new Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => new Vector2(x - other.x, y - other.y);
  Vector2 operator *(num other) => new Vector2(x * other, y * other);
  Vector2 operator /(num other) => new Vector2(x / other, y / other);
  bool operator ==(Vector2 other) => (x == other.x && y == other.y);

  String toString() {
    return "$x/$y";
  }

  /**
   * Returns the distance from one vector to another
   */
  num distanceTo(Vector2 other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }
  
  /**
   * Returns the magnitute of the current vector
   */
  num magnitude() {
    return new Vector2.empty().distanceTo(this);
  }
  
  // returns absolute angle to another Vector2 in degrees
  num angleTo(Vector2 other) {   
    return radToDeg(atan2(other.y - y, other.x - x));
  }
  
  /**
   * Normalizes the current vector
   */
  Vector2 normalize() {   
    var mag = magnitude();
    return new Vector2(x / mag, y / mag);
  }
  
  /**
   * Clamps a vector to an absolute max value
   */
  Vector2 clamp(Vector2 max) {
    if (x.abs() > max.x.abs())
      x = max.x;
    if (y.abs() > max.y.abs())
      y = max.y;
    return this;
  }
  
  // 2 vectors facing same direction > 0, perpendicular = 0, different direction < 0
  num dotProduct(Vector2 other) {
    return (x * other.x + y * other.y);
  }
  
  // calculates a perpendicular Vector2
  Vector2 getNormal() {
    return new Vector2(y, -x);    
  }
  
  Vector2 negate() {
   return new Vector2(-x, -y);
  }
}

class Vector3 {
  num x, y, z;

  Vector3(this.x, this.y, this.z);

  Vector3 operator +(Vector3 other) => new Vector3(x + other.x, y + other.y, z + other.z);
}