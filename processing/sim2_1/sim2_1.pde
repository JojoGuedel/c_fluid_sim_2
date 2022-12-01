void evaluate() {
  // TODO: cache dt for every particle
  float sim_t = 0;
  float min_dt = delta_time;
  int sim_steps = 0;

  Particle co1;
  Particle co2;

  // simulate for the durration of delta_t
  while (sim_t < delta_time) {
    co1 = null;
    co2 = null;

    // TODO: just modify tree instead of rebuilding it every time
    tree.clear();
    for (int i = 0; i < particles.length; i++)
      tree.add(particles[i], particles[i].area());

    // check collisions for all particles
    for (int i = 0; i < particles.length; i++) {
      Particle part = particles[i];
      // check particle-particle collisions
      ArrayList<Particle> elements = tree.get(part.area());

      // find the next collision with another particle
      if (elements.size() > 1) {
        for (int j = 0; j < elements.size(); j++) {
          Particle other = elements.get(j);
          if (part.vel == other.vel && part.pos == other.pos && part.m == other.m && part.r == other.r)
            continue;
          
          float tc = part.check_collision(other);
          
          if (tc < TOLERANCE)
            continue;

          if (DEBUG_PREDICTION) {
            noStroke();
            fill(10, 200, 150, 255);
            ellipse(part.pos.x + part.vel.x * tc, part.pos.y + part.vel.y * tc, 2 * part.r, 2 * part.r);
            
            // fill(255, 10, 10, 50);
            // ellipse(other.pos.x + other.vel.x * tc, other.pos.y + other.vel.y * tc, 2 * other.r, 2 * other.r);
          }

          if (tc > min_dt)
            continue;

          min_dt = tc;
          co1 = part;
          co2 = other;
        }
      }
    }

    // update position of all particles
    for (Particle part : particles) {
      part.simulate_velocity(min_dt);

      // slow things down
      part.vel.mult(VISCOSITY);
    }

    // calculate the velocity after the next collision
    if (co1 != null){
      co1.collide(co2);
    }

    // keep track of the sim_step count
    sim_steps += 1;

    // keep track of the simulated time
    sim_t += min_dt;
    min_dt = delta_time - sim_t;
  }
}

void setup() {
  size(500, 500);

  tree = new QuadTree(new Area(0, 0, WIDTH, HEIGHT), QUADTREE_LAYERS);
  
  particles = new Particle[PARTICLE_COUNT];
  // particles[0] = new Particle(5, 10, new PVector(100, 100), new PVector(100, 0));
  // particles[1] = new Particle(10, 10, new PVector(260, 100), new PVector(0, 0));
  
  // for (int y = 0; y < PARTICLE_COUNT; y++) {
  //   for (int x = 0; x < PARTICLE_COUNT; x++) {
  //     particles[x + y * PARTICLE_COUNT] = new Particle(PARTICLE_SIZE, 1, new PVector((x + 0.5) * (width / PARTICLE_COUNT), (y + 0.5) * (height / PARTICLE_COUNT)), new PVector(0, 0));
  //   }
  // }
  
  for (int i = 0; i < PARTICLE_COUNT; i++)
    particles[i] = new Particle(PARTICLE_SIZE, 1, new PVector(WIDTH, HEIGHT).add(PVector.random2D(this).mult(WIDTH / 2)), PVector.random2D(this).mult(100)); 
}

void draw() {
  background(255);
  
  stroke(0);
  
  evaluate();
  
  for (Particle part : particles) {
    part.draw();
    part.area().draw();
  }
}

void mouseDragged() {
  Area mouse_area = new Area(mouseX - 20, mouseY - 20, 40, 40);
  
  PVector dv = new PVector(mouseX - pmouseX, mouseY - pmouseY).mult(DRAG_MULT);
  
  ArrayList<Particle> elements = tree.get(mouse_area);
  for (int i = 0; i < elements.size(); i++) {
    if (mouse_area.overlaps(elements.get(i).area()))
      elements.get(i).vel.add(dv);
  }
  
  mouse_area.draw();
}
