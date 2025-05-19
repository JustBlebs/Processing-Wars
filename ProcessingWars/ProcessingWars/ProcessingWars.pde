//when I wake up, fix the cancel button in the fire state so that it put you back into the state it was before, cause otherwise its broken af




import java.util.*;				//Include the collections framework (Lists, Maps, Queues) and other core java stuff
import javax.swing.*;			//Inlcude the Swing framework that the renderer uses to get things relating to screen coordinates, actual app windows, etc.
import processing.awt.*;	//Include the Processing Abstract Window Toolkit (AWT) to use in tandem w/ Swing for the above 


Pair<Integer, Integer> posRef;			//An integer pair for the screen coordinates of the main program window
int barSize;												//An integer for the size of the title bar. Will eventually vary based on operating system
PApplet main = this;

boolean globalMenuToggle = true;		//Whether or not the menu (the window attached to the side) is visible/toggled
boolean menuToggleBuff = !globalMenuToggle;	//A bool for if the toggle has been switched (to avoid polling every cycle)
boolean depRendFinished = true;							//Whether or not a dependent render (usage of the renderer in different threads/PApplets) is complete. Might not need anymore

PFont font; 																//The font to be used across the program

int menuState = 0;													//the state of the menu. NOT TO BE CONFUSED WITH SELECTION STATE. This is for the titlescreen, endscreen, switching between those, etc

MapGrid Map;																//A MapGrid Object with all of the map data, inculding tile data, id's of units, other such info
Bricklayer bricklayer;											//A Bricklayer object, used for drawing the map and units based on the tilemap
UnitList uList;															//A UnitList object, which is really just a wrapper for an ArrayList of Units, 
Pather pather; 															//A universal Pather, by which all units are to do pathing stuff by, mainly for fear of the memory involved of multiple having this at once
PWindow menu;																//And finally, a PWindow that contains the sidebar menu code. This felt cooler and more interesting than just putting it in one window

int day;																		//The current day. Days end when both teams have finished their turns
int turn;																		//The current turn, as in who is in control right now
Player[] players = new Player[] {new Player("P1",1), new Player("P2", 2)};

int hoverX, hoverY;                         //vars for the position of the mouse. Yes it just takes mouseX and mouseY, but I need it as a global reference for the menu window, which has its own
int clickedX, clickedY;											//ints for storing the last place the mouse was pressed. Crucial for selecting units and the factory
ArrayList<MapCell> ifr = new ArrayList<>();

volatile int selected = -1;													//The current unit selected's ID, which is really their position in the UnitList
volatile int selectionState = 0;											//The "state" of selection, aka a thing to tell the menu what buttons to show/allow
volatile boolean comingFromMove = false;

int user = 0;																//the user, a dummy int that corresponds to the player right now. Will have to change this later

void settings() {														//I'm using settings() here to do some funky things relating to window sizes
	println(System.getProperty("os.name"));		//Cout the operating system for sanctity's sake
	if (System.getProperty("os.name") == "Linux") {		//if its Linux (which is a flawed check because not every Linux distro/user uses the GNOME GUI, which I use)...
		barSize = 71;																		//...assumedly (I eyeballed this) the titlebar size is about 71 pixels. So set barSize to that
	} else if (System.getProperty("os.name") == "Windows") {	//if its Windows (which is nice because Microsoft has standards)...
		barSize = 32;																						//...the title bar size is 32px
	} else if (System.getProperty("os.name") == "Mac") {			//and if its Mac...
    barSize = 21;																						//...21 px
  }
}


void setup() {
	
	stroke(0);
	ellipseMode(CORNER);
	font = loadFont("./data/PixelifySans-Regular-17.vlw");			//load the font
	clickedX = 1; clickedY = 1;																	//and set the clicked position to 1, so that it doesn't have a heart attack if I'm debugging

	Map = new MapGrid("./maps/dummy");													//load the Map from the map file. Eventually I'll need to select this by hand instead of it being a defined path
	for (MapCell[] c : Map.MapCells) {													//and for each cell in the map grid
		for (MapCell d : c) {
			d.getNeighbors();																				//populate the neighbors arrayList so that we can just reference that easly
		}																													//can't do that in the construction, unfortunatly, because it will point to values that don't exist in the moment
	}
	delay(200);																									//wait 100ms. This seems to prevent an error with the bricklayer loading the tilemap and not drawing.
	bricklayer = new Bricklayer("./Tilemap.png",50);						//load the tilemap for the bricklayer and specify the tile size.
	delay(200);
	uList = new UnitList();																			//make a UnitList for uList
	pather = new Pather(Map) ;																	//and make a Pather with Map. I Really don't need to specify it's using Map, since it's global, but I did anyways. might fix
  windowResize(Map.wMap*50,Map.hMap*50);											//and, once all that is done, resize the window so that the Map is the whole window
  //pather.pathIt(new int[] { 0,16 }, new int[] { 0, 0 });
  
  //pather.bfs(new int[] {7,2}, INFN, 3);

  menu = new PWindow();																				//And create the menu window, which is important since it's a whole separate program, essentially
  alignWindowCenter(width+200,height,this);
}

void draw() {																									//every cycle...:
  posRef = readWindowPosition();															//get the main window's screen position and put it in posRef
  hoverY = mouseY; hoverX = mouseX;														//set hoverX and Y to mouseX and Y for the reasons above
  background(#0c0c0c);																				//redraw the background. technically uneccessary, since vvv just draws the whole screen anyways, but eh
	bricklayer.drawMap();																				//draw the whole screen from the render buffer.
	
	uList.drawUnits();																					//and draw the units (which is really just the Breadth First Search visualization when that's even being used) 
   
}

void mousePressed() {
	//if (mouseX < Map.wMap*50) {
  	//replace everything that has separatee x,y with int[] pairs for ease later
  
  	//first, get the coordinate corr. to the grid 
		clickedX = toGrid(new int[] {mouseY,mouseX})[1];
		clickedY = toGrid(new int[] {mouseY,mouseX})[0];
		if (Map.unitMap[clickedY][clickedX] != -1 && uList.Units.get(Map.unitMap[clickedY][clickedX]).owner == user && !uList.Units.get(Map.unitMap[clickedY][clickedX]).hasActed && selected == -1) { //replace with actual player values later
      selected = Map.unitMap[clickedY][clickedX];                            //theoretically this sets selected to the id of the object at the coordinate
      //aka "selects" the unit at the position, by setting selected to the unit's id
      //and from here, we enter the selection world.
      selectionState = 1; //we go into state 1: nothing! not really. It brings up the correct menu on the sidebar
      comingFromMove = true;
      if (uList.Units.get(Map.unitMap[clickedY][clickedX]).unitType == 8 || uList.Units.get(Map.unitMap[clickedY][clickedX]).unitType == 9) {
      	ifr = uList.Units.get(Map.unitMap[clickedY][clickedX]).indirectFireRange(uList.Units.get(Map.unitMap[clickedY][clickedX]).unitType == 8? 1:2, uList.Units.get(Map.unitMap[clickedY][clickedX]).unitType == 8? 3:5);
      }
    } 
    switch (selectionState) {
    	case 0: break;						//0 is the default case, essentially the stuff for saving, loading, etc.
    	case 1: break;						//1 is the selected state, which opens the menu to actions, i.e. moving, attacking, capturing. cancel returns to 0
    	case 2: break;						//2 is the movement state. click to move to a location. leads to 3. cancel returns to 0.
    	case 3: break;						//3 is the movement confmirmation state. check whether or not to wait (end action), attack (if possible, go to 4), cancel (return to 2), or cap (end action)
    	case 4: break;						//4 is the attack state, which is only availble if there is someone who can be attacked. Either cancels (return to 2? or maybe 3?), or attacks (end action)
    	case 5: break; 						//5 is the factory state, which will have its own UI for buying
    	case 6: break;						//6 is the log state, for reading the notation that I may or may not add at some point
    }
		//when I wake up and open this, next step is the end turn, mainly adding the money incrementing. Then the fire function. Then all the ornamentla stuff.
	

		if (selected != -1 && selectionState != 2 && selectionState != 4) {
      uList.Units.get(selected).teleTo(clickedX,clickedY);
      //return;																																	//its dumb, but this ensures the mouse can't immediatly reselect the unit
 		}
 		
		if (selected == -1 && Map.MapCells[clickedY][clickedX].isFactory && Map.MapCells[clickedY][clickedX].buildingOwner == user && !Map.MapCells[clickedY][clickedX].isOccupied) {
  		menu.scrollPos = 0;
			selectionState = 5;
		} else if (selectionState == 5) {
			selectionState = 0;
		}
	
}

void keyPressed() {
  //pretty much everything here is just debugging stuff to test units before I get things running properly
  
  
	if (key == 'a' && Map.MapCells[5][8].isOccupied == false) {
		uList.addUnit(new Unit(user,8,5,3));
	} if (key == 'd') {
  	if (!uList.Units.isEmpty()) {
  		uList.deleteUnit(0);
  		Map.MapCells[5][8].isOccupied = false;
		}
	}
	if (key == 'm') {
		globalMenuToggle = !globalMenuToggle;
		//println(globalMenuToggle + " " + menuToggleBuff);
	}
	if (key == ' ') {
		endTurn();
	}
	if (key == 'z' && selected != -1) {			//deselect the current unit
		selected = -1;
	}
	
}

void endTurn() {
  players[user].money += 1000 * players[user].ownedBuildings;
  for (Unit u : uList.Units) {
    if (u.owner == user) {
      u.hasActed = true;
    }
  }
  user = user == 0? 1 : 0;
	for (Unit u : uList.Units) {
		if (u.owner == user) {
			u.hasActed = false;
		}
	}
}

void saveStateToFile() {
	//ughhhhhhhhhhhh I don't know how i'm gonna do this but ughhhhhh I'll get to it


}

void loadStateFromFile() {

}
