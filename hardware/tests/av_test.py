#!/usr/bin/env python3
"""
Wake-word triggered A/V capture test: listens on the mic for a trigger word,
then both cameras + mic record 5s simultaneously, then the speaker announces
"done".

Requirements on the Pi (Raspberry Pi OS Bookworm):
    rpicam-vid          -> preinstalled (rpicam-apps)
    arecord / aplay     -> sudo apt install alsa-utils
    espeak-ng           -> sudo apt install espeak-ng   (spoken "done" announcement)
    vosk (Python pkg)   -> pip install vosk              (offline wake-word listening)
    Vosk small EN model -> download + unzip, then point VOSK_MODEL_PATH at the folder:
        wget https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
        unzip vosk-model-small-en-us-0.15.zip

ALSA card numbers for the mic/speaker are looked up by name at startup (see
_find_card() below) rather than hardcoded — USB card numbers are not stable
across reboots/reconnects and have been observed to swap between the mic and
speaker on this hardware.

Run with:
    python3 tests/av_test.py
"""

import json
import re
import subprocess
import sys

from vosk import Model, KaldiRecognizer

DURATION_S = 5
MIC_CARD_NAME = "USB PnP Sound Device"
SPEAKER_CARD_NAME = "USB2.0 Device"

TRIGGER_WORD = "capture"
VOSK_MODEL_PATH = "/home/michael/vosk-model-small-en-us-0.15"
VOSK_SAMPLE_RATE = 16000

CAM0_OUT = "cam0.h264"
CAM1_OUT = "cam1.h264"
AUDIO_OUT = "mic.wav"


def _find_card(tool, name_substr):
    """Return 'plughw:N,0' for the ALSA card whose name matches name_substr, per `tool -l`."""
    out = subprocess.run([tool, "-l"], capture_output=True, text=True).stdout
    for line in out.splitlines():
        m = re.match(r"^card (\d+): \S+ \[([^\]]+)\]", line)
        if m and name_substr.lower() in m.group(2).lower():
            return f"plughw:{m.group(1)},0"
    raise RuntimeError(f"No device matching {name_substr!r} found in `{tool} -l` output:\n{out}")


def wait_for_trigger(mic_device):
    """Block until TRIGGER_WORD is heard on the mic."""
    print(f"Listening for wake word '{TRIGGER_WORD}'... (Ctrl+C to cancel)")

    model = Model(VOSK_MODEL_PATH)
    recognizer = KaldiRecognizer(model, VOSK_SAMPLE_RATE)

    listen = subprocess.Popen(
        ["arecord", "-D", mic_device, "-f", "S16_LE", "-r", str(VOSK_SAMPLE_RATE),
         "-c", "1", "-t", "raw"],
        stdout=subprocess.PIPE,
    )
    last_partial = ""
    try:
        while True:
            chunk = listen.stdout.read(4000)
            if not chunk:
                break
            if recognizer.AcceptWaveform(chunk):
                text = json.loads(recognizer.Result()).get("text", "")
                if text:
                    print(f"  heard (final): {text!r}")
            else:
                text = json.loads(recognizer.PartialResult()).get("partial", "")
                # Debug visibility (Jul 2026): partial results fire continuously, so only
                # print when the text actually changes, otherwise this spams the terminal.
                if text and text != last_partial:
                    print(f"  hearing (partial): {text!r}")
                    last_partial = text
            if TRIGGER_WORD in text:
                print(f"Heard '{text}' -> triggered.")
                return
    finally:
        listen.terminate()
        listen.wait()


def start_camera(camera_index, out_path):
    return subprocess.Popen([
        "rpicam-vid",
        "--camera", str(camera_index),
        "--timeout", str(DURATION_S * 1000),
        "--width", "1280",
        "--height", "720",
        "--nopreview",
        "--output", out_path,
    ])


def start_audio(out_path, mic_device):
    return subprocess.Popen([
        "arecord", "-D", mic_device,
        "-d", str(DURATION_S),
        "-f", "cd", "-t", "wav",
        out_path,
    ])


def announce_done(speaker_device):
    print("Announcing done...")
    espeak = subprocess.Popen(["espeak-ng", "--stdout", "done"], stdout=subprocess.PIPE)
    subprocess.run(["aplay", "-D", speaker_device], stdin=espeak.stdout)
    espeak.stdout.close()
    espeak.wait()


def main():
    mic_device = _find_card("arecord", MIC_CARD_NAME)
    speaker_device = _find_card("aplay", SPEAKER_CARD_NAME)
    print(f"Mic: {mic_device} ({MIC_CARD_NAME!r})  Speaker: {speaker_device} ({SPEAKER_CARD_NAME!r})")

    wait_for_trigger(mic_device)

    print(f"Capturing {DURATION_S}s from cam0, cam1, and mic simultaneously...")
    procs = {
        "cam0 -> " + CAM0_OUT: start_camera(0, CAM0_OUT),
        "cam1 -> " + CAM1_OUT: start_camera(1, CAM1_OUT),
        "mic  -> " + AUDIO_OUT: start_audio(AUDIO_OUT, mic_device),
    }

    ok = True
    for label, proc in procs.items():
        try:
            ret = proc.wait(timeout=DURATION_S + 10)
        except subprocess.TimeoutExpired:
            proc.kill()
            ret = -1
        if ret == 0:
            print(f"  OK   {label}")
        else:
            ok = False
            print(f"  FAIL {label} (exit {ret})")

    if not ok:
        print("One or more captures failed — check device names above (rpicam-hello "
              "--list-cameras / arecord -l) before re-running.")
        sys.exit(1)

    announce_done(speaker_device)


if __name__ == "__main__":
    main()
