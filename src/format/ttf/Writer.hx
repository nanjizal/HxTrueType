package format.ttf;

import format.ttf.Data;
import format.ttf.Constants;

class Writer {
    var o:haxe.io.Input;
    public function new(o) {
        this.o = o;
        o.bigEndian = true;
    }
    public function write( ttf: Data ){
        
        
        
    }
    public function writeHeader( header: header_ ){
        o.write( header );
    }
    
}