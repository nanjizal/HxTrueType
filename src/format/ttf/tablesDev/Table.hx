package format.ttf.tables;
// new not yet used see making directories.
abstract enum TableName( String ) to String from String {
    var hhea;
    var head;
    var maxp;
    var loca;
    var hmtx;
    var cmap;
    var glyf;
    var kern;
    var post;
    var OS_2;
}

enum Table {
    TGlyf( descriptions: Array<GlyfDescription> );
    THmtx( metrics:      Array<Metric>          );
    TCmap( subtables:    Array<CmapSubTable>    );
    TKern( kerning:      Array<KernSubTable>    );
    TName( records:      Array<NameRecord>      );
    THead( data:         HeadData );
    THhea( data:         HheaData );
    TLoca( data:         LocaData );
    TMaxp( data:         MaxpData );
    TPost( data:         PostData );
    TOS2(  data:         OS2Data  );
    TUnkn( bytes:        Bytes    );
}
class TableTable(){
    // Totally wrong!!
    public inline
    function toString():String {
        return switch( table ) {
            case THmtx( metrics ):      dumpTHmtx(metrics);
            case TCmap( subtables ):    dumpTCmap(subtables);
            case TGlyf( descriptions ): dympTGlyf(descriptions);
            case TKern(kerning):        dumpTKern(kerning);
            case TName(records):        dumpTName(records);
            case TPost(data):           dumpTPost(data);
            case THhea(data):           dumpTHhea(data);
            case THead(data):           dumpTHead(data);
            case TMaxp(data):           dumpTMaxp(data);
            case TLoca(data):           dumpTLoca(data);
            case TOS2(data):            dumpTOS2(data);
            case TUnkn(bytes): dumpTUnk(bytes);
        }
    }
}