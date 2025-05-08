class MapCell {  
  //should each cell contain a reference to its neighbors?
  //it would make the A* and the DFS easier methinks

  int terrain;              //visual terrain value
  int defense;              //defensive value of the tile
  
  boolean isBuilding = false;
  int buildingHealth = 20;
  int buildingOwner = -1;
  
  int x;
  int y;
  ArrayList<MapCell> neighbors = new ArrayList<>(); //a list of the neighbors of a cell. 
  boolean isOccupied = false;
  boolean isPassable;
  int controller = -1;      //correspondant to the owner value of a unit if this space is occupied

  int[] cost;


  public MapCell(int terrain, int x, int y) {
    this.terrain = terrain;
    this.x = x;
    this.y = y;
    
    isPassable  = !(this.terrain == 1);
    switch (this.terrain) {
      //[0] is infantry/foot, [1] is mechanized, [2] is tires, [3] is treads
      case 0: cost = new int[] {1,1,2,1}; defense = 1; break;    //normal ground, plains
      case 1: cost = new int[] {9,9,9,9}; defense = 0; break;    //water
      case 2: cost = new int[] {1,1,1,1}; defense = 0; break;    //road
      case 3: cost = new int[] {1,1,3,2}; defense = 2; break;    //forest
      case 5: cost = new int[] {2,1,9,9}; defense = 4; break;    //mountains. tread and tires arbitrarily large to prevent movement
      case 4: cost = new int[] {1,1,1,1}; defense = 0; break;    //bridge
      //leave a case gap here and in the mapGen for expansion if I want to
      
      case 12: cost = new int[] {1,1,1,1}; defense = 3; buildingOwner = 0; isBuilding = true;	break;    //city, is always neutral
      case 13: cost = new int[] {1,1,1,1}; defense = 2; buildingOwner = 1; isBuilding = true;	break;    //factory, player 1
      case 14: cost = new int[] {1,1,1,1}; defense = 3; buildingOwner = 1; isBuilding = true;	break;    //HQ, player player 1
      case 15: cost = new int[] {1,1,1,1}; defense = 2; buildingOwner = 2; isBuilding = true;	break;    //factory, player 2
      case 16: cost = new int[] {1,1,1,1}; defense = 3; buildingOwner = 2; isBuilding = true;	break;    //HQ, player 2
      default: cost = new int[] {1,1,1,1}; defense = 1; break;
      //case 0: cost = new int[] {1,1,2,1}; break; 
    }
  }


  public void getNeighbors() {
    
    for (int i = 1; i >= -1; i -= 2) {
      if (((y - i) >= 0) && ((y - i) < Map.hMap)) {    //the equivalent of isValid
        neighbors.add(Map.MapCells[y - i][x]);
      } 
    } 
    for (int i = 1; i >= -1; i -= 2) {
      if (((x - i) >= 0) && ((x - i) < Map.wMap)) {
        neighbors.add(Map.MapCells[y][x - i]);
        println(Map.MapCells[y][x-i].x + "," + Map.MapCells[y][x-i].y + ",");
      }
    }
  }

}


class MapGrid {
	MapCell[][] MapCells;																		//the MapGrid is really just something to hold a 2d array of MapCell and render stuff with it
	int[][] unitMap;																		//a separate 2d array containing the id of a unit at a point, for selection handling (with dead cells at -1 for indexing)
	int wMap;																						//the width of the map
	int hMap;																						//the height

	public MapGrid(String path) {												//the map constructor

		byte[] mapBytes = loadBytes(path); 								//make a byte array out of the bytes of the file at path
    wMap = (int)mapBytes[0];													//use the 0th byte as the width
    hMap = (int)mapBytes[1];													//and the 1st byte as the height
    
    for (int b = 0; b < mapBytes.length; b++) {				//check to make sure the map data is properly encoded (width and height bytes match # of tiles)...		
    	if(mapBytes[b] == -1 && b-2 != wMap*hMap) {			//by seeing if the index of mapBytes b-2 (to account for the width and height bytes), is equal to the width times height
    		print(b-2 + "," + wMap*hMap);
    		throw new InvalidMapDimensions("Invalid Map Dimensions in Mapfile " + path);			//if it isn't, throw an error and break the program. I think it's necessary, and it safer...
    		//because if I let any random user submitted data go in, it could be bad. Trust me. I'm a C++ programmer. I know.
    	}
    }
		print('\n');

		//assuming we passed the dimension check...
    
    MapCells = new MapCell[hMap][wMap];										//...make a new MapCell array with height hMap and width wMap
    unitMap = new int[hMap][wMap];
    
		
		for (int i = 0; i < hMap; i++) {									//and fill each "cell" of the 2d array with a new MapCell
      for (int j = 0; j < wMap; j++) {
        MapCells[i][j] = new MapCell((int)mapBytes[i*wMap+j+2],j,i);		//for now it just copies the data to terrain and weight. Translation will come later
        print(MapCells[i][j].terrain + ",");												//and print for now to make sure it corresponds to what is being displayed
        unitMap[i][j] = -1;
      }
      print('\n');
    }
	}
	
	//void renderMap() {																	//renderMap method, which only handles the map part of the map. No entities.
	//	for (int i = 0; i < hMap; i++) {
 //     for (int j = 0; j < wMap; j++) {
 //       switch (MapCells[i][j].terrain) {
 //       	case 0:
 //       		fill(255);
 //       	break;
 //       	case 1:																						USE Bricklayer's Render, not this anymore
 //           fill(#0000FF);
 //         break;
 //         case 3:
 //           fill(#00FF00);
 //         break;
 //         case 5:
 //           fill(#c1c1c1);
 //         break;
 //       }
 //       square((50*j),50*i,50); //replace with tilemap stuff later
 //     }
 //   }
	//}

	void mouseIs() {
    fill(255);
    if (mouseX < wMap*50) {
    	menu.text(min((mouseX-(mouseX % 50))/50,wMap) + "," + min((mouseY-(mouseY % 50))/50,hMap),50,24);
    } else {
    	menu.text("Menu",50,24);
    }
  }

}
