"""
Device existence tests for Pi 5.

These tests only check that the OS can see each device — no frames captured,
no audio recorded. Run these first over SSH to confirm wiring before
running functional tests.

Requirements on the Pi (all pre-installed on Raspberry Pi OS):
    v4l2-ctl  ->  sudo apt install v4l-utils
    arecord   ->  sudo apt install alsa-utils
    aplay     ->  sudo apt install alsa-utils

Run with:
    pytest tests/test_devices.py -v
"""

import subprocess


def _run(cmd):
    """Run a shell command, return (stdout, returncode)."""
    result = subprocess.run(
        cmd, shell=True, capture_output=True, text=True
    )
    return result.stdout + result.stderr, result.returncode


# ---------------------------------------------------------------------------
# Cameras
# ---------------------------------------------------------------------------

class TestCameraExistence:
    def test_camera_0_device_node_exists(self):
        out, _ = _run("ls /dev/video0")
        assert "/dev/video0" in out, "/dev/video0 not found — is camera 0 connected?"

    def test_camera_1_device_node_exists(self):
        out, _ = _run("ls /dev/video1")
        assert "/dev/video1" in out, "/dev/video1 not found — is camera 1 connected?"

    def test_v4l2_lists_both_cameras(self):
        out, code = _run("v4l2-ctl --list-devices")
        assert code == 0, "v4l2-ctl failed — is v4l-utils installed? (sudo apt install v4l-utils)"
        video_nodes = [line.strip() for line in out.splitlines() if "/dev/video" in line]
        assert len(video_nodes) >= 2, (
            f"Expected at least 2 /dev/video* nodes, found {len(video_nodes)}:\n{out}"
        )


# ---------------------------------------------------------------------------
# Microphone
# ---------------------------------------------------------------------------

class TestMicrophoneExistence:
    def test_usb_mic_listed_by_arecord(self):
        out, code = _run("arecord -l")
        assert code == 0, "arecord -l failed — is alsa-utils installed? (sudo apt install alsa-utils)"
        assert "USB" in out or "usb" in out.lower(), (
            f"No USB capture device found in arecord output:\n{out}"
        )


# ---------------------------------------------------------------------------
# Speaker
# ---------------------------------------------------------------------------

class TestSpeakerExistence:
    def test_usb_speaker_listed_by_aplay(self):
        out, code = _run("aplay -l")
        assert code == 0, "aplay -l failed — is alsa-utils installed? (sudo apt install alsa-utils)"
        assert "USB" in out or "usb" in out.lower(), (
            f"No USB playback device found in aplay output:\n{out}"
        )
