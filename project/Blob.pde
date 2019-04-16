class Blob {
  private PApplet parent;
  
  public Contour contour;
  
  public boolean availableToMatch;
  public boolean delete;
  
  private int initTimer;
  public int timer;
  
  int id;
  
  Blob(PApplet parent, int id, Contour c) {
    this.parent = parent;
    this.id = id;
    this.contour = new Contour(parent, c.pointMat);
    
    availableToMatch = true;
    delete = false;
  }
  
  void display() {
    Rectangle r = contour.getBoundingBox();
    
    fill(0,0,255,100); // Blue
    stroke(0,0,255);
    rect(r.x, r.y, r.width, r.height);
    fill(255);
  }
  
  void updateFromContour(Contour c) {
    contour = new Contour(parent, c.pointMat);
    timer = initTimer;
  }
  
  void countDown() {
    timer--;
  }
  
  boolean dead() {
    return timer < 0;
  }
  
  public Rectangle getBoundingBox() {
    return contour.getBoundingBox();
  }
}
