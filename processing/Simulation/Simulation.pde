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

  public int IX(int x, int y) {
    x = constrain(x, 0, size - 1);
    y = constrain(y, 0, size - 1);
    return y * size + x;
  }

  public void addVel(int x, int y, float amountX, float amountY) {
    Vx[IX(x, y)] += amountX;
    Vy[IX(x, y)] += amountY;
  }

  public void addDen(int x, int y, float amount) {
    density[IX(x, y)] += amount;
  }

  public void diffuse(int b, float[] f, float[] f0, float diff) {
    float a = dt * diff * (size - 2) * (size - 2);
    linSolve(b, f, f0, a, 1 + 4 * a);
  }

  public void linSolve(int b, float[] f, float[] f0, float a, float c) {
    float cRecip = 1.0 / c;
    for (int i = 0; i < iter; i++) {
      for (int y = 1; y < size - 1; y++) {
        for (int x = 1; x < size - 1; x++) {
          f[IX(x, y)] =
            cRecip * (
            f0[IX(x, y)] +
            a * (
            f[IX(x+1, y  )] +
            f[IX(x-1, y  )] +
            f[IX(x, y+1)] +
            f[IX(x, y-1)]));
        }
      }
      setBoundary(b, f);
    }
  }

  public void project(float[] velX, float[] velY, float[] p, float[] div) {
    for (int y = 1; y < size - 1; y++) {
      for (int x = 1; x < size - 1; x++) {
        // calculate the divergence
        // x and y are averaged and then added
        // they can be added because it is independendt of the axsis
        // this stuff is then scaled by the size (I don't know why, it's convertet right back and it works with out it)
        div[IX(x, y)] = -0.5f*(
          velX[IX(x + 1,   y)] -
          velX[IX(x - 1,   y)] +
          velY[IX(  x, y + 1)] -
          velY[IX(  x, y - 1)]
          ) / size;
        
        // p is cleared
        p[IX(x, y)] = 0;
      }
    }

    setBoundary(0, div);
    setBoundary(0, p);
    // p is the avg div
    linSolve(0, p, div, 1, 4);

    for (int y = 1; y < size - 1; y++) {
      for (int x = 1; x < size - 1; x++) {
        velX[IX(x, y)] -= 0.5f * (p[IX(x+1, y)] - p[IX(x-1, y)]) * size;
        velY[IX(x, y)] -= 0.5f * (p[IX(x, y+1)] - p[IX(x, y-1)]) * size;
      }
    }

    setBoundary(1, velX);
    setBoundary(2, velY);
  }

  public void advect(int b, float[] d, float[] d0, float[] velX, float[] velY) {
    float i0, i1, j0, j1;

    // this is so that the cells don't need to be of equal size in x and y direction.
    // I don't need this so I won't have this in my sim
    float dtx = dt * (size - 2);
    float dty = dt * (size - 2);

    float s0, s1, t0, t1;
    float tmp1, tmp2, x, y;

    float Nfloat = size;
    float ifloat, jfloat;
    int i, j;

    for (j = 1, jfloat = 1; j < size - 1; j++, jfloat++) {
      for (i = 1, ifloat = 1; i < size - 1; i++, ifloat++) {
        tmp1 = dtx * velX[IX(i, j)];
        tmp2 = dty * velY[IX(i, j)];
        x    = ifloat - tmp1;
        y    = jfloat - tmp2;

        if (x < 0.5f) x = 0.5f;
        if (x > Nfloat - 0.5f) x = Nfloat - 0.5f;
        i0 = floor(x); // L
        i1 = i0 + 1.0f; // R
        if (y < 0.5f) y = 0.5f;
        if (y > Nfloat - 0.5f) y = Nfloat - 0.5f;
        j0 = floor(y); // B
        j1 = j0 + 1.0f; // T

        // offset to the left side of the cell
        s1 = x - i0;
        // offset to the right side of the cell
        s0 = 1.0f - s1;
        // offset to the bottom side of the cell
        t1 = y - j0;
        // offset to the top side of the cell
        t0 = 1.0f - t1;

        int i0i = (int)i0;
        int i1i = (int)i1;
        int j0i = (int)j0;
        int j1i = (int)j1;

        // modify the field with subpixel percision
        // this is done with the offset that was calculated before by using it as a weight
        d[IX(i, j)] =
          s0 * ( t0 * d0[IX(i0i, j0i)] + t1 * d0[IX(i0i, j1i)]) +
          s1 * ( t0 * d0[IX(i1i, j0i)] + t1 * d0[IX(i1i, j1i)]);
      }
    }
    setBoundary(b, d);
  }

  public void setBoundary(int b, float[] f) {
    for (int i = 1; i < size - 1; i++) {
      f[IX(i, 0)] = b == 2 ? -f[IX(i, 1)] : f[IX(i, 1)];
      f[IX(i, size-1)] = b == 2 ? -f[IX(i, size-2)] : f[IX(i, size-2)];
    }

    for (int j = 1; j < size - 1; j++) {
      f[IX(0, j)] = b == 1 ? -f[IX(1, j)] : f[IX(1, j)];
      f[IX(size-1, j)] = b == 1 ? -f[IX(size-2, j)] : f[IX(size-2, j)];
    }

    f[IX(     0, 0     )] = 0.5f * (f[IX(     1,      0)] + f[IX(     0,      1)] + f[IX(     0,      0)]);
    f[IX(     0, size-1)] = 0.5f * (f[IX(     1, size-1)] + f[IX(     0, size-2)] + f[IX(     0, size-1)]);
    f[IX(size-1, 0     )] = 0.5f * (f[IX(size-2,      0)] + f[IX(size-1,      1)] + f[IX(size-1,      0)]);
    f[IX(size-1, size-1)] = 0.5f * (f[IX(size-2, size-1)] + f[IX(size-1, size-2)] + f[IX(size-1, size-1)]);
  }
  
  void step() {    
    diffuse(1, Vx0, Vx, visc);
    diffuse(2, Vy0, Vy, visc);
    
    project(Vx0, Vy0, Vx, Vy);
    
    advect(1, Vx, Vx0, Vx0, Vy0);
    advect(2, Vy, Vy0, Vx0, Vy0);
    
    project(Vx, Vy, Vx0, Vy0);
    
    diffuse(0, density0, density, diff);
    advect(0, density, density0, Vx, Vy);
  }
}

final int SIZE = 100;
final int ITER = 50;
float scale = 5.0f;

FluidField fluid = new FluidField(SIZE, ITER, 0.0001, 0.0001, 0.01);

void setup() {
  noStroke();
  size(500, 500);
}

void draw() {
  fluid.step();
  
  float s = 0;
  for (int i = 0; i < fluid.density.length; i++) {
    s += fluid.density[i];
  }
  
  println(s);
  
  background(51);
  for (int y = 0; y < fluid.size; y++) {
    for (int x = 0; x < fluid.size; x++) {
      noStroke();
      fill(255, 255, 255, fluid.density[fluid.IX(x, y)] / 10);
      rect(x * scale, y * scale, scale, scale);
      stroke(0, 0, 255);
      line(x * scale, y * scale, scale * (x + fluid.Vx[fluid.IX(x, y)]), scale * (y + fluid.Vy[fluid.IX(x, y)]));
    }
  }
}

void mouseDragged() {
  int x = int((float)mouseX / scale);
  int y = int((float)mouseY / scale);
  float vx = (mouseX - pmouseX) * 5;
  float vy = (mouseY - pmouseY) * 5;
  fluid.addDen(x, y, 1000);
  fluid.addVel(x, y, vx, vy);
}
