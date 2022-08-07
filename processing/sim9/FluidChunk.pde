class FluidChunk {
  PVector pos;
  State state;

  FluidCell[] cells;

  FluidChunk(PVector pos) {
    this.pos = new PVector(
      floor(pos.x / SIZE) * SIZE,
      floor(pos.y / SIZE) * SIZE);
    state = State.inactive;

    cells = new FluidCell[SIZE * SIZE];

    for (int y = 0; y < SIZE; y++)
      for (int x = 0; x < SIZE; x++)
        cells[IX(new PVector(x, y))] = new FluidCell(new PVector(this.pos.x + x, this.pos.y + y));
  }
 //<>//
  int IX(PVector pos) {
    return floor(pos.x) + floor(pos.y) * SIZE;
  }

  boolean contains(PVector pos) {
    PVector tPos = new PVector(floor(pos.x), floor(pos.y));
    if (tPos.x < this.pos.x || tPos.x >= this.pos.x + SIZE)
      return false;
    if (tPos.y < this.pos.y || tPos.y >= this.pos.y + SIZE)
      return false;

    return true;
  }

  // TODO: this might cause problems because of the same name. PLS check if this works
  FluidCell getCell(PVector pos) {
    if (contains(pos)){
      int ix= IX(new PVector(pos.x - this.pos.x, pos.y - this.pos.y));
      FluidCell temp = cells[ix];
      return temp;
    }

    return sim9.this.getCell(pos, false);
  }

  void setState() {
    state = State.inactive;

    for (int i = 0; i < SIZE * SIZE; i++) {
      state = State.max(state, cells[i].state);

      if (state == State.active)
        break;
    }
  }

  // reset all necessary values before the tick
  void stage0() {
    for (int i = 0; i < SIZE * SIZE; i++)
      cells[i].stage0();
  }

  // diffuse vel
  void stage1() {
    for (int p = 1; p <= PRECISION; p++)
      for (int i = 0; i < SIZE * SIZE; i++)
        cells[i].stage1(p, 0);
  }

  // project vel
  void stage2() {
    for (int p = 1; p <= PRECISION; p++)
      for (int i = 0; i < SIZE * SIZE; i++)
        cells[i].stage2(p, 0);
  }

  // move vel
  void stage3() {
    for (int i = 0; i < SIZE * SIZE; i++)
      cells[i].stage3();
  }

  // project vel
  void stage4() {
    for (int p = 1; p <= PRECISION; p++)
      for (int i = 0; i < SIZE * SIZE; i++)
        cells[i].stage4(p, 0);
  }

  // diffuse dens
  void stage5() {
    for (int p = 1; p <= PRECISION; p++)
      for (int i = 0; i < SIZE * SIZE; i++)
        cells[i].stage5(p, 0);
  }

  // move dens
  void stage6() {
    for (int i = 0; i < SIZE * SIZE; i++)
      cells[i].stage6();
  }

  // clean up
  boolean stage7() {
    setState();

    if (state == State.inactive) {
      chunks.remove(this);
      return true;
    }

    return false;
  }

  void render() {
    for (int y = 0; y < SIZE; y++) {
      for (int x = 0; x < SIZE; x++) {
        FluidCell cell = cells[IX(new PVector(x, y))];
        PVector sPos = toScreen(new PVector(pos.x + x, pos.y + y));

        noStroke();
        fill(255, 255, 255, cell.dens);
        rect(sPos.x, sPos.y, 1 / scale, 1 / scale);

        if(cell.state == State.inactive)
          stroke(255, 0, 0);
        else if (cell.state == State.passive)
          stroke(255, 255, 0);
        else if (cell.state == State.active)
          stroke(0, 255, 0);
        line(sPos.x, sPos.y, sPos.x + toScreen(cell.vel.x / 100), sPos.y + toScreen(cell.vel.y / 100));
      }
    }
  }
}
