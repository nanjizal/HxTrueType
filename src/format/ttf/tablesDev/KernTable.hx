package ttf.table;
// KERN
enum KernSubTable {
    KernSub0( kerningPairs:Array<KerningPair> );
    KernSub1( array:Array<Int> );
}

typedef KerningPair = {
    left:Int,
    right:Int,
    value:Int
}
abstract KernTable( Array<KernSubTable> ) to Array<KernSubTable> {
    public
    function new( arrKernSubTable: Array<KernSubTable> ){
        this = arrKernSubTable;
    }
    // kern (kerning) table
    function read( bytes: Bytes ): Array<KernSubTable> {
        if( bytes == null )
            return [];
        var input = new BytesInput( bytes );
        input.bigEndian = true;

        var version = input.readUInt16();
        var nTables = input.readUInt16();
        var tables:Array<KernSubTable> = new Array();
        for (i in 0...nTables) {
            var version = input.readUInt16();
            var length = input.readUInt16();
            var coverage = input.readUInt16();
            var _format = coverage >> 8;
            switch (_format) {
                case 0:
                    var nPairs = input.readUInt16();
                    var searchRange = input.readUInt16();
                    var entrySelector = input.readUInt16();
                    var rangeShift = input.readUInt16();
                    kerningPairs = new Array();
                    for (i in 0...nPairs)
                        kerningPairs.push({
                            left: getCharCodeFromIndex(input.readUInt16()),
                            right: getCharCodeFromIndex(input.readUInt16()),
                            value: input.readInt16()
                        });
                    tables.push( KernSub0( kerningPairs ) );

                case 2:
                    var rowWidth = input.readUInt16();
                    var leftOffsetTable = input.readUInt16();
                    var rightOffsetTable = input.readUInt16();
                    var array = input.readUInt16();
                    var firstGlyph = input.readUInt16();
                    var nGlyphs = input.readUInt16();
                    var offsets = [];
                    for (i in 0...nGlyphs)
                        offsets.push(input.readUInt16());
                    tables.push(KernSub1(offsets));
            }
        }
        return tables;
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        if (bytes == null)
            throw 'no cmap table found';
        var input = new BytesInput(bytes);
        input.bigEndian = true;
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
        buf.add( kerning.length);
        buf.add( '\n' );
        var idx = 0;
        for (i in 0...kerning.length) {
            var table = kerning[i];
            buf.add('Kerning subtable:');
            buf.add(i);
            buf.add('\n');
            switch (table) {
                case KernSub0(kerningPairs):
                    buf.add('Format: 0');
                    for (j in 0...kerningPairs.length) {
                        //if (limit != -1 && j > limit)
                        //    break;
                        buf.add('\nsubtables[');
                        buf.add(i);
                        buf.add('].kerningPairs[');
                        buf.add(j);
                        buf.add('].left =');
                        buf.add(kerningPairs[j].left);
                        buf.add('\nsubtables[');
                        buf.add(i);
                        buf.add('].kerningPairs[');
                        buf.add(j);
                        buf.add('].right =');
                        buf.add(kerningPairs[j].right);
                        buf.add('\nsubtables[');
                        buf.add(i);
                        buf.add('].kerningPairs[');
                        buf.add(j);
                        buf.add('].value =');
                        buf.add(kerningPairs[j].value);
                    }
                case KernSub1(array):
                    buf.add('KernSub1\n');
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
    
    function getCharCodeFromIndex(index:Int):Int {
        for (i in 0...glyphIndexArray.length)
            if (glyphIndexArray[i] != null && glyphIndexArray[i].index == index)
                return glyphIndexArray[i].charCode;
        throw 'charcode not found for index ' + index;
    }

}