#!/bin/bash
# MLX Whisper Dictation — double-tap right ⌘ to toggle recording
cd "$(dirname "$0")"
source venv/bin/activate
exec python whisper-dictation.py -m mlx-community/whisper-large-v3-turbo --k_double_cmd -l en,es -t 60
