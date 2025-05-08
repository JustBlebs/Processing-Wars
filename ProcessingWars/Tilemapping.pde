//If I have the time, I should try png palette manipulation for the tilemap

class Bricklayer {
	PImage tilesheet;
	PImage tileBuffer;
	PImage indivBuffer;
	PGraphics renderBuffer; //a placeholder for using a double buffer system for rendering the map
	int wSheet;
	int hSheet;
	int sTile;

	Bricklayer(PImage tilesheet, int sTile) {
		this.tilesheet = tilesheet;
		this.sTile = sTile;
		
		wSheet = tilesheet.width/sTile;
		hSheet = tilesheet.height/sTile;
		tileBuffer = createImage(50,50,ARGB);
		indivBuffer = createImage(50,50,ARGB);
		renderBuffer = createGraphics(Map.wMap*50,Map.hMap*50);
	}

	  Bricklayer(String path, int sTile) {
    tilesheet = loadImage(path);
    this.sTile = sTile;
    
    wSheet = tilesheet.width/sTile;
    hSheet = tilesheet.height/sTile;
    tileBuffer = createImage(50,50,ARGB);
    indivBuffer = createImage(50,50,ARGB);
    renderBuffer = createGraphics(Map.wMap*50,Map.hMap*50);
    //renderBuffer.loadPixels();
  }

	/*public void setPalette(color... pallette) {
			//we'll fill this later for map pallettes and stuff, since that can be taken from/stored in the map file, 
	}*/
	public void drawMap() {								//the assumption is that we only really need to deterministically make the map once via this, and we can just draw on top of the "image"
		renderBuffer.beginDraw();
		
		for (int i = 0; i < Map.hMap; i++) {
			for (int j = 0; j < Map.wMap; j++) {
				byte count = 0b00000000;
  			if (!(Map.MapCells[i][j].terrain == 1)) {				//for non-water cells (will have to deal with bridges later, methinks)
					//(Map.MapCells[i][j].terrain == 0 || (Map.MapCells[i][j].terrain >= 3 && Map.MapCells[i][j].terrain <= 5) || (Map.MapCells[i][j].terrain >= 14 && Map.MapCells[i][j].terrain <= 16)) {
					getSprite(0);																	//get the land sprite and but it in the tile buffer
					switch (Map.MapCells[i][j].terrain) {					//and then, put on top of it the corresponding sprite for buildings, terrain
						case 3: getSprite(16); 	break;
						case 5: getSprite(8); 	break;
						case 12: getSprite(32); break;
						case 13: getSprite(24);  break;
						case 14: getSprite(33); break;
						case 15: getSprite(24); break;
						case 16: getSprite(33); ; break;
						case 2:
							for (int k = 0; k < Map.MapCells[i][j].neighbors.size(); k++) {
  							count <<= 1;
  							count = (Map.MapCells[i][j].neighbors.get(k).terrain == 2 || Map.MapCells[i][j].neighbors.get(k).terrain == 4 ? (byte)(count | 0b00000001) : count);
  						}
  						switch (count) {
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
					}
					if (Map.MapCells[i][j].buildingOwner == 1) {
						swapColor(#D77BBA, #23F4FA);
					} if (Map.MapCells[i][j].buildingOwner == 2) {
						swapColor(#D77BBA, #FF0000);
					} if (Map.MapCells[i][j].buildingOwner == 0) {
            swapColor(#D77BBA, #A0A0A0);
          } 
				} else {		
  				//just replace all of this with edge casing. Don't need to do too much fancy if the grid is rectangular anyways, aka we know where the lowest and highest rows and cols are
																												//make an empty byte to take our neighbor terrain count
					for (int k = 0; k < Map.MapCells[i][j].neighbors.size(); k++) {									//for each neighbor,
						 if (i == Map.hMap - 1 && k == 0) {
              count <<= 1;      
              count |= 0b00000001;
            }
            
						count <<= 1;																					//SHIFT LEFT count  1 byte 
						count = (Map.MapCells[i][j].neighbors.get(k).terrain == 1 ? (byte)(count | 0b00000001) : count); //and insert 1 at the last position if water, and 0 if not via bitwise OR
					
						if (i == 0 && k == 0) {
							count <<= 1;      
							count |= 0b00000001;
						}
						if (j == 0 && k == 1) {
              count <<= 1;      
              count |= 0b00000001;
            }
            if (j == Map.wMap - 1 && k == Map.MapCells[i][j].neighbors.size()-1) {
              count <<= 1;      
              count |= 0b00000001;
            }
 					}							
 					if ((i == Map.hMap - 1 || i == 0) && (count == 0b00000111 || count == 0b00001011)) {			
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
					//probably would want to do the unit layer here too, so make a separate func for that ig and come back to it
				//println(i + "," + j + ": " + binary(count));
				}
				//Map.MapCells[j][i].tileSprite = count;
				renderBuffer.image(tileBuffer,j * 50,i * 50);
			}

		}
		renderBuffer.endDraw();
		flushGraphics();
	}

	public void flushGraphics() {
		image(renderBuffer,0,0);
	}
	
	public void getSprite(int index) {			//put a sprite/tile from the tilesheet to the buffer to be used for rendering
		if(!(index <= 0 && index > wSheet*hSheet)) {			//if the index is actually a value on the spritesheet
			tileBuffer.blend(tilesheet,(index % wSheet) * 50, ((index + (wSheet - (index % wSheet)))/wSheet - 1) * 50,sTile,sTile,0,0,sTile,sTile,BLEND);	//copy the sprite at the index to the sprite buffer
			tileBuffer.loadPixels();
		} //^ this is pretty much just like, a Java version of C++ Wingdi.h's bitblt. i mean, its an image copy function so yeah.
	}

	public PImage getIndivSprite(int index) {				//for get sprites individually
		if(!(index <= 0 && index > wSheet*hSheet)) {      //if the index is actually a value on the spritesheet
			indivBuffer.copy(tilesheet,(index % wSheet) * 50, ((index + (wSheet - (index % wSheet)))/wSheet - 1) * 50, sTile,sTile,0,0,sTile,sTile);
      return indivBuffer;
    }
    return null;
	}

	public void swapColor(color target, color tint) {							//change a color of a sprite to another color, meant for team color stuff
		for (int i = 0; i < tileBuffer.pixels.length; i++) {
			if (tileBuffer.pixels[i] == target) {
				tileBuffer.pixels[i] = tint;
			}
			tileBuffer.updatePixels();
		}
	}

}
