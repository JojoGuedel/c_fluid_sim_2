int sizeX = 10;
int sizeY = 10;

int IX(int x, int y) {
  return x + y * sizeX;
}

void move(float modify[], float modify0[], float[] velX, float[] velY, float dt) {
  for (int y = 0; y < sizeY; y++) {
    for (int x = 0; x < sizeX; x++) {
      // calculate the distance traveled
      float dsx = dt * velX[IX(x, y)];
      float dsy = dt * velY[IX(x, y)];

      // calculate the new position
      float targetX = x - dsx;
      float targetY = y - dsy;

      // TODO: this must be modified to work with chunks
      // contrain the position to avoid out of bounce
      // this is not needed in a chunk system
      targetX = constrain(targetX, 0.5, sizeX - 0.5);
      targetY = constrain(targetY, 0.5, sizeY - 0.5);

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

      // modify the field with subpixel percision
      // this is done with the offset that was calculated before by using it as a weight
      modify[IX(x, y)] =
        weightL * (weightT * modify0[IX(L, T)] + weightB * modify0[IX(L, B)]) +
        weightR * (weightT * modify0[IX(R, T)] + weightB * modify0[IX(R, B)]);
    }
  }
}

void solve(float[] modify, float[] modify0, float a, float c, int percision) {
  // c is the div value, to calculate the weighted avg of the 5 cells
  // a decides how much the other cells are weighted
  for (int p = 0; p < percision; p++) {
    for (int y = 1; y < sizeY - 1; y++)
      for (int x = 1; x < sizeX - 1; x++) {
        modify[IX(x, y)] = 
          (modify0[IX(x, y)] +
          a * (
           modify[IX(x + 1, y)] +
           modify[IX(x - 1, y)] +
           modify[IX(x, y + 1)] +
           modify[IX(x, y + 1)])
         ) / c /*(1 + 4.0f * diff_rate_dt)*/;
      }
    // fluid_set_boundaries(fluid_target, width, height);
  }
}
