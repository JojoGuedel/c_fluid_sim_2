class Particle {
  float r;
  float m;

  PVector pos;
  PVector vel;

  Particle(float r, float m, PVector pos, PVector vel) {
    this.r = r;
    this.m = m;
    this.pos = pos;
    this.vel = vel;
  }

  Area area() {
    float dvx = vel.x * delta_time;
    float dvy = vel.y * delta_time;

    float cx = vel.x > 0? -r: r;
    float cy = vel.y > 0? -r: r;

    return new Area(pos.x + cx, pos.y + cy, dvx * PARTICLE_AREA_MULT - 2 * cx, dvy * PARTICLE_AREA_MULT - 2 * cy);
  }

  void simulate_velocity(float dt) {
    pos.x += vel.x * dt;
    pos.y += vel.y * dt;

    if (pos.x > WIDTH)
      pos.x = 0;
    if (pos.x < 0)
      pos.x = WIDTH;

    if (pos.y > HEIGHT)
      pos.y = 0;
    if (pos.y < 0)
      pos.y = HEIGHT;
  }

  void collide(Particle other) {
    PVector n = other.pos.copy().sub(this.pos);
    PVector un = n.copy().div(n.mag());
    PVector ut = new PVector(-un.y, un.x);

    float n1 = un.copy().dot(this.vel);
    float t1 = ut.copy().dot(this.vel);
    float n2 = un.copy().dot(other.vel);
    float t2 = ut.copy().dot(other.vel);

    float n1_a = (n1 * (this.m - other.m) + 2 * other.m * n2) / (this.m + other.m);
    float n2_a = (n2 * (other.m - this.m) + 2 * this.m * n1) / (this.m + other.m);

    PVector v1n = un.copy().mult(n1_a);
    PVector v1t = ut.copy().mult(t1);
    PVector v2n = un.copy().mult(n2_a);
    PVector v2t = ut.copy().mult(t2);

    this.vel = v1n.add(v1t);
    other.vel = v2n.add(v2t);
  }

  float check_collision(Particle other) {
    PVector p1 = this.pos.copy();
    PVector v1 = this.vel.copy();
    float r1 = this.r;

    PVector p2 = other.pos.copy();
    PVector v2 = other.vel.copy();
    float r2 = other.r;

    // (x(vb) - x(va))² + (y(vb) - y(va))²
    float a = (v2.x - v1.x) * (v2.x - v1.x) + (v2.y - v1.y) * (v2.y - v1.y);
    // ((x(B) - x(A)) (x(vb) - x(va)) + (y(B) - y(A)) (y(vb) - y(va))) * 2
    float b = 2 * ((p2.x - p1.x) * (v2.x - v1.x) + (p2.y - p1.y) * (v2.y - v1.y));
    // (x(B) - x(A))² + (y(B) - y(A))² - (ra + rb)²
    float c = (p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y) - (r1 + r2) * (r1 + r2);

    // only real numbers are important
    float D = b * b - 4 * a * c;
    if (D < 0)
      return -1.0;

    // everybodies favorite, the midnight formula
    // (-b + sqrt(b² - 4a c)) / (2a)
    float tc1 = (-b + sqrt(D)) / (2 * a);
    // (-b - sqrt(b² - 4a c)) / (2a)
    float tc2 = (-b - sqrt(D)) / (2 * a);

    // determine the nearest collision in the future
    float tc = (tc2 >= TOLERANCE && (tc2 < tc1 || tc1 <= TOLERANCE)) ? tc2 : tc1;

    if (tc < TOLERANCE)
      return -1.0;

    return tc;
  }

  void draw() {
    fill(200);
    noStroke();
    ellipse(pos.x, pos.y, 2 * r, 2 * r);
    
    if (DEBUG_VEL) {
      colorMode(HSB, 100);
      float a = vel.mag() / 10;
      strokeWeight(1);
      stroke(a, 100, 50);
      line(pos.x, pos.y, pos.x + vel.x / 10, pos.y + vel.y / 10);
      colorMode(RGB, 255);
    }
  }
}
