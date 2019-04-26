package format.ttf.tables;
//CMAP
enum Platform {
    Unicode(enc:LangUnicode);
    Macintosh(enc:LangMacintosh);
    Reserved;
    Microsoft(enc:LangMicrosoft);
}

enum LangUnicode {
    Default;
    Version11;
    ISO10646;
    Unicode2;
}

enum LangMacintosh {
    Roman;
    Japanese;
    TraditionalChinese;
    Korean;
    Arabic;
    Hebrew;
    Greek;
    Russian;
    RSymbol;
    Devanagari;
    Gurmukhi;
    Gujarati;
    Oriya;
    Bengali;
    Tamil;
    Telugu;
    Kannada;
    Malayalam;
    Sinhalese;
    Burmese;
    Khmer;
    Thai;
    Laotian;
    Georgian;
    Armenian;
    SimplifiedChinese;
    Tibetan;
    Mongolian;
    Geez;
    Slavic;
    Vietnamese;
    Sindhi;
    Uninterpreted;
}

enum LangMicrosoft {
    Unknown;
}

// CMAP
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
typedef CmapGroup = {
    startCharCode:Int,
    endCharCode:Int,
    startGlyphCode:Int
}

typedef CmapEntry = {
    platformId:Int,
    platformSpecificId:Int,
    offset:Int
}

typedef CmapHeader = {
    platformId:Int,
    platformSpecificId:Int,
    format:Int,
    offset:Int,
    language:Int
}
@:forward
abstract CmapTable( TCmapTable ) to TCmapTable { 
    public
    function new( arrCmapSubTable: Array<CmapSubTable> ){
        this = arrCmapSubTable;
    }
    
    // cmap (character code mapping) table
    function read( bytes: Bytes ):Array<CmapSubTable> {
        if (bytes == null)
            throw 'no cmap table found';
        var input = new BytesInput(bytes);
        input.bigEndian = true;

        var version = input.readUInt16();
        var numberSubtables = input.readUInt16();

        var directory:Array<CmapEntry> = new Array();
        for (i in 0...numberSubtables) {
            directory.push({
                platformId: input.readUInt16(),
                platformSpecificId: input.readUInt16(),
                offset: input.readInt32(),
            });
        }
        var subTables:Array<CmapSubTable> = new Array();
        for (i in 0...numberSubtables) {
            subTables.push(readSubTable(bytes, directory[i]));
        }
        return subTables;
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        
        return o;
    }
    static function dumpTCmap(subtables:Array<CmapSubTable>, lim:Int = -1 ):String {
        buf.add('================================= cmap table =================================\n');
        buf.add('Number of subtables: ');
        buf.add(subtables.length);
        buf.add("\n");
        for (i in 0...subtables.length) {
            var subtable = subtables[i];
            buf.add("=================================\n");
            buf.add('Subtable ');
            buf.add(i);
            buf.add('  ');
            buf.add(Type.enumConstructor(subtable));
            buf.add("\n");

            var header = Type.enumParameters(subtable)[0];
            var platformId:Int = header.platformId;
            var platformSpecificId:Int = header.platformSpecificId;
            buf.add('platformId: ');
            buf.add(platformId);
            buf.add(' = ');
            buf.add(Type.getEnumConstructs(Platform)[platformId]);
            buf.add('\nplatformSpecificId: ');
            buf.add(platformSpecificId);
            buf.add(' = ');
            buf.add(switch (platformSpecificId) {
                case 0: Type.getEnumConstructs(LangUnicode)[platformSpecificId];
                case 1: Type.getEnumConstructs(LangMacintosh)[platformSpecificId];
                case 3: Type.getEnumConstructs(LangMicrosoft)[platformSpecificId];
                case _: 'UNSPECIFIED';
            });

            buf.add('\noffset: ');
            buf.add(header.offset);
            buf.add('\nformat: ');
            buf.add(header.format);
            buf.add('\nlanguage: ');
            buf.add(header.language);
            buf.add("\n");
            switch (subtable) {
                default:
                    buf.add("not supported yet\n");

                case Cmap0(header, glyphIndexArray):
                    for (j in 0...256) {
                        buf.add('macintosh CharCode :');
                        buf.add(j);
                        buf.add(', index = ');
                        buf.add(glyphIndexArray[j].index);
                        buf.add(', char: ');
                        buf.add(String.fromCharCode(glyphIndexArray[j].charCode));
                        buf.add("\n");
                    }

                case Cmap4(header, glyphIndexArray):
                    for (j in 0...glyphIndexArray.length)
                        if (glyphIndexArray[j] != null) {
                            buf.add('unicode charCode: ');
                            buf.add(j);
                            buf.add(', index = ');
                            buf.add(glyphIndexArray[j].index);
                            buf.add(', char: ');
                            buf.add(String.fromCharCode(glyphIndexArray[j].charCode));
                            buf.add("\n");
                        }
            }
        }
        return buf.toString();
    }
    
}