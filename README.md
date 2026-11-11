# MYWORD Notebook

A personal notebook for learning English. Type or record your sentences, check their grammar, listen to your recordings, and find any word again later.

It is a plain HTML, CSS and JavaScript website: no build step, no framework, no server-side code, no account and no API key.

## Features

- **Type or record**: switch between typing a sentence and recording it. While you record, your words appear as text (speech-to-text in Chrome, Edge and Safari).
- **Voice recorder**: live timer and sound-level meter while recording; every saved recording gets a player with a waveform, seeking, 0.75× / 1× / 1.25× speed and download.
- **Grammar check**: the *Check grammar* button corrects the sentence and explains each change. It uses the free [LanguageTool](https://languagetool.org) API plus built-in rules for common learner mistakes (tenses with "yesterday" / "last week", "have seen … yesterday", "My sister have", "There is many", "since 2010" and more).
- **Organise**: groups (like "Lesson 5"), color categories (Everyday conversation, Job interview, Questions, Work & business, Friends & family, Study & school), tags, favourites and a *Correct* mark.
- **Search**: find any word in your sentences and corrections, with highlighting.
- **Backup**: export everything (including recordings) to one `.json` file and import it again, in any browser or on another computer.
- Light and dark mode, and works on phones.

## Run it on your computer

The microphone only works on `https://` pages or on `http://localhost`, so open the site through a local web server rather than by double-clicking `index.html`.

**Windows (nothing to install):**

```powershell
powershell -ExecutionPolicy Bypass -File serve.ps1
```

This starts a small server and opens `http://localhost:8080`. Use `-Port 8081` to choose another port, or `-NoBrowser` to skip opening the browser. Press `Ctrl+C` to stop.

**Any other static server also works**, for example `python -m http.server 8080` or `npx serve`.

## Publish it with GitHub Pages

1. Push these files to a GitHub repository.
2. In the repository, open **Settings → Pages**.
3. Under **Build and deployment**, choose **Deploy from a branch**, select your main branch and the `/ (root)` folder, then **Save**.
4. After a minute your notebook is live at `https://<your-username>.github.io/<repository-name>/`.

GitHub Pages uses `https://`, so recording works there too.

## Where your data is stored

Sentences, recordings and groups are saved **only in your browser** (IndexedDB), separately for each browser and each address. Nothing is uploaded to GitHub or to any server of this project.

- Your notebook on `localhost:8080` and your notebook on `github.io` are **separate**. To move your sentences, use **Export backup** on one and **Import backup** on the other.
- Clearing your browser's site data, or using a private window, removes the notebook. Export a backup now and then.

**Sent to other services:**

- **Check grammar** sends the sentence you are checking to `api.languagetool.org`.
- **Speech-to-text** in Chrome and Edge is processed by the browser maker's online speech service.

## Browser support

| Feature | Chrome / Edge | Safari | Firefox |
|---|---|---|---|
| Notebook, search, groups, backup | Yes | Yes | Yes |
| Recording and playback | Yes | Yes | Yes |
| Live speech-to-text | Yes | Yes | No (type what you said) |

## Project structure

```
index.html   The whole app in one file: page, styles and scripts
serve.ps1    Tiny local web server for Windows (PowerShell)
.nojekyll    Tells GitHub Pages to serve the files as they are
```

Inside `index.html`, the scripts are in this order: storage (IndexedDB), microphone recorder, speech-to-text, grammar rules, grammar checker (rules + LanguageTool), audio player, and the notebook app itself.
