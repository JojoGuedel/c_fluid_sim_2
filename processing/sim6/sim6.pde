int sizeX;
int sizeY;

ArrayList<FluidChunk> fluidChunks;

FluidChunk getChunk(int x, int y) {
  x = x / sizeX;
  y = y / sizeY;
  
  for(var chunk : fluidChunks) {
    if (chunk.posX == x && chunk.posY == y) {
      return chunk;
    }
  }
  
  return null;
}

void step(float dt) {
  for (var chunk : fluidChunks) {
    FluidChunk[] localChunks = new FluidChunk[9];
  }
}

class FluidChunk {
  int posX;
  int posY;
  
  float[] velX;
  float[] velY;
  
  float[] density;
  float[] density0;
  
  void diffuse() {
    
  }
  
  void solve() {
    
  }
}
