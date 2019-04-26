package ttf.tables;

// HMTX
typedef MetricData = {
    advanceWidth:    Int,
    leftSideBearing: Int
}

@:forward
abstract MetricTable( Array<MatricData> ) to Array<MetricData> {
    public
    function new( arrMetricData: Array<MetricData>){
        this = arrMetricData;
    }
    public inline
    function toString ( , lim:Int = -1 ): String {
        var buf = Table.buffer;
        buf.add('\n================================= hmtx table =================================\n');
        for (i in 0...this.length) {
            if( limit != -1 && i > limit ) break;
            buf.add( '\nmetrics[');
            buf.add( i );
            buf.add( ']: advanceWidth: ');
            buf.add( this[ i ].advanceWidth);
            buf.add( ', leftSideBearing:');
            buf.add( this[ i ].leftSideBearing);
        }
        return buf.toString();
    }
}