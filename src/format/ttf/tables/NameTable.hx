package ttf.tables;


@:forward
abstract NameTable( NameRecord ) to NameRecord { 
    public
    function new( nameData: NameData ){
        this = nameData;
    }
    // name (name) table
    static public inline 
    function read(bytes:Bytes):Array<NameRecord> {
        var input = new BytesInput(bytes);
        input.bigEndian = true;

        var _format = input.readUInt16(); // 0
        var count = input.readUInt16();
        var stringOffset = input.readUInt16();

        var nameRecords:Array<NameRecord> = new Array();
        for (i in 0...count) {
            nameRecords.push({
                platformId: input.readUInt16(),
                platformSpecificId: input.readUInt16(),
                languageID: input.readUInt16(),
                nameID: input.readUInt16(),
                length: input.readUInt16(),
                offset: input.readUInt16(),
                record: ""
            });
        }
        nameRecords.sort(sortOnOffset16);
        var fontNameRecord = null;
        for (i in 0...count) {
            if (nameRecords[i].nameID == 4 && (nameRecords[i].platformId == 3 || nameRecords[i].platformId == 0)) {
                fontNameRecord = nameRecords[i];
                break;
            }
        }
        if (fontNameRecord == null)
            throw 'fontNameRecord not found'
        else {
            input.read(fontNameRecord.offset);
            for (i in 0...Std.int(fontNameRecord.length / 2))
                fontNameRecord.record += String.fromCharCode(input.readUInt16());
        }
        fontName = fontNameRecord.record;
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

        return nameRecords;
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        throw 'NOT YET IMPLEMENTED';
        return o;
    }
    public inline
    function toString(records:Array<NameRecord> , lim:Int = -1 ):String {
        var buf = Table.buffer;
        buf.add('\n================================= name table =================================\n');
        for (rec in records) {
            buf.add('platformId: ');
            buf.add(rec.platformId);
            buf.add('\nplatformSpecificId: ');
            buf.add(rec.platformSpecificId);
            buf.add('\nlanguageID: ');
            buf.add(rec.languageID);
            buf.add('\nnameID: ');
            buf.add(rec.nameID);
            buf.add('\nlength: ');
            buf.add(rec.length);
            buf.add('\noffset: ');
            buf.add(rec.offset);
            buf.add('\nrecord: ');
            buf.add(rec.record);
            buf.add('\n\n');
        }
        return buf.toString();
    }
    
    
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