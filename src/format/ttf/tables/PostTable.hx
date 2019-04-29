package format.ttf.tables; // POST
import haxe.io.BytesInput;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
typedef PostData = {
    version:            Int32,
    italicAngle:        Int32,
    underlinePosition:  Int,
    underlineThickness: Int,
    isFixedPitch:       Int32,
    minMemType42:       Int32,
    maxMemType42:       Int32,
    minMemType1:        Int32,
    maxMemType1:        Int32,
    numGlyphs:          Int,
    glyphNameIndex:     Array<Int>,
    psGlyphName:        Array<String>
}
@:forward
abstract PostTable( PostData ) to PostData { 
    public
    function new( postData: PostData ){
        this = postData;
    }
    @:from
    static public inline 
    function read( bytes: Bytes ): PostTable {
        var input = new BytesInput( bytes );
        input.bigEndian = true;
        var postData = {
            version:            input.readInt32(),
            italicAngle:        input.readInt32(),
            underlinePosition:  input.readInt16(), // FWord
            underlineThickness: input.readInt16(), // FWord
            isFixedPitch:       input.readInt32(),
            minMemType42:       input.readInt32(),
            maxMemType42:       input.readInt32(),
            minMemType1:        input.readInt32(),
            maxMemType1:        input.readInt32(),
            numGlyphs:          0,
            glyphNameIndex:     new Array(),
            psGlyphName:        new Array()
        }
        if( postData.version == 0x00020000 ){
            postData.numGlyphs = input.readUInt16();
            for( i in 0...postData.numGlyphs ){
                postData.glyphNameIndex[i] = input.readUInt16();
            }
            var high = 0;
            for( i in 0...postData.numGlyphs ){
                if( high < postData.glyphNameIndex[ i ] ){
                    high = postData.glyphNameIndex[ i ];
                }
            }
            if( high > 257 ) {
                high -= 257;
                for( i in 0...high ){
                    postData.psGlyphName[ i ] = input.readString( input.readByte() );
                }
            }
        }
        return new PostTable( postData );
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        throw 'NOT YET IMPLEMENTED';
        return o;
    }
    public inline
    function toString():String {
        var buf = Tables.buffer;
        buf.add( '\n=================================' );
        buf.add( ' post table ' );
        buf.add( '=================================\n' );
        buf.add( 'version : ' );
        buf.add( this.version );
        buf.add( '\nitalicAngle : ');
        buf.add( this.italicAngle);
        buf.add( '\nunderlinePosition : ');
        buf.add( this.underlinePosition );
        buf.add( '\nunderlineThickness : ' );
        buf.add( this.underlineThickness );
        buf.add( '\nisFixedPitch : ' );
        buf.add( this.isFixedPitch );
        buf.add( '\nminMemType42 : ' );
        buf.add( this.minMemType42 );
        buf.add( '\nmaxMemType42 : ' );
        buf.add( this.maxMemType42 );
        buf.add( '\nminMemType1 : ' );
        buf.add( this.minMemType1 );
        buf.add( '\nmaxMemType1 : ' );
        buf.add( this.maxMemType1 );
        buf.add( '\nnumGlyphs : ' );
        buf.add( this.numGlyphs );
        buf.add('\n');
        var idx = 0;
        for( i in this.glyphNameIndex ){
            buf.add( 'glyphNameIndex: ' );
            buf.add( idx++ );
            buf.add( ' : ' );
            buf.add( i );
            buf.add( '\n' );
        }
        idx = 0;
        for( i in this.psGlyphName ) {
            buf.add( 'psGlyphNameIndex: ' );
            buf.add( idx++ );
            buf.add( ' : ' );
            buf.add( i );
            buf.add( '\n' );
        }
        return buf.toString();
    }
}