int sizeX;
int sizeY;

ArrayList<FluidChunk> fluidChunks;

int IX(int posX, int posY) {
  return posX + posY * sizeX;
}

FluidCell getCell(int posX, int posY) {
  posX= (posX / sizeX) * sizeX;
  posY = (posY / sizeY) * sizeY;

  for (int i = 0; i < fluidChunks.size(); i++) {
    if (fluidChunks.get(i).contains(posX, posY))
      return fluidChunks.get(i).getCell(posX, posY);
  }

  return null;
}

FluidChunk getChunk(int x, int y) {
  x = (x / sizeX) * sizeX;
  y = (y / sizeY) * sizeY;

  for (var chunk : fluidChunks) {
    if (chunk.posX == x && chunk.posY == y) {
      return chunk;
    }
  }

  return null;
}

void tick(float dt) {
  for (var chunk : fluidChunks) {
  }
}

class FluidChunk {
  int posX;
  int posY;

  FluidCell[] cells;

  FluidChunk(int posX, int posY) {
    this.posX = posX;
    this.posY = posY;

    // init cells
    cells = new FluidCell[sizeX * sizeY];

    for (int x = posX; x < posX + sizeX; x++) {
      for (int y = posY; y < posY + sizeY; y++) {
        cells[IX(x - posX, y - posY)] = new FluidCell(x, y);
      }
    }
  }

  boolean contains(float posX, float posY) {
    if (posX < this.posX || posX >= this.posX + sizeX)
      return false;

    if (posY < this.posY || posY >= this.posY + sizeY)
      return false;

    return true;
  }

  FluidCell getCell(int posX, int posY) {
    if (contains(posX, posY))
      return cells[IX(posX - this.posX, posY - this.posY)];
    else
      return getCell(posX, posY);
  }

  void tick(float dt) {
    
    for (int y = 0; y < sizeY; y++)
      for (int x = 0; x < sizeX; x++)
        moveVel(x, y, dt);
  }

  void moveVel(int x, int y, float dt) {
    // calculate the distance traveled
    float dsx = dt * cells[IX(x, y)].vx0;
    float dsy = dt * cells[IX(x, y)].vy0;
    
    // calculate the new position
    float targetX = posX + x - dsx;
    float targetY = posY + y - dsy;
    
    // calculate the positions
    // left side
    int L = floor(targetX);
    // right side
    int R = L + 1;
    // top side
    int T = floor(targetY);
    // bottom side
    int B = T + 1;
    
    // get the cells
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
    cells[IX(x, y)].vx =
      weightL * (weightT * LT.vx0 + weightB * LB.vx0) +
      weightR * (weightT * RT.vx0 + weightB * RB.vx0);
    
    cells[IX(x, y)].vy =
      weightL * (weightT * LT.vy0 + weightB * LB.vy0) +
      weightR * (weightT * RT.vy0 + weightB * RB.vy0);
  }
  
  void solveVel(int x, int y, int precision) {
    for (int i = 0; i < precision; i++) {
      modify[IX(x, y)] = 
        (modify0[IX(x, y)] +
        a * (
         modify[IX(x + 1, y)] +
         modify[IX(x - 1, y)] +
         modify[IX(x, y + 1)] +
         modify[IX(x, y + 1)])
    }
  }

  void diffuse() {
  }
}

class FluidCell {
  int x;
  int y;

  float vx, vx0;
  float vy, vy0;

  float d, d0;

  FluidCell(int posX, int posY) {
    x = posX;
    y = posY;

    vx = vx0 = 0;
    vy = vy0 = 0;
    d = d0 = 0;
  }
}
