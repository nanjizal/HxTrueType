package format.ttf.tables;
//CMAP
enum CmapSubTable {
    Cmap0(header:CmapHeader, glyphIndexArray:Array<GlyphIndex>);
    Cmap2(header:CmapHeader, glyphIndexArray:Array<GlyphIndex>, subHeaderKeys:Array<Int>, subHeaders:Array<Int>);
    Cmap4(header:CmapHeader, glyphIndexArray:Array<GlyphIndex>);
    Cmap6(header:CmapHeader, glyphIndexArray:Array<GlyphIndex>, firstCode:Int);
    Cmap8(header:CmapHeader, groups:Array<CmapGroup>, is32:Array<Int>);
    Cmap10(header:CmapHeader, glyphIndexArray:Array<Int>, startCharCode:Int, numChars:Int);
    Cmap12(header:CmapHeader, groups:Array<CmapGroup>);
    CmapUnk(header:CmapHeader, bytes:Bytes);
}
@:forward
abstract CmapSubTable( TCmapTable ) to TCmapSubTable { 
    public
    function new( :  ){
        this = ;
    }
    
    function read( bytes, entry: CmapEntry ):CmapSubTable {
        var input = new BytesInput(bytes);
        input.bigEndian = true;
        input.read(entry.offset);

        var cmapFormat = input.readUInt16();
        var length = input.readUInt16();
        var language = input.readUInt16();

        var cmapHeader = {
            platformId: entry.platformId,
            platformSpecificId: entry.platformSpecificId,
            offset: entry.offset,
            format: cmapFormat,
            language: language
        }

        glyphIndexArray = new Array();
        allGlyphs = new Array();

        if (cmapFormat == 0) {
            for (j in 0...256)
                glyphIndexArray[j] = {
                    charCode: j,
                    index: input.readByte(),
                    char: MacGlyphNames.names[j],
                };
            return Cmap0(cmapHeader, glyphIndexArray);
        } else if (cmapFormat == 4) {
            var segCount = cast input.readUInt16() / 2;
            var searchRange = input.readUInt16();
            var entrySelector = input.readUInt16();
            var rangeShift = input.readUInt16();
            var endCodes = new Array();
            var startCodes = new Array();
            var idDeltas = new Array();
            var idRangeOffsets = new Array();
            var glyphIndices = new Array();
            for (i in 0...segCount)
                endCodes.push(input.readUInt16());
            input.readUInt16();
            for (i in 0...segCount)
                startCodes.push(input.readUInt16());
            for (i in 0...segCount)
                idDeltas.push(input.readUInt16());
            for (i in 0...segCount)
                idRangeOffsets.push(input.readUInt16());
            var count = Std.int((length - (8 * segCount + 16)) / 2);
            for (i in 0...count)
                glyphIndices[i] = input.readUInt16();

            glyphIndexArray[0] = {charCode: 0, index: 0, char: String.fromCharCode(0)}; // unknown glyph (missing character)
            glyphIndexArray[1] = {charCode: 1, index: 1, char: String.fromCharCode(1)}; // null
            glyphIndexArray[2] = {charCode: 2, index: 2, char: String.fromCharCode(2)}; // carriage return
            allGlyphs.concat(glyphIndexArray);

            for (i in 0...segCount) {
                // trace('segment '+i+'/'+segCount +' =>  startCode:'+startCodes[i]+',  endCode:'+endCodes[i]+',  idDelta:'+idDeltas[i]+',  idRangeOffset:'+idRangeOffsets[i]);
                for (j in startCodes[i]...endCodes[i] + 1) {
                    var index = mapCharCode(j, glyphIndices, segCount, startCodes, endCodes, idRangeOffsets, idDeltas);
                    // trace('charCode: '+ j + ', char: '+ String.fromCharCode(j)+', index:'+ index);
                    var glyphIndex:GlyphIndex = {
                        charCode: j,
                        index: index,
                        char: String.fromCharCode(j)
                    };
                    glyphIndexArray[j] = glyphIndex;
                    allGlyphs.push(glyphIndex);
                }
            }
            return Cmap4(cmapHeader, glyphIndexArray);
        } else if (cmapFormat == 6) {
            var firstCode:Int = input.readUInt16();
            var entryCount:Int = input.readUInt16();
            for (j in 0...entryCount) {
                var glyphIndex:GlyphIndex = {
                    charCode: j,
                    index: input.readUInt16(),
                    char: MacGlyphNames.names[j]
                };
                glyphIndexArray[j] = glyphIndex;
            }
            return Cmap6(cmapHeader, glyphIndexArray, firstCode);
        } else {
            return CmapUnk(cmapHeader, bytes);
        }
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        
        return o;
    }
    function mapCharCode(charCode:Int, glyphIndices:Array<Int>, segCount:Int, startCodes:Array<Int>, endCodes:Array<Int>, idRangeOffsets:Array<Int>,
            idDeltas:Array<Int>):Int {
        try {
            for (i in 0...segCount)
                if (endCodes[i] >= charCode)
                    if (startCodes[i] <= charCode)
                        if (idRangeOffsets[i] > 0) {
                            var index:Int = Std.int(idRangeOffsets[i] / 2 + (charCode - startCodes[i]) - (segCount - i));
                            return glyphIndices[index];
                        } else {
                            var index:Int = Std.int((idDeltas[i] + charCode) % 65536);
                            return index;
                        } else
                        break;
            return 0;
        } catch (e:Dynamic)
            return 0;
        return 0;
    }
    
}