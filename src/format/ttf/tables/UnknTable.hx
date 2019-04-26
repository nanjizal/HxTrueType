package ttf.tables;

abstract UnknTable( String ) to String {
    public inline
    function new( str: String ){
        this = str;
    }
    @:from
    public static inline 
    function read( bytes: Bytes ): UnknTable {
        return new UnKntable( 'unknown table' );
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        return o;
    }
    @:to
    public static inline
    function toString( bytes , lim:Int = -1 ):String {
        return '\n================================= unknown table =================================\n';
    }
}