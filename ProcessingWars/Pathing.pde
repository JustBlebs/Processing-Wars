class Cell {
  int parent_i, parent_j;
  double f, g, h;

  Cell() {
      this.parent_i = 0;
      this.parent_j = 0;
      this.f = 0;
      this.g = 0;
      this.h = 0;
  }
}

class Pather {
	private int ROWS;		//the number of rows of the map (height)
  private int COLS;		//the number of columns (width)
  MapGrid mapData;
  int[] src;
  int[] dest;
  
  int[][] pathingGrid;
  
  Pather(MapGrid mapData/*, int[] src, int[] dest/*, int[][] pathingGrid*/) {
    this.mapData = mapData;
    ROWS = mapData.hMap;
    COLS = mapData.wMap;
    
    pathingGrid = new int[ROWS][COLS];
    for (int i = 0; i < ROWS; i++) {
    	for (int j = 0; j < COLS; j++) {
    		pathingGrid[i][j] = mapData.MapCells[i][j].isPassable ? 1 : 0;
    	}
    }	
  	/*this.src  = src ;
  	this.dest = dest;*/
  	//this.pathingGrid = pathingGrid;
  }
  
  public void pathIt(int[] src, int[] dest) {
    println();
    for (int i = 0; i < ROWS; i++) {
      for (int j = 0; j < COLS; j++) {
        print(pathingGrid[i][j] + ",");
      }
      println();
    }  
  	aStarSearch(pathingGrid, src, dest);
  }
  
  private boolean isValid(int row, int col) {
  	return (row >= 0) && (row < ROWS) && (col >= 0) && (col < COLS);
  }
  
  private boolean isPassable(int[][] grid, int row, int col) {
  	return grid[row][col] == 1;
  }
  
  private boolean isDestination(int row, int col, int[] dest) {
  	return row == dest[0] && col == dest[1];
  }
  
  private double calculateH(int row, int col, int[] dest) {	//calculate the Manhattan distance for the heuristic
  	return abs(row - dest[0]) + abs(col - dest[1]);					//aka the distance non-diagonally
  }
  
  private void tracePath(Cell[][] cellDetails, int[] dest) {
  	println("Path is");
  	int row = dest[0];
  	int col = dest[1];
  
  	Map<int[], Boolean> path = new LinkedHashMap<>();
  
  	while (!(cellDetails[row][col].parent_i == row && cellDetails[row][col].parent_j == col)) {
  		path.put(new int[] {row, col}, true);
  		int tempRow = cellDetails[row][col].parent_i;
  		int tempCol = cellDetails[row][col].parent_j;
  		row = tempRow;
  		col = tempCol;
  	}
  
  	path.put(new int[] {row,col}, true);
  	List<int[]> pathList = new ArrayList<>(path.keySet());
  	Collections.reverse(pathList);
  
  	pathList.forEach(p -> {						//i wish I could explain the lambda expression here but I cant
  		if (p[0] == 2 || p[0] == 1) {
  			print(" -> (" + p[0] + ", " + (p[1]) + ")");
  		} else {
  			print(" -> (" + p[0] + ", " + p[1] + ")");
  		}
  	});
  	println();
  }
  
  private void aStarSearch(int[][] grid, int[] src, int[] dest) {
  	if (!isValid(src[0], src[1]) || !isValid(dest[0], dest[1])) {
  		println("Source or Dest is invalid");
  		return;  
  	}
		
		// might have to remove this check if I'm using it as a gen pathing for the AI
  	if (!isPassable(grid, src[0], src[1]) || !isPassable(grid, dest[0], dest[1])) {
  		println("Source or Dest is blocked");
  		return;
    }
    
  	if(isDestination(src[0], src[1], dest)) {
  		println("Already here");
  		return;
  	}
  	
  	boolean[][] closedList = new boolean[ROWS][COLS];
  	Cell[][] cellDetails = new Cell[ROWS][COLS];
  
  	for (int i = 0; i < ROWS; i++) {
  		for (int j = 0; j < COLS; j++) {
  			cellDetails[i][j] = new Cell();
        cellDetails[i][j].f
            = Double.POSITIVE_INFINITY;
        cellDetails[i][j].g
            = Double.POSITIVE_INFINITY;
        cellDetails[i][j].h
            = Double.POSITIVE_INFINITY;
        cellDetails[i][j].parent_i = -1;
        cellDetails[i][j].parent_j = -1;
  		}
  	}
  
  	int i = src[0], j = src[1];
    cellDetails[i][j].f = 0;
    cellDetails[i][j].g = 0;
    cellDetails[i][j].h = 0;
    cellDetails[i][j].parent_i = i;
    cellDetails[i][j].parent_j = j;
    
    Map<Double, int[]> openList = new HashMap<>();
    openList.put(0.0d, new int[] { i, j });
  	
  	boolean foundDest = false;
  
  	while (!openList.isEmpty()) {
  		Map.Entry<Double, int[]> p = openList.entrySet().iterator().next();
  		for (Map.Entry<Double, int[]> q : openList.entrySet()) {
  			if (q.getKey() < p.getKey()) {
  				p = q;
  			}
  		}
  		
  		openList.remove(p.getKey());
  		
  		i = p.getValue()[0];
  		j = p.getValue()[1];
  		closedList[i][j] = true;
  
  		double gNew, hNew, fNew;
  		
  		//come back to condense this into the two for loops like before
  
  
  		if (isValid(i - 1, j)) {
                if (isDestination(i - 1, j, dest)) {
                    cellDetails[i - 1][j].parent_i = i;
                    cellDetails[i - 1][j].parent_j = j;
                    System.out.println(
                        "The destination cell is found");
                    tracePath(cellDetails, dest);
                    foundDest = true;
                    return;
                }
                else if (!closedList[i - 1][j]
                         && isPassable(grid, i - 1, j)) {
                    gNew = cellDetails[i][j].g + 1;
                    hNew = calculateH(i - 1, j, dest);
                    fNew = gNew + hNew;

                    if (cellDetails[i - 1][j].f
                            == Double.POSITIVE_INFINITY

                        || cellDetails[i - 1][j].f > fNew) {
                        openList.put(
                            fNew, new int[] { i - 1, j });

                        cellDetails[i - 1][j].f = fNew;
                        cellDetails[i - 1][j].g = gNew;
                        cellDetails[i - 1][j].h = hNew;
                        cellDetails[i - 1][j].parent_i = i;
                        cellDetails[i - 1][j].parent_j = j;
                    }
                }
            }





            // 2nd Successor (South)
            if (isValid(i + 1, j)) {
                if (isDestination(i + 1, j, dest)) {
                    cellDetails[i + 1][j].parent_i = i;
                    cellDetails[i + 1][j].parent_j = j;
                    System.out.println(
                        "The destination cell is found");
                    tracePath(cellDetails, dest);
                    foundDest = true;
                    return;
                }
                else if (!closedList[i + 1][j]
                         && isPassable(grid, i + 1, j)) {
                    gNew = cellDetails[i][j].g + 1;
                    hNew = calculateH(i + 1, j, dest);
                    fNew = gNew + hNew;

                    if (cellDetails[i + 1][j].f
                            == Double.POSITIVE_INFINITY
                        || cellDetails[i + 1][j].f > fNew) {
                        openList.put(
                            fNew, new int[] { i + 1, j });

                        cellDetails[i + 1][j].f = fNew;
                        cellDetails[i + 1][j].g = gNew;
                        cellDetails[i + 1][j].h = hNew;
                        cellDetails[i + 1][j].parent_i = i;
                        cellDetails[i + 1][j].parent_j = j;
                    }
                }
            }

            // 3rd Successor (East)
            if (isValid(i, j + 1)) {
                if (isDestination(i, j + 1, dest)) {
                    cellDetails[i][j + 1].parent_i = i;
                    cellDetails[i][j + 1].parent_j = j;
                    System.out.println(
                        "The destination cell is found");
                    tracePath(cellDetails, dest);
                    foundDest = true;
                    return;
                }
                else if (!closedList[i][j + 1]
                         && isPassable(grid, i, j + 1)) {
                    gNew = cellDetails[i][j].g + 1;
                    hNew = calculateH(i, j + 1, dest);
                    fNew = gNew + hNew;

                    if (cellDetails[i][j + 1].f
                            == Double.POSITIVE_INFINITY
                        || cellDetails[i][j + 1].f > fNew) {
                        openList.put(
                            fNew, new int[] { i, j + 1 });

                        cellDetails[i][j + 1].f = fNew;
                        cellDetails[i][j + 1].g = gNew;
                        cellDetails[i][j + 1].h = hNew;
                        cellDetails[i][j + 1].parent_i = i;
                        cellDetails[i][j + 1].parent_j = j;
                    }
                }
            }

            // 4th Successor (West)
            if (isValid(i, j - 1)) {
                if (isDestination(i, j - 1, dest)) {
                    cellDetails[i][j - 1].parent_i = i;
                    cellDetails[i][j - 1].parent_j = j;
                    System.out.println(
                        "The destination cell is found");
                    tracePath(cellDetails, dest);
                    foundDest = true;
                    return;
                }
                else if (!closedList[i][j - 1]
                         && isPassable(grid, i, j - 1)) {
                    gNew = cellDetails[i][j].g + 1;
                    hNew = calculateH(i, j - 1, dest);
                    fNew = gNew + hNew;

                    if (cellDetails[i][j - 1].f
                            == Double.POSITIVE_INFINITY
                        || cellDetails[i][j - 1].f > fNew) {
                        openList.put(
                            fNew, new int[] { i, j - 1 });

                        cellDetails[i][j - 1].f = fNew;
                        cellDetails[i][j - 1].g = gNew;
                        cellDetails[i][j - 1].h = hNew;
                        cellDetails[i][j - 1].parent_i = i;
                        cellDetails[i][j - 1].parent_j = j;
                    }
                }
            }
						
  
  	}
  	if (!foundDest) { println("Failed to find the destination cell"); }
  }
  
  //hoo boy a method hidden under all of this!

  public ArrayList bfs(int[] origin, int unitType, int movement) { //a BFS algo for finding valid moves. pair with A* for the movement
  	ArrayList<MapCell> visited = new ArrayList<MapCell>();
  	Queue<Pair<MapCell, Integer>> q = new LinkedList<>(); //a q containing pairs of cells and movement "points" remaining at said cell
  	  	
  	visited.add(Map.MapCells[origin[0]][origin[1]]);		//add the source node to visited
  	q.add(new Pair(Map.MapCells[origin[0]][origin[1]], movement));			//and add it to the queue
  	//println(q.peek().getKey().x + ", " + q.peek().getKey().y);
  	
  	while (!q.isEmpty()) {															//while we have a q, or unsearched cells...
  		//println("q is not empty");
  		Pair<MapCell, Integer> curr = q.poll();						//...store our current cell-point pair in curr
  		//println("current movement: " + curr.getValue());
  		for (MapCell cell : curr.getKey().neighbors) {		//and for every neighbor of curr's cell...
  		//if that neighbor hasn't been visited already and we still have enough movement points to go to them
  			//println("in iter " + cell.x + cell.y);
  			//println("cost of movement to cell: " + cell.cost[unitType]);
  			if (!visited.contains(cell) && (curr.getValue() - cell.cost[unitType] >= 0)) {					
    			//println("in the if");
    			visited.add(cell);
    			q.add(new Pair(cell, curr.getValue() - cell.cost[unitType]));
  			} 
  		}
  			
  	}
  	/*for (MapCell cell : visited) {
  		println(cell.x + ", " + cell.y);
  	}*/
  	return visited;
  }
}
