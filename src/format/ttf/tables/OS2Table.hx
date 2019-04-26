package ttf.tables; // OS2
typedef OS2Data = {
    version:                Int,
    xAvgCharWidth:          Int,
    usWeightClass:          Int,
    usWidthClass:           Int,
    fsType:                 Int,
    ySubscriptXSize:        Int,
    ySubscriptYSize:        Int,
    ySubscriptXOffset:      Int,
    ySubscriptYOffset:      Int,
    ySuperscriptXSize:      Int,
    ySuperscriptYSize:      Int,
    ySuperscriptXOffset:    Int,
    ySuperscriptYOffset:    Int,
    yStrikeoutSize:         Int,
    yStrikeoutPosition:     Int,
    sFamilyClass:           Int,
    bFamilyType:            Int,
    bSerifStyle:            Int,
    bWeight:                Int,
    bProportion:            Int,
    bContrast:              Int,
    bStrokeVariation:       Int,
    bArmStyle:              Int,
    bLetterform:            Int,
    bMidline:               Int,
    bXHeight:               Int,
    ulUnicodeRange1:        Int32,
    ulUnicodeRange2:        Int32,
    ulUnicodeRange3:        Int32,
    ulUnicodeRange4:        Int32,
    achVendorID:            Int32,
    fsSelection:            Int,
    usFirstCharIndex:       Int,
    usLastCharIndex:        Int,
    sTypoAscender:          Int,
    sTypoDescender:         Int,
    sTypoLineGap:           Int,
    usWinAscent:            Int,
    usWinDescent:           Int,
    /*
        ulCodePageRange1:  Int32,
        ulCodePageRange2:  Int32,

        sxHeight:          Null<Int>,
        sCapHeight:        Null<Int>,
        usDefaultChar:     Null<Int>,
        usBreakChar:       Null<Int>,
        usMaxContext:      Null<Int>
     */
}

// 0S2 (compatibility) table
abstract OS2Table( OS2Data ) to OS2Data {
    public inline function new( oS2Data: OS2Data ){
        this = oS2Data;
    }
    @:from
    static public inline 
    function read( bytes: Bytes ): OS2Table {
        if( bytes == null ) throw 'no maxp table found';
        var i = new BytesInput( bytes );
        i.bigEndian = true;
        return new OS2Table( {
            version:                 i.readUInt16(),
            xAvgCharWidth:           i.readInt16(),
            usWeightClass:           i.readUInt16(),
            usWidthClass:            i.readUInt16(),
            fsType:                  i.readInt16(),
            ySubscriptXSize:         i.readInt16(),
            ySubscriptYSize:         i.readInt16(),
            ySubscriptXOffset:       i.readInt16(),
            ySubscriptYOffset:       i.readInt16(),
            ySuperscriptXSize:       i.readInt16(),
            ySuperscriptYSize:       i.readInt16(),
            ySuperscriptXOffset:     i.readInt16(),
            ySuperscriptYOffset:     i.readInt16(),
            yStrikeoutSize:          i.readInt16(),
            yStrikeoutPosition:      i.readInt16(),
            sFamilyClass:            i.readInt16(),

            // panose start
            bFamilyType:             i.readByte(),
            bSerifStyle:             i.readByte(),
            bWeight:                 i.readByte(),
            bProportion:             i.readByte(),
            bContrast:               i.readByte(),
            bStrokeVariation:        i.readByte(),
            bArmStyle:               i.readByte(),
            bLetterform:             i.readByte(),
            bMidline:                i.readByte(),
            bXHeight:                i.readByte(),
            // panose end

            ulUnicodeRange1:         i.readInt32(),
            ulUnicodeRange2:         i.readInt32(),
            ulUnicodeRange3:         i.readInt32(),
            ulUnicodeRange4:         i.readInt32(),
            achVendorID:             i.readInt32(),
            fsSelection:             i.readInt16(),
            usFirstCharIndex:        i.readUInt16(),
            usLastCharIndex:         i.readUInt16(),
            sTypoAscender:           i.readInt16(),
            sTypoDescender:          i.readInt16(),
            sTypoLineGap:            i.readInt16(),
            usWinAscent:             i.readUInt16(),
            usWinDescent:            i.readUInt16()
            /*
                          ulCodePageRange1 : i.readInt32(),
                          ulCodePageRange2 : i.readInt32(),

                sxHeight:-1,
                          sCapHeight:-1,
                          usDefaultChar:-1,
                          usBreakChar:-1,
                          usMaxContext:-1
             */
        } );

        /*
                  if (os2Data.version == 2)
            {
              os2Data.sxHeight = i.readInt16();
              os2Data.sCapHeight = i.readInt16();
              os2Data.usDefaultChar = i.readUInt16();
              os2Data.usBreakChar = i.readUInt16();
              os2Data.usMaxContext = i.readUInt16();
            }
        */
    }
    public inline
    function write( o: haxe.io.Output ): haxe.io.Output {
        o.writeInt16( this.version );
        o.writeInt16( this.xAvgCharWidth );
        o.writeInt16( this.usWeightClass );
        o.writeInt16( this.usWidthClass );
        o.writeInt16( this.fsType );
        o.writeInt16( this.ySubscriptXSize );
        o.writeInt16( this.ySubscriptYSize );
        o.writeInt16( this.ySubscriptXOffset );
        o.writeInt16( this.ySubscriptYOffset );
        o.writeInt16( this.ySuperscriptXSize );
        o.writeInt16( this.ySuperscriptYSize );
        o.writeInt16( this.ySuperscriptXOffset );
        o.writeInt16( this.ySuperscriptYOffset );
        o.writeInt16( this.yStrikeoutSize );
        o.writeInt16( this.yStrikeoutPosition );
        o.writeInt16( this.sFamilyClass );

        // panose start
        o.writeByte( this.bFamilyType );
        o.writeByte( this.bSerifStyle );
        o.writeByte( this.bWeight );
        o.writeByte( this.bProportion );
        o.writeByte( this.bContrast );
        o.writeByte( this.bStrokeVariation );
        o.writeByte( this.bArmStyle );
        o.writeByte( this.bLetterform );
        o.writeByte( this.bMidline );
        o.writeByte( this.bXHeight );
        // panose end

        o.writeInt32(  this.ulUnicodeRange1 );
        o.writeInt32(  this.ulUnicodeRange2 );
        o.writeInt32(  this.ulUnicodeRange3 );
        o.writeInt32(  this.ulUnicodeRange4 );
        o.writeInt32(  this.achVendorID );
        o.writeInt16(  this.fsSelection );
        o.writeUInt16( this.usFirstCharIndex );
        o.writeUInt16( this.usLastCharIndex );
        o.writeInt16(  this.sTypoAscender );
        o.writeInt16(  this.sTypoDescender );
        o.writeInt16(  this.sTypoLineGap );
        o.writeUInt16( this.usWinAscent );
        o.writeUInt16( this.usWinDescent );
        return o;
    }
    public inline
    function toString(): String {
        var buf = Table.buffer;
        buf.add( '\n=================================' );
        buf.add( ' os/2 table '
        buf.add( '=================================\n') ;
        buf.add( 'version: ' );
        buf.add( this.version );
        buf.add( '\nxAvgCharWidth : ' );
        buf.add( this.xAvgCharWidth );
        buf.add( '\nusWeightClass : ' );
        buf.add( this.usWeightClass );
        buf.add( '\nusWidthClass : ' );
        buf.add( this.usWidthClass );
        buf.add( '\nfsType : ' );
        buf.add( this.fsType);
        buf.add( '\nySubscriptXSize : ' );
        buf.add( this.ySubscriptXSize );
        buf.add( '\nySubscriptYSize : ' );
        buf.add( this.ySubscriptYSize );
        buf.add( '\nySubscriptXOffset : ' );
        buf.add( this.ySubscriptXOffset );
        buf.add( '\nySubscriptYOffset : ' );
        buf.add( this.ySubscriptYOffset );
        buf.add( '\nySuperscriptXSize : ' );
        buf.add( this.ySuperscriptXSize );
        buf.add( '\nySuperscriptYSize : ' );
        buf.add( this.ySuperscriptYSize );
        buf.add( '\nySuperscriptXOffset : ' );
        buf.add( this.ySuperscriptXOffset );
        buf.add( '\nySuperscriptYOffset : ' );
        buf.add( this.ySuperscriptYOffset );
        buf.add( '\nyStrikeoutSize : ' );
        buf.add( this.yStrikeoutSize );
        buf.add( '\nyStrikeoutPosition : ' );
        buf.add( this.yStrikeoutPosition );
        buf.add( '\nsFamilyClass : ' );
        buf.add( this.sFamilyClass );

        buf.add( '\nbFamilyType : ' );
        buf.add( this.bFamilyType );
        buf.add( '\nbSerifStyle : ' );
        buf.add( this.bSerifStyle );
        buf.add( '\nbWeight : ' );
        buf.add( this.bWeight );
        buf.add( '\nbProportion : ' );
        buf.add( this.bProportion );
        buf.add( '\nbContrast : ' );
        buf.add( this.bContrast );
        buf.add( '\nbStrokeVariation : ' );
        buf.add( this.bStrokeVariation );
        buf.add( '\nbArmStyle : ' );
        buf.add( this.bArmStyle );
        buf.add( '\nbLetterform : ' );
        buf.add( this.bLetterform );
        buf.add( '\nbMidline : ' );
        buf.add( this.bMidline );
        buf.add( '\nbXHeight : ' );
        buf.add( this.bXHeight );

        buf.add( '\nulUnicodeRange1 : ' );
        buf.add( this.ulUnicodeRange1 );
        buf.add( '\nulUnicodeRange2 : ' );
        buf.add( this.ulUnicodeRange2 );
        buf.add( '\nulUnicodeRange3 : ' );
        buf.add( this.ulUnicodeRange3 );
        buf.add( '\nulUnicodeRange4 : ' );
        buf.add( this.ulUnicodeRange4 );
        buf.add( '\nachVendorID : ' );
        buf.add( this.achVendorID );
        buf.add( '\nfsSelection : ' );
        buf.add( this.fsSelection );
        buf.add( '\nusFirstCharIndex : ' );
        buf.add( this.usFirstCharIndex );
        buf.add( '\nusLastCharIndex : ' );
        buf.add( this.usLastCharIndex );
        buf.add( '\nsTypoAscender : ' );
        buf.add( this.sTypoAscender );
        buf.add( '\nsTypoDescender : ' );
        buf.add( this.sTypoDescender );
        buf.add( '\nsTypoLineGap : ' );
        buf.add( this.sTypoLineGap );
        buf.add( '\nusWinAscent : ' );
        buf.add( this.usWinAscent );
        buf.add( '\nusWinDescent : ' );
        buf.add( this.usWinDescent );
        /*
            buf.add('ulCodePageRange1 : ' + data.ulCodePageRange1+'\n'
            buf.add('ulCodePageRange2 : ' + data.ulCodePageRange2+'\n'

            buf.add('sxHeight : ' + data.sxHeight+'\n'
            buf.add('sCapHeight : ' + data.sCapHeight+'\n'
            buf.add('usDefaultChar : ' + data.usDefaultChar+'\n'
            buf.add('usBreakChar : ' + data.usBreakChar+'\n'
            buf.add('usMaxContext : ' + data.usMaxContext+'\n'
         */

        return buf.toString();
    }
    
}