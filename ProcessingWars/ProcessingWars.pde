import java.util.*;
import javax.swing.*;
import processing.awt.*;
//import java.util.stream.Collectors;
//import java.lang.*;

Pair<Integer, Integer> posRef;
int barSize;
boolean globalFocused = true;
boolean globalMenuToggle = false;
boolean menuToggleBuff = !globalMenuToggle;
boolean depRendFinished = true;
int hoverX, hoverY;

PFont font; //= loadFont("./data/PixelifySans-Regular-17.vlw");

int menuState = 0;

MapGrid Map;
Bricklayer bricklayer;
UnitList uList;
Pather pather; 
PWindow menu;

int day;
int turn;

int clickedX;
int clickedY;
int selected = -1;

int user = 1;

void settings() {
	println(System.getProperty("os.name"));
	if (System.getProperty("os.name") == "Linux") {
		barSize = 71;
	} else if (System.getProperty("os.name") == "Windows") {
		barSize = 32;
	} else if (System.getProperty("os.name") == "Mac") {
    barSize = 21;
  }
}


void setup() {
	stroke(0);
	ellipseMode(CORNER);
	font = loadFont("./data/PixelifySans-Regular-17.vlw");
	clickedX = 1;
	clickedY = 1;

	Map = new MapGrid("./maps/dummy");						//will need to bundle all of this into a function later
	for (MapCell[] c : Map.MapCells) {
		for (MapCell d : c) {
			d.getNeighbors();
		}
	}
	bricklayer = new Bricklayer("./Tilemap.png",50);
	uList = new UnitList();
	pather = new Pather(Map) ;
  windowResize(Map.wMap*50,Map.hMap*50);
  pather.pathIt(new int[] { 0,16 }, new int[] { 0, 0 });
  
  pather.bfs(new int[] {7,2}, INFN, 3);
  //cursor();
  menu = new PWindow();
}

synchronized void draw() {
  hoverY = mouseY;
  hoverX = mouseX;
  //print(hoverX + ", " + hoverY + "\n");
  posRef = readWindowPosition();
  background(#0c0c0c);
	bricklayer.drawMap();
	
	uList.drawUnits();
	
   
}

void mousePressed() {
  
	if (mouseX < Map.wMap*50) {
  	//replace everything that has separatee x,y with int[] pairs for ease later
		clickedX = toGrid(new int[] {mouseY,mouseX})[1];
		clickedY = toGrid(new int[] {mouseY,mouseX})[0];
		if (selected != -1) {
      uList.Units.get(selected).teleTo(clickedX,clickedY);
      return;																																	//its dumb, but this ensures the mouse can't immediatly reselect the unit
 		}
		else if (Map.unitMap[clickedY][clickedX] != -1 && uList.Units.get(Map.unitMap[clickedY][clickedX]).owner == user && !uList.Units.get(Map.unitMap[clickedY][clickedX]).hasActed) { //replace with actual player values later
      selected = Map.unitMap[clickedY][clickedX];                            //theoretically this sets selected to the id of the object at the coordinate
      //println(selected);
    }     
	}
}

void keyPressed() {
	if (key == 'a' && Map.MapCells[5][7].isOccupied == false) {
		uList.addUnit(new Unit(1,7,5,TRED));
	} if (key == 'd') {
		uList.deleteUnit();
		Map.MapCells[5][7].isOccupied = false;
	}// if (key == 's') {
	//	println(selected);
	//	println(Map.MapCells[5][7].isOccupied);
	//	if (selected != -1) {
	//		println(Map.unitMap[5][7]);
	//	}
	//} 
	if (key == 'm') {
		globalMenuToggle = !globalMenuToggle;
		println(globalMenuToggle + " " + menuToggleBuff);
	}
	if (key == ' ') {
		endTurn();
	}
	if (key == 'z' && selected != -1) {
		selected = -1;
	}
	
}

void endTurn() {
	for (Unit u : uList.Units) {
		if (u.owner == user) {
			u.hasActed = false;
		}
	}
}
