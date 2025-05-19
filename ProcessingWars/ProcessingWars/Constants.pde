//just somewhere for me to put constants because 
//A) I don't like clutter and ProcessingWars.ide still has a lot of code
//B) it's nice to have just a reference sheet
//and C) this is a mess anyways so why not make it more complicated

//constants for unit movement and damage calc
final static int INFN = 0;
final static int MECH = 1;
final static int TIRE = 2;
final static int TRED = 3;

//a pair class, kinda like std::pair in c++ and practically equivalent to Pair in Javafx
class Pair<K, V> {						//A Pair is made up of two types/objects K and V
	private final K kee;				//kee is a thing of type K
	private final V val;				//val is a thing of type V
															//fundamentally this is like a Map, but I really just want it for paired data storage. It's main purpose is for the pathing stuff
	public Pair(K kee, V val) {	//construction is just kee and val
		this.kee = kee;
		this.val = val;
	}

	public K getKey() {					//returns the kee
		return kee;
	}

  public V getValue() {				//returns the val
    return val;
  }
  														//^ these are just so that it's practically analouge to the real Pair class Javafx has. Also because Pairs should be immaleable, so they should be final
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

void alignWindowCenter(int w, int h, PApplet window) {
	window.windowMove((displayWidth - w)/2, (displayHeight - h)/2);
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

//check if the mouse is in a set bounding

public boolean isInBounds(int x, int y, int w, int h, PApplet window) {
	return (window.mouseX > x && window.mouseX < x+w && window.mouseY > y && window.mouseY < y+h);
}

 public String nameOf(int unitType) {
	switch (unitType) {
		case 1: return "Infantry";
		case 2: return "Mechanized";
    case 3: return "Recon";
    case 4: return "Light Tank";
    case 5: return "Md. Tank";
    case 6: return "APC";
    case 7: return "Anti-Air";
    case 8: return "Artillery";
    case 9: return "Rocket Art.";
    default: return "InvalidName"; 
	}
}

public int costOf(int unitType) {
  switch (unitType) {
    case 1: return 1000;
    case 2: return 3000;
    case 3: return 4000;
    case 4: return 7000;
    case 5: return 16000;
    case 6: return 5000;
    case 7: return 8000;
    case 8: return 6000;
    case 9: return 15000;
    default: return 10000; 
  }
}

public String tileNameOf(int terrain) {
  switch(terrain) {
  	case 0: return "Plains";
    case 1: return "Sea";
    case 2: return "Road";
    case 3: return "Woods";
    case 5: return "Mountains";
    case 4: return "Bridge";
    
    case 12: return "City";
    case 13: return "Factory";
    case 14: return "HQ"; 
    case 15: return "Factory";
    case 16: return "HQ";
    default: return "InvalidTile";
	}

}

static final float[][] baseDMG = { 	//INFT	MECH	RCON	LTNK	MTNK	APC*	AAGN	ARTY	RKTS
/*atk by def*/     			/*INFT*/		{ 5.50, 4.50, 1.20, 0.50, 0.10, 1.40, 0.50, 1.50, 2.50 },
                				/*MECH*/    { 6.50, 5.50, 8.50, 5.50, 1.50, 7.50, 6.50, 7.00, 8.50 },
                				/*RCON*/		{ 7.00, 6.50, 3.50, 0.60, 0.10, 4.50, 0.40, 4.50, 5.50 },
                				/*LTNK*/		{ 7.50, 7.00, 8.50, 5.50, 1.50, 7.50, 6.50, 7.00, 8.50 },
                        /*MTNK*/    { 10.5, 9.50, 10.5, 8.50, 5.50, 10.5, 10.5, 10.5, 10.5 },
                				/*APC**/		{ 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 },
                				/*AAGN*/		{ 10.5, 10.5, 6.00, 2.50, 1.00, 5.00, 4.50, 5.00, 5.50 },
                				/*ARTY*/		{ 9.00, 8.50, 8.00, 7.00, 4.50, 7.00, 7.50, 7.50, 8.00 },
                				/*RKTS*/		{ 9.50, 9.00, 9.00, 8.00, 5.50, 8.00, 8.50, 8.00, 8.50 }
										};

public float damageCalculator(Unit attacker, Unit defender, boolean predict) {
	float attackValue = (baseDMG[attacker.unitType][defender.unitType] + (!predict? random(0,9)/10f : 0f));
	//print(attackValue + ",");
	//print("(" + Map.MapCells[defender.unitY][defender.unitX].defense + "),");
	//print("(" + defender.health+ "),");
  float defenseValue = (100f - Map.MapCells[defender.unitY][defender.unitX].defense * defender.health)/100f;
  //print(defenseValue + ",");
  //println(attacker.health/10f * attackValue * defenseValue);
  return attacker.health/10f * attackValue * defenseValue;
}
