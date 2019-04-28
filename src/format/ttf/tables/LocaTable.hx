package format.ttf.tables; // LOCA
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import format.ttf.tables.Tables;
typedef LocaData = {
    maxpNumGlyphs:  Int,
    factor:         Int,
    offsets:        Array<Int>
}
@:forward
abstract LocaTable( LocaData ) to LocaData { 
    public
    function new( locaData: LocaData ){
        this = locaData;
    }
    static public inline 
    function read( bytes, head, maxp ): LocaTable {
        if (bytes == null)
            throw 'no loca table found';
        var input = new BytesInput(bytes);
        input.bigEndian = true;
        var offsets = new Array();
        var maxpNumGlyphs = maxp.numGlyphs;
        if( head.indexToLocFormat == 0 )
            for (i in 0...maxpNumGlyphs + 1)
                untyped offsets[ i ] = input.readUInt16() * 2;
        else
            for (i in 0...maxpNumGlyphs + 1)
                untyped offsets[ i ] = input.readInt32();
        return new LocaTable( { maxpNumGlyphs: maxpNumGlyphs
                              , factor:        head.indexToLocFormat == 0 ? 2 : 1
                              , offsets:       offsets
        } );
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        switch( this.factor ){
            case 2: // == 0
                for (i in 0...this.maxpNumGlyphs + 1)
                    o.writeUInt16( Std.int( this.offsets[ i ]/2 ) );
            case 1, _:
                for (i in 0...this.maxpNumGlyphs + 1)
                    o.writeInt32( Std.int( this.offsets[ i ] ) );
        }
        return o;
    }
    @:to
    public inline
    function toString(): String {
        var buf = Tables.buffer;
        buf.add( '\n================================= loca table =================================\n' );
        buf.add( 'factor: ' );
        buf.add( this.factor );
        buf.add( '\n' );
        for (i in 0...this.offsets.length) {
            //if( limit != -1 && i > limit ) break;
            buf.add( 'offsets[' );
            buf.add( i );
            buf.add( ']: ' );
            buf.add( this.offsets[ i ] );
            buf.add( '\n' );
        }
        return buf.toString();
    }
}