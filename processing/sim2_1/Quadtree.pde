class QuadTree {
  int layer;
  Area area;
  QuadTree[] children;
  ArrayList<Particle> elements;
  
  QuadTree(Area area, int layers) {
    layer = layers;
    this.area = area;
    
    // create children
    if (layer > 1) {
      float w = area.size.x / 2;
      float h = area.size.y / 2;
      
      children = new QuadTree[4];
      children[0] = new QuadTree(new Area(area.pos.x    , area.pos.y    , w, h), layers - 1);
      children[1] = new QuadTree(new Area(area.pos.x + w, area.pos.y    , w, h), layers - 1);
      children[2] = new QuadTree(new Area(area.pos.x    , area.pos.y + h, w, h), layers - 1);
      children[3] = new QuadTree(new Area(area.pos.x + w, area.pos.y + h, w, h), layers - 1);
    }
    else {
      children = new QuadTree[0];
    }
    
    elements = new ArrayList<Particle>();
  }
  
  void clear() {
    elements.clear();
    
    for (int i = 0; i < children.length; i++)
      children[i].clear();
  }
  
  boolean add(Particle element, Area area) {
    if (!this.area.contains(area))
      return false;
      
    if (DEBUG_QUADTREE) {
      this.area.draw();
    }
    
    for (int i = 0; i < children.length; i++) {
      if (children[i].area.contains(area)){
        children[i].add(element, area);
        return true;
      }
    }
    
    elements.add(element);
    return true;
  }
  
  ArrayList get_all() {
    ArrayList result = new ArrayList();
    result.addAll(elements);
    
    for (int i = 0; i < children.length; i++)
      result.addAll(children[i].get_all());
    
    return result;
  }
  
  ArrayList get(Area area) {
    if (!this.area.overlaps(area))
      return new ArrayList();
    
    if (DEBUG_QUADTREE) {
      // this.area.draw();
    }
    
    ArrayList result = new ArrayList();
    result.addAll(elements);
    
    for (int i = 0; i < children.length; i++) {
      if (area.contains(children[i].area))
        result.addAll(children[i].get_all());
      
      else if (area.overlaps(children[i].area))
        result.addAll(children[i].get(area));
    }
    
    return result;
  }
}
