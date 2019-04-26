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

class Reader {
    var input:           haxe.io.Input;
    var tablesHash:      Hash<Bytes>;
    var glyphIndexArray: Array<GlyphIndex>;
    var kerningPairs:    Array<KerningPair>;

    public var fontName:String;
    public var allGlyphs:Array<GlyphIndex>;

    public function new(i) {
        input = i;
        input.bigEndian = true;
    }

    public function read():TTF {
        var header: Header_ = input;
        var directory = readDirectory( header );
        var hheaData = ( tablesHash.get( "hhea" ): HheaData_ );
        var headData = ( tablesHash.get( "head" ): HeadData_ );
        var maxpData = ( tablesHash.get( "maxp" ): MaxpData_ );
        var locaData = readLocaTable( tablesHash.get( "loca" ), headData, maxpData );
        var hmtxData = readHmtxTable( tablesHash.get( "hmtx" ), maxpData, hheaData );
        var cmapData = readCmapTable( tablesHash.get( "cmap" ) );
        var glyfData = readGlyfTable( tablesHash.get( "glyf" ), maxpData, locaData, cmapData, hmtxData );
        var kernData = readKernTable( tablesHash.get( "kern" ) );
        // var postData = readPostTable(tablesHash.get("post"));
        var os2Data = ( tablesHash.get( "OS_2" ): OS2Data_ );
        var nameData = readNameTable(tablesHash.get("_name"));
        var tables = [ THhea( hheaData )
                     , THead( headData )
                     , TMaxp( maxpData )
                     , TLoca( locaData )
                     , THmtx( hmtxData )
                     , TCmap( cmapData )
                     , TGlyf( glyfData )
                     , TKern( kernData )
                 /*  , TPost( postData )*/
                     , TOS2( os2Data )
                     , TName( nameData )
        ];
        return { header:    header
               , directory: directory
               , tables:    tables
        };
    }

}