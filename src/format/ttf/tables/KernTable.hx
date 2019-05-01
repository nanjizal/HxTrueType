package ttf.table;
// KERN
enum KernSubTable {
    KernSub0( kerningPairs:Array<KerningPair> );
    KernSub1( array:Array<Int> );
}

typedef KerningPair = {
    left:  Int,
    right: Int,
    value: Int
}

typedef KernData = {
    kernTables:       Array<KernSubTable>,
    glyphIndexArray:  Array<GlyphIndex>
}

abstract KernTable( kernData ) to KernData {
    public
    function new( kernData: KernData ){
        this = kernData;
    }
    // kern (kerning) table
    static public inline 
    function read( bytes: Bytes, glyphArray: Array<GlyphIndex> ): KernTable {
        if( bytes == null ) return [];
        var input = new BytesInput( bytes );
        input.bigEndian = true;
        var version = input.readUInt16();
        var nTables = input.readUInt16();
        var tables  = new Array<KernSubTable>();
        for( i in 0...nTables ){
            var version  = input.readUInt16();
            var length   = input.readUInt16();
            var coverage = input.readUInt16();
            var _format  = coverage >> 8;
            switch( _format ){
                case 0:
                    var nPairs        = input.readUInt16();
                    var searchRange   = input.readUInt16();
                    var entrySelector = input.readUInt16();
                    var rangeShift    = input.readUInt16();
                    kerningPairs      = new Array();
                    for( i in 0...nPairs ){
                        kerningPairs.push( { left:  getCharCodeFromIndex( input.readUInt16(), glyphArray )
                                           , right: getCharCodeFromIndex( input.readUInt16(), glyphArray )
                                           , value: input.readInt16() });
                    }
                    tables.push( KernSub0( kerningPairs ) );
                case 2:
                    var rowWidth         = input.readUInt16();
                    var leftOffsetTable  = input.readUInt16();
                    var rightOffsetTable = input.readUInt16();
                    var array            = input.readUInt16();
                    var firstGlyph       = input.readUInt16();
                    var nGlyphs          = input.readUInt16();
                    var offsets          = [];
                    for (i in 0...nGlyphs ) offsets.push( input.readUInt16() );
                    tables.push( KernSub1( offsets ) );
            }
        }
        return new KernTable( { kernTable: tables, glyphIndexArray: glyphIndexArray );
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        var kernPair: KerningPair;
        var glyphArray = this.glyphIndexArray;
        for( i in 0...this.kernTables.length ){
            var table = this.kernTables[ i ];
            switch( table ){
                case KernSub0( kerningPairs ):
                    for( j in 0...kerningPairs.length ){
                        kernPair = kerningPairs[ j ];
                        o.writeUInt16( getIndexFromCharCode( kernPair.left,  glyphArray ) );
                        o.writeUInt16( getIndexFromCharCode( kernPair.right, glyphArray ) );
                        o.writeInt16( kernPair.value );
                    }
                case KernSub1( array ):
                    o.writeUInt16( 0 ); // rowWidth
                    o.writeUInt16( 0 ); // leftOffsetTable
                    o.writeUInt16( 0 ); // rightOffsetTable
                    o.writeUInt16( 0 ); // array
                    o.writeUInt16( 0 ); // vfirstGlyph
                    o.writeUInt16( array.length ); //nGlyphs
                    for( i in 0...array.length ){
                        o.writeUInt16( array[ i ] );
                    }
            }
        }
        return o;
    }
    @:to
    public inline
    function toString():String {
        var buf = Table.buffer;
        buf.add( '\n=================================' );
        buf.add( ' kern table ' );
        buf.add( '=================================\n' );
        buf.add( 'Number of subtables:');
        buf.add( this.kernPair.length);
        buf.add( '\n' );
        var idx = 0;
        for( i in 0..this.kernPair.length ){
            var table = this.kernPair.[ i ];
            buf.add( 'Kerning subtable:' );
            buf.add( i );
            buf.add( '\n' );
            switch( table ) {
                case KernSub0( kerningPairs ):
                    buf.add( 'Format: 0' );
                    for( j in 0...kerningPairs.length ){
                        //if (limit != -1 && j > limit)
                        //    break;
                        buf.add( '\nsubtables[' );
                        buf.add( i );
                        buf.add( '].kerningPairs[' );
                        buf.add( j );
                        buf.add( '].left =' );
                        buf.add( kerningPairs[ j ].left );
                        buf.add( '\nsubtables[' );
                        buf.add( i );
                        buf.add( '].kerningPairs[' );
                        buf.add( j );
                        buf.add( '].right =' );
                        buf.add( kerningPairs[ j ].right );
                        buf.add( '\nsubtables[' );
                        buf.add( i );
                        buf.add( '].kerningPairs[' );
                        buf.add( j );
                        buf.add( '].value =' );
                        buf.add( kerningPairs[ j ].value );
                    }
                case KernSub1( array ):
                    buf.add( 'KernSub1\n' );
                    /*rowWidth, leftClassTable,    rightClassTable,    array):
                        buf.add('Format: 1');
                        buf.add('subtables['+ i +'].rowWidth:'+rowWidth);
                        buf.add('subtables['+ i +'].leftClassTable:'+leftClassTable);
                        buf.add('subtables['+ i +'].rightClassTable:'+rightClassTable);
                        buf.add('subtables['+ i +'].array:'+array);
                     */
            }
        }
        return buf.toString();
    }
    static inline
    function getIndexFromCharCode( charCode: Int, glyphArray: Array<GlyphIndex> ): Int {
        for( i in 0...glyphArray.length )
            if( glyphArray[ i ] != null && glyphArray[ i ].charCode = charCode )
                return glyphArray[ i ].index;
        throw 'index not found for charCode ' + charCode;
    }
    static inline
    function getCharCodeFromIndex( index: Int, glyphArray: Array<GlyphIndex> ): Int {
        for( i in 0...glyphArray.length )
            if( glyphArray[ i ] != null && glyphArray[ i ].index == index )
                return glyphArray[ i ].charCode;
        throw 'charcode not found for index ' + index;
    }

}
