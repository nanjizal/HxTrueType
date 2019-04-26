package ttf.tables;
// HHEA
typedef HheaData = {
    version:                Int32,
    ascender:               Int,
    descender:              Int,
    lineGap:                Int,
    advanceWidthMax:        Int,
    minLeftSideBearing:     Int,
    minRightSideBearing:    Int,
    xMaxExtent:             Int,
    caretSlopeRise:         Int,
    caretSlopeRun:          Int,
    caretOffset:            Int,
    reserved:               Bytes,
    metricDataFormat:       Int,
    numberOfHMetrics:       Int
}

// TABLES:
// hhea (horizontal header) table
abstract HheaTable( HheaData ) to HheaData {
    public inline function new( hheaData: HheaData ){
        this = hheaData;
    }
    @:from
    static public inline 
    function read( bytes: Bytes ): HheaData_ {
        if( bytes == null ) throw 'no hhea table found';
        var i = new BytesInput( bytes );
        i.bigEndian = true;
        return new HheaTable( {
            version:                 i.readInt32(),
            ascender:                i.readInt16(),  // FWord (F-Units Int16)
            descender:               i.readInt16(),  // FWord
            lineGap:                 i.readInt16(),  // FWord
            advanceWidthMax:         i.readUInt16(), // UFWord
            minLeftSideBearing:      i.readInt16(),  // FWord
            minRightSideBearing:     i.readInt16(),  // FWord
            xMaxExtent:              i.readInt16(),  // FWord
            caretSlopeRise:          i.readInt16(),
            caretSlopeRun:           i.readInt16(),
            caretOffset:             i.readInt16(),  // FWord
            reserved:                i.read( 8 ),
            metricDataFormat:        i.readInt16(),
            numberOfHMetrics:        i.readUInt16()
        } );
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        o.writeInt32(  this.version             );
        o.writeInt16(  this.ascender            );
        o.writeInt16(  this.descender           );
        o.writeInt16(  this.lineGap             );
        o.writeUInt16( this.advanceWidthMax     );
        o.writeInt16(  this.minLeftSideBearing  );
        o.writeInt16(  this.minRightSideBearing );
        o.writeInt16(  this.xMaxExtent          );
        o.writeInt16(  this.caretSlopeRise      );
        o.writeInt16(  this.caretSlopeRun       );
        o.writeInt16(  this.caretOffset         );
        o.write(       this.reserved            );
        o.writeInt16(  this.metricDataFormat    );
        o.writeInt16(  this.numberOfHMetrics    );
        return o;
    }
    @:to
    public inline
    function toString():String {
        var buf = Table.buffer;
        buf.add( '\n================================='
        buf.add( ' hhea table '
        buf.add( '=================================\n' );
        buf.add( 'version: ' );
        buf.add( this.version );
        buf.add( '\nascender: ' );
        buf.add( this.ascender );
        buf.add( '\ndescender: ' );
        buf.add( this.descender );
        buf.add( '\nlineGap: ' );
        buf.add( this.lineGap );
        buf.add( '\nadvanceWidthMax: ' );
        buf.add( this.advanceWidthMax );
        buf.add( '\nminLeftSideBearing: ' );
        buf.add( this.minLeftSideBearing );
        buf.add( '\nminRightSideBearing: ' );
        buf.add( this.minRightSideBearing );
        buf.add( '\nxMaxExtent: ' );
        buf.add( this.xMaxExtent );
        buf.add( '\ncaretSlopeRise: ' );
        buf.add( this.caretSlopeRise );
        buf.add( '\ncaretSlopeRun: ' );
        buf.add( this.caretSlopeRun );
        buf.add( '\ncaretOffset: ' );
        buf.add( this.caretSlopeRun );
        buf.add( '\nmetricDataFormat: ' );
        buf.add( this.metricDataFormat );
        buf.add( '\nnumberOfHMetrics: ' );
        buf.add( this.numberOfHMetrics );
        return buf.toString();
    }
    
}