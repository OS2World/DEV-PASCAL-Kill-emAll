
  ( Kill'emAll ) Example program of using DMLib and SEAL with Virtual Pascal
  --------------------------------------------------------------------------


About:
- - - -

  This package was created for fun, to check what can be done with the
 DualMode library and the SEAL Audio Library for OS/2, both written or ported
 by Marty Amodeo.

  It has been released to help and encourage others to use them, and create
 games or whatever for the OS/2 and eCS operating systems.

Program:
- - - - -

  You can use the following keys while in the program:

   Arrow keys: Move the ship
   Space     : Shoot
   Q / W     : Set volume of music
   A / S     : Set volume of sound effects
   Alt+Home  : Switch to Full-Screen and back
               (Note: you may use Home+Alt in full screen due to a bug in MGL!)
   Esc       : Exit program

  Well, actually, there is nothing to kill, you can only fly around yet.
  If you want to have enemies too, hey, you can freely modify the code! :)

Units and Source Code:
- - - - - - - - - - - -

  All the sources can be used freely, but of course, don't forget to read the
 licence agreement of the DualMode library and the SEAL, they can be different.

  In the \Source directory you will find the following Pascal files:

   KillAll.pas      : It's the main program
   DMLib.pas        : "Wrapper" unit to access the DualMode Library's functions
   SEAL_Audio.pas   : The same as above, just for SEAL Audio Library.
   GraphUtils.pas   : Some small graphical helper functions and procedures.
   DMLib_Handler.pas: Functions using DMLib, but separated to keep main program
                      simple.
   SEAL_Handler.pas : Same as above, just for SEAL Audio Library.

  For more information check the units' source codes, they are well commented.

  To get more information about DualMode library or the SEAL Audio Library,
  check the \Doc directory. There you will find the original ReadMe files for
  the libraries, and URLs where you can download them or read more about them.
  
ThankYou
- - - - -

  Many thanks to Marty Amodeo for creating and/or porting these powerful
 libraries! Thanks!
  Also thanks for the creators of Virtual Pascal, a real professional cross-
 platform compiler for OS/2, Win32, Linux and DPMI! (http://www.vpascal.com)

Contact the author:
- - - - - - - - - -

  If you have questions or comments you can contact me by e-mail:
  Doodle <kocsisp@dragon.klte.hu>

Doodle'2001