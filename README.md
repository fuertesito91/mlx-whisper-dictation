# MLX Whisper Dictation for macOS

**Replace Apple's built-in dictation with OpenAI's Whisper — running locally on Apple Silicon.**

Apple's native dictation is... fine. But if you've ever watched it butcher a technical term, mangle a name, or struggle with accented speech, you know it could be better. This app replaces it with [OpenAI Whisper](https://github.com/openai/whisper) running locally via [MLX](https://github.com/ml-explore/mlx) — Apple's own machine learning framework optimized for M-series chips.

**No cloud. No API keys. No subscription. Just better dictation.**

## How It Works

1. **Double-tap ⌘ (Command)** → starts recording (you'll hear a pop sound)
2. **Speak** into your mic
3. **Tap ⌘** → stops recording, transcribes your speech, and types the text into whatever app you're using

It runs as a lightweight menu bar app (⏯ icon) and works in **any text field** — browsers, editors, chat apps, Notes, Terminal, everything.

https://github.com/user-attachments/assets/placeholder-demo.gif

## Why?

| | Apple Dictation | MLX Whisper Dictation |
|---|---|---|
| **Accuracy** | Good for simple English | Excellent across languages, accents, technical terms |
| **Languages** | Limited per-language models | 99 languages, auto-detection, multilingual in one session |
| **Privacy** | Sends audio to Apple servers | 100% local — never leaves your Mac |
| **Model** | Proprietary, no choice | Choose from 40+ Whisper model variants |
| **Speed** | Fast (cloud) | Fast (MLX on Apple Silicon GPU) |
| **Custom vocabulary** | No | Whisper handles jargon, names, and code terms better |

## Requirements

- **macOS** (Ventura 13.0+ recommended)
- **Apple Silicon** (M1/M2/M3/M4) — required for MLX
- **Python 3.10+**
- **Homebrew** (for installing dependencies)

## Installation

### 1. Install system dependencies

```bash
brew install portaudio
```

### 2. Clone and set up

```bash
git clone https://github.com/YOUR_USERNAME/mlx-whisper-dictation.git
cd mlx-whisper-dictation
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. Grant macOS permissions

The app needs **Accessibility** and **Input Monitoring** permissions to detect key presses and type text into other apps.

1. Open **System Settings → Privacy & Security → Accessibility**
2. Click **+** and add the Python binary from the venv:
   ```
   /path/to/mlx-whisper-dictation/venv/bin/python
   ```
   (Tip: press ⌘+Shift+G in the file picker to type the path)
3. Do the same under **Input Monitoring**

> If you run from Terminal, also add **Terminal.app** (or your terminal of choice) to both lists.

### 4. First run (downloads the model)

```bash
source venv/bin/activate
python whisper-dictation.py -m mlx-community/whisper-large-v3-turbo --k_double_cmd -l en -t 60
```

The first run will download the Whisper model (~1.5 GB). After that, it's cached locally.

### 5. (Optional) Install as auto-start service

Create a LaunchAgent so it starts automatically on login:

```bash
cat > ~/Library/LaunchAgents/com.whisper-dictation.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.whisper-dictation</string>
    <key>ProgramArguments</key>
    <array>
        <string>/FULL/PATH/TO/mlx-whisper-dictation/venv/bin/python</string>
        <string>/FULL/PATH/TO/mlx-whisper-dictation/whisper-dictation.py</string>
        <string>-m</string>
        <string>mlx-community/whisper-large-v3-turbo</string>
        <string>--k_double_cmd</string>
        <string>-l</string>
        <string>en</string>
        <string>-t</string>
        <string>60</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/whisper-dictation.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/whisper-dictation.err</string>
</dict>
</plist>
EOF
```

**Replace `/FULL/PATH/TO/` with the actual path** to your cloned repo, then load it:

```bash
launchctl load ~/Library/LaunchAgents/com.whisper-dictation.plist
```

To manage the service:
```bash
launchctl stop com.whisper-dictation    # Stop
launchctl start com.whisper-dictation   # Start
launchctl unload ~/Library/LaunchAgents/com.whisper-dictation.plist  # Disable
```

## Usage

| Action | Trigger |
|---|---|
| Start recording | Double-tap ⌘ (Command) |
| Stop recording & transcribe | Single tap ⌘ |
| Start recording (alt) | Click "Start Recording" in menu bar |
| Stop recording (alt) | Click "Stop Recording" in menu bar |

### Audio feedback
- **Pop** sound → recording started
- **Blow** sound → recording stopped, transcribing

### Command-line options

```
-m, --model_name      Whisper model to use (default: mlx-community/whisper-large-v3-mlx)
-k, --key_combination Key combo for toggle (default: cmd_l+alt on macOS)
--k_double_cmd        Use double-tap ⌘ instead of key combination
-l, --language        Language code(s), comma-separated (e.g., "en" or "en,es,fr")
-t, --max_time        Max recording duration in seconds (default: 30)
```

### Recommended models

| Model | Size | Speed | Accuracy | Best for |
|---|---|---|---|---|
| `whisper-large-v3-turbo` | ~1.5 GB | ⚡ Fast | ★★★★★ | **Recommended** — best balance |
| `whisper-large-v3-mlx` | ~3 GB | Medium | ★★★★★ | Maximum accuracy |
| `whisper-small-mlx` | ~500 MB | ⚡⚡ Very fast | ★★★☆☆ | Older Macs, quick notes |
| `whisper-tiny-mlx` | ~150 MB | ⚡⚡⚡ Instant | ★★☆☆☆ | Testing only |

## Multilingual

Specify multiple languages and switch between them from the menu bar:

```bash
python whisper-dictation.py --k_double_cmd -l en,es,fr -m mlx-community/whisper-large-v3-turbo
```

The active language appears in the menu bar dropdown. Click a language to switch.

## Troubleshooting

### "This process is not trusted! Input event monitoring will not be possible"
→ Add the Python binary to **Accessibility** and **Input Monitoring** in System Settings (see installation step 3).

### Double-tap ⌘ doesn't trigger recording
→ Make sure you're using `--k_double_cmd` flag. Tap quickly (within 0.4 seconds).

### Text appears in the wrong app
→ The app switches focus back to wherever you were before recording started. If you click elsewhere during recording, the text will go to the originally focused app.

### Model download is slow
→ First run downloads from Hugging Face. Subsequent runs use the cached model in `~/.cache/huggingface/`.

## Credits

- Built on [OpenAI Whisper](https://github.com/openai/whisper)
- Accelerated by [Apple MLX](https://github.com/ml-explore/mlx) and [mlx-whisper](https://github.com/ml-explore/mlx-examples)
- Original concept by [Diwannist/mlx-whisper-dictation](https://github.com/Diwannist/mlx-whisper-dictation)
- Native macOS integration (NSEvent, rumps) for seamless menu bar experience

## License

MIT
