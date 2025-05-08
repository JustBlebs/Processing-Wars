//This file will just hold any custom errors/warnings I might have to throw

class InvalidMapDimensions extends RuntimeException {			//error for if the product of the first two bits of a mapfile != the index of the terminator byte (0xFF) - 2
	public InvalidMapDimensions(String m) {									//aka, if width*height != # of map bytes
		super(m);
	}
}


//Most will surround file reading, methinks
//invalid mapdata, 
