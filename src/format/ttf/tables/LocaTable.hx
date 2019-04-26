package format.ttf.tables;
//LOCA
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
    public static inline
    function read( bytes, head, maxp ): LocaData{
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
        return new LocaTable( {
            maxpNumGlyphs: maxpNumGlyphs
            factor:        head.indexToLocFormat == 0 ? 2 : 1,
            offsets:       offsets
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
                    o.writeUInt32( Std.int( this.offsets[ i ] ) );
        }
        return o;
    }
    @:to
    public inline
    function toString( limit:Int = -1 ): String {
        var buf = Table.buffer;
        buf.add( '\n================================= loca table =================================\n' );
        buf.add( 'factor: ' );
        buf.add( this.factor );
        buf.add( '\n' );
        for (i in 0...this.offsets.length) {
            if( limit != -1 && i > limit ) break;
            buf.add( 'offsets[' );
            buf.add( i );
            buf.add( ']: ' );
            buf.add( this.offsets[ i ] );
            buf.add( '\n' );
        }
        return buf.toString();
    }
}