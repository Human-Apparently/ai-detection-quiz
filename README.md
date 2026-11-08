# AI Detection Quiz

A simple, responsive seven-screen quiz: introduction, three images, one audio clip, one short text and a results page. No framework, package install or build step is required.

## Current status: response collection enabled

The GitHub Pages website submits completed answers to Supabase through `submit_ai_quiz`. Answers are validated and scored in the database. Anonymous visitors cannot read, change, or delete response rows. The browser contains only the publishable key, which is intended to be public.

A live API test verified persistence and retry behavior. **One known test record must be excluded from study statistics**; see [`supabase/TEST_DATA.md`](supabase/TEST_DATA.md) for its ID and filtering queries. Browser UI verification is still pending because this environment lacks a browser executable.

Administrators can view and export responses in Supabase Table Editor. Participant sharing and download controls were removed in the second interface review. No name or email is requested. This open questionnaire does not enforce one response per person.

## View

Open `index.html` locally or enable GitHub Pages under **Settings → Pages → Deploy from a branch → main → / (root)**.

All media are stored in `media/`; no external font service is used. Relative URLs work under the GitHub Pages repository path.

## Connect collection later

Supabase setup: see [`supabase/SETUP.zh-CN.md`](supabase/SETUP.zh-CN.md) and run [`supabase/setup.sql`](supabase/setup.sql). The project URL and publishable key are configured, and collection is enabled after a real API submission was verified. A generic independent HTTPS endpoint is also supported through `apiUrl`.

The endpoint must accept a JSON POST containing `id` (random UUID), `consent`, `version`, `answers` (five entries with `choice`, `confidence` and `seconds`) and total `duration`. Validate consent and every field, restrict CORS to the deployed website, make response IDs idempotent, score server-side and persist answers before reporting success. Return `{id, score, review}` where `review` has five `{answer, explanation, source}` entries. Return a non-2xx status if storage fails. Review the privacy text before launching the study.

## Content sources

- Human woodland image: https://images.unsplash.com/photo-1472396961693-142e6e269027
- Human portrait: https://images.unsplash.com/photo-1517841905240-472988babdf9
- Café image: generated with OpenAI image generation for this quiz.
- Human narration: a 24-second excerpt from LibriVox's *A Scandal in Bohemia* recording at https://archive.org/details/adventures_sherlock_holmes_rg_librivox
- Text: generated with ChatGPT for this quiz.

`DESIGN.md` documents the visual direction. This is an educational quiz; five choices do not establish overall AI detection ability.
