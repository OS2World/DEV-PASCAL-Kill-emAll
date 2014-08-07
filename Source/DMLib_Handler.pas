///////////////////////////////////////////////
//
// DMLib_Handler unit
//
// Some functions and variables has been
// separated here to keep the main program
// simplier.
//
// This unit deals with DualMode library,
// handles Input events and Window Close
// event.
//
// Sets ShuttingDown variable to True when
// user closed the PM Window.
//
///////////////////////////////////////////////

Unit DMLib_Handler;

interface
uses DMLib, os2mm, os2pmapi;

const Allowed_Modes:array[1..13] of vidmode_descrip=(
  ( Width:320; Height:240; depth:8  ),
  ( Width:320; Height:240; depth:16 ),
  ( Width:320; Height:240; depth:24 ),
  ( Width:320; Height:240; depth:32 ),
  ( Width:640; Height:400; depth:8  ),
  ( Width:640; Height:400; depth:16 ),
  ( Width:640; Height:400; depth:24 ),
  ( Width:640; Height:400; depth:32 ),
  ( Width:640; Height:480; depth:8  ),
  ( Width:640; Height:480; depth:16 ),
  ( Width:640; Height:480; depth:24 ),
  ( Width:640; Height:480; depth:32 ),
  ( Width:0; Height:0; depth:0  )
);

const MaxKeyBufferSize=64;
var   KeyBuffer:string;
      KeyIsPressed:array[0..127] of boolean;   // True if the key is currently pressed
      KeyWasReleased:array[0..127] of boolean; // True if the key has been released.
                                               // You have to clear after checking!

// For Key codes check the KB_* constants of DMLib unit!

      VidBuf : pchar;                    // Pointer to video buffer
      EventHandler:MGLSC_event_handlers; // Addresses of event handlers
      ShuttingDown:boolean;              // True if DMLib is shutting down, so
                                         // better not to call any functions of it.

// -----------------    Functions and Procedures --------------------------

// - - - Reset_Keyboard_States  - - - - - - - - - - - - - - - - - - - - - -
// Initializes KeyIsPressed, KeyWasReleased and KeyBuffer variables
//
Procedure Reset_Keyboard_States;

// - - - MyProcessInput - - - - - - - - - - - - - - - - - - - - - - - - - -
// Function to process DMLib's input events.
// Currently only Keyboard events are handled here.
//
// !!! Remember to declare all DMLib functions as CDECL !!!
//
procedure MyProcessInput( iet:InputEventType; p1:short; p2:short); cdecl;

// - - - MyWindowClosed - - - - - - - - - - - - - - - - - - - - - - - - - -
// Function to detect when the user closes the PM window, and DMLib
// starts to shut down.
//
// !!! Remember to declare all DMLib functions as CDECL !!!
//
Procedure MyWindowClosed; cdecl;

implementation

Procedure Reset_Keyboard_States;
begin
  fillchar(KeyIsPressed,sizeof(KeyIsPressed),false);
  fillchar(KeyWasReleased,Sizeof(KeyWasReleased),false);
  KeyBuffer:='';
end;

procedure MyProcessInput( iet:InputEventType; p1:short; p2:short);
begin
  if (iet=MGLSC_KEYBOARD_MAKE) then // Is is a KeyPress event?
  begin
    if (p1<=127) and (p1>=0) then   // Make sure that it's a real key code
    begin
      KeyIsPressed[p1]:=true;       // Set the key as pressed
                                    // and insert into KeyBuffer
      if length(KeyBuffer)<MaxKeyBufferSize then KeyBuffer:=KeyBuffer+chr(p1);

      // ---          Check and process Alt+Home combinations!
      //
      // If one of the Alt keys is pressed and the Home is also pressed, and
      // the user has pressed one of these keys right now, then we have to
      // switch to/from full-screen!
      //
      if (((KeyIsPressed[KB_leftAlt]) or (KeyIsPressed[KB_rightAlt])) and (KeyIsPressed[KB_Home])) and // Alt + Home
         ((p1=KB_LeftAlt) or (p1=KB_RightAlt) or (p1=KB_Home)) then                                    // pressed right now...
      begin
        WinPostMsg( MGLSC_clientState^.clientwin, WM_TOGGLEFS, 0, 0 );
        Reset_Keyboard_States;
      end;
    end;
  end else
  if (iet=MGLSC_KEYBOARD_BREAK) then // Is it a KeyRelease event?
  begin
    if (p1<=127) and (p1>=0) then    // Make sure that it's a real key code
    begin
      KeyIsPressed[p1]:=false;       // Set the key to be not pressed anymore
      KeyWasReleased[p1]:=true;
    end;
  end;
end;

Procedure MyWindowClosed;
begin
  ShuttingDown:=true;
end;

begin
  // Initialize main variables
  Reset_Keyboard_States;
  fillchar(EventHandler,sizeof(EventHandler),0); // Set every field to NIL
  EventHandler.ProcessInput:=@MyProcessInput;    // Process input messages
  EventHandler.WindowClosed:=@MyWindowClosed;    // Get notification of Window Closed event
  ShuttingDown:=false;
end.
