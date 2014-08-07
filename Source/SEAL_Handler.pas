Unit SEAL_Handler;
interface
uses SEAL_Audio;

function Init_SEAL:longint;
procedure Uninit_SEAL;

implementation

function Init_SEAL:longint;
var Info:TAudioInfo;
begin
  AInitialize;

  Info.nDeviceId := AUDIO_DEVICE_MAPPER;
  Info.wFormat := AUDIO_FORMAT_16BITS or AUDIO_FORMAT_STEREO or AUDIO_FORMAT_FILTER;
  Info.nSampleRate := 44100;
  ASuggestBufferSize(10*1024);  // 10K buffer
                                // The buggy Ensoniq driver traps on smaller buffer...:(
  result:=AOpenAudio(Info);
end;

procedure Uninit_SEAL;
begin
  ACloseAudio;
end;

begin
end.
