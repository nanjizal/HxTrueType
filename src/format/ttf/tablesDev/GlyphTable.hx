package ttf.tables;
// GLYF
enum GlyfDescription {
    TGlyphSimple(header:GlyphHeader, data:GlyphSimple);
    TGlyphComposite(header:GlyphHeader, components:Array<GlyphComponent>);
    TGlyphNull;
}

typedef GlyphHeader = {
    numberOfContours:Int,
    xMin:Int,
    yMin:Int,
    xMax:Int,
    yMax:Int,
}

typedef GlyphSimple = {
    endPtsOfContours:Array<Int>,
    instructions:Array<Int>,
    flags:Array<Int>,
    xCoordinates:Array<Int>,
    yCoordinates:Array<Int>,
}

typedef GlyphComponent = {
    flags:Int,
    glyphIndex:Int,
    argument1:Int,
    argument2:Int,
    transform:Transform
}
// glyf (glyph outline) table
function readGlyfTable(bytes:Bytes, maxp:MaxpData, loca:LocaData, cmap, hmtx):Array<GlyfDescription> {
    if (bytes == null)
        throw 'no glyf table found';
    var input = new BytesInput(bytes);
    input.bigEndian = true;
    var descriptions:Array<GlyfDescription> = new Array();
    for (i in 0...maxp.numGlyphs)
        descriptions.push(readGlyf(i, input, loca.offsets[i + 1] - loca.offsets[i]));
    return descriptions;
}

