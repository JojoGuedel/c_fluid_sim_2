final boolean DEBUG_QUADTREE = true;
final boolean DEBUG_PREDICTION = false;
final boolean DEBUG_VEL = true;

final int WIDTH = 500;
final int HEIGHT = 500;

final float TOLERANCE = 0.0001;
final float VISCOSITY = 0.999;

final int PARTICLE_COUNT = 50;
final int QUADTREE_LAYERS = 6;

final float PARTICLE_AREA_MULT = 5;
final float DRAG_MULT = 10;
final float PARTICLE_SIZE = 3;


float delta_time = 0.01;

Particle[] particles;
QuadTree tree;
