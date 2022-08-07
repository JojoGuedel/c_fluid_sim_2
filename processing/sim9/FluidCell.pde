class FluidCell { //<>//
  State state;
  int callCount;

  PVector pos;
  PVector vel, vel0;
  float dens, dens0;
  float div, div0;

  FluidCell (PVector pos) {
    state = State.inactive;
    callCount = 0;

    this.pos = new PVector(floor(pos.x), floor(pos.y));
    vel = vel0 = new PVector();
    dens = dens0 = 0;
    div = div0 = 0;
  }

  FluidCell get() {
    callCount++;
    return this;
  }

  void setState() {
    if (callCount <= 0)
      state = State.inactive;
    else
      state = State.passive;
    
    if (vel.mag() > VEL_MIN)
      ; // state = State.max(state, State.active);
    
    if (dens > DENS_MIN)
      state = State.max(state, State.active);
  }

  // reset all necessary values before the tick
  void stage0() {
    callCount = 0;

    p1 = 0;
    p2 = 0;
    p4 = 0;
    p5 = 0;

    vel0 = vel.copy();
    dens0 = dens;
  }

  int p1;
  // diffuse vel
  void stage1(int p, int rc) {
    // only update necessary
    if (p <= p1 || rc >= FILL_LIMIT)
      return;

    p1++;

    // update neighbors if cell is active
    if (state == State.active) {
      getCell(new PVector(pos.x + 1, pos.y), true).get().stage1(p, ++rc);
      getCell(new PVector(pos.x - 1, pos.y), true).get().stage1(p, ++rc);
      getCell(new PVector(pos.x, pos.y + 1), true).get().stage1(p, ++rc);
      getCell(new PVector(pos.x, pos.y - 1), true).get().stage1(p, ++rc);
    }

    // TODO: I don't want to scale by the size anymore
    float a = dt * visc;
    float c = 1 + 4 * a;

    FluidCell R = getCell(new PVector(pos.x + 1, pos.y), false);
    FluidCell L = getCell(new PVector(pos.x - 1, pos.y), false);
    FluidCell B = getCell(new PVector(pos.x, pos.y + 1), false);
    FluidCell T = getCell(new PVector(pos.x, pos.y - 1), false);

    // set vel0
    vel0.x = (vel.x + a * (R.vel0.x + L.vel0.x + B.vel0.x + T.vel0.x)) / c;
    vel0.y = (vel.y + a * (R.vel0.y + L.vel0.y + B.vel0.y + T.vel0.y)) / c;

    // udpate cellState
    setState();
  }

  int p2;
  // project vel
  void stage2(int p, int rc) {
    // only update necessary
    if (p <= p2 || rc >= FILL_LIMIT)
      return;

    p2++;

    FluidCell R = getCell(new PVector(pos.x + 1, pos.y), false);
    FluidCell L = getCell(new PVector(pos.x - 1, pos.y), false);
    FluidCell B = getCell(new PVector(pos.x, pos.y + 1), false);
    FluidCell T = getCell(new PVector(pos.x, pos.y - 1), false);

    div0 = (L.vel0.x - R.vel0.x + T.vel0.y - B.vel0.y);
    div = 0;

    // update neighbors if cell is active
    if (state == State.active) {
      getCell(new PVector(pos.x + 1, pos.y), true).get().stage2(p, ++rc);
      getCell(new PVector(pos.x - 1, pos.y), true).get().stage2(p, ++rc);
      getCell(new PVector(pos.x, pos.y + 1), true).get().stage2(p, ++rc);
      getCell(new PVector(pos.x, pos.y - 1), true).get().stage2(p, ++rc);
    }

    float a = 1;
    float c = 4;

    div = (div0 + a * (R.div + L.div + B.div + T.div)) / c;

    // set vel
    vel.x = vel0.x - (0.5f * (R.div - L.div));
    vel.y = vel0.y - (0.5f * (B.div - T.div));

    setState();
  }

  // move vel
  void stage3() {
    // calculate the distance traveled
    float dsx = dt * vel.x;
    float dsy = dt * vel.y;

    // calculate the new position
    float targetX = pos.x - dsx;
    float targetY = pos.y - dsy;

    // calculate the positions
    int L = floor(targetX);        // L = i0
    int R = L + 1;                 // R = i1
    int B = floor(targetY);        // B = j0
    int T = B + 1;                 // T = j1

    // calculate the offsets to use them as weights
    float weightR = targetX - L;         // weightR = s1
    float weightL = 1.0f - weightR;      // weightL = s0
    float weightT = targetY - B;         // weightT = t1
    float weightB = 1.0f - weightT;      // weightB = t0

    // get the cells
    FluidCell LT = getCell(new PVector(L, T), false);
    FluidCell LB = getCell(new PVector(L, B), false);
    FluidCell RT = getCell(new PVector(R, T), false);
    FluidCell RB = getCell(new PVector(R, B), false);

    // modify the vel0 with subpixel percision
    // this is done with the offset that was calculated before by using it as a weight
    vel0.x =
      weightL * (weightT * LT.vel.x + weightB * LB.vel.x) +
      weightR * (weightT * RT.vel.x + weightB * RB.vel.x);

    vel0.y =
      weightL * (weightT * LT.vel.y + weightB * LB.vel.y) +
      weightR * (weightT * RT.vel.y + weightB * RB.vel.y);

    setState();
  }

  // TODO: this is exactly the same as stage2.
  int p4;
  // project vel
  void stage4(int p, int rc) {
    // only update necessary
    if (p <= p4 || rc >= FILL_LIMIT)
      return;

    p4++;

    FluidCell R = getCell(new PVector(pos.x + 1, pos.y), false);
    FluidCell L = getCell(new PVector(pos.x - 1, pos.y), false);
    FluidCell B = getCell(new PVector(pos.x, pos.y + 1), false);
    FluidCell T = getCell(new PVector(pos.x, pos.y - 1), false);

    div0 = (L.vel0.x - R.vel0.x + T.vel0.y - B.vel0.y);
    div = 0;

    // update neighbors if cell is active
    if (state == State.active) {
      getCell(new PVector(pos.x + 1, pos.y), true).get().stage4(p, ++rc);
      getCell(new PVector(pos.x - 1, pos.y), true).get().stage4(p, ++rc);
      getCell(new PVector(pos.x, pos.y + 1), true).get().stage4(p, ++rc);
      getCell(new PVector(pos.x, pos.y - 1), true).get().stage4(p, ++rc);
    }

    float a = 1;
    float c = 4;

    div = (div0 + a * (R.div + L.div + B.div + T.div)) / c;

    // set vel
    vel.x = vel0.x - (0.5f * (R.div - L.div));
    vel.y = vel0.y - (0.5f * (B.div - T.div));

    setState();
  }

  int p5;
  // diff dens
  void stage5(int p, int rc) {
    // only update necessary
    if (p <= p5 || rc >= FILL_LIMIT)
      return;
    
    if (state == State.inactive)
      return;

    p5++;

    // update neighbors if cell is active
    if (state == State.active) {
      getCell(new PVector(pos.x + 1, pos.y), true).get().stage5(p, ++rc);
      getCell(new PVector(pos.x - 1, pos.y), true).get().stage5(p, ++rc);
      getCell(new PVector(pos.x, pos.y + 1), true).get().stage5(p, ++rc);
      getCell(new PVector(pos.x, pos.y - 1), true).get().stage5(p, ++rc);
    }

    // TODO: I don't want to scale by the size anymore
    float a = dt * diff;
    float c = 1 + 4 * a;

    FluidCell R = getCell(new PVector(pos.x + 1, pos.y), false);
    FluidCell L = getCell(new PVector(pos.x - 1, pos.y), false);
    FluidCell B = getCell(new PVector(pos.x, pos.y + 1), false);
    FluidCell T = getCell(new PVector(pos.x, pos.y - 1), false);

    // set dens0
    dens0 = (dens + a * (R.dens0 + L.dens0 + B.dens0 + T.dens0)) / c;

    // udpate cellState
    setState();
  }

  // move dens
  void stage6() {
    if (state == State.inactive)
      return;
    
    // calculate the distance traveled
    float dsx = dt * vel.x;
    float dsy = dt * vel.y;

    // calculate the new position
    float targetX = pos.x - dsx;
    float targetY = pos.y - dsy;
    
    // calculate the positions
    int L = floor(targetX);        // L = i0
    int R = L + 1;                 // R = i1
    int B = floor(targetY);        // B = j0
    int T = B + 1;                 // T = j1

    // calculate the offsets to use them as weights
    float weightR = targetX - L;         // weightR = s1
    float weightL = 1.0f - weightR;      // weightL = s0
    float weightT = targetY - B;         // weightT = t1
    float weightB = 1.0f - weightT;      // weightB = t0

    // get the cells
    FluidCell LT = getCell(new PVector(L, T), false);
    FluidCell LB = getCell(new PVector(L, B), false);
    FluidCell RT = getCell(new PVector(R, T), false);
    FluidCell RB = getCell(new PVector(R, B), false);

    // modify the dens with subpixel percision
    // this is done with the offset that was calculated before by using it as a weight
    dens =
      weightL * (weightT * LT.dens0 + weightB * LB.dens0) +
      weightR * (weightT * RT.dens0 + weightB * RB.dens0);

    setState();
  }
}
