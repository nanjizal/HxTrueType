package ttf.tables;
typedef HeaderData = {
    majorVersion:  Int,
    minorVersion:  Int,
    numTables:     Int,
    searchRange:   Int,
    entrySelector: Int,
    rangeShift:    Int,
}
abstract Header( HeaderData ) to HeaderData {
    public inline function new( header: Header ){
        this = header;
    }
    @:from
    static public inline 
    function read( i: haxe.io.Input ): Header_ {
        return new Header( { majorVersion:    i.readUInt16()
                           , minorVersion:    i.readUInt16()
                           , numTables:       i.readUInt16()
                           , searchRange:     i.readUInt16()
                           , entrySelector:   i.readUInt16()
                           , rangeShift:      i.readUInt16() } );
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        o.writeUInt16( this.majorVersion  );
        o.writeUInt16( this.minorVersion  );
        o.writeUInt16( this.numTables     );
        o.writeUInt16( this.searchRange   );
        o.writeUInt16( this.entrySelector );
        o.writeUInt16( this.rangeShift    );
        return o;
    }
    @:to
    public inline
    function toString(): String {
        var buf = Table.buffer;
        buf.add( '\n================================='
        buf.add( ' Header '
        buf.add( '=================================\n');
        buf.add( 'majorVersion: ' );
        buf.add( this.majorVersion );
        buf.add( '\nminorVersion: ' );
        buf.add( this.minorVersion );
        buf.add( '\nnumTables' );
        buf.add( this.numTables );
        buf.add( '\nsearchRange' );
        buf.add( this.searchRange );
        buf.add( '\nentrySelector' );
        buf.add( this.entrySelector );
        buf.add( '\nrangeShift' );
        buf.add( this.rangeShift );
        return buf.toString();
    }
}