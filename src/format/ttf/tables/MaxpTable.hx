package format.ttf.tables;// MAXP
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import format.ttf.tables.Tables;
typedef MaxpData = {
    versionNumber:          haxe.Int32,
    numGlyphs:              Int,
    maxPoints:              Int,
    maxContours:            Int,
    maxComponentPoints:     Int,
    maxComponentContours:   Int,
    maxZones:               Int,
    maxTwilightPoints:      Int,
    maxStorage:             Int,
    maxFunctionDefs:        Int,
    maxInstructionDefs:     Int,
    maxStackElements:       Int,
    maxSizeOfInstructions:  Int,
    maxComponentElements:   Int,
    maxComponentDepth:      Int
}

// maxp (maximum profile) table
@:forward
abstract MaxpTable( MaxpData ) to MaxpData {
    public inline function new( maxpData: MaxpData ){
        this = maxpData;
    }
    @:from
    static public inline 
    function read( bytes: Bytes ): MaxpTable {
        if( bytes == null ) throw 'no maxp table found';
        var i = new BytesInput(bytes);
        i.bigEndian = true;
        return new MaxpTable( {
            versionNumber:          i.readInt32(),
            numGlyphs:              i.readUInt16(),
            maxPoints:              i.readUInt16(),
            maxContours:            i.readUInt16(),
            maxComponentPoints:     i.readUInt16(),
            maxComponentContours:   i.readUInt16(),
            maxZones:               i.readUInt16(),
            maxTwilightPoints:      i.readUInt16(),
            maxStorage:             i.readUInt16(),
            maxFunctionDefs:        i.readUInt16(),
            maxInstructionDefs:     i.readUInt16(),
            maxStackElements:       i.readUInt16(),
            maxSizeOfInstructions:  i.readUInt16(),
            maxComponentElements:   i.readUInt16(),
            maxComponentDepth:      i.readUInt16()
        });
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        o.writeInt32( this.versionNumber );
        o.writeInt16( this.numGlyphs );
        o.writeInt16( this.maxPoints );
        o.writeInt16( this.maxContours );
        o.writeInt16( this.maxComponentPoints );
        o.writeInt16( this.maxComponentContours );
        o.writeInt16( this.maxZones );
        o.writeInt16( this.maxTwilightPoints );
        o.writeInt16( this.maxStorage );
        o.writeInt16( this.maxFunctionDefs );
        o.writeInt16( this.maxInstructionDefs );
        o.writeInt16( this.maxStackElements );
        o.writeInt16( this.maxSizeOfInstructions );
        o.writeInt16( this.maxComponentElements );
        o.writeInt16( this.maxComponentDepth );
        return o;
    }
    @:to
    public inline
    function toString():String {
        var buf = Tables.buffer;
        buf.add( '\n=================================' );
        buf.add( ' maxp table ' );
        buf.add( '=================================\n' );
        buf.add( 'versionNumber:' );
        buf.add( this.versionNumber );
        buf.add( '\nnumGlyphs:' );
        buf.add( this.numGlyphs );
        buf.add( '\nmaxPoints:' );
        buf.add( this.maxPoints );
        buf.add( '\nmaxContours:' );
        buf.add( this.maxContours );
        buf.add( '\nmaxComponentPoints:' );
        buf.add( this.maxComponentPoints );
        buf.add( '\nmaxComponentContours:' );
        buf.add( this.maxComponentContours );
        buf.add( '\nmaxZones:' );
        buf.add( this.maxZones );
        buf.add( '\nmaxTwilightPoints:' );
        buf.add( this.maxTwilightPoints );
        buf.add( '\nmaxStorage:' );
        buf.add( this.maxStorage );
        buf.add( '\nmaxFunctionDefs:' );
        buf.add( this.maxFunctionDefs );
        buf.add( '\nmaxInstructionDefs:' );
        buf.add( this.maxInstructionDefs );
        buf.add( '\nmaxStackElements:' );
        buf.add( this.maxStackElements );
        buf.add( '\nmaxSizeOfInstructions:' );
        buf.add( this.maxSizeOfInstructions );
        buf.add( '\nmaxComponentElements:' );
        buf.add( this.maxComponentElements );
        buf.add( '\nmaxComponentDepth:' );
        buf.add( this.maxComponentDepth );
        return buf.toString();
    }
    
}