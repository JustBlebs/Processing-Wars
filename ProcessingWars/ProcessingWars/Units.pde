//I'd really like if Java had a one-to-one analog to C/C++'s struct, because I'm really only making this to hold some data
class Player {    									//anyways this is the player
  String name;											//they've got a name...
  int id;														//an "id" which, like the unit ids, is just an index
  int money;												//the money this player has
  int ownedBuildings = 0;						//and how many buildings they oen

  Player(String name, int id) {			//Player Constructor
    this.name = name;								//Name is name
    money = 10000;									//money is 10000, for the kick start
    this.id = id;										//and id is id. don't remember why this is here but its fine
  }
}

class UnitList {										//The unitList class, a glorfied Unit ArrayList with extras
  ArrayList<Unit> Units;						//said Unit ArrayList
  
  public UnitList() {								//The constructor is literally just making a new Unit Array List
  	Units = new ArrayList<Unit>();	//I wasn't kidding calling this a glorified Unit ArrayList
  }
  
  void addUnit(Unit u) {						//Add unit method
  	Units.add(u);										//does as the tin says
  	u.id = Units.lastIndexOf(u);		//sets the id to the last index of the UnitList
  	u.hasActed = true;							//and sets the new Unit to having already acted, so that you can't move them until the next turn
  	flushUnitIds();									//And flush the unit ids. Redundant? I think so
  	//print(u.id);
  }
  
  void deleteUnit(int id) {								//Delete unit method
    Map.unitMap[Units.get(id).unitY][Units.get(id).unitX] = -1;									//set the unitMap id back to -1
    Map.MapCells[Units.get(id).unitY][Units.get(id).unitX].isOccupied = false;	//and the occupation status of the tile to false
  	Units.remove(id);																														//And remove the unit
  	flushUnitIds();																															//and reset all the ids
  	
  }
  
  void flushUnitIds() {																													//flush is the wrong word to use here, but I don't really care
  	for (Unit u : Units) {																											//for every unit
    	u.id = Units.indexOf(u);																									//set the id to the index
  		u.updateUnit();																														//update it? Honestly don't remember why this is here
  	}
  }
  
  void drawUnits() {																														//another erroniously named method
  	for (Unit u : Units) {																											//that just draws the moveable tiles
    	if (u.id == selected && selectionState != 2 && selectionState != 4) {
    		u.validMovementOptions();
    	}
  	}
  }
  
}


class Unit implements Cloneable {
  int id;		//the index of the unit in the unitList
  //int histId; //keep this here for now if I want to add a notation type thing (game history, a la chess)
  int owner;				//the owner of the unit
	int unitX, buffX;	//the last position of the unit
	int unitY, buffY;	//the current position of the unit
	boolean hasActed = false; //whether or not a unit has taken an action this turn.
	
	int health;		//hitpoints. how much damage a unit can take. it's always ten.
	int movement; //a default movement value, that's kinda like points, per se. you consume them to move. No points left, can't move. Costs to much, can't go to space.
	int fuel;			//the amount of movement a unit can make before hvaing to resupply
	int ammo;			//the number of attacks a unit can do, if they are affected by that

	int unitType;	//which unti the unit actually is
	int unitClass;//which movement cost the unit should use

	@Override			//overriding clonability so that it can be cloned
    public Object clone() throws CloneNotSupportedException {
      return super.clone();
    }

	public Unit(int owner, int x, int y, int type) 	{
		this.owner = owner;		//owner is owner
		this.unitX = x;				//unit x is x
		this.unitY = y;				//y is y
		unitType = type;			//type is type
		health = 10;					//health is 10

		//add ammo and fuel later
		
		switch(unitType) {
			case 1: unitClass = INFN; movement = 3; break;		//infantry
			case 2: unitClass = MECH; movement = 2; break;		//mechanized
			case 3: unitClass = TIRE; movement = 8; break;		//recon
			case 4: unitClass = TRED; movement = 6; break;		//Light Tank
			case 5: unitClass = TRED; movement = 5; break;		//Med Tank
			case 6: unitClass = TIRE; movement = 6; break; 		//APC
			case 7: unitClass = TIRE; movement = 6; break;		//Anti-Air Gun, prob wont use because there's no air units. Yet.
			case 8: unitClass = TRED; movement = 5; break;		//Artillery
			case 9: unitClass = TRED; movement = 5; break;		//Rockets
			
		}

		
		
		//histId = this.hashCode(); 

		//Map.unitMap[unitY][unitX] = id; //why is it backwards???? I dont know???
		//Map.MapCells[y][x].isOccupied = true;
		
		//for (int i = 0; i < Map.hMap; i++) {                  //and fill each "cell" of the 2d array with a new MapCell
  //    for (int j = 0; j < Map.wMap; j++) {                   //and print for now to make sure it corresponds to what is being displayed
  //      print(Map.unitMap[i][j]+",");
  //    }
  //    print('\n');
  //  }
	}


	void teleTo(int x, int y) {															//the move function, named as such because it was originally just a teleporter w/o regard for cost
		if (Map.MapCells[y][x].isOccupied || !Map.MapCells[y][x].isPassable) {	//if x,y is occupied or can't be passed
  		return;																																//do nothing
  	} if (selected == id) {																									//but if the unit is selected
  		buffX = unitX; buffY = unitY;																					//put the position in the buffer, in case we have to go back
			unitX = x; unitY = y;																									//put the x and y as the new position
			selectionState = 2;																										//and put us in selection state 2, the movement confirm
			if (unitType == 8 || unitType == 9) {																	//also, if the unit is an indirect fire troop,
				ifr = indirectFireRange(unitType == 8? 1:2, unitType == 8? 3:5);		//put the new fire zone in ifr
			}
			updateUnit();																													//and update the unit
		}
	}

	void capture() {																													//capture method, for when a unit is on a building
		Map.MapCells[unitY][unitX].buildingHealth -= this.health;								//subtract the units health from the building health
		hold();																																	//and end the unit's action
		if (Map.MapCells[unitY][unitX].buildingHealth <= 0) {										//if the building health goes to less than zero
			Map.MapCells[unitY][unitX].buildingOwner = this.owner;								//make this units owner the new owner
			players[user].ownedBuildings++;																				//and increment the player's owned building count
		}
	}

	void hold() {																															//hold method, for staying still/ending an action
  	selectionState = 0;																											//go back to the normal selection state
  	hasActed = true;																												//this unit is done
		selected = -1;																													//set selcted to nothing
		ifr = new ArrayList<>();																								//empty ifr so that it doesn't draw it
	}
	
	void cancel() {																														//cancel, for canceling movement
  	selectionState = 1; 																										//set selection state back to movement state
  	comingFromMove = true;
		unitX ^= buffX;																													//xor swap unitx and unity with their buffers to reset the position
		buffX ^= unitX;
		unitX ^= buffX;
		unitY ^= buffY;
    buffY ^= unitY;
    unitY ^= buffY;
    updateUnit();																														//and update unit
    if (unitType == 8 || unitType == 9) {																		//if indirect fire,
    	ifr = indirectFireRange(unitType == 8? 1:2, unitType == 8? 3:5);			//draw the fire zone
    }
	}

	
	Pair<ArrayList<MapCell>,Boolean> enemyNeighbors() {												//enemy neighbors, which returns a Pair of ArrayList and Boolean (because I need to make sure that the return isn't empty)
  	ArrayList<MapCell> enemies = new ArrayList<>();													//make a new ArrayList called enemies
  	if (unitType != 8 && unitType != 9) {																		//if this *isn't* an indirect fire unit...
  		for (MapCell cell : Map.MapCells[unitY][unitX].neighbors) {						//for every cell in the neighbors ArrayList
  			if (cell.controller != owner && cell.controller != -1) {						//check if that cell is controlled by the enemy, and if it is,
  				enemies.add(cell);																								//add that to enemies
  			}
  		}
    } else if (unitType == 8 || unitType == 9){															//if it *is* an indirect fire unit...
      enemies = indirectFireRange(unitType == 8? 1:3, unitType == 8? 3:6);	//make enemies the entire return of indirectFireRange within the range of the unit (2-3 for arty, 3-5 for rkts)
  		enemies.removeIf(cell -> !(cell.controller != owner && cell.controller != -1));	//and for each cell now in enemies, remove everything but enemy controlled tiles
    }
		return new Pair(enemies,!enemies.isEmpty());														//and return whatever result, plus whether or not it's empty, which makes my life easier, I think
	}

	ArrayList<MapCell> indirectFireRange(int lesser, int greater) {										//indirect fire range tiles method, for getting all the tiles in an ifr unit's range
		ArrayList<MapCell> inner = pather.bfs(new int[] {unitY, unitX}, MECH, lesser);	//make a new ArrayList of MapCells called inner from the breadth first search return using MECH, since it has no movement penalties
    ArrayList<MapCell> outer = pather.bfs(new int[] {unitY, unitX}, MECH, greater);	//and ditto for outer, giving us a big "circle" and a little "circle" of tiles
    ArrayList<MapCell> difference = new ArrayList<>();															//and make a new ArrayList called difference
    for (MapCell cell : outer) {																										//for every cell in the bigger circle,
      if (!inner.contains(cell)) {																									//if a cell isn't in the inner circle,
        difference.add(cell);																												//put it in difference
      }	
    }
    return difference;																															//and return the difference
	}

	//void fire(Pair<ArrayList<MapCell>,Boolean> enemies) {
		


	//}

	void updateUnit() {																																//update unit method, for making sure positions are up to date after every thing
  	Map.MapCells[buffY][buffX].controller = -1;																			//essentially, everything at the last position gets set to empty
  	Map.unitMap[buffY][buffX] = -1;
  	Map.MapCells[buffY][buffX].isOccupied = false;
  	Map.MapCells[unitY][unitX].controller = owner;																	//while everything at the new positon is set to full/occupied
		Map.unitMap[unitY][unitX] = id;
		Map.MapCells[unitY][unitX].isOccupied = true;
		
	}

	void validMovementOptions() {																											//valid movement method, for seeing what is allowed to move to
		ArrayList<MapCell> validTiles = pather.bfs(new int[] {unitY, unitX},unitClass,movement);		//get a new ArrayList of MapCells from the breadth-first using the unit info
		for (MapCell cell : validTiles) {																														//and with said ArrayList, for each cell
			int[] tile = toCanvas(new int[] {cell.y, cell.x});																				//make a new int array from the cell position converting back to canvas coordinates
			image(bricklayer.getIndivSprite(34),tile[1],tile[0]);																			//to draw the box sprite at the tile position 
			if (isInBounds(cell.x*50,cell.y*50,50,50,main)) {																					//and if the mouse is in the bounds of a tile
				pather.pathIt(new int[] { unitY, unitX }, toGrid(new int[] { mouseY, mouseX }), unitClass);	//show the pathing to it, even though it's not really accurate
			}	
		}
	}

}
