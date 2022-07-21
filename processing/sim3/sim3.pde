float[] getSection(float[] a, PVector aSize, PVector pos, PVector size) {
  if (pos.x + size.x < 0 || pos.x + size.x >= aSize.x)
    return null;
  if (pos.y + size.y < 0 || pos.y + size.y >= aSize.y)
    return null;

  float[] ret = new float[int(size.x * size.y)];
  
  for (int y = 0; y < size.y; y++) {
    for (int x = 0; x < size.x; x++) {
      ret [int(x + y * size.x)] = a[int(x + pos.x + y*aSize.x)];
    }
  }
  
  return ret;
}

void setSection(float[] a, PVector aSize, float[]b, PVector bSize, PVector pos) {
  if (pos.x + bSize.x < 0 || pos.x + bSize.x >= aSize.x)
    return;
  if (pos.y + bSize.y < 0 || pos.y + bSize.y >= aSize.y)
    return;
  
  for (int y = 0; y < bSize.y; y++) {
    for (int x = 0; x < bSize.x; x++) {
      a[int(x + pos.x + y*aSize.x)] = b[int(x + y*bSize.x)];
    }
  }
}

class FluidWorld {
  float scale;
  PVector offset;

  ArrayList<FluidChunk> chunks;
  PVector chunkSize;

  public FluidWorld(PVector chunkSize) {
    scale = 2.0f;
    offset = new PVector(1, 5);
    
    chunks = new ArrayList<FluidChunk>();
    
    this.chunkSize = chunkSize;
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
  
  public void tick() {
  }
  
  public void render() {
  }
  
  public void addDensity(PVector pos, float amount) {
    for (int i = 0; i < chunks.size(); i++) {
      if (chunks.get(i).contains(pos)) {
        chunks.get(i).addDensity(pos, amount);
        return;
      }
    }
    
    PVector cPos = new PVector(floor(pos.x / chunkSize.x) * chunkSize.x, floor(pos.y / chunkSize.y) * chunkSize.y);
    FluidChunk chunk = new FluidChunk(this, cPos, chunkSize);
    chunk.addDensity(pos, amount);
    chunks.add(chunk);
  }
}

class FluidChunk {  
  PVector pos;
  PVector size;
  
  boolean isEmpty;
  
  FluidField fluidField;

  public FluidChunk(FluidWorld world, PVector pos, PVector size) {
    this.pos = pos;
    this.size = size;
    
    isEmpty = true;
    fluidField = new FluidField(int(size.x), 10, 0.001, 0, 0.01);
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
  
  public void addDensity(PVector pos, float amount) {
    fluidField.addDensity(int(pos.x - size.x), int(pos.y - size.y), amount);
  }
  
  public void updateData() {
    
  }
}

class FluidField {
  int size;
  int iter;
  float dt;
  float diff;
  float visc;

  float[] density0;
  float[] density;

  float[] Vx;
  float[] Vy;

  float[] Vx0;
  float[] Vy0;

  public FluidField(int size, int iter, float diffusion, float viscosity, float dt) {
    int N = size;

    this.size = size;
    this.iter = iter;
    this.dt = dt;
    this.diff = diffusion;
    this.visc = viscosity;

    density0 = new float[N * N];
    density = new float[N * N];

    Vx = new float[N * N];
    Vy = new float[N * N];

    Vx0 = new float[N * N];
    Vy0 = new float[N * N];
  }
  
  int IX(int x, int y) {
    return x + y * size;
  }
  
  public void addDensity(int x, int y, float amount) {
    density[IX(x, y)] += amount;
  }
}

final PVector vUP = new PVector(0, 1);
final PVector vDW = new PVector(0, -1);
final PVector vRG = new PVector( 1, 0);
final PVector vLF = new PVector(-1, 1);

FluidWorld f = new FluidWorld(new PVector(10, 10));

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

int sizeX = 10;
int sizeY = 10;

void move(int mode, float modify[], float modify0[], float[] velx, float[] velY, float dt) {
  for (int y = 0; y < sizeY; y++) {
    for (int x = 0; x < sizeX; x++) {
      
    }
  }
}
