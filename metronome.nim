# Read a audio file (e.g. WAV or Ogg Vorbis)
import os, times
import openal
import streams

type AudioObject* = object
  buffer*: ALuint
  source*: ALuint
  context*: ALCcontext
  device*: ALCdevice

type WavFile* = object
  data*: pointer
  size*: int
  freq*: int
  channels*: int


proc readWav*(
  path: string,
  ): WavFile =
  # load PCM data from wav file
  var f = newFileStream(open(path))
  let
    chunkID = f.readStr(4)
    chunkSize = f.readUint32()
    format = f.readStr(4)

    subchunk1ID = f.readStr(4)
    subchunk1Size = f.readUint32()
    audioFormat = f.readUint16()
    numChannels = f.readUint16()
    sampleRate = f.readUint32()
    byteRate = f.readUint32()
    blockAlign = f.readUint16()
    bitsPerSample2 = f.readUint16()

  var subchunk2ID = ""
  var subchunk2Size: uint32
  var data: TaintedString

  while subchunk2ID != "data":
    subchunk2ID = f.readStr(4)
    subchunk2Size = f.readUint32()
    data = f.readStr(int subchunk2Size)

  assert chunkID == "RIFF"
  assert format == "WAVE"
  assert subchunk1ID == "fmt "
  assert audioFormat == 1
  assert subchunk2ID == "data"

  result.channels = int numChannels
  result.size = data.len
  result.freq = int sampleRate
  result.data = unsafeAddr data[0]

proc setupAudio(path: string) :AudioObject =
  # read the wav file
  var wav = readWav(path) # read wav file using simple helper utility
  var buffer = ALuint(0) # buffer is like a record of a sound
  var source = ALuint(0) # source is like a record player, it can play 1 buffer at a time

  # open setup and error handling
  let device = alcOpenDevice(nil)
  if device == nil: quit "OpenAL: failed to get default device"
  let ctx = device.alcCreateContext(nil)
  if ctx == nil: quit "OpenAL: failed to create context"
  if not alcMakeContextCurrent(ctx): quit "OpenAL: failed to make context current"

  # setup buffer
  alGenBuffers(ALsizei 1, addr buffer)
  alBufferData(buffer, AL_FORMAT_MONO16, wav.data, ALsizei wav.size, ALsizei wav.freq)

  # setup source
  alGenSources(ALsizei 1, addr source)
  alSourcei(source, AL_BUFFER, Alint buffer)

  result.buffer = buffer
  result.source = source
  result.context = ctx
  result.device = device


if paramCount() != 1:
  echo("Usage: playfile <filename>")
  quit(-1)

var filename = paramStr(1)
var audio = setupAudio(filename)

var bpm = 120
var next_click = getTime()
let dur = initDuration(milliseconds = toInt(60000 / bpm))
var last_click = getTime()
while true:
    var now = getTime()
    if now >= next_click:
        # echo $(now - last_click)
        # last_click = now
        next_click = next_click + dur
        alSourcePlay(audio.source)
    os.sleep(10)

# wait for sound to finish playing
# sleep(2500)

# taredown and error handling
alDeleteSources(1, addr audio.source)
alDeleteBuffers(1, addr audio.buffer)
alcDestroyContext(audio.context)
if not alcCloseDevice(audio.device): quit "OpenAL: failed to close device"
