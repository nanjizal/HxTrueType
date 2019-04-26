/**
 * All credits to Jan Flanders
 * https://code.google.com/archive/p/hxswfml/
 */

package format.ttf;

import format.ttf.Data;
import format.ttf.Constants;

class Tools {
    static var limit:Int;
    static var buf:StringBuf;

    public static function dumpTable(table:Table, lim:Int = -1):String {
        buf = new StringBuf();
        limit = lim;
        return switch (table) {
            case THmtx(metrics): dumpTHmtx(metrics);
            case TCmap(subtables): dumpTCmap(subtables);
            case TGlyf(descriptions): dympTGlyf(descriptions);
            case TKern(kerning): dumpTKern(kerning);
            case TName(records): dumpTName(records);

            case TPost(data): dumpTPost(data);
            case THhea(data): dumpTHhea(data);
            case THead(data): dumpTHead(data);
            case TMaxp(data): dumpTMaxp(data);
            case TLoca(data): dumpTLoca(data);
            case TOS2(data): dumpTOS2(data);

            case TUnkn(bytes): dumpTUnk(bytes);
        }
    }
}

