class UnitList {
  ArrayList<Unit> Units;
  
  public UnitList() {
  	Units = new ArrayList<Unit>();
  }
  
  void addUnit(Unit u) {
  	Units.add(u);
  	u.id = Units.lastIndexOf(u);			//probs redundant cause of fuids
  	flushUnitIds();
  	print(u.id);
  }
  
  void deleteUnit() {
    Map.unitMap[Units.get(0).unitY][Units.get(0).unitX] = -1;
    Map.MapCells[Units.get(0).unitY][Units.get(0).unitX].isOccupied = false;
  	Units.remove(0);
  	flushUnitIds();
  	
  }
  
  void flushUnitIds() {
  	for (Unit u : Units) {
    	u.id = Units.indexOf(u);
  		u.updateUnit();
  	}
  }
  
  void drawUnits() {
  	for (Unit u : Units) {
    	if (u.id == selected) {
    		u.validMovementOptions();
    	}
  		u.renderUnit();
  	}
  }
  
}


class Unit {
  int id;
  int histId; //keep this here for now if I want to add a notation type thing (game history, a la chess)
  int owner;
	int unitX, buffX;
	int unitY, buffY;
	//boolean isSelected; probably redundant, seeing as I have a global selected value who corresponds to 
	boolean hasActed = false; //a bool storing whether or not a unit has taken an action this turn.
	
	int health;
	int movement = 3; //a default movement value, that's kinda like points, per se. you consume them to move. No points left, can't move. Costs to much, can't go to space.
	int unitType;

	public Unit(int owner, int x, int y, int type) 	{
		this.owner = owner;
		this.unitX = x;
		this.unitY = y;
		this.unitType = type;

		histId = this.hashCode(); 

		Map.unitMap[unitY][unitX] = id; //why is it backwards???? I dont know???
		Map.MapCells[x][y].isOccupied = true;
		
		for (int i = 0; i < Map.hMap; i++) {                  //and fill each "cell" of the 2d array with a new MapCell
      for (int j = 0; j < Map.wMap; j++) {                   //and print for now to make sure it corresponds to what is being displayed
        print(Map.unitMap[i][j]+",");
      }
      print('\n');
    }
	}


	void teleTo(int x, int y) {															//a dummy move function for testing unitlist, tile occupation
		if (Map.MapCells[y][x].isOccupied || !Map.MapCells[y][x].isPassable) {
  		return;
  	} if (selected == id) {
  		buffX = unitX; buffY = unitY;
			unitX = x;
			unitY = y;
			selected = -1;
			hasActed = true;
			updateUnit();
  		print(selected);
		}
	}

	void moveTo(int x, int y) {
    
    
	}



	void updateUnit() {
  	Map.unitMap[buffY][buffX] = -1;
  	Map.MapCells[buffY][buffX].isOccupied = false;
		Map.unitMap[unitY][unitX] = id;
		Map.MapCells[unitY][unitX].isOccupied = true;
	}
	
	void renderUnit() {
  	if (hasActed == true) {
      fill(#CCCCCC);
      circle(unitX*50,unitY*50,50);
      
    } 
  	else if (selected == id) {
    	fill(#FF0000);
    	
  		fill(#FF33FF);
  		circle(unitX*50,unitY*50,50);
  		
  	} else {
  		fill(#FF00FF);
  		circle(unitX*50,unitY*50,50);
  	}
		
	}

	void validMovementOptions() {
  	//this really should just call some DFS function in pather, since that will globally be handling pathing rather than units, methinks
  	//so make a dfs algo for Pather
  	push();
  	depRendFinished = false;
  	println(hex(g.fillColor));
  	//menu.notify("debugInfo");
  	fill(0xCCFF0000);
		ArrayList<MapCell> validTiles = pather.bfs(new int[] {unitY, unitX},unitType,movement);
		for (MapCell cell : validTiles) {
  		//println(cell.x + "," + cell.y);
			int[] tile = toCanvas(new int[] {cell.y, cell.x});
			image(bricklayer.getIndivSprite(34),tile[1],tile[0]);
			//square(tile[1],tile[0],50);
		}
		println(hex(g.fillColor));
		depRendFinished = true;
		pop();
	}
}

//class Building {
//	int posX, posY;
//	int type;
//	int owner;

//	Building(int posX, int posY, int type, int owner) {
//		this.posX = posX;
//		this.posY = posY;
//		this.type = type;
//		this.owner = owner;
//	}
	
	
	
//}
