/**
 * All credits to Jan Flanders
 * https://code.google.com/archive/p/hxswfml/
 */

package format.ttf;

import format.ttf.Data;
import format.ttf.Constants;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.ds.StringMap as Hash;
import format.ttf.tables.Header;
import format.ttf.tables.HheaTable;
import format.ttf.tables.MaxpTable;
import format.ttf.tables.HeadTable;
import format.ttf.tables.LocaTable;
import format.ttf.tables.HmtxTable;
import format.ttf.tables.OS2Table;
import format.ttf.tables.NameTable;
class Reader {
	var input:haxe.io.Input;
	var tablesHash:Hash<Bytes>;
	var glyphIndexArray:Array<GlyphIndex>;
	var kerningPairs:Array<KerningPair>;

	public var fontName:String;
	public var allGlyphs:Array<GlyphIndex>;

	public function new(i) {
		input = i;
		input.bigEndian = true;
	}

	public function read():TTF {
		var header: Header = input;
		var directory = readDirectory( header );
		var hheaData = ( tablesHash.get( "hhea" ): HheaTable );
		var headData = ( tablesHash.get( "head" ): HeadTable );
		var maxpData = ( tablesHash.get( "maxp" ): MaxpTable );
                var locaData = ( LocaTable.read( tablesHash.get( "loca" ), headData, maxpData ): LocaTable );
                var hmtxData = ( HmtxTable.read( tablesHash.get( "hmtx" ), maxpData, hheaData ): HmtxTable );
	    	var cmapData = readCmapTable( tablesHash.get( "cmap" ) );
		var glyfData = readGlyfTable( tablesHash.get( "glyf" ), maxpData, locaData, cmapData, hmtxData );
		var kernData = readKernTable( tablesHash.get( "kern" ) );
		// var postData = (tablesHash.get("post"): PostTable );
		var os2Data  = ( tablesHash.get( "OS_2" ): OS2Table );
		var nameData = ( tablesHash.get("_name"): NameTable );
		var tables = [
				THhea( hheaData ),
				THead( headData ),
				TMaxp( maxpData ),
				TLoca( locaData ),
				THmtx( hmtxData.metrics ),
				TCmap( cmapData ),
				TGlyf( glyfData ),
				TKern( kernData ),
				/*TPost( postData ),*/
				TOS2( os2Data ),
				TName( nameData.nameRecords )
		];
		return {
			header: header,
			directory: directory,
			tables: tables
		};
	}

	function readDirectory(header):Array<Entry> {
		tablesHash = new Hash();
		var directory:Array<Entry> = new Array();
		for (i in 0...header.numTables) {
			var tableId = input.readInt32();
			var bytesOutput = new haxe.io.BytesOutput();
			bytesOutput.bigEndian = true;
			bytesOutput.writeInt32(tableId);
			var bytesName = bytesOutput.getBytes();
			var tableName:String = new haxe.io.BytesInput(bytesName).readString(4);
			if (tableName == 'name')
				tableName = '_name';
			directory[i] = {
				tableId: tableId,
				tableName: tableName,
				checksum: input.readInt32(),
				offset: input.readInt32(),
				length: input.readInt32()
			};
		}
		directory.sort(sortOnOffset32);
		for (i in 0...directory.length) {
			var entry = directory[i];
			var start = entry.offset;
			var end:Int;
			if (i == directory.length - 1)
				end = start + entry.length;
			else
				end = directory[i + 1].offset;
			var bytes = input.read(end - start);
			tablesHash.set(entry.tableName.split('/').join('_'), bytes);
		}
		return directory;
	}

	function sortOnOffset32(e1, e2):Int {
		var x = e1.offset;
		var y = e2.offset;
		var result = 0;
		if (x < y)
			result = -1;
		if (x == y)
			result = 0;
		if (x > y)
			result = 1;
		return result;
	}

	function sortOnOffset16(e1, e2):Int {
		var x = e1.offset;
		var y = e2.offset;
		var result = 0;
		if (x < y)
			result = -1;
		if (x == y)
			result = 0;
		if (x > y)
			result = 1;
		return result;
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

	function readGlyf(glyphIndex, input, len):GlyfDescription {
		if (len > 0) {
			var numberOfContours = input.readInt16();
			var glyphHeader = {
				numberOfContours: numberOfContours,
				xMin: input.readInt16(), // FWord
				yMin: input.readInt16(), // FWord
				xMax: input.readInt16(), // FWord
				yMax: input.readInt16() // FWord
			}
			len -= 10;
			if (numberOfContours >= 0) {
				return TGlyphSimple(glyphHeader, readGlyfSimple(numberOfContours, input, len));
			} else if (numberOfContours == -1) {
				return TGlyphComposite(glyphHeader, readGlyfComposite(input, len, glyphIndex));
			} else {
				throw 'unknown GlyfDescription';
			}
		} else {
			return TGlyphNull;
		}
		return TGlyphNull;
	}

	function readGlyfSimple(numberOfContours, input, len):GlyphSimple {
		var endPtsOfContours:Array<Int> = new Array();
		for (i in 0...numberOfContours) {
			endPtsOfContours[i] = input.readUInt16();
			len -= 2;
		}
		var count:Int = endPtsOfContours[numberOfContours - 1] + 1;

		var instructionLength = input.readUInt16();
		len -= 2;

		var instructions:Array<Int> = new Array();
		for (i in 0...instructionLength) {
			instructions[i] = input.readByte();
			len -= 1;
		}

		var flags:Array<Int> = new Array();
		var iindex:Int = 0;
		var jindex:Int = 1;
		while (true) {
			if (iindex < count) {
				flags[iindex] = input.readByte();
				len -= 1;
				if ((flags[iindex] & 0x08) != 0) {
					var repeats:Int = input.readByte();
					len -= 1;
					jindex = 1;
					while (true) {
						if (jindex < repeats + 1) {
							flags[iindex + jindex] = flags[iindex];
							jindex++;
						} else
							break;
					}
					iindex += repeats;
				}
				iindex++;
			} else
				break;
		}
		var xCoordinates:Array<Int> = new Array();
		var yCoordinates:Array<Int> = new Array();
		var x:Int = 0;
		var y:Int = 0;
		for (i in 0...count) {
			if ((flags[i] & 0x10) != 0) {
				if ((flags[i] & 0x02) != 0) {
					x += input.readByte();
					len -= 1;
				}
			} else {
				if ((flags[i] & 0x02) != 0) {
					x += -(input.readByte());
					len -= 1;
				} else {
					x += input.readInt16();
					len -= 2;
				}
			}
			xCoordinates[i] = x;
		}

		for (i in 0...count) {
			if ((flags[i] & 0x20) != 0) {
				if ((flags[i] & 0x04) != 0) {
					y += input.readByte();
					len -= 1;
				}
			} else {
				if ((flags[i] & 0x04) != 0) {
					y += -(input.readByte());
					len -= 1;
				} else {
					y += input.readInt16();
					len -= 2;
				}
			}
			yCoordinates[i] = y;
		}
		var glyphSimple:GlyphSimple = {
			endPtsOfContours: endPtsOfContours,
			flags: flags,
			instructions: instructions,
			xCoordinates: xCoordinates,
			yCoordinates: yCoordinates
		}
		input.read(len);
		return glyphSimple;
	}

	function readGlyfComposite(input, len, glyphIndex):Array<GlyphComponent> {
		var components:Array<GlyphComponent> = new Array();
		input.read(len);
		return components;
		/*
			var components:Array<GlyphComponent>=new Array();
				  var firstIndex   = 0;
				  var firstContour = 0;
			var flags = 0xFF;
				  try
				  {
			while ((flags & CFlag.MORE_COMPONENTS) != 0)
				{
					var argument1, argument2, xtranslate, ytranslate, point1, point2, xscale, yscale, scale01, scale10;
			var flags = input.readInt16();
					len-=2;
			  var glyphIndex = input.readInt16();
					trace('glyph Composite index =' +cast glyphIndex);
					len-=2;
			  if ((flags & CFlag.ARG_1_AND_2_ARE_WORDS) != 0)
			  {
				argument1 = input.readInt16();
				argument2 = input.readInt16();
						len-=4;
			  }
					else
			  {
				argument1 = input.readByte();
				argument2 = input.readByte();
						len-=2;
			  }
			  if ((flags & CFlag.ARGS_ARE_XY_VALUES) != 0)
			  {
						xtranslate = argument1;
				ytranslate = argument2;
			  }
					else
			  {
				point1 = argument1;
				point2 = argument2;
			  }

					var transform=null;
			  if ((flags & CFlag.WE_HAVE_A_SCALE) != 0)
			  {
				xscale = yscale = input.readInt16()/ 0x4000;
						transform = Transform1(xscale);
						len-=2;
			  }
					else if ((flags & CFlag.WE_HAVE_AN_X_AND_Y_SCALE) != 0)
					{
				xscale = input.readInt16()/0x4000;
				yscale = input.readInt16()/0x4000;
						transform = Transform2(xscale, yscale);
						len-=4;
			   }
					 else if ((flags & CFlag.WE_HAVE_A_TWO_BY_TWO) != 0)
					 {
				  xscale = input.readInt16()/0x4000;
				  scale01 = input.readInt16()/0x4000;
				  scale10 = input.readInt16()/0x4000;
				  yscale = input.readInt16()/ 0x4000;
							transform = Transform3(xscale, yscale, scale01, scale10);
							len-=8;
			   }

					var comp:GlyphComponent=
					{
						flags:flags,
						glyphIndex:glyphIndex,
						argument1:argument1,
						argument2:argument1,
						transform:transform
					}
			  components.push(comp);

			  var desc:GlyfDescript = descriptions[glyphindex];
			  if (desc != null)
			  {
				 firstIndex   += desc.getPointCount();
				firstContour += desc.getContourCount();
			  }
			}
			if ((flags & CFlag.WE_HAVE_INSTRUCTIONS) != 0)
			{
						var instructionLength = input.readUInt16();
						len-=2;
						var instructions:Array<Int> = new Array();
						for (i in 0...instructionLength)
						{
							instructions[i] = input.readByte();
							len-=1;
						}
			}

				//trace('composite remaining length: '+ len);
				input.read(len);
				  }
			catch (e:Dynamic)
			{
			 //throw e;
				  }
			input.read(len);
			return components;
		 */
	}

	// cmap (character code mapping) table
	function readCmapTable(bytes:Bytes):Array<CmapSubTable> {
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

	function readSubTable(bytes, entry:CmapEntry):CmapSubTable {
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

	function getCharCodeFromIndex(index:Int):Int {
		for (i in 0...glyphIndexArray.length)
			if (glyphIndexArray[i] != null && glyphIndexArray[i].index == index)
				return glyphIndexArray[i].charCode;
		throw 'charcode not found for index ' + index;
	}

	// kern (kerning) table
	function readKernTable(bytes:Bytes):Array<KernSubTable> {
		if (bytes == null)
			return [];
		var input = new BytesInput(bytes);
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
					tables.push(KernSub0(kerningPairs));

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
}

typedef CmapEntry = {
	platformId:Int,
	platformSpecificId:Int,
	offset:Int
}
		
