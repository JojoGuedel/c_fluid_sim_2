class FluidCell {
  FluidCell L;
  FluidCell R;
  FluidCell U;
  FluidCell D;

  int x;
  int y;

  float vx, vx0;
  float vy, vy0;

  float den, den0;
  float div, div0;

  int state;

  int step;
  int subStep;

  boolean del;

  FluidCell(int x, int y) {
    this.x = x;
    this.y = y;

    vx = vx0 = 0;
    vy = vy0 = 0;

    den = den0 = 0;
    div = div0 = 0;

    state = 0;

    step = 0;
    subStep = 0;

    del = false;

    L = getCell(x - 1, y);
    if (L != null) L.R = this;

    R = getCell(x + 1, y);
    if (R != null) R.L = this;

    U = getCell(x, y - 1);
    if (U != null) U.D = this;

    D = getCell(x, y + 1);
    if (D != null) D.U = this;
  }

  void destroy() {
    if (L != null) L.R = null;
    if (R != null) R.L = null;
    if (U != null) U.D = null;
    if (D != null) D.U = null;

    fluidCells.remove(this);
  }

  void tick() {
    switch(step) {
    case 0:
      for (int j = 0; j < PRECISION; j++) solveVel(j + step * PRECISION);
      step++;

    case 1:
      for (int j = 0; j < PRECISION; j++) solveDiv(j + step * PRECISION);

      moveVel();
      step++;

    case 2:
      for (int j = 0; j < PRECISION; j++) solveDiv(j + step * PRECISION);
      step++;

    case 4:
      for (int j = 0; j < PRECISION; j++) solveDen(j + step * PRECISION);
      moveDen();
      step++;
    }

    state = -1;
    if (den > TOLERANCE || (vx > TOLERANCE || vx < -TOLERANCE) || (vy > TOLERANCE || vy < -TOLERANCE)) {
      state = 1;

      if (L == null) fluidCells.add(L = new FluidCell(x - 1, y));
      else L.state = max(0, L.state);

      if (R == null) fluidCells.add(R = new FluidCell(x + 1, y));
      else R.state = max(0, L.state);

      if (U == null) fluidCells.add(U = new FluidCell(x, y - 1));
      else U.state = max(0, L.state);

      if (D == null) fluidCells.add(D = new FluidCell(x, y + 1));
      else D.state = max(0, L.state);
    }
  }

  void solveVel(int index) {
    if (index != subStep)
      return;
      
    subStep++;

    if (L != null) L.solveVel(subStep - 1);
    if (R != null) R.solveVel(subStep - 1);
    if (U != null) U.solveVel(subStep - 1);
    if (D != null) D.solveVel(subStep - 1);

    vx = (vx0 + av * (
      (R != null? R.vx : 0)+
      (L != null? L.vx : 0) +
      (U != null? U.vx : 0) +
      (D != null? D.vx : 0))) / cv;

    vy = (vy0 + av * (
      (R != null? R.vy : 0)+
      (L != null? L.vy : 0) +
      (U != null? U.vy : 0) +
      (D != null? D.vy : 0))) / cv;
  }

  void solveDen(int index) {
    if (index != subStep)
      return;
    
    subStep++;

    if (L != null) L.solveDen(subStep - 1);
    if (R != null) R.solveDen(subStep - 1);
    if (U != null) U.solveDen(subStep - 1);
    if (D != null) D.solveDen(subStep - 1);

    den0 = (den + ad * (
      (R != null? R.den0 : 0)+
      (L != null? L.den0 : 0) +
      (U != null? U.den0 : 0) +
      (D != null? D.den0 : 0))) / cd;
  }

  void solveDiv(int index) {
    if (index <= subStep)
      return;

    div = -0.5f*(
      (L != null? L.vx : 0) -
      (R != null? R.vx : 0) +
      (U != null? U.vy : 0) -
      (D != null? D.vy : 0));

    subStep++;

    if (L != null) L.solveDiv(subStep - 1);
    if (R != null) R.solveDiv(subStep - 1);
    if (U != null) U.solveDiv(subStep - 1);
    if (D != null) D.solveDiv(subStep - 1);

    div0 =
      (div0 + (
      (R != null? R.div : 0) +
      (L != null? L.div : 0) +
      (U != null? U.div : 0) +
      (D != null? D.div : 0)) / 4);

    vx = 0.5f * ((R != null? R.div0 : 0) - (L != null? L.div0 : 0));
    vy = 0.5f * ((U != null? U.div0 : 0) - (D != null? D.div0 : 0));
  }

  void moveVel() {
    // calculate the distance traveled
    float dsx = dt * vx;
    float dsy = dt * vy;

    // calculate the new position
    float targetX = x - dsx;
    float targetY = y - dsy;

    // calculate the positions
    // left side
    int L = floor(targetX);
    // right side
    int R = L + 1;
    // top side
    int T = floor(targetY);
    // bottom side
    int B = T + 1;

    FluidCell LT = getCell(L, T);
    FluidCell LB = getCell(L, B);
    FluidCell RT = getCell(R, T);
    FluidCell RB = getCell(R, B);

    // offset to the right side
    float weightR = targetX - L;
    // offset to the left side
    float weightL = 1.0f - weightR;
    // offset to the bottom side
    float weightB = targetY - T;
    // offset to the top side
    float weightT = 1.0f - weightB;

    // modify the field with subpixel percision
    // this is done with the offset that was calculated before by using it as a weight
    vx =
      weightL * (weightT * (LT != null? LT.vx0 : 0) + weightB * (LB != null? LB.vx0 : 0)) +
      weightR * (weightT * (RT != null? RT.vx0 : 0) + weightB * (RB != null? RB.vx0 : 0));

    vy =
      weightL * (weightT * (LT != null? LT.vy0 : 0) + weightB * (LB != null? LB.vy0 : 0)) +
      weightR * (weightT * (RT != null? RT.vy0 : 0) + weightB * (RB != null? RB.vy0 : 0));
  }

  void moveDen() {
    // calculate the distance traveled
    float dsx = dt * vx;
    float dsy = dt * vy;

    // calculate the new position
    float targetX = x - dsx;
    float targetY = y - dsy;

    // calculate the positions
    // left side
    int L = floor(targetX);
    // right side
    int R = L + 1;
    // top side
    int T = floor(targetY);
    // bottom side
    int B = T + 1;

    FluidCell LT = getCell(L, T);
    FluidCell LB = getCell(L, B);
    FluidCell RT = getCell(R, T);
    FluidCell RB = getCell(R, B);

    // offset to the right side
    float weightR = targetX - L;
    // offset to the left side
    float weightL = 1.0f - weightR;
    // offset to the bottom side
    float weightB = targetY - T;
    // offset to the top side
    float weightT = 1.0f - weightB;

    // modify the field with subpixel percision
    // this is done with the offset that was calculated before by using it as a weight
    den =
      weightL * (weightT * (LT != null? LT.den0 : 0) + weightB * (LB != null? LB.den0 : 0)) +
      weightR * (weightT * (RT != null? RT.den0 : 0) + weightB * (RB != null? RB.den0 : 0));
  }
}

FluidCell getCell(int x, int y) {
  for (var cell : fluidCells)
    if (cell.x == x && cell.y == y)
      return cell;

  return null;
}

void addDen(int x, int y, float amount) {
  for (FluidCell cell : fluidCells) {
    if (cell.x == x && cell.y == y) {
      cell.den += amount;
      return;
    }
  }

  FluidCell cell = new FluidCell(x, y);
  cell.den += amount;
  fluidCells.add(cell);
}

void addVel(int x, int y, float vx, float vy) {
  for (FluidCell cell : fluidCells) {
    if (cell.x == x && cell.y == y) {
      cell.vx += vx;
      cell.vy += vy;
      return;
    }
  }

  println("Lol");

  FluidCell cell = new FluidCell(x, y);
  cell.vx += vx;
  cell.vy += vy;
  fluidCells.add(cell);
}

final int N = 100;
final int PRECISION = 20;
final float TOLERANCE = 0.000001;

float scale = 5;

ArrayList<FluidCell> fluidCells = new ArrayList<FluidCell>();

float dt;

float diff = 0; // 0.001;
float visc = 0; // 0.001;

float av, cv;
float ad, cd;

void preTick(float dt) {
  this.dt = dt;

  av = dt * visc * N * N; // TODO: this might be wrong
  cv = 1 + 4 * av;

  ad = dt * diff * N * N;
  cd = 1 + 4 * ad;
}

void tick() {
  for (int i = 0; i < fluidCells.size(); i++) {
    fluidCells.get(i).tick();
  }

  for (int i = 0; i < fluidCells.size(); i++) {
    if (fluidCells.get(i).state < 0)
      fluidCells.get(i).destroy();
  }
}

void render() {
  background(51);

  for (FluidCell cell : fluidCells) {
    fill(255, 255, 255, cell.den / 0.0010);
    rect(cell.x * scale, cell.y * scale, scale, scale);
  }
}

void setup() {
  size(500, 500);
  // noStroke();
}

void draw() {
  preTick(0.01);
  tick();

  float s = 0;
  for (FluidCell cell : fluidCells) {
    s += cell.den;
  }

  render();
}

void mouseDragged() {
  int x = int((float)mouseX / scale);
  int y = int((float)mouseY / scale);
  float vx = (mouseX - pmouseX) * 5;
  float vy = (mouseY - pmouseY) * 5;

  addDen(x, y, 1000);
  addVel(x, y, vx, vy);
}
