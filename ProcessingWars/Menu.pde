//a PWindow class that handles multi-window stuff

class PWindow extends PApplet {
  PWindow() {
    super(); 
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }
  
  PImage hoverTile; 
  
  void settings() {
    fullScreen();
  }

  void setup() {
    windowResize(200,Map.hMap * 50+39);
    background(0);
    textFont(font);
    surface.setTitle("Menu");
    hoverTile = createImage(50,50,ARGB);
  }

  void draw() {
    hoverTile.copy( bricklayer.renderBuffer, hoverX - (hoverX % 50) , hoverY - (hoverY % 50) , 50 , 50 , 0, 0, hoverTile.width , hoverTile.height);
    //hoverTile.resize(100,100);
    hoverTile.loadPixels();
    
   	if (globalMenuToggle != menuToggleBuff) {					//a simple state change check so that we don't run setVisible every cycle
      menuToggleBuff = globalMenuToggle;							//because otherwise the main window becomes uninteractable cause its being shown again
      surface.setVisible(globalMenuToggle);
   }
		windowMove(posRef.getKey() + Map.wMap*50, posRef.getValue()-39);
		
		if (depRendFinished) {
  		background(0x0c);
			
			//push();
			noStroke();
			fill(0x60);
			rect(0,0,this.width,200);
			fill(0xa0);
			rect(5,5,this.width-10,190);
			

			debugInfo();
			
			//pop();
		}
		image(hoverTile,20,20);
  }
  
	void debugInfo() {
  	//this.wait();
		Map.mouseIs();
    text("SelectedID: " + selected,50,48);
    text("UnitID Map: ",50,60);
    for (int i = 0; i < Map.hMap; i++) {
      for (int j = 0; j < Map.wMap; j++) {
        text(Map.unitMap[i][j],50 + 10*j-50,72+12*i);
      }
    }
    
    text("Tile: " + clickedX + "," + clickedY,50-25,200);
    text("Tile Data:", 50-25, 212);
    text("Terrain: " + Map.MapCells[clickedY][clickedX].terrain,50-25,224);
    text("Defense: " + Map.MapCells[clickedY][clickedX].defense,50-25,236);
    text("Neighbors: ",50-25,248);
    for (int i = 0; i < Map.MapCells[clickedY][clickedX].neighbors.size(); i++) {
      //text("testpattern", 50, 260+12*i);
      text(Map.MapCells[clickedY][clickedX].neighbors.get(i).x + "," + Map.MapCells[clickedY][clickedX].neighbors.get(i).y, 50, 260+12*i);
    }
	}
	
	
  	
		
	
} 
