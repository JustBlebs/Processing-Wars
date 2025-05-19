class Cell {																//a cell class for pathing stuff
  int parent_i, parent_j;										//it's got a parent in coordinates
  double f, g, h;														//and f, which is g + h, g, which is the cost to this cell, and h, which is the heuristic to the destination

  Cell() {																	//the constructor just gives it some arbitrary values to be written over
      this.parent_i = -1;
      this.parent_j = -1;
      this.f = Double.POSITIVE_INFINITY;
      this.g = Double.POSITIVE_INFINITY;
      this.h = Double.POSITIVE_INFINITY;
  }
}

class Pather {															//and then out pather class
	final private int ROWS;													//the number of rows of the map (height)
  final private int COLS;													//the number of columns (width)
  MapGrid mapData;													//I pass a reference to the MapGrid here, but I don't really need to do that because the global Map already exists
  int[] src;																//anyways, an int array for the source tile
  int[] dest;																//and another for the destination tile
  int activeUnitClass;											//and also the current unit movement class
  
  int[][] pathingGrid;											//also the pathing grid. its a 2d int array that says whther or not a tile is passable
  
  Pather(MapGrid mapData) {									//the constructor
    this.mapData = mapData;									//just take the Map (which again, should just be using Map but this was before I fully got that Objects are passed by reference and not like, cloned or something)
    ROWS = mapData.hMap;
    COLS = mapData.wMap;
    
    pathingGrid = new int[ROWS][COLS];			//and we make the pathing grid with the dimensions of the map
    for (int i = 0; i < ROWS; i++) {
    	for (int j = 0; j < COLS; j++) {
    		pathingGrid[i][j] = mapData.MapCells[i][j].isPassable ? 1 : 0;	//and make each tile passable or not. I should probably add something for mountains
    	}
    }	
  	/*this.src  = src ;
  	this.dest = dest;*/
  	//this.pathingGrid = pathingGrid;
  }
  
  public void pathIt(int[] src, int[] dest, int unitType) {		//the pathing method. At the moment, literally only used to draw the arrow from the unit to the destination. Hm.
    //println();
    //for (int i = 0; i < ROWS; i++) {
    //  for (int j = 0; j < COLS; j++) {
    //    //print(pathingGrid[i][j] + ",");
    //  }
    //  //println();
    //}  
  	aStarSearch(pathingGrid, src, dest, unitType);		//and it just calls aStarSearch. also hm. well whatever
  }
  
  private boolean isValid(int row, int col) {					//isValid, which checks if the given tile actually exists
  	return (row >= 0) && (row < ROWS) && (col >= 0) && (col < COLS);		//its just if its between 0 and the rows, and 0 and the columns
  }
  
  private boolean isPassable(int[][] grid, int row, int col, int unitType) {
    if ((unitType == TIRE || unitType == TRED) && mapData.MapCells[row][col].terrain == 5) {    //this check is if its a mountain, which for treads and tires should be impassable
        println("unitType cannot pass Mountain");
        return false;
    }
  	return grid[row][col] == 1;
  }
  
  private boolean isDestination(int row, int col, int[] dest) {
  	return row == dest[0] && col == dest[1];
  }
  
  private double calculateH(int row, int col, int[] dest, int unitType) {	//calculate the Manhattan Distance for the heuristic, except not really
  	int lowerL = 0, upperL = 0, closeH = 0, farerH = 0, dunkSum, palmSum;
  	for (int i = 0; i < abs(row - dest[0]); i++) {																						//So for each tile horizontally to the destination...					//I'll call it the Manhattan Congestion Distance
  		closeH += Map.MapCells[row - i * (int)Math.signum(row - dest[0])][col].cost[unitType];	//Sum the cost to each tile along the bottom from orign...		//Cause, like the Manhattan, the distance travelled
  	}																																																																												//is constant across nodes. But the cost of travel, 
  	for (int i = 0; i < abs(col - dest[1]); i++) {																						//then for each vertically																		//like time, I suppose, is different, as if each 
  		lowerL += Map.MapCells[row][col - i * (int)Math.signum(col - dest[1])].cost[unitType];	//sum to cost from the origin																	//has some preset amount traffic in a direction.
  	}																																																																												//Also, Weighted Mahattan exists,
  	for (int i = 0; i < abs(row - dest[0]); i++) {          																	//then the horizontal costs not from the origin								//but it refers to multiplying *directions* by scalars
      farerH += Map.MapCells[row - i * (int)Math.signum(row - dest[0])][dest[1]].cost[unitType];     																												//so that, say, N-S is "shorter" whlie E-W is "longer"
    }																																																																												//so each block still has a uniform size, per se
    for (int i = 0; i < abs(col - dest[1]); i++) {
      upperL += Map.MapCells[dest[0]][col - i * (int)Math.signum(col - dest[1])].cost[unitType];
    }
  	dunkSum = closeH + upperL;				//sum em
  	palmSum = lowerL + farerH;
  	//println("Position:" + col + ","+ row + " dunk Sum:" + dunkSum + ", palm Sum:" + palmSum);
  	
  	return min(palmSum,dunkSum);	//And we take the lower heuristic, because if one is lower, than it must be more optimal. //this technically breaks down because water has a cost of 9, and mountains too in some cases
  }																//so it struggles to find the actual path of least cost. Switching to maybe the euclidean or diagonal heuristic might help, but I'm unsure. I'll test it
   
  private void tracePath(Cell[][] cellDetails, int[] dest) { //EVERYTHING IS IN Y, X, BTW		//this is the tracing method, which draws the arrow. thats it. I am... ired by past me
  	//println("Path is");
  	int row = dest[0];				//we take the in array and make it just ints. I hate myself for thinking this was okay. Why is it inconsistent between int arrays and sole ints. ugh.
  	int col = dest[1];				//I should say I'm writing most of thses comments pumped with coffee at midnight. Not for any good reason. I just wanted coffee and was willing to suffer
  
  	Map<int[], Boolean> path = new LinkedHashMap<>();		//anyways we make a linked hashmap (a hashmap with a maintained order, like a queue, kinda) for the coordinate and if it has been visted
  
  	while (!(cellDetails[row][col].parent_i == row && cellDetails[row][col].parent_j == col)) {	//so uh... if the cell we're on is not its own parent (I think thats what's happening)
  		path.put(new int[] {row, col}, true);										//we make a new entry for the path with the position and true
  		int tempRow = cellDetails[row][col].parent_i;						//do this... which keeps the parent position and makes that the new place to go
  		int tempCol = cellDetails[row][col].parent_j;
  		row = tempRow;
  		col = tempCol;
  	}
  
  	path.put(new int[] {row,col}, true);											//and then when we get through all of that, put the last one that should be its own parent, because its the source
  	List<int[]> pathList = new LinkedList<>(path.keySet());		//and make a new linked (ordered) list from the keys of the linked hashmap
  	Collections.reverse(pathList);														//and reverse it. Cause we're silly. Actually because we did last-in first out by starting from the end and following the parents
  
  	byte tube;																								//anyways, we then do shenanegans like we do for the water or road edge detection, but easier since theres less possible
  	for (int i = 1; i < pathList.size(); i++) {								//so for each point in the pathList
    	tube = 0b00000000;																			//we set tube to 0
    	int[] to = {0,0};																				//we make to 0,0. 
    	int[] from;																							//and we leave from empty
  		from = new int[] {pathList.get(i - 1)[0] - pathList.get(i)[0], pathList.get(i - 1)[1] - pathList.get(i)[1]}; //and fill it with the difference in x and y from the current cell to the parent
  		if (i < pathList.size()-1) {														//and if we're at the end of the list
  			 to = new int[] {pathList.get(i + 1)[0] - pathList.get(i)[0], pathList.get(i + 1)[1] - pathList.get(i)[1]};	//we set to the same way as well
  		}
  		//then we handle the edges, excpet much much easier. I really should just redo the water, road handling and replace it with this because it's so much more intuitive
  		if (from[0] == -1 || to[0] == -1) {		//top case
  			tube |= 0b00001000;
  		}	if (from[0] == 1 || to[0] == 1) {		//bottom
  			tube |= 0b00000100;
  		} if (from[1] == -1 || to[1] == -1) { //left
        tube |= 0b00000010;
      }  if (from[1] == 1 || to[1] == 1) {	//right
        tube |= 0b00000001;
      }
      //println(binary(tube));
      switch (tube) {																					//and like always, the cases from the resultant tube. 
        case 0b00001100: image(bricklayer.getIndivSprite(53), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;    //vert
        case 0b00000011: image(bricklayer.getIndivSprite(52), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;    //horiz
        case 0b00001010: image(bricklayer.getIndivSprite(63), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;    //top to left
        case 0b00000101: image(bricklayer.getIndivSprite(54), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;    //bottom to right
        case 0b00001001: image(bricklayer.getIndivSprite(62), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;    //top to right
        case 0b00000110: image(bricklayer.getIndivSprite(55), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;    //bottom to left
        case 0b00000100: image(bricklayer.getIndivSprite(51), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;    //end bottom
        case 0b00001000: image(bricklayer.getIndivSprite(59), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;   //end top
        case 0b00000001: image(bricklayer.getIndivSprite(60), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;   //end right
        case 0b00000010: image(bricklayer.getIndivSprite(61), pathList.get(i)[1] * 50, pathList.get(i)[0] * 50); break;   //end left
      }	//I guess I should explain why I use bytes here. It's simple really. I like not wasting space. An int is 4 bytes, but a byte is one. 
  	}		//also, bytes are much easier to think about since I can define them using the 0b macro, and thus know which bits I want to flip
  	
  	
  	//pathList.forEach(p -> {  fill(#44FF0000); square(p[1]*50,p[0]*50,50);  });
  
  	//pathList.forEach(p -> {	print(" -> (" + p[0] + ", " + p[1] + ")");  });
  	//println();
  }
  
  private void aStarSearch(int[][] grid, int[] src, int[] dest, int unitType) {		//ooh look its the main event, the A* search! 
  	if (!isValid(src[0], src[1]) || !isValid(dest[0], dest[1]) ) {								//first we check if the tile is valid
  		println("Source or Dest is invalid");
  		return;  
  	}
		
		// might have to remove this check if I'm using it as a gen pathing for the AI			//what AI.
  	if (!isPassable(grid, src[0], src[1], unitType) || !isPassable(grid, dest[0], dest[1], unitType)) {			//anyways, then we check the passability of the destination and the source
  		println("Source or Dest is blocked");
  		return;
    }
    
  	if(isDestination(src[0], src[1], dest)) {								//also we check that the destination isn't just where we are already
  		println("Already here");
  		return;
  	}
  	
  	boolean[][] closedList = new boolean[ROWS][COLS];				//anyways we make a 2d bool array for telling us what tiles we've visited
  	Cell[][] cellDetails = new Cell[ROWS][COLS];						//and we make a graph, so to speak, out of the Cells from earlier
  
  	for (int i = 0; i < ROWS; i++) {
  		for (int j = 0; j < COLS; j++) {
  			cellDetails[i][j] = new Cell();											//this just fills  ^^^ that ^^^ with empty cells
  		}
  	}
  
  	int i = src[0], j = src[1];															//and we set i and j to the coordniates of the source tile
    cellDetails[i][j].f = 0;																//f is 0, because g and h are 0 and 0 + 0 = 0. wow
    cellDetails[i][j].g = 0;																//g is 0 because it doesn't cost us to move to where we already are
    cellDetails[i][j].h = 0;																//and h is 0 because... well it doesn't really matter because it's the source and we know the solution will include this tile
    cellDetails[i][j].parent_i = i;
    cellDetails[i][j].parent_j = j;
    
    Map<Double, int[]> openList = new HashMap<>();					//and then we make a hashmap of Double, int array as our open list, which tells us what cells we still have to traverse
    openList.put(0.0d, new int[] { i, j });									//and we put in the source cell 0.0 and the coordinates of the source
  	
  	boolean foundDest = false;															//and we make a new boolean to keep track of if we've found the destination
  
  	while (!openList.isEmpty()) {														//so while we've still got tiles to explore
  		Map.Entry<Double, int[]> p = openList.entrySet().iterator().next();	//we make a map entry object p that is the next tile's heuristic (i think) //wrong, its the f
  		for (Map.Entry<Double, int[]> q : openList.entrySet()) {						//and for each entry q in the openList
  			if (q.getKey() < p.getKey()) {																		//if q's heuristic (no, f) is smaller
  				p = q;																													//we set p to q
  			}
  		}
  		
  		openList.remove(p.getKey());																				//and we remove p from the open list
  		
  		i = p.getValue()[0];																								//and do stuff with it, first setting its coordinates to i and j
  		j = p.getValue()[1];
  		closedList[i][j] = true;																						//and adding it to the closed list so we don't traverse it again
  
  		double gNew, hNew, fNew;																						//and we make some doubles to catch our calculations that we'll put in p
  		
  		for (int k = -1; k <= 1; k += 2) {																	//this for loop just switches between -1 and 1, and does the following
        if (isValid(i, j + k)) {																					//so, if the tile horizontally adjacent in either direction exists
          if (isDestination(i, j + k, dest)) {														//first, check if it's the goal, and if it is...
            cellDetails[i][j + k].parent_i = i;														//set its coordniates to i and j
            cellDetails[i][j + k].parent_j = j;
            //println("The destination cell is found");
            tracePath(cellDetails, dest);																	//and run tracePath from the result
            foundDest = true;																							//set foundDest to true. Don't really need this at this point but eh
            return;																												//and end this function
          } else if (!closedList[i][j + k] && isPassable(grid, i, j + k, unitType)) {	//otherwise, if the tile isn't in the closedList and is passable
            gNew = cellDetails[i][j].g + 1; //Map.MapCells[i][j].terrain;	//and then, for the new g here, we add the g of the parent with... well it's one. it breaks otherwise
            hNew = calculateH(i, j + k, dest, unitType);									//then the new h is the huristic from this tile
            fNew = gNew + hNew;																						//and f is the sum of those two
            if (cellDetails[i][j + k].f == Double.POSITIVE_INFINITY || cellDetails[i][j + k].f > fNew) {	//now, if the cell we're at's f is poitive infinty or more than fNew
              openList.put(fNew, new int[] { i, j + k });									//throw it in the openList with the new f
              cellDetails[i][j + k].f = fNew;															//and add all the corect statistics to the cell
              cellDetails[i][j + k].g = gNew;
              cellDetails[i][j + k].h = hNew;
              cellDetails[i][j + k].parent_i = i;
              cellDetails[i][j + k].parent_j = j;
            }
          } 
        }
        
      }
      for (int k = -1; k <= 1; k += 2) {																		//and ditto all of that for the horizontal adjacencies
        if (isValid(i + k, j)) {
          if (isDestination(i + k, j, dest)) {
            cellDetails[i + k][j].parent_i = i;
            cellDetails[i + k][j].parent_j = j;
            println("The destination cell is found");
            tracePath(cellDetails, dest);
            foundDest = true;
            return;
          } else if (!closedList[i + k][j] && isPassable(grid, i + k, j, unitType)) {
            gNew = cellDetails[i][j].g + 1;//Map.MapCells[i][j].terrain;
            hNew = calculateH(i + k, j, dest, unitType);
            fNew = gNew + hNew;
            if (cellDetails[i + k][j].f == Double.POSITIVE_INFINITY || cellDetails[i + k][j].f > fNew) {
              openList.put(fNew, new int[] { i + k, j });
              cellDetails[i + k][j].f = fNew;
              cellDetails[i + k][j].g = gNew;
              cellDetails[i + k][j].h = hNew;
              cellDetails[i + k][j].parent_i = i;
              cellDetails[i + k][j].parent_j = j;
            }
          }
        }
      }
  	}
  	if (!foundDest) { println("Failed to find the destination cell. ended at:"); //and now, if all that failed somehow, which in some instances it can, we just give up
		}
		for (boolean[] ba : closedList) {	//and print the values of the closed list to see how it broke
        for (boolean b : ba) {				//this isn't really needed since if it breaks it's usually from a code error, but eh
          print((b? 1 : 0) + " ");
        }
          println();
      }
      //by the way, this function actually *doesn't* find the shortest path for a few reasons.
      //the main issue is the heuristic calculation. You saw the explanation for that, I'm sure. Water and mountains screw it up badly because we need to traverse Manhattan
      //the ideal heuristic knows what the actual distance is, but that's not helpful for us since we don't know that
      //but our heuristic overcompensates if there's water in the way, especially in both directions, and that screws up the pathing
      //well, that and the way we search the tiles
      //since we, for pretty much every tile, check every adjacency, if we're on a tile that happens to be next to the goal
      //even if this tile isn't on the ideal path, but is just a tile we're checking, it'll "find" the goal and return the path through that tile
      //which further breaks things. 
      //Ideally, we'd check the path from every edge of the goal to see if a path to one of those is better.
      //but from there we'd need to check the edges of each edge.
      //and whoops, the real solution is probably just using Dijkstra's algorithim.
      //But A* is (usually) computationally faster, and (usually) finds the shortest path
      //so I'm sticking with it (and also because I don't want to implement that with only a few days left)
      //*Note from the next night: Yen's algorithim actually would be better I think, computation wise, because the *second best* and *third best* might actually be the best after all
    }

  //hoo boy a method hidden under all of that!

  public ArrayList bfs(int[] origin, int unitType, int movement) { 			//a BFS algo for finding valid moves. pair with A* for the movement
  	ArrayList<MapCell> visited = new ArrayList<MapCell>();
  	Queue<Pair<MapCell, Integer>> q = new LinkedList<>(); 							//a q containing pairs of cells and movement "points" remaining at said cell
  	  	
  	visited.add(Map.MapCells[origin[0]][origin[1]]);										//add the source node to visited
  	q.add(new Pair(Map.MapCells[origin[0]][origin[1]], movement));			//and add it to the queue
  	
  	while (!q.isEmpty()) {																							//while we have a q, or unsearched cells...
  		Pair<MapCell, Integer> curr = q.poll();														//...store our current cell-point pair in curr
  		for (MapCell cell : curr.getKey().neighbors) {										//and for every neighbor of curr's cell...
  			if (!visited.contains(cell) && (curr.getValue() - cell.cost[unitType] >= 0)) {	//if that neighbor hasn't been visited already and we still have enough movement points to go to them
    			visited.add(cell);																						//we add the cell to vistited
    			q.add(new Pair(cell, curr.getValue() - cell.cost[unitType]));	//and add it to the q
  			} 
  		}
  	}
  	return visited;																											//and we return the resultant ArrayList of MapCells
  }
}
