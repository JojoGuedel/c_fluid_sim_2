int sizeX;
int sizeY;

float visc;
float diff;
float dt;

ArrayList<FluidCell> fluidCells;

FluidCell getCell(int x, int y) {
  // TODO: find a algorythm that doesn't have to search the whole array
  for (FluidCell fluidCell : fluidCells) {
    if (fluidCell.posX == x && fluidCell.posY == y) {
      return fluidCell;
    }
  }

  return null;
}

class FluidCell {
  int posX, posX0;
  int posY, posY0;

  float velX, velX0;
  float velY, velY0;
  
  float div, div0;

  float density;
  float density0;

  FluidCell(int posX, int posY) {
    this.posX = posX0 = posX;
    this.posY = posY0 = posY;

    velX = velX0 = 0;
    velY = velY0 = 0;

    density = density0 = 0;
  }
  
  void step() {
    diffuse(1, visc);
    diffuse(2, visc);
    
    project(Vx0, Vy0, Vx, Vy);
    
    move(1);
    move(2);
    
    project(Vx, Vy, Vx0, Vy0);
    
    diffuse(0, diff);
    move(0);
  }
  
  void diffuse(int mode, float diff) {
    float a = dt * diff * (sizeX - 2) * (sizeY - 2);
    solve(mode, a, 1 + 4 * a);
  }
  
  void solve(int mode, float a, float c) {
    // c is the div value, to calculate the weighted avg of the 5 cells
    // a decides how much the other cells are weighted
    float L, R, B, T;
    FluidCell LCell = getCell(posX - 1, posY);
    FluidCell RCell = getCell(posX + 1, posY);
    FluidCell BCell = getCell(posX, posY + 1);
    FluidCell TCell = getCell(posX, posY - 1);


    switch(mode) {
    case 0:
      L = LCell == null? 0 : LCell.density;
      R = RCell == null? 0 : RCell.density;
      B = BCell == null? 0 : BCell.density;
      T = TCell == null? 0 : TCell.density;

      density = (density0 + a * (L + R + B + T)) / c;
      break;
    case 1:
      L = LCell == null? 0 : LCell.velX;
      R = RCell == null? 0 : RCell.velX;
      B = BCell == null? 0 : BCell.velX;
      T = TCell == null? 0 : TCell.velX;

      velX = (velX0 + a * (L + R + B + T)) / c;
      break;
    case 2:
      L = LCell == null? 0 : LCell.velY;
      R = RCell == null? 0 : RCell.velY;
      B = BCell == null? 0 : BCell.velY;
      T = TCell == null? 0 : TCell.velY;

      velY = (velY0 + a * (L + R + B + T)) / c;
      break;
    case 3:
      L = LCell == null? 0 : LCell.div;
      R = RCell == null? 0 : RCell.div;
      B = BCell == null? 0 : BCell.div;
      T = TCell == null? 0 : TCell.div;

      div = (div0 + a * (L + R + B + T)) / c;
      break;
    }
  }

  void move(int mode) {
    // calculate the distance traveled
    float dsx = dt * velX;
    float dsy = dt * velY;

    // calculate the new position
    float targetX = posX - dsx;
    float targetY = posY - dsy;

    // TODO: this stuff can be cached
    // calculate the positions
    // left side
    int L = floor(targetX);
    // right side
    int R = L + 1;
    // top side
    int T = floor(targetY);
    // bottom side
    int B = T + 1;

    // offset to the right side
    float weightR = targetX - L;
    // offset to the left side
    float weightL = 1.0f - weightR;
    // offset to the bottom side
    float weightB = targetY - T;
    // offset to the top side
    float weightT = 1.0f - weightB;

    float LT, LB, RT, RB;
    FluidCell LTCell = getCell(L, T);
    FluidCell LBCell = getCell(L, B);
    FluidCell RTCell = getCell(R, T);
    FluidCell RBCell = getCell(R, B);

    switch(mode) {
    case 0:
      LT = LTCell == null? 0 : LTCell.density0;
      LB = LBCell == null? 0 : LBCell.density0;
      RT = LTCell == null? 0 : RTCell.density0;
      RB = LBCell == null? 0 : RBCell.density0;

      density =
        weightL * (weightT * LT + weightB * LB) +
        weightR * (weightT * RT + weightB * RB);
      break;
    case 1:
      LT = LTCell == null? 0 : LTCell.velX0;
      LB = LBCell == null? 0 : LBCell.velX0;
      RT = LTCell == null? 0 : RTCell.velX0;
      RB = LBCell == null? 0 : RBCell.velX0;

      velX =
        weightL * (weightT * LT + weightB * LB) +
        weightR * (weightT * RT + weightB * RB);
      break;
    case 2:
      LT = LTCell == null? 0 : LTCell.velY0;
      LB = LBCell == null? 0 : LBCell.velY0;
      RT = LTCell == null? 0 : RTCell.velY0;
      RB = LBCell == null? 0 : RBCell.velY0;

      velY =
        weightL * (weightT * LT + weightB * LB) +
        weightR * (weightT * RT + weightB * RB);
      break;
    }
  }
  
  void project1() {
    float L, R, B, T;
    FluidCell LCell = getCell(posX - 1, posY);
    FluidCell RCell = getCell(posX + 1, posY);
    FluidCell BCell = getCell(posX, posY + 1);
    FluidCell TCell = getCell(posX, posY - 1);
    
    L = LCell == null? 0 : LCell.velX;
    R = RCell == null? 0 : RCell.velX;
    B = BCell == null? 0 : BCell.velY;
    T = TCell == null? 0 : TCell.velY;
    
    // calculate the divergence
    // x and y are averaged and then added
    // they can be added because it is independendt of the axsis
    // this stuff is then scaled by the size (I don't know why, it's convertet right back and it works with out it)
    div = -0.5f*(R - L + B - T);
    div0 = 0;
    
    solve(3, 1, 4);
  }
  
  void project2() {
    float L, R, B, T;
    FluidCell LCell = getCell(posX - 1, posY);
    FluidCell RCell = getCell(posX + 1, posY);
    FluidCell BCell = getCell(posX, posY + 1);
    FluidCell TCell = getCell(posX, posY - 1);
    
    L = LCell == null? 0 : LCell.div0;
    R = RCell == null? 0 : RCell.div0;
    B = BCell == null? 0 : BCell.div0;
    T = TCell == null? 0 : TCell.div0;
    
    velX -= 0.5f * (R - L);
    velY -= 0.5f * (B - T);
  }
}
