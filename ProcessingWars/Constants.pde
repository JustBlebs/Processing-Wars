//just somewhere for me to put constants because 
//A) I don't like clutter and ProcessingWars.ide still has a lot of code
//B) it's nice to have just a reference sheet
//and C) this is a mess anyways so why not make it more complicated
//Also D) I can hide environment objects like PWindow and stuff here that are funky 

//constants for unit movement and damage calc
final static int INFN = 0;
final static int MECH = 1;
final static int TIRE = 2;
final static int TRED = 3;

//a pair class, kinda like std::pair in c++ and practically equivalent to Pair in Javafx
class Pair<K, V> {
	private final K kee;
	private final V val;

	public Pair(K kee, V val) {
		this.kee = kee;
		this.val = val;
	}

	public K getKey() {
		return kee;
	}

  public V getValue() {
    return val;
  }
  
  public void printPair() {
  	println(kee + ", " + val);
  }
}


//this is funky, sure, but this gets the position on the screen of a PSurface window.

Pair<Integer,Integer> readWindowPosition() {
  PSurfaceAWT.SmoothCanvas canvas = (PSurfaceAWT.SmoothCanvas)surface.getNative();
  JFrame frame = (JFrame)canvas.getFrame();
  return new Pair(frame.getX(), frame.getY());
  //println("Position: ", frame.getX(), frame.getY());
}

//converters in terms of y,x

//convert a canvas position, like mouseX and Y, to a corresponding grid position
public int[] toGrid(int[] pos) {
	int[] gridPos = new int[2];
	gridPos[0] = min((pos[0]-(pos[0] % 50))/50,Map.hMap);
	gridPos[1] = min((pos[1]-(pos[1] % 50))/50,Map.wMap);
	return gridPos;
}

//convert a grid position to a corresponding (loose) canvas position
public int[] toCanvas(int[] pos) {
	int[] canvasPos = new int[2]; 
	canvasPos[0] = pos[0] * 50;
	canvasPos[1] = pos[1] * 50;
	return canvasPos;
}
