/**
 * All credits to Jan Flanders
 * https://code.google.com/archive/p/hxswfml/
 */

package format.ttf;
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.io.Bytes;

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


enum Transform {
    Transform1(scale:Float);
    Transform2(xscale:Float, yscale:Float);
    Transform3(xscale:Float, yscale:Float, scale01:Float, scale10:Float);
}



typedef GlyphIndex = {
    charCode:Int,
    index:Int,
    char:String
}



// NAME
typedef NameRecord = {
    platformId:Int,
    platformSpecificId:Int,
    languageID:Int,
    nameID:Int,
    length:Int,
    offset:Int,
    record:String,
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
