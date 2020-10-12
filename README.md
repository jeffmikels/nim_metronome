# Nim Metronome

Whenever I learn a new language, I try to implement a metronome. It helps me understand the basic structure of the language as well as ways to interact with the device subsystems like audio playback.

This is an implementation of a command-line metronome in the Nim programming language using the OpenAL audio library.

It runs on the command line.

## Installation / Compilation

If you have nim installed, the rest of these commands should work to get the metronome running.

```bash
$ git clone https://github.com/jeffmikels/nim_metronome.git
$ cd nim_metronome
$ nimble install openal
$ nim c metronome
$ ./metronome click.wav
```

## Please contribute...

Please add your PRs to help me and others learn Nim with this example.
