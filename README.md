# AI Detection Quiz

A simple, responsive seven-screen quiz: introduction, three images, one audio clip, one short text and a results page. No framework, package install or build step is required.

## Current status: design preview

This version does **not collect or submit responses**. A visible banner explains preview mode. Answers stay in memory until the page is refreshed; participants can download their own answers as CSV. Scores and source explanations work locally for design review.

A GitHub repository stores source code; it is not a response database. GitHub Pages serves static files and cannot store submissions. Before recruiting 100+ participants, connect an independent HTTPS endpoint and database. Do not put database passwords or private API keys in this repository.

## View

Open `index.html` locally or enable GitHub Pages under **Settings → Pages → Deploy from a branch → main → / (root)**.

All media are stored in `media/`; no external font service is used. Relative URLs work under the GitHub Pages repository path.

## Connect collection later

Set `apiUrl` in `config.js` to the independent submission endpoint. Keep it empty until the backend is ready.

The endpoint must accept a JSON POST containing `id` (random UUID), `consent`, `version`, `answers` (five entries with `choice`, `confidence` and `seconds`) and total `duration`. Validate consent and every field, restrict CORS to the deployed website, make response IDs idempotent, score server-side and persist answers before reporting success. Return `{id, score, review}` where `review` has five `{answer, explanation, source}` entries. Return a non-2xx status if storage fails. Review the privacy text before launching the study.

## Content sources

- Human woodland image: https://images.unsplash.com/photo-1472396961693-142e6e269027
- Human portrait: https://images.unsplash.com/photo-1517841905240-472988babdf9
- Café image: generated with OpenAI image generation for this quiz.
- Human narration: a 24-second excerpt from LibriVox's *A Scandal in Bohemia* recording at https://archive.org/details/adventures_sherlock_holmes_rg_librivox
- Text: generated with ChatGPT for this quiz.

`DESIGN.md` documents the visual direction. This is an educational quiz; five choices do not establish overall AI detection ability.
