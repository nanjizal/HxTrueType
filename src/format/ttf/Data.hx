/**
 * All credits to Jan Flanders
 * https://code.google.com/archive/p/hxswfml/
 */

package format.ttf;
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.io.Bytes;
import format.ttf.tables.Header;
import format.ttf.tables.HeadTable;
import format.ttf.tables.MetricTable;
import format.ttf.tables.NameTable;
import format.ttf.tables.HeadTable;
import format.ttf.tables.HheaTable;
import format.ttf.tables.LocaTable;
import format.ttf.tables.MaxpTable;
import format.ttf.tables.PostTable;
import format.ttf.tables.OS2Table;

typedef TTF = {
	header:Header,
	directory:Array<Entry>,
	tables:Array<Table>
}
    
typedef Entry = {
	tableId:Int32,
	tableName:String,
	checksum:Int32,
	offset:Int32,
	length:Int32,
}

enum Table {
	TGlyf(descriptions:Array<GlyfDescription>);
	THmtx(metrics:Array<MetricData>);
	TCmap(subtables:Array<CmapSubTable>);
	TKern(kerning:Array<KernSubTable>);
	TName(records:Array<NameRecord>);
	THead(data:HeadData);
	THhea(data:HheaData);
	TLoca(data:LocaData);
	TMaxp(data:MaxpData);
	TPost(data:PostData);
	TOS2(data:OS2Data);
	TUnkn(bytes:Bytes);
}

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

enum Transform {
	Transform1(scale:Float);
	Transform2(xscale:Float, yscale:Float);
	Transform3(xscale:Float, yscale:Float, scale01:Float, scale10:Float);
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

typedef CmapHeader = {
	platformId:Int,
	platformSpecificId:Int,
	format:Int,
	offset:Int,
	language:Int
}

typedef GlyphIndex = {
	charCode:Int,
	index:Int,
	char:String
}

typedef CmapGroup = {
	startCharCode:Int,
	endCharCode:Int,
	startGlyphCode:Int
}

// KERN
enum KernSubTable {
	KernSub0(kerningPairs:Array<KerningPair>);
	KernSub1(array:Array<Int>);
}

typedef KerningPair = {
	left:Int,
	right:Int,
	value:Int
}

typedef UnicodeRange = {
	start:Int,
	end:Int
}

typedef Path = {
	type:Null<Int>,
	x:Float,
	y:Float,
	cx:Null<Float>,
	cy:Null<Float>
}
