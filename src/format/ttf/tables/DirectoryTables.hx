package ttf.tables;

abstract DirectoryTables( Array<Entry> ) to Array<Entry> {
    function read( header ):Array<Entry> {
        tablesHash     = new Hash();
        var directory = new Array<Entry>();
        var len: Int = header.numTables;
        for( i in 0...len ){
            var tableId           = input.readInt32();
            var bytesOutput       = new haxe.io.BytesOutput();
            bytesOutput.bigEndian = true;
            bytesOutput.writeInt32( tableId );
            var bytesName         = bytesOutput.getBytes();
            var tableName: String = new haxe.io.BytesInput( bytesName ).readString( 4 );
            if( tableName == 'name' ) tableName = '_name';
            directory[ i ] = { tableId:   tableId
                             , tableName: tableName
                             , checksum:  input.readInt32()
                             , offset:    input.readInt32()
                             , length:    input.readInt32()
            };
        }
        directory.sort( sortOnOffset32 );
        len = directory.length;
        for( i in 0...len ){
            var entry = directory[ i ];
            var start = entry.offset;
            var end:Int;
            if( i == len - 1 ){
                end = start + entry.length;
            } else {
                end = directory[ i + 1 ].offset;
            }
            var bytes = input.read( end - start );
            tablesHash.set( entry.tableName.split( '/' ).join( '_' ), bytes );
        }
        return directory;
    }
    function sortOnOffset32( e1, e2 ): Int {
        var x = e1.offset;
        var y = e2.offset;
        var result = 0;
        if( x  < y ) result = -1;
        if( x == y ) result =  0;
        if( x  > y ) result =  1;
        return result;
    }
}