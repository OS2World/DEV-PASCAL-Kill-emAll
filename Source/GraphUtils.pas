////////////////////////////////////////////////
//
// GraphUtils.PAS
//
// Simple unit to
//  - Load and decode 24bpp PCX files
//  - Handle "Sprites"  (Very basic functions)
//
// This unit can handle 2 type of sprites:
//  Non-Transparent and Transparent ones.
//
// Non-Transparent sprites:
//  - They have the size XSize and YSize.
//  - Their picture is taken from
//    Base_Image+Pic_Num*XSize.
//  - The Base_Image has the width of
//    Base_Image_XSize.
//  - They will be drawn on Dest_Image, which
//    has Dest_Image_XSize width, at XPos;YPos.
//  - If the RGB in the sprite data equals to
//    TRANSPARENT_RGB, the pixel will not be
//    drawn.
//
// Transparent Sprites:
//  - The same as Non-Transparent sprites,
//    but they can be half-visible or so.
//  - The Transparency data is taken from
//    Transp_Base_Image+Pic_Num*XSize. Here there
//    is another "picture" for the sprite, where
//    the RGB values are interpreted the following
//    way:
//    Take the R value, maximize it in 16.
//    16 = Fully show the sprite
//    ...
//    8  = Half visible sprite, half visible background
//    ...
//    0  = Sprite is not visible
//
////////////////////////////////////////////////
Unit GraphUtils;
interface
Const TRANSPARENT_RGB=$000000;  // Set which RGB means transparency for
                                // sprites!
Type Sprite_Data=record
//------ When creating sprite, fill the following ones: -------
       XSize,YSize:word;     // Sprite size
       Base_Image:pointer;   // Where to take sprite datas from
       Base_Image_XSize:word;// Width of base image (pixel)
       Dest_Image:pointer;   // Where to draw sprites to
       Dest_Image_XSize:word;// Width of destination (pixel)
       XPos,YPos:longint;    // Sprite position coordinates (in buffer,
                             // not on screen!!)
       Pic_Num:byte;         // Sprite picture number (0-based)
       Transparent:byte;     // 0 = Non transparent, 1=transparent
       Transp_Base_Image:pointer; // Where to take transparency datas from (same size as Base Image)
       Enabled:boolean;      // Draw or not?
//------ Never touch these: ------------------------------------
       Background:pointer;   // The background of sprite is stored here
       Used:Boolean;         // Is this slot used?
     end;

const MAX_NUM_OF_SPRITES = 64;
var Sprites:array [1..MAX_NUM_OF_SPRITES] of Sprite_Data;  //Sprite datas

// For more information about these functions, check the
// implementation part!

function Load24bitsPCX( filename:string; var img:pointer): boolean;
procedure CopyImage(src,dest:pointer; SrcSize:longint);

// Sprite handling routines
function Create_Sprite(var handle:byte; sdata:Sprite_Data):boolean;
procedure Delete_Sprite(handle:byte);
procedure Draw_Sprites;
procedure Remove_Sprites;
procedure Draw_Sprite(handle:byte);
procedure Remove_Sprite(handle:byte);

implementation
uses use32;

var GraphUtils_OldExitProc:pointer;

// - - - Load24bitsPCX  - - - - - - - - - - - - - - - - - - - - - - - - - -
// Function to load 24 bits per pixel PCX images.
// Loads the file Filename, uncompresses the image into Img (also allocates
// the needed memory, don't forget to freemem it when not needed anymore!),
// and sets Width and Height to the dimensions of the loaded image.
//
function Load24bitsPCX( filename:string; var img:pointer): boolean;
type PCXHeaderType=packed record
       Manufacturer:byte;
       Version:byte;
       Encoding:byte;
       BitsPerPixel:byte;
       Window:array[1..4] of smallint;
       HDpi:smallint;
       VDpi:smallint;
       Colormap:array[1..3*16] of byte;
       Reserved:byte;
       NPlanes:byte;
       BytesPerLine:smallint;
       PaletteInfo:smallint;
       HscreenSize:smallint;
       VscreenSize:smallint;
       Filler:array[1..54] of byte;
     end;
var f:file;
    Header:PCXHeaderType;
    linesize:longint;
    count:longint;
    linebuf,imgypos:pointer;
    dst:^byte;
    y:longint;
    b1,b2:byte;
    Width,Height:word;
    filedata:pchar;
    VirtFilePos:longint;
begin
  result:=false; // Default result is unsuccess

  // 1st step: Read file into memory

  assign(f,filename);
  {$I-}
  reset(f,1);
  {$I+}
  if ioresult<>0 then exit; // Could not open file, exit!
  getmem(filedata,filesize(f)); // Allocate memory for file
  if filedata=nil then
  begin                         // Exit cleanly if not enough memory
    close(f);
    exit;
  end;
  blockread(f,filedata^,filesize(f)); // Read all file into memory
  close(f);                     // Close file.
  VirtFilePos:=0;

  // 2nd step: "Read" PCX header

  move(filedata[VirtFilePos],Header,sizeof(Header));
  inc(VirtFilePos,sizeof(Header));

  Width:=Header.Window[3]-Header.Window[1]+1;
  Height:=Header.Window[4]-Header.Window[2]+1;
  LineSize:=Header.NPlanes*Header.BytesPerLine;

  // Get memory for image data (RGB)
  GetMem(img,Width*Height*3);
  imgypos:=img;
  GetMem(linebuf,linesize+4);

  // 3rd step: Decode PCX planes
  y:=0;
  while (y<Height) do  // For every line
  begin
    dst:=linebuf;      // Decode a line into LineBuf
    count:=0;
    repeat
      b1:=byte(filedata[virtfilepos]);inc(virtfilepos); // Get one byte
      if (b1 and $C0=$C0) then                 // Is it a lot of bytes?
      begin
        b1:=b1 and $3F;                        // Yes, get number of bytes
        b2:=byte(filedata[virtfilepos]);inc(virtfilepos); // and the color
        fillchar(dst^,b1,b2);                  // Create that much values
        inc(dst,b1);                           // Move...
        inc(count,b1);                         //        ...forward
      end else
      begin                                    // It's just one color value!
        dst^:=b1;                              // Store...
        inc(dst);                              //         and move...
        inc(count);                            //                     forward
      end;
    until (count>=linesize); // Decode until we decoded one full line
    // Now we have one line decoded in linebuf, let's store it in image!
    // Linebuf has the values this way:
    // RRRRRRRRRRR...RRRRGGGGGGGGG...GGGGBBBB...BBBBBBBBBBBB
    // We have to make this:
    // RGBRGBRGBRGBRGBRGB...
    asm
      mov esi,linebuf
      mov edi,imgypos
      mov ecx,Width
     @loop:
      mov ebx,Width
      mov al,[esi]         // Get Red
      stosb                // Store
      mov al,[esi+ebx]     // Get Green
      stosb                // Store
      mov al,[esi+ebx*2]   // Get Blue
      stosb                // Store
      inc esi
      dec ecx              // Go to next pixel...
      jnz @loop
    end;
    inc(y);
    inc(longint(imgypos),linesize);
  end;
  freemem(linebuf);
  freemem(filedata);
  Load24bitsPCX:=true;
end;

// - - - CopyImage  - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// This procedure copies Src to Dst, with size SrcSize
// The size should be a multiple of 4.
//
procedure CopyImage(src,dest:pointer; SrcSize:longint);assembler;
asm
  push esi
  push edi
  push ecx
  clc
  mov edi,dest                 // Set destination
  mov esi,src                  // Set source
  mov ecx,SrcSize
  shr ecx,2                    // Get number of dwords to copy
  jz @DontCopy                 // Don't copy if it's zero
  repnz movsd                  // Copy
 @DontCopy:
  pop ecx
  pop edi
  pop esi
end;

// - - - Remove_Sprite  - - - - - - - - - - - - - - - - - - - - - - - - - -
// The procedure removes one sprite from the buffer
//
procedure Remove_Sprite(handle:byte);
var srcPtr,dstPtr:pointer;
    sXSize,sYSize:word;
    dXSize,AddToGoDown:word;
    Dest_Limit:longint;
begin
  if (Handle<1) or (Handle>Max_Num_Of_Sprites) then exit;
  if (Sprites[Handle].Used=false) or (Sprites[Handle].Enabled=false) then
    exit;

  // Copy stored background to the destination buffer!

  srcPtr:=Sprites[Handle].Background;
  sXSize:=Sprites[Handle].XSize*3;
  sYSize:=Sprites[Handle].YSize;
  dstPtr:=Sprites[Handle].Dest_Image;
  Dest_Limit:=longint(Sprites[Handle].Dest_Image)+640*480*3-4;

  dXSize:=Sprites[Handle].Dest_Image_XSize*3;

  dstPtr:=pointer(longint(dstPtr)+Sprites[Handle].XPos*3+
          Sprites[Handle].YPos*dXSize);
  AddToGoDown:=dXSize-sXSize;

  asm
    push esi
    push edi
    push ebx
    push ecx
    cld
    mov esi,srcPtr
    mov edi,dstPtr
    mov ebx,sYSize
   @Copy_OneLine:
    cmp edi,Dest_Limit
    ja @EndOfLoop

    mov ecx,sXSize
    repnz movsb
    add edi,AddToGoDown

    dec ebx
    jnz @Copy_OneLine
   @EndOfLoop:
    pop ecx
    pop ebx
    pop edi
    pop esi
  end;
end;

// - - - Remove_Sprites - - - - - - - - - - - - - - - - - - - - - - - - - -
// The procedure removes all sprites from the buffer
//
procedure Remove_Sprites;
var b:byte;
begin
  for b:=MAX_Num_Of_Sprites downto 1 do
    if Sprites[b].Used then
      Remove_Sprite(b);
end;

// - - - Draw_Sprite  - - - - - - - - - - - - - - - - - - - - - - - - - - -
// The procedure draws one sprite to the buffer
//
procedure Draw_Sprite(handle:byte);
var srcPtr,dstPtr:pointer;
    transpptr:pointer;
    sXSize,sYSize,AddToGoDown:word;
    dXSize,dYSize:word;
    AddDestToGoDown,AddSourToGoDown:word;
    dest_limit:longint;

begin
  if (Handle<1) or (Handle>Max_Num_Of_Sprites) then exit;
  if (Sprites[Handle].Used=false) or (Sprites[Handle].Enabled=false) then
    exit;

  // Store background of sprite!

  dstPtr:=Sprites[Handle].Background;
  dXSize:=Sprites[Handle].XSize*3;
  dYSize:=Sprites[Handle].YSize;

  sXSize:=Sprites[Handle].Dest_Image_XSize*3;
  srcPtr:=Sprites[Handle].Dest_Image;
  Dest_Limit:=longint(Sprites[Handle].Dest_Image)+640*480*3-4;

  srcPtr:=pointer(longint(srcPtr)+Sprites[Handle].XPos*3+
          Sprites[Handle].YPos*sXSize);
  AddToGoDown:=sXSize-dXSize;

  asm
    push esi
    push edi
    push ebx
    push ecx
    cld
    mov esi,srcPtr
    mov edi,dstPtr
    mov ebx,dYSize
   @Copy_OneLine2:
    cmp esi,Dest_Limit
    ja @EndOfCopy

    mov ecx,dXSize
    repnz movsb
    add esi,AddToGoDown

    dec ebx
    jnz @Copy_OneLine2
   @EndOfCopy:
    pop ecx
    pop ebx
    pop edi
    pop esi
  end;

  // Now draw sprite
  transpptr:=pointer(longint(Sprites[Handle].Transp_Base_Image)+
          Sprites[Handle].Pic_Num*Sprites[Handle].XSize*3);

  srcPtr:=pointer(longint(Sprites[Handle].Base_Image)+
          Sprites[Handle].Pic_Num*Sprites[Handle].XSize*3);
  sXSize:=Sprites[Handle].XSize;
  sYSize:=Sprites[Handle].YSize;

  dXSize:=Sprites[Handle].Dest_Image_XSize;
  dstPtr:=Sprites[Handle].Dest_Image;
  dstPtr:=pointer(longint(dstPtr)+Sprites[Handle].XPos*3+
          Sprites[Handle].YPos*dXSize*3);
  AddDestToGoDown:=(dXSize-sXSize)*3;
  AddSourToGoDown:=(Sprites[Handle].Base_Image_XSize-sXSize)*3;
  if Sprites[Handle].Transparent=0 then
  asm           // Draw non-transparent sprites
    push esi
    push edi
    push eax
    push ebx
    push ecx
    cld
    mov esi,srcPtr
    mov edi,dstPtr
    mov ebx,sYSize
   @Copy_OneLine3:
    mov ecx,sXSize
    @More_In_The_Line:

      cmp edi,Dest_Limit
      ja @Exit_From_Loop

      xor eax,eax
      lodsb
      shl eax,8
      lodsb
      shl eax,8
      lodsb
      cmp eax,TRANSPARENT_RGB
      je @Dont_Write
      mov [edi+2],al
      mov [edi+1],ah
      shr eax,16
      mov [edi],al
     @Dont_Write:
      add edi,3

      dec ecx
      jnz @More_In_The_Line
    add edi,AddDestToGoDown
    add esi,AddSourToGoDown
    dec ebx
    jnz @Copy_OneLine3
   @Exit_From_Loop:
    pop ecx
    pop ebx
    pop eax
    pop edi
    pop esi
  end else
  asm           // Draw transparent sprites
    push esi
    push edi
    push eax
    push ebx
    push ecx
    push edx
    cld
    mov esi,srcPtr
    mov edi,dstPtr
    mov ebx,sYSize
    mov edx,TranspPtr
   @Copy_OneLine3_2:
    mov ecx,sXSize
    @More_In_The_Line_2:

      cmp edi,Dest_Limit
      ja @Exit_From_Loop_2


      push ecx
      push ebx

      mov bl,[edx]   // BL = Transparency of source
      shr bl,1       //          Sorry, I've fucked up the drawing in PCX,
                     //          and it was easier to fix here than to redraw
                     //          it. Remove this 'shr bl,1' if you want to get
                     //          the results mentioned in header docs.
                     //  (This way transparency is from 0 to 32...)
      cmp bl,16
      jbe @BL_OK
      mov bl,16
     @BL_OK:
      mov bh,16
      sub bh,bl      // BH = Transparency of background

      xor eax,eax
      lodsb          // Get source Red
      mul bl
      mov cx,ax      // Multiply it into CX
      xor eax,eax
      mov al,[edi]   // Get background Red
      mul bh
      add cx,ax      // Multiply, and add to CX
      shr cx,4       // Divide cx by 16

      mov [edi],cl   // Write the result Red

      xor eax,eax
      lodsb          // Get source Green
      mul bl
      mov cx,ax      // Multiply it into CX
      xor eax,eax
      mov al,[edi+1] // Get background Green
      mul bh
      add cx,ax      // Multiply, and add to CX
      shr cx,4       // Divide cx by 16

      mov [edi+1],cl   // Write the result Green

      xor eax,eax
      lodsb          // Get source Blue
      mul bl
      mov cx,ax      // Multiply it into CX
      xor eax,eax
      mov al,[edi+2] // Get background Blue
      mul bh
      add cx,ax      // Multiply, and add to CX
      shr cx,4       // Divide cx by 16

      mov [edi+2],cl   // Write the result Blue

      add edi,3
      add edx,3

      pop ebx
      pop ecx

      dec ecx
      jnz @More_In_The_Line_2
    add edi,AddDestToGoDown
    add edx,AddDestToGoDown
    add esi,AddSourToGoDown
    dec ebx
    jnz @Copy_OneLine3_2
   @Exit_From_Loop_2:
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop edi
    pop esi
  end;

end;

// - - - Draw_Sprites - - - - - - - - - - - - - - - - - - - - - - - - - - -
// The procedure draws all sprites to the buffer
//
procedure Draw_Sprites;
var b:byte;
begin
  for b:=1 to MAX_Num_Of_Sprites do
    if Sprites[b].Used then
      Draw_Sprite(b);
end;

// - - - Create_Sprite  - - - - - - - - - - - - - - - - - - - - - - - - - -
// The function creates a sprite, returns true if successful.
//
function Create_Sprite(var handle:byte; sdata:Sprite_Data):boolean;
var b:byte;
begin
  b:=1;
  // Find an unused sprite
  while (b<=MAX_NUM_OF_SPRITES) and (Sprites[b].used) do inc(b);
  if (b>MAX_Num_Of_Sprites) then
  begin
    result:=false;
    exit;
  end;
  Sprites[b]:=sdata;
  with Sprites[b] do
  begin
    Used:=true;
    getmem(Background,XSize*YSize*3);
    if Background=NIL then
    begin
      result:=false;
      Used:=false;
      exit;
    end;
  end;
  Handle:=b;
  result:=true;
end;

// - - - Delete_Sprite  - - - - - - - - - - - - - - - - - - - - - - - - - -
// The procedure deletes a sprite
//
procedure Delete_Sprite(handle:byte);
begin
  if (Handle<1) or (Handle>Max_Num_Of_Sprites) then exit;
  if Sprites[Handle].Background<>Nil then
  begin
    freemem(Sprites[Handle].Background);
    Sprites[Handle].Background:=Nil;
  end;
  Sprites[Handle].Used:=false;
end;

//- - - - - Internal routines... - - - - - - - - - - - - - - - -

Procedure Init_Sprites;
var b:byte;
begin
  for b:=1 to MAX_NUM_OF_SPRITES do
  with Sprites[b] do
  begin
    Used:=false;
    Background:=Nil;
  end;
end;

procedure GraphUtils_NewExitProc;
var b:byte;
begin
  exitproc:=GraphUtils_OldExitProc;
  for b:=1 to MAX_NUM_OF_SPRITES do
    Delete_Sprite(b);
end;

begin
  GraphUtils_OldExitProc:=exitproc;
  exitproc:=@GraphUtils_NewExitProc;
  Init_Sprites;
end.
