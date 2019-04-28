package format.ttf.tables;
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import format.ttf.tables.Tables;
import format.ttf.tables.MetricTable;
// new typedef to store some more properties for writing.
typedef HmtxData = {
    metrics:          Array<MetricTable>,
    numberOfHMetrics: Int,
    numGlyphs:        Int
}
@:forward
abstract HmtxTable( HmtxData ) to HmtxData { 
    public
    function new( hmtxData: HmtxData ){
        this = hmtxData;
    }
    // hmtx (horizontal metrics) table
    static public inline 
    function read( bytes, maxp, hhea ): HmtxTable {
        if (bytes == null) throw 'no hmtx table found';
        var input = new BytesInput(bytes);
        input.bigEndian = true;
        var metrics = new Array<MetricTable>();
        for( i in 0...hhea.numberOfHMetrics ){
            metrics.push( new MetricTable( 
                            { advanceWidth:    input.readUInt16()
                            , leftSideBearing: input.readInt16() // FWord
            }));
        }
        var len = maxp.numGlyphs - hhea.numberOfHMetrics;
        var lastAdvanceWidth = metrics[ metrics.length - 1 ].advanceWidth;
        for( i in 0...len ){
            metrics.push( new MetricTable(
                            { advanceWidth:    lastAdvanceWidth
                            , leftSideBearing: input.readInt16() 
                            }));
        }
        return new HmtxTable( { metrics:          metrics
                              , numberOfHMetrics: hhea.numberOfHMetrics
                              , numGlyphs:        maxp.numGlyphs } );
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        var j = 0;
        var m: MetricTable;
        for( i in 0...this.numberOfHMetrics ){
            m = this.metrics[ j ];
            o.writeUInt16( m.advanceWidth );
            o.writeInt16(  m.advanceWidth );
            j++;
        }
        var len = this.numGlyphs - this.numberOfHMetrics;
        for( i in 0...len ){
            m = this.metrics[ j ];
            o.writeInt16( m.leftSideBearing );
            j++;
        }
        return o;
    }
    @:to
    public inline 
    function toString(): String {
        return this.metrics.toString();
    }
}