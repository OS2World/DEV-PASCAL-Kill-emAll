///////////////////////////////////////////////////////////////////////
//
// Virtual Pascal interface for SEAL Audio library v1.06 for OS/2
//
// Back-ported audio.h file
// (This C header file was more up-to-date than the pascal unit...)
//
// For more information about it, check this source code, and
// check the SEAL project at http://projects.netlabs.org !
//
///////////////////////////////////////////////////////////////////////
Unit SEAL_Audio;

(*
 * $Id: audio.h 1.17 1996/09/25 17:13:02 chasan released $
 *              1.18 1998/10/12 23:54:08 chasan released
 *              1.19 1998/10/24 18:20:52 chasan released
 *
 * SEAL Synthetic Audio Library API Interface
 *
 * Copyright (C) 1995, 1996 Carlos Hasan. All Rights Reserved.
 *
 *)

interface
//* audio system version number */
const  AUDIO_SYSTEM_VERSION            = $0106;

//* audio capabilities bit fields definitions */
       AUDIO_FORMAT_1M08               = $00000001;
       AUDIO_FORMAT_1S08               = $00000002;
       AUDIO_FORMAT_1M16               = $00000004;
       AUDIO_FORMAT_1S16               = $00000008;
       AUDIO_FORMAT_2M08               = $00000010;
       AUDIO_FORMAT_2S08               = $00000020;
       AUDIO_FORMAT_2M16               = $00000040;
       AUDIO_FORMAT_2S16               = $00000080;
       AUDIO_FORMAT_4M08               = $00000100;
       AUDIO_FORMAT_4S08               = $00000200;
       AUDIO_FORMAT_4M16               = $00000400;
       AUDIO_FORMAT_4S16               = $00000800;

//* audio format bit fields defines for devices and waveforms */
       AUDIO_FORMAT_8BITS              = $0000;
       AUDIO_FORMAT_16BITS             = $0001;
       AUDIO_FORMAT_LOOP               = $0010;
       AUDIO_FORMAT_BIDILOOP           = $0020;
       AUDIO_FORMAT_REVERSE            = $0080;
       AUDIO_FORMAT_MONO               = $0000;
       AUDIO_FORMAT_STEREO             = $0100;
       AUDIO_FORMAT_FILTER             = $8000;

//* audio resource limits defines */
       AUDIO_MAX_VOICES                = 32;
       AUDIO_MAX_SAMPLES               = 16;
       AUDIO_MAX_PATCHES               = 128;
       AUDIO_MAX_PATTERNS              = 256;
       AUDIO_MAX_ORDERS                = 256;
       AUDIO_MAX_NOTES                 = 96;
       AUDIO_MAX_POINTS                = 12;
       AUDIO_MIN_PERIOD                = 1;
       AUDIO_MAX_PERIOD                = 31999;
       AUDIO_MIN_VOLUME                = $00;
       AUDIO_MAX_VOLUME                = $40;
       AUDIO_MIN_PANNING               = $00;
       AUDIO_MAX_PANNING               = $FF;
       AUDIO_MIN_POSITION              = $00000000;
       AUDIO_MAX_POSITION              = $00100000;
       AUDIO_MIN_FREQUENCY             = $00000200;
       AUDIO_MAX_FREQUENCY             = $00080000;

//* audio error code defines */
       AUDIO_ERROR_NONE                = $0000;
       AUDIO_ERROR_INVALHANDLE         = $0001;
       AUDIO_ERROR_INVALPARAM          = $0002;
       AUDIO_ERROR_NOTSUPPORTED        = $0003;
       AUDIO_ERROR_BADDEVICEID         = $0004;
       AUDIO_ERROR_NODEVICE            = $0005;
       AUDIO_ERROR_DEVICEBUSY          = $0006;
       AUDIO_ERROR_BADFORMAT           = $0007;
       AUDIO_ERROR_NOMEMORY            = $0008;
       AUDIO_ERROR_NODRAMMEMORY        = $0009;
       AUDIO_ERROR_FILENOTFOUND        = $000A;
       AUDIO_ERROR_BADFILEFORMAT       = $000B;
       AUDIO_LAST_ERROR                = $000B;

//* audio device identifiers */
       AUDIO_DEVICE_NONE               = $0000;
       AUDIO_DEVICE_MAPPER             = $FFFF;

//* audio product identifiers */
       AUDIO_PRODUCT_NONE              = $0000;
       AUDIO_PRODUCT_SB                = $0001;
       AUDIO_PRODUCT_SB15              = $0002;
       AUDIO_PRODUCT_SB20              = $0003;
       AUDIO_PRODUCT_SBPRO             = $0004;
       AUDIO_PRODUCT_SB16              = $0005;
       AUDIO_PRODUCT_AWE32             = $0006;
       AUDIO_PRODUCT_WSS               = $0007;
       AUDIO_PRODUCT_ESS               = $0008;
       AUDIO_PRODUCT_GUS               = $0009;
       AUDIO_PRODUCT_GUSDB             = $000A;
       AUDIO_PRODUCT_GUSMAX            = $000B;
       AUDIO_PRODUCT_IWAVE             = $000C;
       AUDIO_PRODUCT_PAS               = $000D;
       AUDIO_PRODUCT_PAS16             = $000E;
       AUDIO_PRODUCT_ARIA              = $000F;
       AUDIO_PRODUCT_WINDOWS           = $0100;
       AUDIO_PRODUCT_LINUX             = $0101;
       AUDIO_PRODUCT_SPARC             = $0102;
       AUDIO_PRODUCT_SGI               = $0103;
       AUDIO_PRODUCT_DSOUND            = $0104;
       AUDIO_PRODUCT_OS2MMPM           = $0105;
       AUDIO_PRODUCT_OS2DART           = $0106;
       AUDIO_PRODUCT_BEOSR3            = $0107;
       AUDIO_PRODUCT_BEOS              = $0108;

//* audio mixer channels */
       AUDIO_MIXER_MASTER_VOLUME       = $0001;
       AUDIO_MIXER_TREBLE              = $0002;
       AUDIO_MIXER_BASS                = $0003;
       AUDIO_MIXER_CHORUS              = $0004;
       AUDIO_MIXER_REVERB              = $0005;

//* audio envelope bit fields */
       AUDIO_ENVELOPE_ON               = $0001;
       AUDIO_ENVELOPE_SUSTAIN          = $0002;
       AUDIO_ENVELOPE_LOOP             = $0004;

//* audio pattern bit fields */
       AUDIO_PATTERN_PACKED            = $0080;
       AUDIO_PATTERN_NOTE              = $0001;
       AUDIO_PATTERN_SAMPLE            = $0002;
       AUDIO_PATTERN_VOLUME            = $0004;
       AUDIO_PATTERN_COMMAND           = $0008;
       AUDIO_PATTERN_PARAMS            = $0010;

//* audio module bit fields */
       AUDIO_MODULE_AMIGA              = $0000;
       AUDIO_MODULE_LINEAR             = $0001;
       AUDIO_MODULE_PANNING            = $8000;

type SEALWord=SmallWord;
     SEALInteger=Longint;
{&AlignRec-}
//* audio capabilities structure */
type TAudioCaps=record
      wProductId:SEALWord;                        //* product identifier */
      szProductName:array[0..29] of char;         //* product name */
      dwFormats:Longint;                          //* formats supported */
     end;
     pAudioCaps=^TAudioCaps;


//* audio format structure */
type TAudioInfo=record
      nDeviceId:SEALInteger;                      //* device identifier */
      wFormat:SEALWord;                           //* playback format */
      nSampleRate:SEALWord;                       //* sampling frequency */
     end;
     pAudioInfo=^TAudioInfo;

//* audio waveform structure */
type TAudioWave=record
      lpData:Pointer;                             //* data pointer */
      dwHandle:Longint;                           //* waveform handle */
      dwLength:Longint;                           //* waveform length */
      dwLoopStart:Longint;                        //* loop start point */
      dwLoopEnd:Longint;                          //* loop end point */
      nSampleRate:SEALWord;                       //* sampling rate */
      wFormat:SEALWord;                           //* format bits */
     end;
     pAudioWave=^TAudioWave;


//* audio envelope point structure */
type TAudioPoint=record
      nFrame:SEALWord;                            //* envelope frame */
      nValue:SEALWord;                            //* envelope value */
     end;
     pAudioPoint=^TAudioPoint;

//* audio envelope structure */
type TAudioEnvelope=record
      aEnvelope:array[1..AUDIO_MAX_POINTS] of TAudioPoint;   //* envelope points */
      nPoints:Byte;                                          //* number of points */
      nSustain:Byte;                                         //* sustain point */
      nLoopStart:Byte;                                       //* loop start point */
      nLoopEnd:Byte;                                         //* loop end point */
      wFlags:SEALWord;                                       //* envelope flags */
      nSpeed:SEALWord;                                       //* envelope speed */
     end;
     pAudioEnvelope=^TAudioEnvelope;

//* audio sample structure */
type TAudioSample=record
      szSampleName:Array[0..31] of Char;          //* sample name */
      nVolume:Byte;                               //* default volume */
      nPanning:Byte;                              //* default panning */
      nRelativeNote:Byte;                         //* relative note */
      nFinetune:Byte;                             //* finetune */
      Wave:TAudioWave;                            //* waveform handle */
     end;
     pAudioSample=^TAudioSample;

//* audio patch structure */
type TAudioPatch=record
      szPatchName:array[0..31] of char;                  //* patch name */
      aSampleNumber:array[1..AUDIO_MAX_NOTES] of byte; //* multi-sample table */
      nSamples:SEALWord;                                 //* number of samples */
      nVibratoType:Byte;                                 //* vibrato type */
      nVibratoSweep:Byte;                                //* vibrato sweep */
      nVibratoDepth:Byte;                                //* vibrato depth */
      nVibratoRate:Byte;                                 //* vibrato rate */
      nVolumeFadeout:SEALWord;                           //* volume fadeout */
      Volume:TAudioEnvelope;                             //* volume envelope */
      Panning:TAudioEnvelope;                            //* panning envelope */
      aSampleTable:pAudioSample;                         //* sample table */
     end;
     pAudioPatch=^TAudioPatch;

//* audio pattern structure */
type TAudioPattern=record
      nPacking:SEALWord;                            //* packing type */
      nTracks:SEALWord;                             //* number of tracks */
      nRows:SEALWord;                               //* number of rows */
      nSize:SEALWord;                               //* data size */
      lpData:Pointer;                               //* data pointer */
     end;
     pAudioPattern=^TAudioPattern;

//* audio module structure */
type TAudioModule=record
      szModuleName:array[0..31] of Char;            //* module name */
      wFlags:SEALWord;                              //* module flags */
      nOrders:SEALWord;                             //* number of orders */
      nRestart:SEALWord;                            //* restart position */
      nTracks:SEALWord;                             //* number of tracks */
      nPatterns:SEALWord;                           //* number of patterns */
      nPatches:SEALWord;                            //* number of patches */
      nTempo:SEALWord;                              //* initial tempo */
      nBPM:SEALWord;                                //* initial BPM */
      aOrderTable:array[1..AUDIO_MAX_ORDERS] of byte;   //* order table */
      aPanningTable:array[1..AUDIO_MAX_VOICES] of byte; //* panning table */
      aPatternTable:pAudioPattern;                  //* pattern table */
      aPatchTable:pAudioPatch;                      //* patch table */
     end;
     pAudioModule=^TAudioModule;

//* audio music track structure */
type TAudioTrack=record
      nNote:Byte;                              //* note index */
      nPatch:Byte;                             //* patch number */
      nSample:Byte;                            //* sample number */
      nCommand:Byte;                           //* effect command */
      bParams:Byte;                            //* effect params */
      nVolumeCmd:Byte;                         //* volume command */
      nVolume:Byte;                            //* volume level */
      nPanning:Byte;                           //* stereo panning */
      dwFrequency:Longint;                     //* note frequency */
      wPeriod:SEALWord;                        //* note period */
     end;
     pAudioTrack=^TAudioTrack;

{&cdecl+}   // The readme.os2 states that we must use standard call convention.
            // But experience shows that it has been compiled with cdecl!

//* audio callback function defines */

// AIAPI means __stdcall

//typedef VOID (AIAPI* LPFNAUDIOWAVE)(LPBYTE, UINT);
type FNAUDIOWAVE=procedure(p1:Pointer; p2:SmallWord);
     pFNAUDIOWAVE=^FNAUDIOWAVE;

//typedef VOID (AIAPI* LPFNAUDIOTIMER)(VOID);
     FNAUDIOTIMER=procedure;
     pFNAUDIOTIMER=^FNAUDIOTIMER;

//typedef VOID (AIAPI* LPFNAUDIOCALLBACK)(BYTE, UINT, UINT);
     FNAUDIOCALLBACK=procedure(p1:Byte; p2:SmallWord; p3:SmallWord);
     pFNAUDIOCALLBACK=^FNAUDIOCALLBACK;

//* audio handle defines */
type HAC = Longint;
     LPHAC = ^HAC;

// Misc. pointers
type pSmallWord=^SmallWord;
     pLongInt=^Longint;
     UINT = SmallWord;
     LPUINT = ^UINT;
     LONG = Longint;
     LPLONG = ^LONG;
     DWORD = Longint;
     LPBOOL = ^LongBool;

//* audio interface API prototypes */

//UINT AIAPI AInitialize(VOID);
function AInitialize:UINT;
//UINT AIAPI AGetVersion(VOID);
function AGetVersion:UINT;
//UINT AIAPI AGetAudioNumDevs(VOID);
function AGetAudioNumDevs:UINT;
//UINT AIAPI AGetAudioDevCaps(UINT nDeviceId, LPAUDIOCAPS lpCaps);
function AGetAudioDevCaps( nDeviceId:UINT; var lpCaps:TAudioCaps ):UINT;
//UINT AIAPI AGetErrorText(UINT nErrorCode, LPSTR lpText, UINT nSize);
function AGetErrorText( nErrorCode:UINT; lpText:pChar; nSize:UINT ):UINT;

//UINT AIAPI APingAudio(LPUINT lpnDeviceId);
function APingAudio( lpnDeviceId:LPUINT ):UINT;
//UINT AIAPI AOpenAudio(LPAUDIOINFO lpInfo);
function AOpenAudio( var lpInfo:TAudioInfo ):UINT;
//UINT AIAPI ACloseAudio(VOID);
function ACloseAudio:UINT;
//UINT AIAPI AUpdateAudio(VOID);
function AUpdateAudio:UINT;

//UINT AIAPI ASetAudioMixerValue(UINT nChannel, UINT nValue);
function ASetAudioMixerValue( nChannel:UINT; nValue:UINT ):UINT;

//UINT AIAPI AOpenVoices(UINT nVoices);
function AOpenVoices( nVoices:UINT ):UINT;
//UINT AIAPI ACloseVoices(VOID);
function ACloseVoices:UINT;

//UINT AIAPI ASetAudioCallback(LPFNAUDIOWAVE lpfnAudioWave);
function ASetAudioCallback( lpfnAudioWave:pFNAUDIOWAVE ):UINT;
//UINT AIAPI ASetAudioTimerProc(LPFNAUDIOTIMER lpfnAudioTimer);
function ASetAudioTimerProc( lpfnAudioTimer:pFNAUDIOTIMER ):UINT;
//UINT AIAPI ASetAudioTimerRate(UINT nTimerRate);
function ASetAudioTimerRate( nTimerRate:UINT ):UINT;

//LONG AIAPI AGetAudioDataAvail(VOID);
function AGetAudioDataAvail:LONG;
//UINT AIAPI ACreateAudioData(LPAUDIOWAVE lpWave);
function ACreateAudioData( lpWave:pAudioWave ):UINT;
//UINT AIAPI ADestroyAudioData(LPAUDIOWAVE lpWave);
function ADestroyAudioData( lpWave:pAudioWave ):UINT;
//UINT AIAPI AWriteAudioData(LPAUDIOWAVE lpWave, DWORD dwOffset, UINT nCount);
function AWriteAudioData( lpWave:pAudioWave; dwOffset:DWORD; nCount:UINT ):UINT;

//UINT AIAPI ACreateAudioVoice(LPHAC lphVoice);
function ACreateAudioVoice( lphVoice:LPHAC ):UINT;
//UINT AIAPI ADestroyAudioVoice(HAC hVoice);
function ADestroyAudioVoice( hVoice:HAC ):UINT;

//UINT AIAPI APlayVoice(HAC hVoice, LPAUDIOWAVE lpWave);
function APlayVoice( hVoice:HAC; lpWave:pAudioWave ):UINT;
//UINT AIAPI APrimeVoice(HAC hVoice, LPAUDIOWAVE lpWave);
function APrimeVoice( hVoice:HAC; lpWave:pAudioWave ):UINT;
//UINT AIAPI AStartVoice(HAC hVoice);
function AStartVoice( hVoice:HAC ):UINT;
//UINT AIAPI AStopVoice(HAC hVoice);
function AStopVoice( hVoice:HAC ):UINT;

//UINT AIAPI ASetVoicePosition(HAC hVoice, LONG dwPosition);
function ASetVoicePosition( hVoice:HAC; dwPosition:LONG ):UINT;
//UINT AIAPI ASetVoiceFrequency(HAC hVoice, LONG dwFrequency);
function ASetVoiceFrequency( hVoice:HAC; dwFrequency:LONG ):UINT;
//UINT AIAPI ASetVoiceVolume(HAC hVoice, UINT nVolume);
function ASetVoiceVolume( hVoice:HAC; nVolume:UINT ):UINT;
//UINT AIAPI ASetVoicePanning(HAC hVoice, UINT nPanning);
function ASetVoicePanning( hVoice:HAC; nPanning:UINT ):UINT;

//UINT AIAPI AGetVoicePosition(HAC hVoice, LPLONG lpdwPosition);
function AGetVoicePosition( hVoice:HAC; lpdwPosition:LPLONG ):UINT;
//UINT AIAPI AGetVoiceFrequency(HAC hVoice, LPLONG lpdwFrequency);
function AGetVoiceFrequency( hVoice:HAC; lpdwFrequency:LPLONG ):UINT;
//UINT AIAPI AGetVoiceVolume(HAC hVoice, LPUINT lpnVolume);
function AGetVoiceVolume( hVoice:HAC; lpnVolume:LPUINT ):UINT;
//UINT AIAPI AGetVoicePanning(HAC hVoice, LPUINT lpnPanning);
function AGetVoicePanning( hVoice:HAC; lpnPanning:LPUINT ):UINT;
//UINT AIAPI AGetVoiceStatus(HAC hVoice, LPBOOL lpnStatus);
function AGetVoiceStatus( hVoice:HAC; lpnStatus:LPBOOL ):UINT;

//UINT AIAPI APlayModule(LPAUDIOMODULE lpModule);
function APlayModule( lpModule:pAudioModule ):UINT;
//UINT AIAPI AStopModule(VOID);
function AStopModule:UINT;
//UINT AIAPI APauseModule(VOID);
function APauseModule:UINT;
//UINT AIAPI AResumeModule(VOID);
function AResumeModule:UINT;
//UINT AIAPI ASetModuleVolume(UINT nVolume);
function ASetModuleVolume( nVolume:UINT ):UINT;
//UINT AIAPI ASetModulePosition(UINT nOrder, UINT nRow);
function ASetModulePosition( nOrder:UINT; nRow:UINT ):UINT;
//UINT AIAPI AGetModuleVolume(LPUINT lpnVolume);
function AGetModuleVolume( lpnVolume:LPUINT ):UINT;
//UINT AIAPI AGetModulePosition(LPUINT pnOrder, LPUINT lpnRow);
function AGetModulePosition( pnOrder:LPUINT; lpnRow:LPUINT ):UINT;
//UINT AIAPI AGetModuleStatus(LPBOOL lpnStatus);
function AGetModuleStatus( var lpnStatus:LongBool ):UINT;
//UINT AIAPI ASetModuleCallback(LPFNAUDIOCALLBACK lpfnAudioCallback);
function ASetModuleCallback( lpfnAudioCallback:pFNAUDIOCALLBACK ):UINT;

//UINT AIAPI ALoadModuleFile(LPSTR lpszFileName,
//                LPAUDIOMODULE* lplpModule, DWORD dwFileOffset);
function ALoadModuleFile( lpszFileName:pChar; var lplpModule:pAudioModule; dwFileOffset:DWORD ):UINT;

//UINT AIAPI AFreeModuleFile(LPAUDIOMODULE lpModule);
function AFreeModuleFile( lpModule:pAudioModule ):UINT;

//UINT AIAPI ALoadWaveFile(LPSTR lpszFileName,
//                LPAUDIOWAVE* lplpWave, DWORD dwFileOffset);
function ALoadWaveFile( lpszFileName:pChar; var lplpWave:pAudioWave; dwFileOffset:DWORD ):UINT;
//UINT AIAPI AFreeWaveFile(LPAUDIOWAVE lpWave);
function AFreeWaveFile( lpWave:pAudioWave ):UINT;

//UINT AIAPI AGetModuleTrack(UINT nTrack, LPAUDIOTRACK lpTrack);
function AGetModuleTrack( nTrack:UINT; var lpTrack:TAudioTrack ):UINT;

// *** NOTE:
//     The following functions are not part of the standard SEAL API
//     and are therefore not portable to platforms other than OS/2.

//void AIAPI ARegisterFilter(void (*)( unsigned char*, unsigned long ));
type FNFILTER=procedure(p1:Pointer; p2:longint);
     pFNFILTER=^FNFILTER;
procedure ARegisterFilter(p:pFNFILTER);

//void AIAPI ASuggestBufferSize( unsigned long suggestion );
procedure ASuggestBufferSize( suggestion : Longint);

//unsigned long AIAPI AGetBufferSize( void );
function AGetBufferSize:Longint;


implementation

//UINT AIAPI AInitialize(VOID);
function AInitialize:UINT; external 'Audio.dll' name 'AInitialize';
//UINT AIAPI AGetVersion(VOID);
function AGetVersion:UINT; external 'Audio.dll' name 'AGetVersion';
//UINT AIAPI AGetAudioNumDevs(VOID);
function AGetAudioNumDevs:UINT; external 'Audio.dll' name 'AGetAudioNumDevs';
//UINT AIAPI AGetAudioDevCaps(UINT nDeviceId, LPAUDIOCAPS lpCaps);
function AGetAudioDevCaps( nDeviceId:UINT; var lpCaps:TAudioCaps ):UINT; external 'Audio.dll' name 'AGetAudioDevCaps';
//UINT AIAPI AGetErrorText(UINT nErrorCode, LPSTR lpText, UINT nSize);
function AGetErrorText( nErrorCode:UINT; lpText:pChar; nSize:UINT ):UINT; external 'Audio.dll' name 'AGetErrorText';

//UINT AIAPI APingAudio(LPUINT lpnDeviceId);
function APingAudio( lpnDeviceId:LPUINT ):UINT; external 'Audio.dll' name 'APingAudio';
//UINT AIAPI AOpenAudio(LPAUDIOINFO lpInfo);
function AOpenAudio( var lpInfo:TAudioInfo ):UINT; external 'Audio.dll' name 'AOpenAudio';
//UINT AIAPI ACloseAudio(VOID);
function ACloseAudio:UINT; external 'Audio.dll' name 'ACloseAudio';
//UINT AIAPI AUpdateAudio(VOID);
function AUpdateAudio:UINT; external 'Audio.dll' name 'AUpdateAudio';

//UINT AIAPI ASetAudioMixerValue(UINT nChannel, UINT nValue);
function ASetAudioMixerValue( nChannel:UINT; nValue:UINT ):UINT; external 'Audio.dll' name 'ASetAudioMixerValue';

//UINT AIAPI AOpenVoices(UINT nVoices);
function AOpenVoices( nVoices:UINT ):UINT; external 'Audio.dll' name 'AOpenVoices';
//UINT AIAPI ACloseVoices(VOID);
function ACloseVoices:UINT; external 'Audio.dll' name 'ACloseVoices';

//UINT AIAPI ASetAudioCallback(LPFNAUDIOWAVE lpfnAudioWave);
function ASetAudioCallback( lpfnAudioWave:pFNAUDIOWAVE ):UINT; external 'Audio.dll' name 'ASetAudioCallback';
//UINT AIAPI ASetAudioTimerProc(LPFNAUDIOTIMER lpfnAudioTimer);
function ASetAudioTimerProc( lpfnAudioTimer:pFNAUDIOTIMER ):UINT; external 'Audio.dll' name 'ASetAudioTimerProc';
//UINT AIAPI ASetAudioTimerRate(UINT nTimerRate);
function ASetAudioTimerRate( nTimerRate:UINT ):UINT; external 'Audio.dll' name 'ASetAudioTimerRate';

//LONG AIAPI AGetAudioDataAvail(VOID);
function AGetAudioDataAvail:LONG; external 'Audio.dll' name 'AGetAudioDataAvail';
//UINT AIAPI ACreateAudioData(LPAUDIOWAVE lpWave);
function ACreateAudioData( lpWave:pAudioWave ):UINT; external 'Audio.dll' name 'ACreateAudioData';
//UINT AIAPI ADestroyAudioData(LPAUDIOWAVE lpWave);
function ADestroyAudioData( lpWave:pAudioWave ):UINT; external 'Audio.dll' name 'ADestroyAudioData';
//UINT AIAPI AWriteAudioData(LPAUDIOWAVE lpWave, DWORD dwOffset, UINT nCount);
function AWriteAudioData( lpWave:pAudioWave; dwOffset:DWORD; nCount:UINT ):UINT; external 'Audio.dll' name 'AWriteAudioData';

//UINT AIAPI ACreateAudioVoice(LPHAC lphVoice);
function ACreateAudioVoice( lphVoice:LPHAC ):UINT; external 'Audio.dll' name 'ACreateAudioVoice';
//UINT AIAPI ADestroyAudioVoice(HAC hVoice);
function ADestroyAudioVoice( hVoice:HAC ):UINT; external 'Audio.dll' name 'ADestroyAudioVoice';

//UINT AIAPI APlayVoice(HAC hVoice, LPAUDIOWAVE lpWave);
function APlayVoice( hVoice:HAC; lpWave:pAudioWave ):UINT; external 'Audio.dll' name 'APlayVoice';
//UINT AIAPI APrimeVoice(HAC hVoice, LPAUDIOWAVE lpWave);
function APrimeVoice( hVoice:HAC; lpWave:pAudioWave ):UINT; external 'Audio.dll' name 'APrimeVoice';
//UINT AIAPI AStartVoice(HAC hVoice);
function AStartVoice( hVoice:HAC ):UINT; external 'Audio.dll' name 'AStartVoice';
//UINT AIAPI AStopVoice(HAC hVoice);
function AStopVoice( hVoice:HAC ):UINT; external 'Audio.dll' name 'AStopVoice';

//UINT AIAPI ASetVoicePosition(HAC hVoice, LONG dwPosition);
function ASetVoicePosition( hVoice:HAC; dwPosition:LONG ):UINT; external 'Audio.dll' name 'ASetVoicePosition';
//UINT AIAPI ASetVoiceFrequency(HAC hVoice, LONG dwFrequency);
function ASetVoiceFrequency( hVoice:HAC; dwFrequency:LONG ):UINT; external 'Audio.dll' name 'ASetVoiceFrequency';
//UINT AIAPI ASetVoiceVolume(HAC hVoice, UINT nVolume);
function ASetVoiceVolume( hVoice:HAC; nVolume:UINT ):UINT; external 'Audio.dll' name 'ASetVoiceVolume';
//UINT AIAPI ASetVoicePanning(HAC hVoice, UINT nPanning);
function ASetVoicePanning( hVoice:HAC; nPanning:UINT ):UINT; external 'Audio.dll' name 'ASetVoicePanning';

//UINT AIAPI AGetVoicePosition(HAC hVoice, LPLONG lpdwPosition);
function AGetVoicePosition( hVoice:HAC; lpdwPosition:LPLONG ):UINT; external 'Audio.dll' name 'AGetVoicePosition';
//UINT AIAPI AGetVoiceFrequency(HAC hVoice, LPLONG lpdwFrequency);
function AGetVoiceFrequency( hVoice:HAC; lpdwFrequency:LPLONG ):UINT; external 'Audio.dll' name 'AGetVoiceFrequency';
//UINT AIAPI AGetVoiceVolume(HAC hVoice, LPUINT lpnVolume);
function AGetVoiceVolume( hVoice:HAC; lpnVolume:LPUINT ):UINT; external 'Audio.dll' name 'AGetVoiceVolume';
//UINT AIAPI AGetVoicePanning(HAC hVoice, LPUINT lpnPanning);
function AGetVoicePanning( hVoice:HAC; lpnPanning:LPUINT ):UINT; external 'Audio.dll' name 'AGetVoicePanning';
//UINT AIAPI AGetVoiceStatus(HAC hVoice, LPBOOL lpnStatus);
function AGetVoiceStatus( hVoice:HAC; lpnStatus:LPBOOL ):UINT; external 'Audio.dll' name 'AGetVoiceStatus';

//UINT AIAPI APlayModule(LPAUDIOMODULE lpModule);
function APlayModule( lpModule:pAudioModule ):UINT; external 'Audio.dll' name 'APlayModule';
//UINT AIAPI AStopModule(VOID);
function AStopModule:UINT; external 'Audio.dll' name 'AStopModule';
//UINT AIAPI APauseModule(VOID);
function APauseModule:UINT; external 'Audio.dll' name 'APauseModule';
//UINT AIAPI AResumeModule(VOID);
function AResumeModule:UINT; external 'Audio.dll' name 'AResumeModule';
//UINT AIAPI ASetModuleVolume(UINT nVolume);
function ASetModuleVolume( nVolume:UINT ):UINT; external 'Audio.dll' name 'ASetModuleVolume';
//UINT AIAPI ASetModulePosition(UINT nOrder, UINT nRow);
function ASetModulePosition( nOrder:UINT; nRow:UINT ):UINT; external 'Audio.dll' name 'ASetModulePosition';
//UINT AIAPI AGetModuleVolume(LPUINT lpnVolume);
function AGetModuleVolume( lpnVolume:LPUINT ):UINT; external 'Audio.dll' name 'AGetModuleVolume';
//UINT AIAPI AGetModulePosition(LPUINT pnOrder, LPUINT lpnRow);
function AGetModulePosition( pnOrder:LPUINT; lpnRow:LPUINT ):UINT; external 'Audio.dll' name 'AGetModulePosition';
//UINT AIAPI AGetModuleStatus(LPBOOL lpnStatus);
function AGetModuleStatus( var lpnStatus:LongBool ):UINT; external 'Audio.dll' name 'AGetModuleStatus';
//UINT AIAPI ASetModuleCallback(LPFNAUDIOCALLBACK lpfnAudioCallback);
function ASetModuleCallback( lpfnAudioCallback:pFNAUDIOCALLBACK ):UINT; external 'Audio.dll' name 'ASetModuleCallback';

//UINT AIAPI ALoadModuleFile(LPSTR lpszFileName,
//                LPAUDIOMODULE* lplpModule, DWORD dwFileOffset);
function ALoadModuleFile( lpszFileName:pChar; var lplpModule:pAudioModule; dwFileOffset:DWORD ):UINT; external 'Audio.dll' name 'ALoadModuleFile';

//UINT AIAPI AFreeModuleFile(LPAUDIOMODULE lpModule);
function AFreeModuleFile( lpModule:pAudioModule ):UINT; external 'Audio.dll' name 'AFreeModuleFile';

//UINT AIAPI ALoadWaveFile(LPSTR lpszFileName,
//                LPAUDIOWAVE* lplpWave, DWORD dwFileOffset);
function ALoadWaveFile( lpszFileName:pChar; var lplpWave:pAudioWave; dwFileOffset:DWORD ):UINT; external 'Audio.dll' name 'ALoadWaveFile';
//UINT AIAPI AFreeWaveFile(LPAUDIOWAVE lpWave);
function AFreeWaveFile( lpWave:pAudioWave ):UINT; external 'Audio.dll' name 'AFreeWaveFile';

//UINT AIAPI AGetModuleTrack(UINT nTrack, LPAUDIOTRACK lpTrack);
function AGetModuleTrack( nTrack:UINT; var lpTrack:TAudioTrack ):UINT; external 'Audio.dll' name 'AGetModuleTrack';

// *** NOTE:
//     The following functions are not part of the standard SEAL API
//     and are therefore not portable to platforms other than OS/2.

//void AIAPI ARegisterFilter(void (*)( unsigned char*, unsigned long ));
procedure ARegisterFilter(p:pFNFILTER); external 'Audio.dll' name 'ARegisterFilter';

//void AIAPI ASuggestBufferSize( unsigned long suggestion );
procedure ASuggestBufferSize( suggestion : Longint); external 'Audio.dll' name 'ASuggestBufferSize';

//unsigned long AIAPI AGetBufferSize( void );
function AGetBufferSize:Longint; external 'Audio.dll' name 'AGetBufferSize';

{&StdCall-}

end.
