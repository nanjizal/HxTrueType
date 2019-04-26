function readGlyf(glyphIndex, input, len):GlyfDescription {
    if (len > 0) {
        var numberOfContours = input.readInt16();
        var glyphHeader = {
            numberOfContours: numberOfContours,
            xMin: input.readInt16(), // FWord
            yMin: input.readInt16(), // FWord
            xMax: input.readInt16(), // FWord
            yMax: input.readInt16() // FWord
        }
        len -= 10;
        if (numberOfContours >= 0) {
            return TGlyphSimple(glyphHeader, readGlyfSimple(numberOfContours, input, len));
        } else if (numberOfContours == -1) {
            return TGlyphComposite(glyphHeader, readGlyfComposite(input, len, glyphIndex));
        } else {
            throw 'unknown GlyfDescription';
        }
    } else {
        return TGlyphNull;
    }
    return TGlyphNull;
}

function readGlyfSimple(numberOfContours, input, len):GlyphSimple {
    var endPtsOfContours:Array<Int> = new Array();
    for (i in 0...numberOfContours) {
        endPtsOfContours[i] = input.readUInt16();
        len -= 2;
    }
    var count:Int = endPtsOfContours[numberOfContours - 1] + 1;

    var instructionLength = input.readUInt16();
    len -= 2;

    var instructions:Array<Int> = new Array();
    for (i in 0...instructionLength) {
        instructions[i] = input.readByte();
        len -= 1;
    }

    var flags:Array<Int> = new Array();
    var iindex:Int = 0;
    var jindex:Int = 1;
    while (true) {
        if (iindex < count) {
            flags[iindex] = input.readByte();
            len -= 1;
            if ((flags[iindex] & 0x08) != 0) {
                var repeats:Int = input.readByte();
                len -= 1;
                jindex = 1;
                while (true) {
                    if (jindex < repeats + 1) {
                        flags[iindex + jindex] = flags[iindex];
                        jindex++;
                    } else
                        break;
                }
                iindex += repeats;
            }
            iindex++;
        } else
            break;
    }
    var xCoordinates:Array<Int> = new Array();
    var yCoordinates:Array<Int> = new Array();
    var x:Int = 0;
    var y:Int = 0;
    for (i in 0...count) {
        if ((flags[i] & 0x10) != 0) {
            if ((flags[i] & 0x02) != 0) {
                x += input.readByte();
                len -= 1;
            }
        } else {
            if ((flags[i] & 0x02) != 0) {
                x += -(input.readByte());
                len -= 1;
            } else {
                x += input.readInt16();
                len -= 2;
            }
        }
        xCoordinates[i] = x;
    }

    for (i in 0...count) {
        if ((flags[i] & 0x20) != 0) {
            if ((flags[i] & 0x04) != 0) {
                y += input.readByte();
                len -= 1;
            }
        } else {
            if ((flags[i] & 0x04) != 0) {
                y += -(input.readByte());
                len -= 1;
            } else {
                y += input.readInt16();
                len -= 2;
            }
        }
        yCoordinates[i] = y;
    }
    var glyphSimple:GlyphSimple = {
        endPtsOfContours: endPtsOfContours,
        flags: flags,
        instructions: instructions,
        xCoordinates: xCoordinates,
        yCoordinates: yCoordinates
    }
    input.read(len);
    return glyphSimple;
}

function readGlyfComposite(input, len, glyphIndex):Array<GlyphComponent> {
    var components:Array<GlyphComponent> = new Array();
    input.read(len);
    return components;
    /*
        var components:Array<GlyphComponent>=new Array();
              var firstIndex   = 0;
              var firstContour = 0;
        var flags = 0xFF;
              try
              {
        while ((flags & CFlag.MORE_COMPONENTS) != 0)
            {
                var argument1, argument2, xtranslate, ytranslate, point1, point2, xscale, yscale, scale01, scale10;
        var flags = input.readInt16();
                len-=2;
          var glyphIndex = input.readInt16();
                trace('glyph Composite index =' +cast glyphIndex);
                len-=2;
          if ((flags & CFlag.ARG_1_AND_2_ARE_WORDS) != 0)
          {
            argument1 = input.readInt16();
            argument2 = input.readInt16();
                    len-=4;
          }
                else
          {
            argument1 = input.readByte();
            argument2 = input.readByte();
                    len-=2;
          }
          if ((flags & CFlag.ARGS_ARE_XY_VALUES) != 0)
          {
                    xtranslate = argument1;
            ytranslate = argument2;
          }
                else
          {
            point1 = argument1;
            point2 = argument2;
          }

                var transform=null;
          if ((flags & CFlag.WE_HAVE_A_SCALE) != 0)
          {
            xscale = yscale = input.readInt16()/ 0x4000;
                    transform = Transform1(xscale);
                    len-=2;
          }
                else if ((flags & CFlag.WE_HAVE_AN_X_AND_Y_SCALE) != 0)
                {
            xscale = input.readInt16()/0x4000;
            yscale = input.readInt16()/0x4000;
                    transform = Transform2(xscale, yscale);
                    len-=4;
           }
                 else if ((flags & CFlag.WE_HAVE_A_TWO_BY_TWO) != 0)
                 {
              xscale = input.readInt16()/0x4000;
              scale01 = input.readInt16()/0x4000;
              scale10 = input.readInt16()/0x4000;
              yscale = input.readInt16()/ 0x4000;
                        transform = Transform3(xscale, yscale, scale01, scale10);
                        len-=8;
           }

                var comp:GlyphComponent=
                {
                    flags:flags,
                    glyphIndex:glyphIndex,
                    argument1:argument1,
                    argument2:argument1,
                    transform:transform
                }
          components.push(comp);

          var desc:GlyfDescript = descriptions[glyphindex];
          if (desc != null)
          {
             firstIndex   += desc.getPointCount();
            firstContour += desc.getContourCount();
          }
        }
        if ((flags & CFlag.WE_HAVE_INSTRUCTIONS) != 0)
        {
                    var instructionLength = input.readUInt16();
                    len-=2;
                    var instructions:Array<Int> = new Array();
                    for (i in 0...instructionLength)
                    {
                        instructions[i] = input.readByte();
                        len-=1;
                    }
        }

            //trace('composite remaining length: '+ len);
            input.read(len);
              }
        catch (e:Dynamic)
        {
         //throw e;
              }
        input.read(len);
        return components;
     */
}

static function dympTGlyf(descriptions:Array<GlyfDescription>):String {
    buf.add('\n================================= glyf table =================================\n');
    for (i in 0...descriptions.length) {
        if (limit != -1 && i > limit)
            break;
        var desc = descriptions[i];
        buf.add('Glyph description: ');
        buf.add(i);
        buf.add('\n');
        switch (desc) {
            case TGlyphSimple(header, data):
                buf.add('\nheader: xMax: ');
                buf.add(header.xMax);
                buf.add(', yMax:');
                buf.add(header.yMax);
                buf.add(', xMin:');
                buf.add(header.xMin);
                buf.add(', yMin:');
                buf.add(header.yMin);
                buf.add('\nendPtsOfContours:');
                buf.add(data.endPtsOfContours);
                buf.add('\ninstructions:');
                buf.add(data.instructions);
                buf.add('\nflags:');
                buf.add(data.flags);
                buf.add('\nxCoordinates:');
                buf.add(data.xCoordinates);
                buf.add('\nyCoordinates:');
                buf.add(data.yCoordinates);

            case TGlyphComposite(header, components):
                buf.add('\nheader: xMax: ');
                buf.add(header.xMax);
                buf.add(', yMax:');
                buf.add(header.yMax);
                buf.add(', xMin:');
                buf.add(header.xMin);
                buf.add(', yMin:');
                buf.add(header.yMin);
                buf.add('\ncomponents: ');
                buf.add(components);

            case TGlyphNull:
                buf.add('\nTGlyphNull');
        }
        buf.add('\n\n');
    }
    return buf.toString();
}
