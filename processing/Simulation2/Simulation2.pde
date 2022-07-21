class FluidWorld {
  float scale;
  PVector offset;

  ArrayList<FluidChunk> chunks;
  PVector chunkSize;

  float diffusion;
  float viscosity;

  public FluidWorld(PVector chunkSize, float diffusion, float viscosity) {
    scale = 2.0f;
    offset = new PVector(1, 5);
    
    chunks = new ArrayList<FluidChunk>();
    
    this.chunkSize = chunkSize;
    this.diffusion = diffusion;
    this.viscosity = viscosity;
  }

  public float toWorld(float val) {
    return val * scale;
  }

  public float toScreen(float val) {
    return val / scale;
  }

  public PVector toWorld(PVector val) {
    return val.copy().add(offset).mult(scale);
  }

  public PVector toScreen(PVector val) {
    return val.copy().div(scale).sub(offset);
  }

  public void drag(PVector deltaVec) {
    offset.add(deltaVec);
  }

  public FluidChunk newChunk(PVector pos) {
    pos.x = int(pos.x / chunkSize.x) * chunkSize.x;
    pos.y = int(pos.y / chunkSize.y) * chunkSize.y;

    FluidChunk chunk = new FluidChunk(this, pos, chunkSize, 10, diffusion, viscosity);
    chunks.add(chunk);
    return chunk;
  }

  public FluidCell getCell(PVector pos) {
    for (int i = 0; i < chunks.size(); i++) {
      if (chunks.get(i).contains(pos)) {
        return chunks.get(i).getCell(pos);
      }
    }
    
    return newChunk(pos).getCell(pos);
  }
  
  void addDensity(PVector pos, float amount) {
    FluidCell c = getCell(pos);
    c.density += amount;
    
    for (int i = 0; i < chunks.size(); i++) {
      if (chunks.get(i).contains(pos)) {
        chunks.get(i).active = true;
        return;
      }
    }
  }
  
  public void tick() {
    for (int i = 0; i < chunks.size(); i++) {
      if (chunks.get(i).active) {
        chunks.get(i).tick(0.00001f);
      }
    }
  }
  
  public void render() {
    for (int i = 0; i < chunks.size(); i++) {
      if (chunks.get(i).active) {
        FluidChunk chunk = chunks.get(i);
        
        for (int y = (int)chunk.pos.y; y < chunk.pos.y + chunk.pos.y + chunk.size.y; y++) {
          for (int x = (int)chunk.pos.x; x < chunk.pos.x + chunk.pos.x + chunk.size.x; x++) {
            PVector pos = new PVector(x, y);
            PVector sPos = toScreen(pos);
            
            println("render");
            
            noStroke();
            fill(255, 255, 255, getCell(pos).density / 10);
            rect(sPos.x, sPos.y, toScreen(1), toScreen(1));
          }
        }
      }
    }
  }
}

class FluidChunk {  
  PVector pos;
  PVector size;
  boolean active;

  int iterations;

  float diffusion;
  float viscosity;

  FluidWorld world;
  FluidCell[] fluidField;

  public FluidChunk(FluidWorld world, PVector pos, PVector size, int iterations, float diffusion, float viscosity) {
    this.pos = pos;
    this.size = size;
    
    active = false;
    
    this.iterations = iterations;

    this.diffusion = diffusion;
    this.viscosity = viscosity;
    
    this.world = world;

    fluidField = new FluidCell[(int)size.x * (int)size.y];
    for (int i = 0; i < fluidField.length; i++) {
      fluidField[i] = new FluidCell();
    }
  }

  public boolean contains(PVector pos) {
    if (pos.x < this.pos.x)
      return false;
    if (pos.x >= this.pos.x + size.x)
      return false;

    if (pos.y < this.pos.y)
      return false;
    if (pos.y >= this.pos.y + size.y)
      return false;

    return true;
  }

  public FluidCell getCell(PVector pos) {
    if (contains(pos)) {
      pos.sub(this.pos);
      return fluidField[(int)pos.x + (int)pos.y * (int)size.y];
    } else {
      return world.getCell(pos);
    }
  }

  public void diffuse(PVector pos, float dt) {
    float a = dt * diffusion * (size.x - 2) * (size.y - 2);
    float c = 1.0f / (1.0f + 4.0f * a);

    FluidCell x = getCell(pos);
    x.density = c * (x.density0 + a * (
      getCell(pos.copy().add(vRG)).density +
      getCell(pos.copy().add(vLF)).density +
      getCell(pos.copy().add(vUP)).density +
      getCell(pos.copy().add(vDW)).density));
    
    if (x.density > 0)
      active = true;
  }

  public void tick(float dt) {
    active = false;
    
    for (int i = 0; i < iterations; i++) {
      for (int y = (int)pos.y; y < pos.y + size.y; y++) {
        for (int x = (int)pos.x; x < pos.x + size.x; x++) {
          diffuse(new PVector(x, y), dt);
        }
      }
    }
  }
}

class FluidCell {
  PVector vel;
  PVector vel0;

  float density;
  float density0;

  public void addVelocity(PVector vel) {
    this.vel.add(vel);
  }

  public void addDensity(float amount) {
    density += amount;
  }

  public FluidCell() {
    vel = new PVector();
    vel0 = new PVector();
    density = 0.0f;
    density0 = 0.0f;
  }
}

final PVector vUP = new PVector(0, 1);
final PVector vDW = new PVector(0, -1);
final PVector vRG = new PVector( 1, 0);
final PVector vLF = new PVector(-1, 1);

FluidWorld f = new FluidWorld(new PVector(10, 10), 0, 0);

PVector pos = new PVector(20, 20);

void setup() {
  size(500, 500);
}

void draw() {
  background(51);

  PVector sPos = f.toScreen(pos);
  
  if (keyPressed) {
    if (key == ' ') {
      f.addDensity(f.toWorld(new PVector(mouseX, mouseY)), 1000);
    }
  }
  
  f.render();
  f.tick();

  rect(sPos.x, sPos.y, f.toScreen(100), f.toScreen(40));
}

void mouseDragged() {
  f.drag(new PVector(pmouseX - mouseX, pmouseY - mouseY));
}

void mouseWheel(MouseEvent event) {
  PVector pos0 = new PVector(mouseX, mouseY);
  PVector wPos = f.toWorld(pos0);
  f.scale *= 1 + (event.getCount() / 10.0f);
  PVector pos1 = f.toScreen(wPos);
  f.offset.add(pos1.sub(pos0));
}
