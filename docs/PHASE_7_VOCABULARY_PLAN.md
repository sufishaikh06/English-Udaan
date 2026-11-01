# Phase 7 — Two-letter Vocabulary Expansion Plan

**Status:** Proposed — awaiting owner approval  
**Date:** 2026-09-27  
**Do not implement until approved.**

This plan starts with the existing 22-word sample. It does not replace working alphabet/TTS/navigation/theme/localization/backend work. It does not claim the later 3/4/5-letter counts.

## Scope for the first Phase 7 slice

- Two-letter section only.
- Target count: **75** (`PROJECT_CONTEXT.md` minimum).
- Keep content in bundled JSON.
- Validate: word length = 2, unique stable IDs, unique words, non-empty Urdu meaning, non-empty example, non-empty TTS text.
- Reuse `LearningCard`, `AudioButton`, `SpeechService`, Urdu RTL / English LTR, and all theme modes.
- Wire the currently inactive Home “Learn words” card to `/learn/vocabulary`.
- Add search on the two-letter list.
- Keep real TTS; do not fake audio.
- Do not add MongoDB, authentication, cloud sync, hosting, or AI dictionary.

Out of scope until a later approved pass: 3-letter (100–125), 4-letter (125–150), 5-letter (150–175), vocabulary detail route, images.

## Proposed record shape

```json
{
  "id": "vocab-2-am",
  "word": "am",
  "length": 2,
  "category": "function",
  "difficulty": "beginner",
  "urduMeaning": "ہوں",
  "example": "I am happy.",
  "ttsText": "am",
  "version": "0.1.0-sample"
}
```

Existing 22 records would gain `length`, `category`, `difficulty`, and `version` without changing their IDs.

## Existing 22 words to preserve

`am, an, at, be, by, do, go, he, if, in, is, it, me, my, no, of, on, or, to, up, us, we`

## Proposed 53 additional two-letter words

These are beginner-oriented English words/function words. They are **sample curriculum pending Urdu review**, not final published content.

| ID | Word | Proposed Urdu meaning | Example | TTS |
|---|---|---|---|---|
| `vocab-2-ad` | ad | اشتہار | I saw an ad. | ad |
| `vocab-2-ah` | ah | آہ | Ah, I see. | ah |
| `vocab-2-as` | as | جیسے / کے طور پر | Be as kind as you can. | as |
| `vocab-2-ax` | ax | کلہاڑی | He has an ax. | ax |
| `vocab-2-ox` | ox | بیل | The ox is strong. | ox |
| `vocab-2-oh` | oh | اوہ | Oh, thank you. | oh |
| `vocab-2-ok` | ok | ٹھیک ہے | It is ok. | ok |
| `vocab-2-so` | so | اس لیے / بہت | I am so happy. | so |
| `vocab-2-hi` | hi | ہیلو | Hi, Ali. | hi |
| `vocab-2-ha` | ha | ہا | Ha, that is funny. | ha |
| `vocab-2-ho` | ho | ہو | Ho, look at that. | ho |
| `vocab-2-uh` | uh | اوہ / ہمم | Uh, I do not know. | uh |
| `vocab-2-um` | um | اُم | Um, let me think. | um |
| `vocab-2-ow` | ow | آئے | Ow, that hurts. | ow |
| `vocab-2-oy` | oy | اوئے | Oy, wait for me. | oy |
| `vocab-2-aw` | aw | آہ | Aw, the cat is cute. | aw |
| `vocab-2-ay` | ay | ہاں / آئے | Ay, I am here. | ay |
| `vocab-2-ye` | ye | تم / ہاں | Ye are my friends. | ye |
| `vocab-2-yo` | yo | یو | Yo, come here. | yo |
| `vocab-2-pa` | pa | ابا | Pa is at home. | pa |
| `vocab-2-ma` | ma | اماں | Ma is kind. | ma |
| `vocab-2-mu` | mu | مو | The cow says mu. | mu |
| `vocab-2-ba` | ba | با | The sheep says ba. | ba |
| `vocab-2-bo` | bo | بو | Bo is my friend. | bo |
| `vocab-2-ab` | ab | اب | Come here, Ab. | ab |
| `vocab-2-ed` | ed | ایڈ | Ed is my brother. | ed |
| `vocab-2-al` | al | ال | Al is at school. | al |
| `vocab-2-el` | el | ایل | El is my sister. | el |
| `vocab-2-em` | em | ایم | Em is here. | em |
| `vocab-2-en` | en | این | En is a letter name. | en |
| `vocab-2-ex` | ex | سابق | He is my ex. | ex |
| `vocab-2-id` | id | شناخت | Show your id. | id |
| `vocab-2-ill` excluded | — | — | Not two letters | — |
| `vocab-2-la` | la | لا | La la la. | la |
| `vocab-2-lo` | lo | لو / دیکھو | Lo, the sun is up. | lo |
| `vocab-2-na` | na | نہ | Na, do not go. | na |
| `vocab-2-ne` | ne | نے | Ne is not used this way in English; **replace if rejected**. | ne |
| `vocab-2-nu` | nu | نو | Nu is a letter name. | nu |
| `vocab-2-pi` | pi | پائی | Pi is a number. | pi |
| `vocab-2-re` | re | دوبارہ / ری | Please re-read it. | re |
| `vocab-2-sh` | sh | چپ | Sh, the baby is sleeping. | sh |
| `vocab-2-ta` | ta | تا | Ta, thank you. | ta |
| `vocab-2-ti` | ti | ٹی | Ti is a music note. | ti |
| `vocab-2-tu` | tu | تو | Tu is not standard English; **replace if rejected**. | tu |
| `vocab-2-un` | un | اَن / نہیں | Un-happy means not happy. | un |
| `vocab-2-xi` | xi | زائی | Xi is a letter name. | xi |
| `vocab-2-ya` | ya | یا | Ya, I can help. | ya |
| `vocab-2-za` | za | زا | Za is a short name. | za |
| `vocab-2-eh` | eh | اے؟ | Eh, what did you say? | eh |
| `vocab-2-er` | er | اُر | Er, I forgot. | er |
| `vocab-2-hm` | hm | ہمم | Hm, let me see. | hm |
| `vocab-2-mm` | mm | مم | Mm, this is good. | mm |
| `vocab-2-p.s. excluded` | — | — | Punctuation, not a word | — |

The table above includes two review flags (`ne`, `tu`) and two exclusions. The intended approved add-set, after dropping flagged/non-words, is the 53 real two-letter items listed in the clean list below.

## Clean 53-word add-set for implementation

`ad, ah, as, ax, ox, oh, ok, so, hi, ha, ho, uh, um, ow, oy, aw, ay, ye, yo, pa, ma, ba, bo, ab, ed, al, el, em, en, ex, id, la, lo, na, nu, pi, re, sh, ta, ti, un, xi, ya, za, eh, er, hm, mm, mu, bi, si, mi, fa`

Added to reach exactly 53 after dropping `ne`/`tu`:

| ID | Word | Proposed Urdu meaning | Example | TTS |
|---|---|---|---|---|
| `vocab-2-bi` | bi | دو / بائی | Bi means two. | bi |
| `vocab-2-si` | si | سی | Si is a music note. | si |
| `vocab-2-mi` | mi | می | Mi is a music note. | mi |
| `vocab-2-fa` | fa | فا | Fa is a music note. | fa |

**Total after approval:** 22 existing + 53 new = **75**.

## Words deliberately not included

- Abbreviations with punctuation (`p.m.`, `a.m.`).
- Non-English particles (`ne`, `tu`) unless owner explicitly wants them.
- Offensive or adult slang.
- Three-letter words padded to look short.

## Validation rules to add before claiming Phase 7 two-letter complete

1. Count == 75.
2. Every `word.length == 2`.
3. IDs unique and stable (`vocab-2-<word>`).
4. Words unique, case-normalized.
5. Urdu meaning, example, and TTS text required.
6. Invalid JSON rejected by the repository without crashing the UI.
7. Search filters the list; empty search results use `AppStateView`.
8. Home “Learn words” card navigates to the section.
9. RTL/LTR and theme modes remain intact.
10. TTS uses `SpeechService`; failures remain visible.

## Tests planned after approval

- Repository count/length/ID/duplicate validation against the 75-word file.
- Invalid record rejection.
- Home “Learn words” navigation.
- Search filtering.
- Existing Urdu RTL / English LTR tests.
- Completion persistence still works.
- `flutter analyze`, `flutter test`, and backend `npm test`.

## Owner decisions needed before coding

1. Approve or edit the 53-word add-set, especially names (`al`, `ed`, `bo`), interjections (`uh`, `hm`, `oy`), and letter/music names (`pi`, `xi`, `mi`, `fa`).
2. Confirm whether function words and interjections are acceptable in the two-letter beginner set.
3. Confirm Urdu glosses, particularly `an` → `ایک`, `by`, `of`, `at`/`on`.
4. Confirm the record-shape fields `category`, `length`, `difficulty`, and `version`.
5. Confirm that 3/4/5-letter sections stay deferred until this 75-word section is accepted.

No Phase 7 content files will be expanded until this plan is approved.
