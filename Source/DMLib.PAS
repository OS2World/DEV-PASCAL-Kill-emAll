Unit DMLib;
interface
uses Use32,os2base,os2def,os2mm,os2pmapi;

// ---- Converted DualMode.h file from Dualmode library Release 4 ----
{&cdecl+}

type vidmode_descrip=packed record
       width, height:ulong;
       depth: ulong;
     end;
type pvidmode_descrip=^vidmode_descrip;

type MGLSC_state=record

  // DATA FOR INTERNAL USE ONLY
  // ==========================
  listener_thread, server_pid, pm_thread : ULONG;
    // Thread IDs and process IDs
  MGL_session : ULONG;
    // Session ID for full screen session (for use with DosSelectSession)
  shared_packet : pointer;
    // Packet used for communication with MGLServer
  command_queue, listener_queue : HQUEUE;
    // Queues for communicating with MGLServer
  client_wakeup : HEV;
    // Wake-up call for synchronous commands to MGLServer
  diveinst : HDIVE;
    // DIVE instance
  divebufnum, depthfourcc : ULONG;
    // DIVE buffer handle and the fourcc representation of current color depth
  BlSet : SETUP_BLITTER;
    // Parameters for PM DIVE operation
  palette_dirty : BOOL;
    // Internal flag marking the palette as dirty
    // Shadow palette is contained in the shared packet
  fswidth, fsheight, fsdepth : integer;
    // Dimensions of the full screen video mode chosen
  winclassname, wintitle : PChar;
  windowdecor : ulong;
  allowedmodes : pvidmode_descrip;
    // Stored internally, but developer passes these in
  vidmode_reinit : BOOL;
    // Flag that full screen session needs to change its video mode
    // (PM mode can change immediately, but full screen session needs
    //  to wait until it's reactivated to change.)
  disallow_blit : BOOL;
    // Temporary disallow blitting when screen mode is being changed.

  dbfp : pointer;  // FILE *dbfp     Debug file handle


  // DATA THAT COULD BE USEFUL FOR DEVELOPERS
  // ========================================
  autoBlitVidBufferOnRefresh : BOOL;
    // Toggles whether or not the video buffer should automatically be
    // blitted when the screen mode changes.
  isFullScreen : BOOL;
    // 1 if full screen session is active
  vidbuffer : pointer;
    // Video buffer.  Write your image HERE.
  framesync_sem : HEV;
    // Posted when a blit has been completed
  width, height, depth : integer;
    // Dimensions of the video buffer
  clientwin, framewin : HWND;
    // Client and frame window handles
  stretchblit : BOOL;
    // Enable an image to be stretched as it is blitted in full screen mode
  custommodes : BOOL;
    // Whether or not the use of custom on-the-fly video modes is allowed
end;
type pMGLSC_State=^MGLSC_State;


type InputEventType=(
  MGLSC_KEYBOARD_MAKE, MGLSC_KEYBOARD_BREAK, MGLSC_MOUSE_MOVE,
  MGLSC_MOUSE_BUTTON_PRESS, MGLSC_MOUSE_BUTTON_RELEASE,
  MGLSC_JOYSTICK_MOVE, MGLSC_JOYSTICK_BUTTON,
  MGLSC_JOYSTICK2_MOVE, MGLSC_JOYSTICK2_BUTTON
);

const   MGLSC_WINDOW_DECOR_MENU     =1;
        MGLSC_WINDOW_DECOR_ICON     =2;
        MGLSC_WINDOW_DECOR_TASKLIST =4;
        MGLSC_WINDOW_DECOR_MINMAX   =8;
        MGLSC_WINDOW_DECOR_SYSMENU  =16;
        MGLSC_WINDOW_DECOR_TITLEBAR =32;

        MGLSC_WINDOW_DECOR_PLAIN    =0;
        MGLSC_WINDOW_DECOR_ALL      =63;

type
  TypAdditionalWindowProc = function( a:HWND; b:ULONG; c:MPARAM; d:MPARAM) : MRESULT;
  //MRESULT EXPENTRY (*AdditionalWindowProc) ( HWND, ULONG, MPARAM, MPARAM );
  // If this is set, it is called from the window procedure after normal window
  // processing is complete.
  TypWindowInitializer = procedure;
  //void (*WindowInitializer) ( void );
  // This is called just after the window is created.  You can use this
  // time to enable or disable any menu items and set the window position
  // before it pops up.

  TypProcessInput = procedure ( a:InputEventType; b:short; c:short);
  //void (*ProcessInput) ( InputEventType, short, short );
  // In the keyboard messages, the first data parameter is the keyboard
  // scancode, and the second is unused.

  // In mouse and joystick movements the 2 data parameters are X and Y
  // position respectively.

  // In mouse and joystick button press messages, the first data parameter
  // is a bitmask of the button(s) pressed, and the second is unused.

  // Note that this function can be called by either the PM thread or the
  // listener queue thread (handling MGL input).  Don't rely on calling
  // any Win* API functions here.

  TypWindowClosed = procedure;
  //void (*WindowClosed) ( void );
  // Called on a WM_CLOSE message.  Use this opportunity to tell your core
  // to close up shop.  (Don't worry about closing the MGL session.  This
  // should be handled automatically.)

  TypPMMenuAction = procedure (a:ULONG);
  //void (*PMMenuAction) ( ULONG );
  // Handle any PM menu interaction here.  Command ID is passed in.

type MGLSC_event_handlers=record
  AdditionalWindowProc : ^TypAdditionalWindowProc;
  WindowInitializer : ^TypWindowInitializer;
  ProcessInput : ^TypProcessInput;
  WindowClosed : ^TypWindowClosed;
  PMMenuAction : ^TypPMMenuAction;
end;
type pMGLSC_event_handlers=^MGLSC_event_handlers;

type PMKey=record
  description : pchar;
  MGL_key : byte;
end;

Const DEFINED_KEYS=111;

//
// API CALLS
// =========
//

procedure MGLSC_init( width:integer; height:integer; depth:integer;
                      view_leftx:integer; view_topy:integer; view_rightx:integer; view_bottomy:integer;
                      eventhandler:pMGLSC_event_handlers; winclassname:pchar;
                      wintitle:pchar;allowedmodes:pvidmode_descrip;
                      windowDecorations:byte; allowCustomModes:byte;
                      useJoystickIfAvailable:byte );
// eventhandler is copied to the global struct.
// The mglclient global struct is cleared at the beginning of this call.
// You can customize the window class name and window titlebar text here.
// Note that the classname and window title strings should be
// permanently allocated somewhere before calling, not allocated on a
// stack frame that could be popped (use a global character array).
// The same is true of the allowedmodes structure.
// The allowedmodes structure should have the video modes in
// size-ascending order if you wish to get the "best fit" full screen
// video mode for the size you select.  Color depths should also be
// ascending.
// If you wish to enable joystick input, set useJoystickIfAvailable to 1
// and your ProcessInput function will receive data from the joystick
// every time MGLSC_flushUserInput (see below) is called.

procedure MGLSC_reinit( width:integer; height:integer; depth:integer;
                        allowCustomModes:byte; useJoystickIfAvailable:byte );
// Change any of the above parameters after MGLSC_init has already been
// called without shutting everything down and restarting.  This call
// attempts to use the same viewport even if the video buffer size
// changes.  If the video buffer size becomes smaller than the viewport,
// then the viewport is made smaller.

function MGLSC_clientState:pMGLSC_state;
// Returns a pointer to much useful information about the state of this
// client.  You should avoid modifying any parameters in this structure
// unless you *really* know what you're doing.  Use it for information
// only.

procedure MGLSC_setViewPort(view_leftx:integer; view_topy:integer; view_rightx:integer;
                            view_bottomy:integer; pickBestVidMode:byte);
// Sets the viewable area of the video buffer.  This allows you to make
// a video buffer that is bigger than the displayed surface to improve
// performance by not requiring you to worry about clipping your images.
// You must post a WM_BLITFRAME message for this change to take effect.
// Illegal coordinate values will be rounded to the nearest legal value.
// If pickBestVidMode is non-zero, then the full screen video mode will
// be changed to provide the best fit for the viewport.  The mode will
// be selected out of the available modes passed to MGLSC_init.  If the
// viewport is made larger than the full screen mode size, the full
// screen mode will automatically be changed to the best fit mode.

procedure MGLSC_flushUserInput;
// Makes sure that user input is acknowledged and passed to the
// appropriate event handler routine.  This call returns immediately
// and does not wait for any user input to occur.  This should be called
// about once per frame.

function MGLSC_getKeyName(PMkeycode:char):pchar;
// Returns a string describing the key passed in.  This is only really
// useful for GUI configuration dialogs, so it accepts key codes
// received from WM_CHAR KC_SCANCODE messages.  If you want the name
// associated with an MGL key code, you need to call the translate function
// below.

function MGLSC_MGLkeyToPMKeycode(MGLkeycode:char):char;
// Translates key codes received through ProcessInput or the MGL evt_
// API calls to equivalent PM scancodes.  Note that this involves a
// reverse-lookup and can be slow.  Don't use this too often if at all.

function MGLSC_PMkeyToMGLKeycode( PMkeycode:char ):char;
// Translates key codes received through a WM_CHAR KC_SCANCODE message
// to the equivalent MGL keycode.  This is not needed if the key code
// is obtained in your ProcessInput event.  These values are translated
// automatically.  This is only needed if you've got your own PM window
// getting keyboard input.

function MGLSC_isJoystickPresent:byte;
// Returns whether or not a supported joystick driver was detected.

function MGLSC_getNumJoysticks:byte;
// Returns the number of joysticks present.

function MGLSC_getNumJoyButtons( whichStick:LONG ):byte;
// Returns the number of buttons on the joystick selected (0-based).

procedure MGLSC_mouseGrab( yesNo:byte );
// When yesNo is non-zero, this causes the application to grab control of
// the mouse pointer, make the system mouse cursor invisible, and accept
// and log mouse movement and button information.  Mouse grabbing is
// automatically activated when in full screen mode, so this setting only
// applies to PM operation.  You will not receive mouse input in PM mode
// unless mouseGrab is activated.  Mouse grabbing is automatically
// deactivated if the window focus changes in PM mode.  On startup, this
// library defaults to having grabbing deactivated.

procedure MGLSC_setMouseModeRelative( isRelative:char );
// Toggles whether mouse movement should be given as relative or absolute
// measures of mouse position.  When relative mode is set on, only the
// change in the mouse position since the last event flush will be
// returned.  When absolute mode is specified (by passing a 0 to this
// function), an absolute position is specified in terms of the size of
// the playfield.  On startup, this library defaults to relative mode.
// This function can also be used to reset the absolute position back to
// the center of the playfield if absolute mode is selected.

procedure MGLSC_setMousePosition( x:integer; y:integer);
// Sets the mouse position to the desired location.  Note that these
// coordinates are in terms of the size of the viewport.


// HERE'S HOW YOU COMMUNICATE WITH THIS INTERFACE...
// =================================================
// Simply call MGLSC_init with the appropriate parameters.
// You can blit by posting a WM_BLITFRAME to the client window handle.
// This will blit the entire frame and update the palette if needed.
// The semaphore "framesync_sem" will be posted when the blit is complete.
// If you wish to update the palette, cast a pointer to the shared packet
//  to be a MGL_SERVER_COLORS_SET_PACKET *.  Next, access the "colors"
//  member of this structure and modify it as you like.  Finally, set the
//  MGLSC_clientState()->palette_dirty to 1.
// When the user specifies that they wish to go full screen or come back,
//  simply post a WM_TOGGLEFS to the client window handle.  If this is the
//  first time you've gone full screen, MGLServer will be initialized without
//  special intervention required by the developer.
// To receive user input, periodically call MGLSC_flushUserInput.
//  IMPORTANT NOTE: you MUST call this function to have the system acknowledge
//  CTRL-ESC to switch tasks, otherwise, the user can be held captive by your
//  application.  You should probably call this function with every frame
//  blit.  This function will also ensure that mouse and joystick input is
//  acknowledged.
// To capture the video buffer of your application to the clipboard, simply
//  post a WM_CLIPCAPTURE to MGLSC_clientState()->clientwin.  You will hear
//  a WA_WARNING if it succeeded or a WA_ERROR if it failed to capture.
// The WM_MOUSE_RECENTER message is used internally when mouse grabbing is
//  active.
// To adjust the window size and position to convenient values, use the
//  WM_SETWINSIZE message.  MPARAM1 is the scaling factor and MPARAM2 is
//  a flag specifying whether or not you want the window centered on the
//  desktop.
// To shut down both the PM and MGL sessions cleanly, issue a WM_CLOSE
//  message to the client window handle and do a DosWaitThread on the
//  MGLSC_clientState()->pm_thread.
//
// **IMPORTANT NOTE**
// Some audio drivers cause a problem with MGL when they are playing sound
// while MGL is initializing.  To avoid this problem, the first time the
// user requests to go full screen, you should shut down your application's
// audio interface and re-enable it when the mode switch is complete.  You
// can time this correctly simply by using WinSendMsg to pass the WM_TOGGLEFS
// message rather than WinPostMsg.  When WinSendMsg returns, it is safe to
// re-enable audio in your application.

Const WM_BLITFRAME      =WM_USER;
      WM_TOGGLEFS       =WM_USER+1;
      WM_CLIPCAPTURE    =WM_USER+2;
      WM_MOUSE_RECENTER =WM_USER+3;
      WM_SETWINSIZE     =WM_USER+4;


// This interface reserves WM_USER and WM_USER+1, so the first real user
//  message starts at WM_USER+2 or WM_USER_MSG as I've defined below.
     WM_USER_MSG        =WM_USER+50;

// Some folks might not have these definitions

Const WM_VRNENABLE  =$7f;
      WM_VRNDISABLE =$7e;

{&cdecl-}
// ---- End of Converted DualMode.h file from Dualmode library Release 3 ----

// ---- Keyboard codes from Scitech MGL, event.h file ----

const
    KB_padEnter             = $60; (* Keypad keys *)
    KB_padMinus             = $4A;
    KB_padPlus              = $4E;
    KB_padTimes             = $37;
    KB_padDivide            = $61;
    KB_padLeft              = $62;
    KB_padRight             = $63;
    KB_padUp                = $64;
    KB_padDown              = $65;
    KB_padInsert            = $66;
    KB_padDelete            = $67;
    KB_padHome              = $68;
    KB_padEnd               = $69;
    KB_padPageUp            = $6A;
    KB_padPageDown          = $6B;
    KB_padCenter            = $4C;
    KB_F1                   = $3B; (* Function keys *)
    KB_F2                   = $3C;
    KB_F3                   = $3D;
    KB_F4                   = $3E;
    KB_F5                   = $3F;
    KB_F6                   = $40;
    KB_F7                   = $41;
    KB_F8                   = $42;
    KB_F9                   = $43;
    KB_F10                  = $44;
    KB_F11                  = $57;
    KB_F12                  = $58;
    KB_left                 = $4B; (* Cursor control keys *)
    KB_right                = $4D;
    KB_up                   = $48;
    KB_down                 = $50;
    KB_insert               = $52;
    KB_delete               = $53;
    KB_home                 = $47;
    KB_end                  = $4F;
    KB_pageUp               = $49;
    KB_pageDown             = $51;
    KB_capsLock             = $3A;
    KB_numLock              = $45;
    KB_scrollLock           = $46;
    KB_leftShift            = $2A;
    KB_rightShift           = $36;
    KB_leftCtrl             = $1D;
    KB_rightCtrl            = $6C;
    KB_leftAlt              = $38;
    KB_rightAlt             = $6D;
    KB_leftWindows          = $5B;
    KB_rightWindows         = $5C;
    KB_menu                 = $5D;
    KB_sysReq               = $54;
    KB_esc                  = $01; (* Normal keyboard keys *)
    KB_1                    = $02;
    KB_2                    = $03;
    KB_3                    = $04;
    KB_4                    = $05;
    KB_5                    = $06;
    KB_6                    = $07;
    KB_7                    = $08;
    KB_8                    = $09;
    KB_9                    = $0A;
    KB_0                    = $0B;
    KB_minus                = $0C;
    KB_equals               = $0D;
    KB_backSlash            = $2B;
    KB_backspace            = $0E;
    KB_tab                  = $0F;
    KB_Q                    = $10;
    KB_W                    = $11;
    KB_E                    = $12;
    KB_R                    = $13;
    KB_T                    = $14;
    KB_Y                    = $15;
    KB_U                    = $16;
    KB_I                    = $17;
    KB_O                    = $18;
    KB_P                    = $19;
    KB_leftSquareBrace      = $1A;
    KB_rightSquareBrace     = $1B;
    KB_enter                = $1C;
    KB_A                    = $1E;
    KB_S                    = $1F;
    KB_D                    = $20;
    KB_F                    = $21;
    KB_G                    = $22;
    KB_H                    = $23;
    KB_J                    = $24;
    KB_K                    = $25;
    KB_L                    = $26;
    KB_semicolon            = $27;
    KB_apostrophe           = $28;
    KB_Z                    = $2C;
    KB_X                    = $2D;
    KB_C                    = $2E;
    KB_V                    = $2F;
    KB_B                    = $30;
    KB_N                    = $31;
    KB_M                    = $32;
    KB_comma                = $33;
    KB_period               = $34;
    KB_divide               = $35;
    KB_space                = $39;
    KB_tilde                = $29;

// ---- End of Keyboard codes from Scitech MGL, event.h file ----

implementation

procedure MGLSC_init; external 'dualmode.dll' name 'MGLSC_init';
procedure MGLSC_reinit; external 'dualmode.dll' name 'MGLSC_reinit';
function MGLSC_clientState; external 'dualmode.dll' name 'MGLSC_clientState';
procedure MGLSC_setViewPort; external 'dualmode.dll' name 'MGLSC_setViewPort';
procedure MGLSC_flushUserInput; external 'dualmode.dll' name 'MGLSC_flushUserInput';
function MGLSC_getKeyName; external 'dualmode.dll' name 'MGLSC_getKeyName';
function MGLSC_MGLkeyToPMKeycode; external 'dualmode.dll' name 'MGLSC_MGLkeyToPMKeycode';
function MGLSC_PMkeyToMGLKeycode; external 'dualmode.dll' name 'MGLSC_PMkeyToMGLKeycode';
function MGLSC_isJoystickPresent; external 'dualmode.dll' name 'MGLSC_isJoystickPresent';
function MGLSC_getNumJoysticks; external 'dualmode.dll' name 'MGLSC_getNumJoysticks';
function MGLSC_getNumJoyButtons; external 'dualmode.dll' name 'MGLSC_getNumJoyButtons';
procedure MGLSC_mouseGrab; external 'dualmode.dll' name 'MGLSC_mouseGrab';
procedure MGLSC_setMouseModeRelative; external 'dualmode.dll' name 'MGLSC_setMouseModeRelative';
procedure MGLSC_setMousePosition; external 'dualmode.dll' name 'MGLSC_setMousePosition';

end.
