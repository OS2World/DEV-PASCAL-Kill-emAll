/////////////////////////////////////////////////////////////////////////
//
// This program is an example of using the DualMode library and the
// SEAL Audio Library for OS/2 together with Virtual Pascal.
//
// To get more information about what is what in this heap of units,
// please check readme.txt!
//
// Usage of the program:
//  ESC   : Exit
//  Arrows: Move ship
//  Space : Shoot
//  Alt+Home : Switch to full screen and back
//  A / S : change effect volume
//  Q / W : change music volume
//
// In Full Screen mode you have to press Home+Alt, not Alt+Home
// to get it recognized.
// It's a bug in Scitech's MGL, hopefully they will fix it soon.
//
// Doodle / 2001
/////////////////////////////////////////////////////////////////////////

Program KillEmAll_Game;
{$PMType PM}
uses DMLib, DMLib_Handler, GraphUtils,    // Graphics related units
     SEAL_Audio, SEAL_Handler,            // Music/Sound FX related units
     os2base, os2pmapi;                   // Others

Const Num_Of_Clouds=8;

var
      BgX,BgY:integer;                   // Background X and Y positions
      Background_Pic:pointer;            // Background picture data
      Sprites_Pic:pointer;               // Sprites picture data
      Temp_Pic:pointer;                  // Temporary picture ('Loading...')
      Ship_Handle:byte;                  // Handle of Ship sprite
      Ship_XPos, Ship_YPos:word;         // Position of Ship on screen
      Bullet_Handle:array[1..16] of byte;// Handles of bullets
      Bullet_XPos,
      Bullet_YPos:array[1..16] of word;  // Positions of bullets on screen
      Cloud_Handle:array[1..Num_Of_Clouds] of byte;  // Handles of clouds
      Cloud_XPos,
      Cloud_YPos:array[1..Num_Of_Clouds] of integer; // Positions of clouds on screen
      Cloud_Timer:array[1..Num_Of_Clouds] of byte;   // Slow-Down timer for clouds
      VolumeBar_Under:pointer;           // Saved image, what is under volumebar
      rc:Longint;                        // Result Code of Dos* calls...

      pGameMusicModule:pAudioModule;     // Background music for game
      pLaserWave:pAudioWave;             // Sound of shooting

      MusicVolume:byte;
      EffectVolume:byte;
      NumberOfVoices:byte;               // Number of simultan voices

      b:byte;                            // General variable


// - - - Create_Sprites - - - - - - - - - - - - - - - - - - - - - - - - - -
// Creates sprites from Sprites_Pic image
//
Procedure Create_Sprites;
var sdTemp:Sprite_Data;
    b:byte;
begin
  // Create Ship
  with sdTemp do
  begin
    XSize:=41; // 41x53 pixel sprites
    YSize:=53;
    Base_Image:=Sprites_Pic;  // The picture is in this image
    Base_Image_XSize:=640;    // which has this width.
    Dest_Image:=VidBuf;       // I want to draw this sprite to this buffer
    Dest_Image_XSize:=640;    // which has this width.
    Pic_Num:=0;               // Draw the first picture of this sprite.
    Transparent:=0;           // Non transparent
    Enabled:=True;

    XPos:=320;                // Starting position of sprite in the buffer
    YPos:=160;                // These are buffer coordinates, not screen ones!
  end;
  if not Create_Sprite(Ship_Handle,sdTemp) then Ship_Handle:=0;
                              // Create Bullets
  with sdTemp do
  begin
    XSize:=26; // 26x15 pixel sprites
    YSize:=15;
    Base_Image:=pointer(longint(Sprites_Pic)+166*3); // Bullets start at x=166
    Base_Image_XSize:=640;
    Dest_Image:=VidBuf;
    Dest_Image_XSize:=640;
    Pic_Num:=0;
    Transparent:=0;
    Enabled:=false;           // Don't draw any bullets yet.
    XPos:=0;
    YPos:=0;
  end;
  for b:=1 to 16 do
  begin
    Bullet_XPos[b]:=0;
    Bullet_YPos[b]:=0;
    if not Create_Sprite(Bullet_Handle[b],sdTemp) then Bullet_Handle[b]:=0;
  end;

                              // Create clouds
  with sdTemp do
  begin
    XSize:=50; // 50x35 pixel sprites
    YSize:=35;
    Base_Image:=pointer(longint(Sprites_Pic)+55*640*3);        // Clouds start at x=0; y=55
    Transp_Base_Image:=pointer(longint(Sprites_Pic)+91*640*3); // Cloud transparency data starts at x=0; y=91
    Base_Image_XSize:=640;
    Dest_Image:=VidBuf;
    Dest_Image_XSize:=640;
    Pic_Num:=0;
    Transparent:=1;
    Enabled:=true;           // Draw all Clouds
    XPos:=0;
    YPos:=0;
  end;
  for b:=1 to Num_Of_Clouds do
  begin
    Cloud_XPos[b]:=random(640-50);
    Cloud_YPos[b]:=random(240-35);
    Cloud_Timer[b]:=0;
    if not Create_Sprite(Cloud_Handle[b],sdTemp) then Cloud_Handle[b]:=0;
  end;
end;

// - - - Delete_Sprites - - - - - - - - - - - - - - - - - - - - - - - - - -
// Deletes all allocated sprites
//
Procedure Delete_Sprites;
var b:byte;
begin
  Delete_Sprite(Ship_Handle);
  for b:=1 to 16 do Delete_Sprite(Bullet_Handle[b]);
end;

// - - - New_Shot - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Creates a new shot when user presses Space
//
Procedure New_Shot;
var b:byte;
    Panning:integer;
begin
  b:=1;             // First find an unused Bullet sprite
  while (b<=16) and (Sprites[Bullet_Handle[b]].enabled=true) do inc(b);

  if b<=16 then     // If we found one,
  begin
    Bullet_XPos[b]:=Ship_XPos+8;  // Set initial coordinates
    Bullet_YPos[b]:=Ship_YPos+15;
    Sprites[Bullet_Handle[b]].XPos:=BgX+Bullet_XPos[b];  // of sprite too,
    Sprites[Bullet_Handle[b]].YPos:=BgY+Bullet_YPos[b];
    Sprites[Bullet_Handle[b]].Enabled:=true;             // and enable it!

    // Generate some noise...

    DosEnterCritSec;
    APlayVoice(NumberOfVoices,pLaserWave);
    ASetVoiceVolume(NumberOfVoices,EffectVolume);

    Panning:=Bullet_XPos[b];
    Panning:=(Panning*255) div 320;

    ASetVoicePanning(NumberOfVoices,Panning);
    DosExitCritSec;
  end;

end;

// - - - Move_Shots - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Animates and moves all enabled bullet sprites
//
Procedure Move_Shots;
var b:byte;
begin
  for b:=1 to 16 do
    if Sprites[Bullet_Handle[b]].Enabled then  // Is this bullet visible?
    begin
      if Bullet_YPos[b]>5 then    // Still on picture?
      begin
        Dec(Bullet_YPos[b],5);    // Yes, go more up,
        Sprites[Bullet_Handle[b]].YPos:=BgY+Bullet_YPos[b]; // Set new Y pos.

        if (Sprites[Bullet_Handle[b]].Pic_Num=0) then // Animate it!
          Sprites[Bullet_Handle[b]].Pic_Num:=1 else
          Sprites[Bullet_Handle[b]].Pic_Num:=0;

      end
      else  // If it would go out of the picture, destroy it.
        Sprites[Bullet_Handle[b]].Enabled:=false;
    end;
end;


// - - - InitVariables  - - - - - - - - - - - - - - - - - - - - - - - - - -
// Assigns NIL to most pointers
//
procedure InitVariables;
begin
  Background_Pic:=NIL;
  Sprites_Pic:=NIL;
  Temp_Pic:=NIL;
  pGameMusicModule:=NIL;
  pLaserWave:=Nil;
end;

// - - - Load_Pictures  - - - - - - - - - - - - - - - - - - - - - - - - - -
// Loads pictures.
// Exits with false if unsuccessful.
//
function Load_Pictures:Boolean;
begin
  result:=false;
  if not Load24BitsPCX('Data\starting.pcx', Temp_Pic) then exit;
  if not Load24bitsPCX('Data\field.pcx', Background_Pic) then exit;
  if not Load24bitsPCX('Data\ship.pcx', Sprites_Pic) then exit;
  result:=true;
end;

// - - - Unload_Pictures- - - - - - - - - - - - - - - - - - - - - - - - - -
// Frees memory allocated for pictures.
//
procedure Unload_Pictures;
begin
  if Temp_Pic<>NIL then
  begin
    freemem(Temp_Pic);Temp_Pic:=NIL;
  end;
  if Background_Pic<>NIL then
  begin
    freemem(Background_Pic);Background_Pic:=NIL;
  end;
  if Sprites_Pic<>NIL then
  begin
    freemem(Background_Pic);Background_Pic:=NIL;
  end;
end;

// - - - Load_Sounds- - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Loads WAV(s) and XM(s)
//
function Load_Sounds:Boolean;
begin
  result:=false;
  if ALoadModuleFile('Data\gamemus.xm', pGameMusicModule,0)<>0 then exit;
  if ALoadWaveFile('Data\laser.wav', pLaserWave,0)<>0 then exit;
  result:=true;
end;

// - - - Unload_Sounds- - - - - - - - - - - - - - - - - - - - - - - - - - -
// Frees memory allocated for sounds and musics
//
procedure UnLoad_Sounds;
begin
  if pLaserWave<>NIL then
  begin
    AFreeWaveFile(pLaserWave);
    pLaserWave:=NIL;
  end;
  if pGameMusicModule<>NIL then
  begin
    AFreeModuleFile(pGameMusicModule);
    pGameMusicModule:=NIL;
  end;
end;

// - - - CleanUp- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Unload sounds and graphics
//
procedure CleanUp;
begin
  Unload_Pictures;
  Unload_Sounds;
end;

// - - - Init_VolumeBar - - - - - - - - - - - - - - - - - - - - - - - - - -
// Allocates memory for storing image under volume bar
//
Procedure Init_VolumeBar;
begin
  Getmem(VolumeBar_Under,100*20*3);
end;

// - - - Uninit_VolumeBar - - - - - - - - - - - - - - - - - - - - - - - - -
// Frees memory allocated at Init_VolumeBar
//
procedure Uninit_VolumeBar;
begin
  Freemem(VolumeBar_Under);
end;

// - - - Draw_VolumeBar - - - - - - - - - - - - - - - - - - - - - - - - - -
// Saves part of image where volume bar will be drawn, then
// draws volume bar.
//
procedure Draw_VolumeBars;
var r,g,b:word;
    x,y:word;
    source,Destination:pointer;
begin

  // Save background

  destination:=VolumeBar_Under;
  source:=pointer(longint(vidbuf)+BgX*3+(BgY+219)*640*3); // x=0; y=219; relative to BgX and BgY
  for b:=1 to 20 do         // Draw all 20 lines
  begin
    move(Source^,Destination^,300);
    destination:=pointer(longint(destination)+300);
    source:=pointer(longint(source)+640*3);
  end;

  // Draw bars...
  destination:=pointer(longint(vidbuf)+BgX*3+(BgY+219)*640*3); // x=0; y=219;
  for x:=0 to MusicVolume do
  for y:=0 to 8 do
  begin
    r:=mem[longint(destination)+x*3+y*640*3];
    g:=mem[longint(destination)+x*3+y*640*3+1];
    b:=mem[longint(destination)+x*3+y*640*3+2];

    r:=r+180; if r>255 then r:=255;
    b:=b+100; if b>255 then b:=255;

    mem[longint(destination)+x*3+y*640*3]:=r;
    mem[longint(destination)+x*3+y*640*3+1]:=g;
    mem[longint(destination)+x*3+y*640*3+2]:=b;
  end;

  for x:=0 to EffectVolume do
  for y:=10 to 18 do
  begin
    r:=mem[longint(destination)+x*3+y*640*3];
    g:=mem[longint(destination)+x*3+y*640*3+1];
    b:=mem[longint(destination)+x*3+y*640*3+2];

    b:=b+180; if b>255 then b:=255;
    r:=r+100; if r>255 then r:=255;

    mem[longint(destination)+x*3+y*640*3]:=r;
    mem[longint(destination)+x*3+y*640*3+1]:=g;
    mem[longint(destination)+x*3+y*640*3+2]:=b;
  end;
end;

// - - - Remove_VolumeBars- - - - - - - - - - - - - - - - - - - - - - - - -
// Draws image saved in Draw_VolumeBars
//
procedure Remove_VolumeBars;
var b:byte;
    source,Destination:pointer;
begin

  // Restore background

  source:=VolumeBar_Under;
  Destination:=pointer(longint(vidbuf)+BgX*3+(BgY+219)*640*3); // x=0; y=219;
  for b:=1 to 20 do         // Draw all 20 lines
  begin
    move(Source^,Destination^,300);
    source:=pointer(longint(source)+300);
    destination:=pointer(longint(destination)+640*3);
  end;
end;


// -- -- -- -- -- -- -- -- -- -- Main Program -- -- -- -- -- -- -- -- -- --

begin
  InitVariables; // Set everything to NIL
  Randomize;

  if not Load_Pictures then
  begin
    CleanUp;
    Halt(1);
  end;

  // Ok. Now we assume that nobody touched our pictures, and they are
  // 640x480x24bit, and we will use 320x240 for display.

  BgX:=160;BgY:=0; // Background shift values

  // Initialize screen and DualMode library
  MGLSC_init( 640, 480, 24,                    // Use this big buffer
              0, 0, 639,479,
              @eventhandler,                   // Here are our event handlers
              'Kill''emAll',                   // Window class name
              'Kill''emAll',                   // Window title
              @allowed_modes,                  // List of allowed video modes for Full Screen
              MGLSC_WINDOW_DECOR_TASKLIST or   // PM Window flags
              MGLSC_WINDOW_DECOR_MINMAX or
              MGLSC_WINDOW_DECOR_SYSMENU  or
              MGLSC_WINDOW_DECOR_TITLEBAR,
              0,                               // Don't allow custom modes,
              0 );                             // don't use joystick.

  VidBuf := MGLSC_clientState^.vidbuffer;      // Get address of video buffer
  MGLSC_clientState^.stretchblit:=true;        // Stretch image on cards
                                               // not supporting 320x240 (later)

  CopyImage(Temp_Pic,vidbuf,640*480*3);        // Copy background to buffer
  WinPostMsg( MGLSC_clientState^.clientwin, WM_BLITFRAME, 0, 0 );  // Show 'Loading...' picture

  if Init_SEAL<>0 then      // Initialize audio library
  begin
    CleanUp;
    Halt(100);
  end;

  if not Load_Sounds then   // Load sounds and musics
  begin
    UnInit_SEAL;
    CleanUp;
    Halt(101);
  end;

  Create_Sprites; // Create sprites from Ship_Pic
  Init_VolumeBar; // Initialize Volume Bars

  DosSleep(1000);  // Wait a second

  MGLSC_SetViewPort(BgX,BgY,BgX+319,BgY+239,1);  // Set screen to 320x240 scrollable
                                                 // (Buffer is 640x480, but only 320x240 visible)

  CopyImage(Background_Pic,vidbuf,640*480*3);  // Copy background to buffer

  Ship_XPos:=140;
  Ship_YPos:=180;

  Draw_Sprites;
  Draw_VolumeBars;

  MusicVolume:=16;  // Quiet music
  EffectVolume:=64; // Loud effects

  NumberOfVoices:=pGameMusicModule^.nTracks+1; // Set number of simultan voices to one more than needed
                                               // by the music.

  AOpenVoices(NumberOfVoices);                 // Setup SEAL, and start music
  APlayModule(pGameMusicModule);
  ASetModuleVolume(MusicVolume);

  // .......................................   Main loop   ..................
  repeat
    if not ShuttingDown then
      MGLSC_FlushUserInput;  // You have to call it to allow DMLib to process
                             // messages, like KeyPress and others...

    Remove_VolumeBars;       // Remove volume bars
    Remove_Sprites;          // Remove sprites from picture

    // ... Update values ...

    // Scroll background down one line
    if BgY>0 then dec(BgY) else BgY:=239;

    // Move ship, and background also if neccessary...
    if KeyIsPressed[KB_Left] then
    begin
      if Ship_XPos>5 then dec(Ship_XPos,2) else
        if BgX>0 then dec(BgX);
    end;
    if KeyIsPressed[KB_Right] then
    begin
      if Ship_XPos<270 then inc(Ship_XPos,2) else
        if BgX<320 then inc(BgX);
    end;
    if KeyIsPressed[KB_Up] then
      if Ship_YPos>100 then dec(Ship_YPos,2);
    if KeyIsPressed[KB_Down] then
      if Ship_YPos<186 then inc(Ship_YPos,2);

    // Change volumes if needed
    if KeyIsPressed[KB_S] then
      if EffectVolume<63 then inc(EffectVolume);
    if KeyIsPressed[KB_A] then
      if EffectVolume>0 then dec(EffectVolume);
    if KeyIsPressed[KB_W] then
      if MusicVolume<63 then
      begin
        inc(MusicVolume);
        ASetModuleVolume(MusicVolume);
      end;
    if KeyIsPressed[KB_Q] then
      if MusicVolume>0 then
      begin
        dec(MusicVolume);
        ASetModuleVolume(MusicVolume);
      end;

    if (Length(KeyBuffer)>0) and (KeyBuffer[Length(KeyBuffer)]=chr(KB_space)) then
    begin // Pressed space?
      New_Shot;
    end;

    Move_Shots;  // Let bullets go up

    if KeyWasReleased[KB_Esc] then // Exit time?
    begin
      ShuttingDown:=true;
    end;

    KeyBuffer:=''; // Empty keyboard buffer

    // Update Sprite positions to let them stay in one place while the
    // background is moving.

    Sprites[Ship_Handle].XPos:=Ship_XPos+BgX;
    Sprites[Ship_Handle].YPos:=Ship_YPos+BgY;

    // Move the clouds
    // (They will be scrolled with the background, but every 2nd frame
    // they will go up one pixel.
    // In every frame they go left or right randomly.)
    for b:=1 to Num_Of_Clouds do
    begin
      if Cloud_Timer[b]>0 then
      begin
        Dec(Cloud_Timer[b]);
        inc(Cloud_YPos[b]);
        if Cloud_YPos[b]>239 then
        begin
          Cloud_YPos[b]:=0; Cloud_XPos[b]:=random(640-50);
        end;

        Cloud_XPos[b]:=Cloud_XPos[b]+Random(3)-1;
        if Cloud_XPos[b]>640-50 then Cloud_Xpos[b]:=640-50;
        if Cloud_XPos[b]<0 then Cloud_XPos[b]:=0;

      end else Cloud_Timer[b]:=1;
      Sprites[Cloud_Handle[b]].XPos:=Cloud_XPos[b];
      Sprites[Cloud_Handle[b]].YPos:=Cloud_YPos[b]+BgY;
    end;


    // Animate ship

    if (Sprites[Ship_Handle].Pic_Num<3) then
      inc (Sprites[Ship_Handle].Pic_Num) else
      Sprites[Ship_Handle].Pic_Num:=0;

    Draw_Sprites;    // Draw sprites to the updated picture
    Draw_VolumeBars; // Draw volume bars again

    if not ShuttingDown then
      // Set background position (set viewport...)
      MGLSC_SetViewPort(BgX,BgY,BgX+319,BgY+239, 1);

    DosSleep(1);     // Give time slice to others too...

    if not ShuttingDown then
      // Draw picture
      WinPostMsg( MGLSC_clientState^.clientwin, WM_BLITFRAME, 0, 0 );

    // Check if PM thread is still running...
    rc:=DosWaitThread( (MGLSC_clientState^.pm_thread), DCWW_NOWAIT );

    // Exit program if user pressed Esc, or closed PM window etc...!
  until (rc<>294) or (ShuttingDown);

  // ................................   End of Main loop   ..................

  AStopModule;         // Stop music
  ACloseVoices;        // Close sound output
  Unload_Sounds;
  Uninit_SEAL;         // Uninitialize SEAL (actually, ACloseAudio...)

  // Free memory
  Uninit_VolumeBar;
  Delete_Sprites;
  CleanUp;
end.

