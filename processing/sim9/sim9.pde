final int SIZE = 10;
final int PRECISION = 10;

final float VEL_MIN = 70;
final float DENS_MIN = 1;

final float CHUNK_LIMIT = 100;
final float FILL_LIMIT = 1;

ArrayList<FluidChunk> chunks;

float dt = 0.01;
float diff = 1;
float visc = 10;
    
float scale = 0.1;
PVector offset = new PVector(); 

enum State {
  inactive(0), // does not get updated or anything
    passive(1), // gets updated by others but cannot update others (values are below tolerance)
    active(2); // can updates others             

  int p;

  private State(int p) {
    this.p = p;
  }

  public static State max(State a, State b) {
    if (a.p > b.p)
      return a;

    return b;
  }
}

FluidCell getCell(PVector pos, boolean force) {
  for (FluidChunk chunk : chunks) {
    if (chunk.contains(pos))
      return chunk.getCell(pos);
  }

  if (!force || chunks.size() == CHUNK_LIMIT)
    return new FluidCell(pos);

  FluidChunk c = new FluidChunk(pos);
  chunks.add(c);
  return c.getCell(pos);
}

void addDens(PVector pos, float amount) {
  getCell(pos, true).dens += amount;
}

void addVel(PVector pos, PVector vel) {
  getCell(pos, true).vel.add(vel);
}

void tick() {
  for (int i = 0; i < chunks.size(); i++)
    chunks.get(i).stage0();

  for (int i = 0; i < chunks.size(); i++)
    chunks.get(i).stage1();

  for (int i = 0; i < chunks.size(); i++)
    chunks.get(i).stage2();

  for (int i = 0; i < chunks.size(); i++)
    chunks.get(i).stage3();

  for (int i = 0; i < chunks.size(); i++)
    chunks.get(i).stage4();

  for (int i = 0; i < chunks.size(); i++)
    chunks.get(i).stage5();

  for (int i = 0; i < chunks.size(); i++)
    chunks.get(i).stage6();

  for (int i = 0; i < chunks.size(); i++)
    if (chunks.get(i).stage7()) i--;
}

float toWorld(float val) {
  return val * scale;
}

PVector toWorld(PVector val) {
  return val.copy().add(offset).mult(scale);
}

float toScreen(float val) {
  return val / scale;
}

PVector toScreen(PVector val) {
  return val.copy().div(scale).sub(offset);
}

void setup() {
  size(800, 700);

  chunks = new ArrayList<FluidChunk>();
}

void draw() {
  background(255);

  // PVector pos = new PVector(20, 20);
  // PVector sPos = toScreen(pos);
  // rect(sPos.x, sPos.y, toScreen(100), toScreen(40));

  // stroke(0, 0, 255);
  // ellipse(mouseX, mouseY, 10, 10);

  tick();

  for (int i = 0; i < chunks.size(); i++)
    chunks.get(i).render();
}

void keyPressed() {
  switch (key) {
  case ' ':
    {
      float vx = (mouseX - pmouseX) * scale * 10000;
      float vy = (mouseY - pmouseY) * scale * 10000;

      addDens(toWorld(new PVector(mouseX, mouseY)), 1000);
      addVel(toWorld(new PVector(mouseX, mouseY)), new PVector(vx, vy));
    }
    break;
  }
}

void mouseDragged() {
  offset.x += pmouseX - mouseX;
  offset.y += pmouseY - mouseY;
}

void mouseWheel(MouseEvent event) {
  PVector pos0 = new PVector(mouseX, mouseY);
  PVector wPos = toWorld(pos0);
  scale *= 1 + (event.getCount() / 10.0f);
  PVector pos1 = toScreen(wPos);
  offset.add(pos1.sub(pos0));
}
