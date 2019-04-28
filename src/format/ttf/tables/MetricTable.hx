package format.ttf.tables;

// HMTX
typedef MetricData = {
    advanceWidth:    Int,
    leftSideBearing: Int
}

@:forward
abstract MetricTable( MetricData ) to MetricData {
    public
    function new( metricData: MetricData ){
        this = metricData;
    }
    public inline
    function toString(): String {
        var buf = Tables.buffer;
        buf.add('\n================================= Metric table =================================\n');
        buf.add( '\nmetrics[');
        buf.add( this );
        buf.add( ']: advanceWidth: ');
        buf.add( this.advanceWidth);
        buf.add( ', leftSideBearing:');
        buf.add( this.leftSideBearing);
        return buf.toString();
    }
}