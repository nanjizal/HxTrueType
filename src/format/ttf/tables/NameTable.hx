package format.ttf.tables;// NAME
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
typedef NameRecord = {
    platformId:         Int,
    platformSpecificId: Int,
    languageID:         Int,
    nameID:             Int,
    length:             Int,
    offset:             Int,
    record:             String
}
typedef NameData = {
    nameRecords:        Array<NameRecord>,
    fontName:           String
}
@:forward
abstract NameTable( NameData ) to NameData { 
    public
    function new( nameData: NameData ){
        this = nameData;
    }
    // name (name) table
    @:from
    static public inline 
    function read( bytes: Bytes ): NameTable {
        var input        = new BytesInput( bytes );
        input.bigEndian  = true;
        var _format      = input.readUInt16(); // 0
        var count        = input.readUInt16();
        var stringOffset = input.readUInt16();
        var nameRecords  = new Array<NameRecord>();
        for (i in 0...count) {
            nameRecords.push({
                platformId:         input.readUInt16(),
                platformSpecificId: input.readUInt16(),
                languageID:         input.readUInt16(),
                nameID:             input.readUInt16(),
                length:             input.readUInt16(),
                offset:             input.readUInt16(),
                record:             ""
            });
        }
        nameRecords.sort( sortOnOffset16 );
        var fontNameRecord = null;
        for( i in 0...count ) {
            var rec = nameRecords[ i ];
            if( rec.nameID == 4 && ( rec.platformId == 3 || rec.platformId == 0)) {
                fontNameRecord = rec;
                break;
            }
        }
        if( fontNameRecord == null ){
            throw 'fontNameRecord not found';
        } else {
            input.read(fontNameRecord.offset);
            for( i in 0...Std.int( fontNameRecord.length / 2 ) ){
                fontNameRecord.record += String.fromCharCode( input.readUInt16() );
            }
        }
        var fontName = fontNameRecord.record;
        /*
            //offsets don't always match with length and there is overlapping. for now we only search the font name (above).
            var lastOffset = -1;
            for(i in 0...count)
            {
                var nameRecord = nameRecords[i];
                var stringBuf = new StringBuf();

                if(nameRecords[i].offset != lastOffset)
                {
                    lastOffset = nameRecords[i].offset;
                    switch(nameRecord.platformId)
                    {
                        case 0, 3:// Unicode (big-endian)// Microsoft encoding, Unicode
                            for (i in 0...Std.int(nameRecord.length/2))
                                stringBuf.add(String.fromCharCode(input.readUInt16()));

                        case 1, 2:// Macintosh encoding, ASCII// ISO encoding, ASCII
                            for (i in 0...nameRecord.length)
                            stringBuf.add(String.fromCharCode(input.readByte()));
                    }
                }
                nameRecord.record = stringBuf.toString();
                //trace(nameRecord.record);
            }
         */

        return new NameTable( { nameRecords: nameRecords, fontName: fontName } );
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        var nameRec = this.nameRecords;
        var len = nameRec.length;
        for( i in 0...len ) {
            var rec = nameRec[ i ];
            o.writeUInt16( rec.platformId );
            o.writeUInt16( rec.platformSpecificId );
            o.writeUInt16( rec.languageID );
            o.writeUInt16( rec.nameID );
            o.writeUInt16( rec.length );
            o.writeUInt16( rec.offset );
            //record: ""
        }
        // TODO: deal with fontName
        return o;
    }
    public inline
    function toString():String {
        var buf = Tables.buffer;
        buf.add( '\n=================================' );
        buf.add( ' name table ' );
        buf.add( '=================================\n');
        var nameRec = this.nameRecords;
        var len = nameRec.length;
        for( i in 0...len ) {
            var rec = nameRec[ i ];
            buf.add( 'platformId: ' );
            buf.add( rec.platformId );
            buf.add( '\nplatformSpecificId: ' );
            buf.add( rec.platformSpecificId );
            buf.add( '\nlanguageID: ' );
            buf.add( rec.languageID );
            buf.add( '\nnameID: ');
            buf.add( rec.nameID );
            buf.add( '\nlength: ');
            buf.add( rec.length );
            buf.add( '\noffset: ');
            buf.add( rec.offset );
            buf.add( '\nrecord: ');
            buf.add( rec.record );
            buf.add( '\n\n' );
        }
        return buf.toString();
    }
    
    static public inline
    function sortOnOffset16( e1, e2 ):Int {
        var x = e1.offset;
        var y = e2.offset;
        var result = 0;
        if( x  < y ) result = -1;
        if( x == y ) result =  0;
        if( x  > y ) result =  1;
        return result;
    }
}