class Area {
  PVector pos;
  PVector size;
  
  Area() {
    pos = new PVector();
    size = new PVector();
  }
  
  Area(float x, float y, float w, float h) {
    if (w < 0) {
      x += w;
      w = -w;
    }
    if (h < 0) {
      y += h;
      h = -h;
    }
    
    pos = new PVector(x, y);
    size = new PVector(w, h);
  }
  
  Area(PVector pos, PVector size) {
    this.pos = pos;
    this.size = size;
  }
  
  boolean contains(Area other) {
    return (other.pos.x >= this.pos.x) && (other.pos.x + other.size.x < this.pos.x + this.size.x) && (other.pos.y >= this.pos.y) && (other.pos.y + other.size.y < this.pos.y + this.size.y);
  }
  
  boolean overlaps(Area other) {
    return (this.pos.x < other.pos.x + other.size.x && this.pos.x + this.size.x >= other.pos.x && this.pos.y < other.pos.y + other.size.y && this.pos.y + this.size.y >= this.pos.y);
  }
  
  void draw() {
    noFill();
    stroke(0);
    strokeWeight(1);
    // ellipse(pos.x, pos.y, 10, 10);
    rect(pos.x, pos.y, size.x, size.y);
  }
}
