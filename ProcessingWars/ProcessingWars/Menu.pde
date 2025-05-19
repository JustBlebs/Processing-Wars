class PWindow extends PApplet {						//a PWindow class that handles multi-window stuff
  PWindow() {															//PWindow code courtesy of https://gist.github.com/atduskgreg/666e46c8408e2a33b09a. I think, I feel like I got it off of a forum but I think this is where that came from
    super(); 
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);	//the way this works is essentially creating another sketch within the confines of the original sketch
  }
  
  PImage hoverTile;												//so I can declare new "global" public variables within it, like the hovered tile image
  PImage selectedTile;										//the selected tile image
  boolean[] activeButtons = {true,true,true,true,true};	//and a boolean array for knowing which buttons are active
  
  void settings() {												//to make this window windowless without too much shenannigans that involve using older frameworks
    fullScreen();													//we set the screen to fullscreen before anything else happens using settings()
  }

  void setup() {													//then in setup,
    delay(300);														//first we wait 300ms to avoid any odd collisions with the main window being created, since this is separately threaded but same renderer
    windowResize(200,Map.hMap * 50+39);		//and then we resize the window to the 200*height of the main window, plus the size of the titlebar
    delay(100);														//then we wait another 100ms, again to avoid some more collisions and ensure we don't do anything while it handles itself
    background(0);												//then the background is black
    textFont(font);												//the font is our font
    surface.setTitle("Menu");							//the title (which we can't see) is Menu
    hoverTile = createImage(50,50,ARGB);	//and we create the empty buffers for hover and se;ected tiles
    selectedTile = createImage(50,50,ARGB);
  }

  void draw() {	
    //first thing we do on each cycle is get the hovered tile from the bricklayer's renderBuffer
    hoverTile.copy( bricklayer.renderBuffer, hoverX - (hoverX % 50) , hoverY - (hoverY % 50) , 50 , 50 , 0, 0, hoverTile.width , hoverTile.height);
    hoverTile.loadPixels();
    if (selected != -1) {		//and then, if we've selected something, get that tile too the same way
    	selectedTile.copy(bricklayer.renderBuffer, uList.Units.get(selected).unitX*50 , uList.Units.get(selected).unitY*50 , 50 , 50 , 0, 0, hoverTile.width , hoverTile.height);
    	hoverTile.loadPixels();
    }
    
   	if (globalMenuToggle != menuToggleBuff) {														//a simple state change check so that we don't run setVisible every cycle
      menuToggleBuff = globalMenuToggle;																//because otherwise the main window becomes uninteractable cause its being shown again and again and again
      surface.setVisible(globalMenuToggle);
   	}
		windowMove(posRef.getKey() + Map.wMap*50, posRef.getValue()-39);		//reposition the window such that its always to the right of the gameplay window
	
		background(0x0c);																										//then we make the background a nice grey
		noStroke();																													//nostroke
		fill(0x60);																													//a lighter gray
		rect(0,0,this.width,490);																						//the "background" box
		
		fill(0xa0);																													//and an even lighter gray
		rect(5,5+50,this.width-10,190);																			//the hovered tile info box box
		rect(5,5,this.width-10,45);																					//the turn/money/player info box box at the very top
		image(hoverTile,20,20+50);																					//the hovered tile
		fill(0);																														//and we switch to black for the text
		text("Day: " + day,15,25);																					//what day it is
		textAlign(RIGHT);																										//we switch to the right
		text("Turn: " + players[user].name,this.width-15,25);								//whose turn it is
		textAlign(LEFT);																										//back to the left
		text("Money: " + players[user].money,15,40);												//and the money of the current player
		text(tileNameOf(Map.MapCells[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50].terrain),80,35+50);					//then the hover info, starting with the tile name
		text("Defense: " + Map.MapCells[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50].defense,80,55+50);				//then the tile's defense
		if (Map.MapCells[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50].isBuilding) {														//and if it's a building
  		text("Capture: " + Map.MapCells[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50].buildingHealth,80,75+50);	//its capture/health
		} if (Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50] != -1) {																	//and if its a unit
			text("Unit Info: ",25,95+50);																																											//the unit info
			try {																																																							//we try this because sometimes it looks for a noexistsent unit
  			text(nameOf(uList.Units.get(Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50]).unitType),25,115+50);		//so assumedly, if theres a name, display it
  			text("Health: " + uList.Units.get(Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50]).health,25,135+50);	//and the health
  			text("Ammo: " + uList.Units.get(Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50]).ammo,25,155+50);			//and ammo
  			text("Fuel: " + uList.Units.get(Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50]).fuel,25,175+50);			//and fuel
  		} catch(IndexOutOfBoundsException m) {																																						//and if it explodes, just move on
  			println(m + ". Error in unitInfoDisplay");																																			//and print it so we know it happened
  		}
		}

		//the buttons!!! aka hell
    fill(!activeButtons[0]? 0x30: isInBounds(5,200+50,(this.width-15)/2,95, this)? 255: 0xa0);													//each of these checks if the button is active or not
    rect(5,200+50,(this.width-15)/2,95);																																								//and fills it light or dark accordingly, this is the top left
    fill(!activeButtons[1]? 0x30: isInBounds(10+(this.width-15)/2,200+50,(this.width-15)/2,95, this)? 255: 0xa0);			
    rect(10+(this.width-15)/2,200+50,(this.width-15)/2,95);																															//top right
    fill(!activeButtons[2]? 0x30: isInBounds(5,300+50,(this.width-15)/2,95, this)? 255: 0xa0);
    rect(5,300+50,(this.width-15)/2,95);																																								//bottom left
    fill(!activeButtons[3]? 0x30: isInBounds(10+(this.width-15)/2,300+50,(this.width-15)/2,95, this)? 255: 0xa0);
    rect(10+(this.width-15)/2,300+50,(this.width-15)/2,95);																															//bottom right
    fill(!activeButtons[4]? 0x30: isInBounds(5,455,this.width-10,30,this)? 255: 0xa0);
    rect(5,455,this.width-10,30);																																												//and finally, the end turn button at the bottom
    push();  																													//we push here because of text align and some other shenaniganry
    fill(0);																													//we go to black for the text
    textAlign(CENTER,CENTER);																					//and align the text to the center both ways
    text(selectionState != 4? "End Turn" : "Cancel",100,470);					//and for the end turn button, it's always either end turn or cancel if in the fire state
    switch (selectionState) {																					//so we go to the selectoin state and get the rest from there
    	case 0: 																												//the default menu case, 0
    		activeButtons = new boolean[] {true,true,true,true,true};			//all buttons should be active
        text("Save",50,250+50);																				//i'm not gonna annotate the text since you just have to read it and it explains
        text("Load",150,250+50);
        text("Back to\nMenu",50,350+50);
        text("Help",150,350+50);
    	break;
    	case 1:																													//selected unit case w/ deselect button
    		try {																													//again in a try in case stuff gets weird
    		activeButtons = new boolean[] {true,
  																		 uList.Units.get(selected).enemyNeighbors().getValue(),																							//this is the fire condition
  																		 Map.MapCells[uList.Units.get(selected).unitY][uList.Units.get(selected).unitX].isBuilding 					//this is the capture condition
  																			&& Map.MapCells[uList.Units.get(selected).unitY][uList.Units.get(selected).unitX].buildingOwner != uList.Units.get(selected).owner,
  																		 true,
																			 false};	
				} catch (IndexOutOfBoundsException m) {	//this try-catch is now unneccessary, I'm pretty sure. I'll keep it until I can confirm
  				selectionState = 0;
  				println(m);
  				break;
				}
        text("Wait",50,250+50);
        text("Fire",150,250+50);
        text("Capture",50,350+50);
        text("Deselect",150,350+50);
    	break;
    	case 2: //the movement confirmation state, 
        activeButtons = new boolean[] {true,uList.Units.get(selected).enemyNeighbors().getValue(),true,false,false};
        text("Hold",50,250+50);
        text("Fire",150,250+50);
        text("Cancel",50,350+50);
        //text(,150,350+50);
      break;
      case 3: break;	//reserved for later if i really need it. I miscalculated at some point how many things I needed
      case 4: 				//case 4 is a fun one: the fire state. We don't have buttons, but we do have UI for enemy unit fight matchups
      	activeButtons = new boolean[] {false,false,false,false,true};
      	textAlign(LEFT);
      	fill(0xa0);
      	rect(5,250,this.width-10,200);		//so I cover up the buttons	with a rectangle
      	fill(0);
      	image(selectedTile,20,270);				//I draw the selected tile with the current unit
      	text(nameOf(uList.Units.get(selected).unitType),85,285);								//its name
        text("Health: " + uList.Units.get(selected).health,85,300);							//health
        text("Ammo: " + uList.Units.get(selected).ammo,85,315);									//ammo, since that kinda matters
        if (Map.MapCells[(hoverY - (hoverY % 50))/50 ][(hoverX - (hoverX % 50))/50].controller != uList.Units.get(selected).owner 
        		&& Map.MapCells[(hoverY - (hoverY % 50))/50 ][(hoverX - (hoverX % 50))/50].controller != -1
        		&& uList.Units.get(selected).enemyNeighbors().getKey().contains(Map.MapCells[(hoverY - (hoverY % 50))/50 ][(hoverX - (hoverX % 50))/50])) {
        		// ^^^ and if the tile we're hovering over has an enemy unit on it and is in the firerange
          text("vs.",20 ,345);																									//we write the matchup
        	image(hoverTile, 20,355);																							//draw the hovered enemy
        	try {																																	//and again, try this just in case it breaks
            text(nameOf(uList.Units.get(Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50]).unitType),85,370);				//we take the name and health of the hovered
            text("Health: " + uList.Units.get(Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50]).health,85,385);
            //text("Ammo: " + uList.Units.get(Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50]).ammo,25,155+50);
          } catch(IndexOutOfBoundsException m) {
            println(m + ". Error in unitInfoDisplay");
          }
          text("Defense: " + Map.MapCells[(hoverY - (hoverY % 50))/50 ][(hoverX - (hoverX % 50))/50].defense, 85, 400);									//as well as the defense of the target
          float predictedDMG = damageCalculator(uList.Units.get(selected), uList.Units.get(Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50]), true);
          // ^^ and here, we get the predicted damage between the two units. This one is the selected fighting the hovered
          Unit after;			//and we prep a Unit to clone to so that we can alter it's health as if it's been attacked
          try {						//for some reason, to make custom objects cloneable, you have to make it throw an excpetion even though it is cloneable
          	after = (Unit) uList.Units.get(Map.unitMap[(hoverY - (hoverY % 50))/50][(hoverX - (hoverX % 50))/50]).clone();	//but whatever. We clone the attacked unit
          	after.health -= predictedDMG;																																										//we subtract the predicted DMG from the clone's health
          	if (!(after.unitType == 8 && after.unitType == 9)) {																														//if the attacked isn't an indrect fire unit
          		text("Return Fire: " + floor(10*damageCalculator(after, uList.Units.get(selected), true)) + "%",20,440);			//we show the result of the returned damage
          	} else {																																																				//otherwise if it is,
          		text("Return Fire: " + 0 + "%",20,440);																																				//we show zero
          	}
        	} catch (CloneNotSupportedException e) {
          	e.printStackTrace();
          }
          text("Predicted DMG: " + floor(predictedDMG) + "%",20,420);																												//and then we show the predicted damage against the target
          
        }
      break;      
      case 5: //the factory state, which is a whole other mess, because again, we hide the original buttons. Excpet we still use their activity states.
      	activeButtons = new boolean[] {!(costOf(scrollPos + 1) >= players[user].money),			//this is just to check if the unit on the button can actually be afforded
                                       !(costOf(scrollPos + 2) >= players[user].money), 
                                       !(costOf(scrollPos + 3) >= players[user].money), 
                                       !(costOf(scrollPos + 4) >= players[user].money),
                                     	 false																					};
      	textAlign(LEFT);
      	for(int i = 1; i < 5; i++) {		//for each button, statring from one to make the costOf work correctly with scrollPos
        	
      		fill(scrollPos % 2 == 0? i % 2 == 0? 0xa0 : 0xcc : i % 2 == 0? 0xcc : 0xa0);	//this is funky, but, if scrollPos is even, and if the button is even, dark, odd, light, odd even, light, odd odd, dark
      		if (costOf(scrollPos + i) >= players[user].money) {					//and if it's too much money, darken it more
      			fill(0x30);
      		}
          rect(5,200+(50*(i-1))+50,this.width-10,50);														//draw said button			
          image(bricklayer.getIndivSprite(39+scrollPos+i),5,200+50+(50*(i-1)));	//grab the sprite of the unit, which is pink because that made it eaiser to pick out which colors to swap
          fill(0);																															//then black for the text
          text(nameOf(scrollPos + i),65,225+50+(50*(i-1)));											//and draw the name
          text("Cost:" + costOf(scrollPos + i),65,240+50+(50 * (i - 1)));				//and the cost
      	}
      break;
    }
    pop();																																			//and we finally pop that push from way back to avoid textAlign mishaps
    if (selectionState != 5) {																									//oh, and if we're hovering over some button outside of the factory state
    	cursor(																																		//we make the cursor a pointer finger if the button we're on is active, and do nothing if it isn't
          ((isInBounds(5,200+50,(this.width-15)/2,95, this) && activeButtons[0])
        || (isInBounds(10+(this.width-15)/2,200+50,(this.width-15)/2,95, this) && activeButtons[1])
        || (isInBounds(5,300+50,(this.width-15)/2,95, this) && activeButtons[2])
        || (isInBounds(10+(this.width-15)/2,300+50,(this.width-15)/2,95, this) && activeButtons[3]))
        || (isInBounds(5,455   ,this.width-10,30,this) && activeButtons[4])
        ? 12 : 0); 
		} else {
			cursor(																																		//ditto for the factory state, but with the positions of the factory buttons
					((isInBounds(5,200+50,this.width-10,50,this) && activeButtons[0])
				|| (isInBounds(5,250+50,this.width-10,50,this) && activeButtons[1])
				|| (isInBounds(5,300+50,this.width-10,50,this) && activeButtons[2])
				|| (isInBounds(5,350+50,this.width-10,50,this) && activeButtons[3])
				|| (isInBounds(5,455	 ,this.width-10,30,this) && activeButtons[4]))
				? 12 : 0);
		}
		//text(selected, 5,height-30);																								
  }
  
  int scrollPos = 0;		//scrollPos! from up there! declared down here! Ugh. Then again, I guess its easier to see it here with the actuall mouse scrolling
  
  void mouseWheel(MouseEvent e) {																								//mousewheel events! solely for the factory state.
  	if (selectionState == 5 && isInBounds(5,200+50,this.width-10,200,this)) {		//if we're in the factory area and in the factory state
  		scrollPos = constrain(scrollPos+e.getCount(),0,5);												//then constrain scrollPos + the event count (±1) between 0 and 5
  	}
  }
  
  
  
  void mousePressed() {																													//oh... the mouse press handling.
    if (selectionState != 4 && activeButtons[4] && isInBounds(5,455,this.width-10,30,this)) {	//first thing we've got here is, if we're not in the fire state and the bottom is active
    	endTurn();																																							//and we press, we end the turn
    } else if (selectionState == 4 && activeButtons[4] && isInBounds(5,455,this.width-10,30,this)){		//but if it's the fire state
    	selectionState = 1;																																			//then cancel the fire state and go ... somewhere
    }
  	switch (selectionState) {
  		case 0: 
  			if (isInBounds(5,200+50,(this.width-15)/2,95, this) && activeButtons[0]) {
  				//The save function
  				saveStateToFile();
  			}
  			if (isInBounds(10+(this.width-15)/2,200+50,(this.width-15)/2,95, this) && activeButtons[1]) {
  				loadStateFromFile();
  			}
  			if (isInBounds(5,300+50,(this.width-15)/2,95, this) && activeButtons[2]) {
  				//go back to the menu
  				saveStateToFile();
  				exit();
  			}
  			if (isInBounds(10+(this.width-15)/2,300+50,(this.width-15)/2,95, this) && activeButtons[3]) {
  				//brings up the help dialog
  			}
  		break;
  		case 1: 
        if (isInBounds(5,200+50,(this.width-15)/2,95, this) && activeButtons[0]) {
          uList.Units.get(selected).hold();
        }
        if (isInBounds(10+(this.width-15)/2,200+50,(this.width-15)/2,95, this) && activeButtons[1]) {
          selectionState = 4;
        }
        if (isInBounds(5,300+50,(this.width-15)/2,95, this) && activeButtons[2]) {
          uList.Units.get(selected).capture();															
        }
        if (isInBounds(10+(this.width-15)/2,300+50,(this.width-15)/2,95, this) && activeButtons[3]) {
  				selectionState = 0;
    			selected = -1;
        }
      break;
      case 2: 
        if (isInBounds(5,200+50,(this.width-15)/2,95, this) && activeButtons[0]) {				//complete movement
          uList.Units.get(selected).hold();
        }
        if (isInBounds(10+(this.width-15)/2,200+50,(this.width-15)/2,95, this) && activeButtons[1]) {
          selectionState = 4;
        }
        if (isInBounds(5,300+50,(this.width-15)/2,95, this) && activeButtons[2]) {
          uList.Units.get(selected).cancel();                              
        }
        
      break;
      case 3: break;				//i dont actually need this anymore, but for sacntity's state, I'll reserve it just in case
      case 4:
      	
      	//this won't be buttons, just data on targets, so no clickable stuff here I'm pretty sure
      
      
      break;
      case 5:
      	if (isInBounds(5,200+50,this.width-10,50,this) && activeButtons[0]) {
        	players[user].money -= costOf(scrollPos+1);
      		uList.addUnit(new Unit(user,clickedX,clickedY,scrollPos+1));
      		selectionState = 0;		
      	}
      	if (isInBounds(5,250+50,this.width-10,50,this) && activeButtons[1]) {
      		players[user].money -= costOf(scrollPos+2);
          uList.addUnit(new Unit(user,clickedX,clickedY,scrollPos+2));
          selectionState = 0;    
        }
        if (isInBounds(5,300+50,this.width-10,50,this) && activeButtons[2]) {
      		players[user].money -= costOf(scrollPos+3);
          uList.addUnit(new Unit(user,clickedX,clickedY,scrollPos+3));
          selectionState = 0;    
        }	
        if (isInBounds(5,350+50,this.width-10,50,this) && activeButtons[3]) {
      		players[user].money -= costOf(scrollPos+4);
          uList.addUnit(new Unit(user,clickedX,clickedY,scrollPos+4));
          selectionState = 0;    
        }
      
      break;
  	}	
  
  }
  
  
  
	void debugInfo() {
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
      text(Map.MapCells[clickedY][clickedX].neighbors.get(i).x + "," + Map.MapCells[clickedY][clickedX].neighbors.get(i).y, 50, 260+12*i);
    }
	}	
	
} 
