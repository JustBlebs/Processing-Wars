class Bricklayer {																									//okay, the bricklayer, aka my graphics handler
	PImage tilesheet;																									//we've got a tilesheet image
	PImage tileBuffer;																								//a buffer that holds a single tile
	PImage indivBuffer;																								//a buffer for individually draw things
	PGraphics renderBuffer; 																					//and a buffer for the whole screen that gets written all at once, for a sort of pseudo dual buffer effect
	int wSheet;																												//we also store the width and height of the tilesheet
	int hSheet;
	int sTile;																												//and the size of each tile

	Bricklayer(PImage tilesheet, int sTile) {													//the constructor
		this.tilesheet = tilesheet;																			//tilesheet is tilesheet
		this.sTile = sTile;																							//tilesize is tilesize
		
		wSheet = tilesheet.width/sTile;																	//the width is the tilesheet width over the tile size (assuming the tiles are square cause why wouldn't they be)
		hSheet = tilesheet.height/sTile;																//and ditto for heigh by height
		tileBuffer = createImage(sTile,sTile,ARGB);											//then we make the empty images, with ARGB handling and a size of sTile^2
		indivBuffer = createImage(sTile,sTile,ARGB);
		renderBuffer = createGraphics(Map.wMap*50,Map.hMap*50);					//and we make the renderBuffer image based on the map's width and height as canvas dimensions
	}

	  Bricklayer(String path, int sTile) {														//this constructor is the same, just using a filepath instead of an image
    tilesheet = loadImage(path);
    this.sTile = sTile;
    
    wSheet = tilesheet.width/sTile;
    hSheet = tilesheet.height/sTile;
    tileBuffer = createImage(50,50,ARGB);
    indivBuffer = createImage(50,50,ARGB);
    renderBuffer = createGraphics(Map.wMap*50,Map.hMap*50);
  }

	public void drawMap() {								//the assumption is that we only really need to deterministically make the map once via this, and we can just draw on top of the "image"
		renderBuffer.beginDraw();						//so we begin the draw, as if this is a regular PApplet and we're in the draw() method
		
		for (int i = 0; i < Map.hMap; i++) {			//for the height
			for (int j = 0; j < Map.wMap; j++) {			//and the width
				byte count = 0b00000000;									//we make an empty byte
  			if (!(Map.MapCells[i][j].terrain == 1)) {				//for non-water cells (will have to deal with bridges later, methinks)
					//(Map.MapCells[i][j].terrain == 0 || (Map.MapCells[i][j].terrain >= 3 && Map.MapCells[i][j].terrain <= 5) || (Map.MapCells[i][j].terrain >= 14 && Map.MapCells[i][j].terrain <= 16)) {
					getSprite(0);																	//get the land sprite and but it in the tile buffer
					switch (Map.MapCells[i][j].terrain) {					//and then, put on top of it the corresponding sprite for buildings, terrain
						case 3: getSprite(16); 	break;							//forest
						case 5: getSprite(8); 	break;							//mountain
						case 12: getSprite(32); break;							//city
						case 13: getSprite(24); break;							//p1 factory
						case 14: getSprite(33); break;							//p1 hq
						case 15: getSprite(24); break;							//p2 factory
						case 16: getSprite(33); break;							//p2 hq
						case 2:																			//and then if it's a road
							for (int k = 0; k < Map.MapCells[i][j].neighbors.size(); k++) {	//we check the neigbors of the tile
  							count <<= 1;																									//we shift left by one bit (which causes issues for edge handling, but there aren't roads on edges in my cases yet)
  							count = (Map.MapCells[i][j].neighbors.get(k).terrain == 2 || Map.MapCells[i][j].neighbors.get(k).terrain == 4 ? (byte)(count | 0b00000001) : count);
  							// ^^ and if the terrain there is a road or a bridge, we flip the least significant/rightmost bit. if not, we do nothing
  						} switch (count) {														//and from the results, we determine which road sprite to use
  							case 0b00001111: getSprite(14); break;			// +
                case 0b00001100: getSprite(29); break;			// |
                case 0b00000011: getSprite(30); break;			// -
                
                case 0b00001000: getSprite(29); break;      //endcap, vert
                case 0b00000100: getSprite(29); break;    	//endcap, vert
                case 0b00000010: getSprite(30); break;   		//endcap, horiz
                case 0b00000001: getSprite(30); break;    	//endcap, horiz
                
  							case 0b00000101: getSprite(5);  break;			
  							case 0b00001001: getSprite(21); break;
  							case 0b00000110: getSprite(7); 	break;
  							case 0b00001010: getSprite(23); break;
  
  							case 0b00000111: getSprite(6);  break;      
                case 0b00001101: getSprite(13); break;
                case 0b00001110: getSprite(15); break;
                case 0b00001011: getSprite(22); break;
  						}
					} if (Map.MapCells[i][j].buildingOwner == 0) {		//and down here, if the building owner is p1,
						swapColor(#D77BBA, #0000FF);										//swap the hot pink with blue
					} if (Map.MapCells[i][j].buildingOwner == 1) {		//if p1,
						swapColor(#D77BBA, #FF0000);										//red
					} if (Map.MapCells[i][j].buildingOwner == -1) {		//and if noone
            swapColor(#D77BBA, #A0A0A0);										//a light grey
          } 
				} else {																						//otherwise, if it's water, we do a whole lot more
  				//just replace all of this with edge casing. Don't need to do too much fancy if the grid is rectangular anyways, aka we know where the lowest and highest rows and cols are
					for (int k = 0; k < Map.MapCells[i][j].neighbors.size(); k++) {									//for each neighbor,
						 if (i == Map.hMap - 1 && k == 0) {										//first, if we're on the bottom edge and we're starting this loop
              count <<= 1;      																	//shift a bit
              count |= 0b00000001;																//and immediately make the rightmost bit 1, because this sets the bottom adjacency to water
            }
						count <<= 1;																					//then, as normal, shift 1 left
						count = (Map.MapCells[i][j].neighbors.get(k).terrain == 1 ? (byte)(count | 0b00000001) : count); //and insert 1 at the last position if water, and 0 if not via bitwise OR
					
						if (i == 0 && k == 0) {																//if we're at the top edge and the beginning of the loop
							count <<= 1;      																	//shift one left
							count |= 0b00000001;																//and set the top adjacency to true
						} if (j == 0 && k == 1) {															//if we're on the left edge and this is the second cycle (which doen't work as it should, but is fixed later)
              count <<= 1;                                        //shift one left 			
              count |= 0b00000001;																//and set, supposedly, the left adjacency bit to true
            } if (j == Map.wMap - 1 && k == Map.MapCells[i][j].neighbors.size()-1) {		//and if we're on the right edge and this is the last run of the loop
              count <<= 1;      																	//you know the drill.
              count |= 0b00000001;
            }
 					}	if ((i == Map.hMap - 1 || i == 0) && (count == 0b00000111 || count == 0b00001011)) {	//now quickly check that, if we're in the last loop and count is either of those two,
   					//its a very band-aid fix but this flips the up-down bits for land edges against the map edge, because I can't for the life of me figure out why they're flipped otherwise
 						count ^= 0b00001100;
 					}
 					//then we use the byte we get to determine what water tile to draw, 
					switch (count) {	//since the prior process gives us a unique identifier for each possible set of adjacencies
						case 0b00000000: getSprite(25); break;		//lake (all land)
						case 0b00001111: getSprite(11); break; 		//sea (all water)
						//inlets (1 water, 3 land)
						case 0b00001000: getSprite(1);	break; 		//inlet mouth down
						case 0b00000100: getSprite(17); break;		//inlet mouth up
            case 0b00000010: getSprite(26); break;   //inlet mouth left
            case 0b00000001: getSprite(28); break;    //inlet mouth right
  					//beaches (3 water, 1 land)
  					case 0b00001011: getSprite(19); break;    //beach land below
            case 0b00000111: getSprite(3); 	break;    //beach land up
            case 0b00001101: getSprite(10); break;   	//beach land left
            case 0b00001110: getSprite(12); break;    //beach land right
            //bays (2 water, 2 land, as pairs)
            case 0b00001001: getSprite(18); break;    //bay land SW
            case 0b00001010: getSprite(20); break;    //bay land SE
            case 0b00000101: getSprite(2); 	break;    //bay land NW
            case 0b00000110: getSprite(4); 	break;    //bay land NE
            //rivers (2 water, 2 land, opposites)
            case 0b00001100: getSprite(27);  break;   //N-S river
            case 0b00000011: getSprite(9);   break;   //E-W river           
  					
					}
				} if (ifr.contains(Map.MapCells[i][j]) && (selectionState == 1 || selectionState == 2)) {		//also, while we're here, if this tile is in the ifr ArrayList and we're on a unit
					getSprite(36);																																						//draw the fire range sprite too
				} if (Map.unitMap[i][j] != -1) {																									//and now for unit handling
  				//should probably (absolutely) put this in a try-catch because for some reason it's having a heart attack rendering when I add a new unit
					switch(uList.Units.get(Map.unitMap[i][j]).unitType) {														//depending on the type
    				case 1: getSprite(40,uList.Units.get(Map.unitMap[i][j]).owner == 1) ; break;	//draw whatever unit, and if it's p2's, flip it horizontally
    				case 2: getSprite(41,uList.Units.get(Map.unitMap[i][j]).owner == 1) ; break;	//I'm not writing out each unit, just look at the list anywhere else because it's the same
    				case 3: getSprite(42,uList.Units.get(Map.unitMap[i][j]).owner == 1) ; break;
            case 4: getSprite(43,uList.Units.get(Map.unitMap[i][j]).owner == 1) ; break;
            case 5: getSprite(44,uList.Units.get(Map.unitMap[i][j]).owner == 1) ; break;
            case 6: getSprite(45,uList.Units.get(Map.unitMap[i][j]).owner == 1) ; break;
            case 7: getSprite(46,uList.Units.get(Map.unitMap[i][j]).owner == 1) ; break;
            case 8: getSprite(47,uList.Units.get(Map.unitMap[i][j]).owner == 1) ; break;
            case 9: getSprite(48,uList.Units.get(Map.unitMap[i][j]).owner == 1) ; break;
    			}
    			swapColor(#ff00de,uList.Units.get(Map.unitMap[i][j]).owner == 0 ? #0000FF : #FF0000); 	//and swap the pinks with the proper team colors
          swapColor(#840874,uList.Units.get(Map.unitMap[i][j]).owner == 0 ? #000044 : #440000); 
          swapColor(#d77bba,uList.Units.get(Map.unitMap[i][j]).owner == 0 ? #33AAFF : #FFAA33); 
          getSprite(35);
          if (uList.Units.get(Map.unitMap[i][j]).hasActed == false && Map.unitMap[i][j] != selected) {	//if the unit on i,j has not acted and is not selected...
          	swapColor(#ff00de,uList.Units.get(Map.unitMap[i][j]).owner == 0 ? #0000FF : #FF0000);				//give them the main team color. they're selectable.

          } else if (uList.Units.get(Map.unitMap[i][j]).hasActed == true) {															//if they've acted
            swapColor(#ff00de,#FFFFFF); 																																//make their indicator white
          } else if (Map.unitMap[i][j] == selected) {																										//if they *are* selected...        	
          	swapColor(#ff00de,uList.Units.get(Map.unitMap[i][j]).owner == 0 ? #33AAFF : #FFAA33); 			//give them the selected color, 
          } 
    		}
				renderBuffer.image(tileBuffer,j * 50,i * 50);																										//and then, after all that, draw the image to the position on the full buffer
			}
		}
		renderBuffer.endDraw();																																							//and when we get through every tile, close the draw
		flushGraphics();																																										//and flush the buffer to the screen
	}

	public void flushGraphics() {																//which is this method, flushing the graphics
		image(renderBuffer,0,0);																	//literally all it does it display the image.
	}
	
	public void getSprite(int index) {									//put a sprite/tile from the tilesheet to the buffer to be used for rendering
		if(!(index <= 0 && index > wSheet*hSheet)) {			//if the index is actually a value on the spritesheet...
			tileBuffer.blend(tilesheet,(index % wSheet) * 50, ((index + (wSheet - (index % wSheet)))/wSheet - 1) * 50,sTile,sTile,0,0,sTile,sTile,BLEND);	//copy the sprite at the index to the sprite buffer
			tileBuffer.loadPixels();		//and load the pixels for color swapping
		} //^ this is pretty much just like, a Java version of C++ Wingdi.h's bitblt. i mean, its an image copy function so yeah.
	}

	public void getSprite(int index, boolean flip) {      //put a sprite/tile from the tilesheet to the buffer to be used for rendering, with an extra flip contition
    if(!(index <= 0 && index > wSheet*hSheet)) {      	//if the index is actually a value on the spritesheet
    	if(flip) {
      	PImage anotherBuffer = createImage(50,50,ARGB);	//so for this, we make another buffer if we want to flip the unit sprite
        anotherBuffer.blend(tilesheet,(index % wSheet) * 50, ((index + (wSheet - (index % wSheet)))/wSheet - 1) * 50,sTile,sTile,0,0,sTile,sTile,BLEND);  //we copy to there
        anotherBuffer.loadPixels();											//and we load the pixels
        for (int j = 0; j < sTile; j++) {								//then for each scanline
          for (int i = 0; i < sTile/2; i++) {						//and half of the width
          	anotherBuffer.pixels[i+j*sTile] ^= anotherBuffer.pixels[(sTile-i-1)+j*sTile];	//we xor swap mirror each pixel across the center line
          	anotherBuffer.pixels[(sTile-i-1)+j*sTile] ^= anotherBuffer.pixels[i+j*sTile];
          	anotherBuffer.pixels[i+j*sTile] ^= anotherBuffer.pixels[(sTile-i-1)+j*sTile];
          }
        }
        anotherBuffer.updatePixels();																						//we update the pixels
        tileBuffer.blend(anotherBuffer,0,0,sTile,sTile,0,0,sTile,sTile,BLEND);  //then write that to the tile
    	} else {																																	//otherwise, if no flipping, then just do the normal getSprite behavior
        tileBuffer.blend(tilesheet,(index % wSheet) * 50, ((index + (wSheet - (index % wSheet)))/wSheet - 1) * 50,sTile,sTile,0,0,sTile,sTile,BLEND);	
        tileBuffer.loadPixels();
    	}
    } 
  }

	public PImage getIndivSprite(int index) {						//for geting sprites individually, which is really only used by the movement range thing
		if(!(index <= 0 && index > wSheet*hSheet)) {     	//because it breaks bad at any other time, and I have no clue why
			indivBuffer.copy(tilesheet,(index % wSheet) * 50, ((index + (wSheet - (index % wSheet)))/wSheet - 1) * 50, sTile,sTile,0,0,sTile,sTile);
      return indivBuffer;
    }
    return null;
	}

	public void swapColor(color target, color tint) {							//change a color of a sprite to another color, meant for team color stuff
		for (int i = 0; i < tileBuffer.pixels.length; i++) {			
			if (tileBuffer.pixels[i] == target) {											//its just switching targeted pixels, nothing special
				tileBuffer.pixels[i] = tint;
			}
			tileBuffer.updatePixels();
		}
	}

}
