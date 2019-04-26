package ttf.tables;
// HEAD
typedef HeadData = {
    version:            Int32,
    fontRevision:       Int32,
    checkSumAdjustment: Int32,
    magicNumber:        Int32,
    flags:              Int,
    unitsPerEm:         Int,
    created:            Float,
    modified:           Float,
    xMin:               Int,
    yMin:               Int,
    xMax:               Int,
    yMax:               Int,
    macStyle:           Int,
    lowestRecPPEM:      Int,
    fontDirectionHint:  Int,
    indexToLocFormat:   Int,
    glyphDataFormat:    Int
}
// head (font header) table
abstract HeadTable( HeadData ) to HeadData {
    public inline function new( headData: HeadData ){
        this = headData;
    }
    @:from
    static public inline 
    function read( bytes: Bytes ): HeadData {
        if( bytes == null ) throw 'no head table found';
        var i = new BytesInput( bytes );
        i.bigEndian = true;
        return new HeadTable( {
            version:            i.readInt32(),
            fontRevision:       i.readInt32(),
            checkSumAdjustment: i.readInt32(),
            magicNumber:        i.readInt32(), // 0x5F0F3CF5
            flags:              i.readUInt16(),
            unitsPerEm:         i.readUInt16(), // range from 64 to 16384
            created:            i.readDouble(),
            modified:           i.readDouble(),
            xMin:               i.readInt16(), // FWord
            yMin:               i.readInt16(), // FWord
            xMax:               i.readInt16(), // FWord
            yMax:               i.readInt16(), // FWord
            macStyle:           i.readUInt16(),
            lowestRecPPEM:      i.readUInt16(),
            fontDirectionHint:  i.readInt16(),
            indexToLocFormat:   i.readInt16(),
            glyphDataFormat:    i.readInt16()
        } );
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        o.writeInt32(  this.version );
        o.writeInt32(  this.fontRevision );
        o.writeInt32(  this.checkSumAdjustment );
        o.writeInt32(  this.magicNumber );
        o.writeUInt16( this.flags );
        o.writeUInt16( this.unitsPerEm );
        o.writeDouble( this.created );
        o.writeDouble( this.modified );
        o.writeInt16(  this.xMin );
        o.writeInt16(  this.yMin );
        o.writeInt16(  this.xMax );
        o.writeInt16(  this.yMax );
        o.writeUInt16( this.macStyle );
        o.writeUInt16( this.lowestRecPPEM );
        o.writeInt16(  this.fontDirectionHint );
        o.writeInt16(  this.indexToLocFormat );
        o.writeInt16(  this.glyphDataFormat );
        return o;
    }
    @:to
    public inline
    function toString(): String {
        var buf = Table.buffer;
        buf.add( '\n=================================' );
        buf.add( ' head table '
        buf.add( '=================================\n' );
        buf.add( 'version: ' );
        buf.add( this.version );
        buf.add( '\nfontRevision : ' );
        buf.add( this.fontRevision);
        buf.add( '\ncheckSumAdjustment :' );
        buf.add( this.checkSumAdjustment );
        buf.add( '\nmagicNumber:' );
        buf.add( this.magicNumber );
        buf.add( '\nflags:' );
        buf.add( this.flags );
        buf.add( '\nunitsPerEm: ' );
        buf.add( this.unitsPerEm );
        buf.add( '\ncreated:' );
        buf.add( this.created );
        buf.add( '\nmodified:' );
        buf.add( this.modified );
        buf.add( '\nxMin: ' );
        buf.add( this.xMin );
        buf.add( '\nyMin: ' );
        buf.add( this.yMin );
        buf.add( '\nxMax: ' );
        buf.add( this.xMax );
        buf.add( '\nyMax: ');
        buf.add( this.yMax);
        buf.add( '\nmacStyle: ' );
        buf.add( this.indexToLocFormat );
        buf.add( '\nlowestRecPPEM:' );
        buf.add( this.lowestRecPPEM );
        buf.add( '\nfontDirectionHint: ' );
        buf.add( this.fontDirectionHint );
        buf.add( '\nindexToLocFormat: ' );
        buf.add( this.indexToLocFormat );
        buf.add( '\nglyphDataFormat: ' );
        buf.add( this.glyphDataFormat );
        return buf.toString();
    }
}