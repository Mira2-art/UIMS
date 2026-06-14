# School Landing Page — Build Playbook (follow-up prompts)

> Ordered batches to build the **university-grade** public landing in **`frontend/`**
> (Vue 3 + Tailwind + shadcn-vue + vue-router + vue-i18n). Run Batch 0 first, verify
> it renders, then proceed. Source of truth: **`design/web-landing-design-spec.md`**.

## Global rules (every batch)

- **University-grade hi-fi:** spacious, editorial typography, real imagery (`src/assets/hero.png` + placeholders), brand teal/amber accents, subtle scroll-reveal (reduced-motion safe). Not wireframes.
- **Tokens:** reuse `src/core/constants/app_colors.ts` + shadcn vars. **No new hex.** Light + dark.
- **Structure:** `src/features/landing/` with one component per section; public route `/` (+ `/about`, `/academics`, `/admissions`, `/news`, `/contact` as needed).
- **Quality:** mobile-first responsive (640/768/1024/1280/1400); a11y (contrast over images via overlay, alt text, keyboard nav, sequential headings); CWV (optimized WebP/AVIF, lazy-load below fold, reserve aspect-ratio); SEO meta + OG + `EducationalOrganization` structured data; i18n (en/fr).
- **After each batch:** stop; confirm it renders at mobile + desktop widths, light + dark.

---

## Batch 0 — Foundation & Hero (validate before continuing)
Public layout shell: **sticky nav header** (logo, links, Portal Login dropdown, **Apply Now** CTA, mobile drawer) + **footer** (columns, contact, social, newsletter, language, legal). **Hero** section (headline, subcopy, dual CTA, `hero.png` + teal overlay). Typography/spacing system per spec §2.

> **Prompt:** "Build the **landing foundation + hero** in `frontend/` per `design/web-landing-design-spec.md`: public layout (sticky nav + footer), typography system, and the Hero section. University-grade hi-fi, light + dark, responsive. Then stop so I can view it."

---

## Batch 1 — Stats & About
Trust/stats counter bar (animated count-up, reduced-motion safe) + About/Mission section (narrative + image + values).

> **Prompt:** "Build the **Stats bar + About/Mission** sections. Hi-fi, responsive."

---

## Batch 2 — Academics & Platform features
Academics/Programs card grid (faculties + flagship programs, optional faculty filter) + "Why Trustech" platform-features cards (student portal, staff tools, real-time grades/attendance, fees online).

> **Prompt:** "Build the **Academics/Programs grid + Why-Trustech features** sections. Hi-fi, responsive."

---

## Batch 3 — Admissions, Campus Life & News
Admissions 3-step path (Apply → Admitted → Enroll) + Campus Life gallery/collage + News & Events cards.

> **Prompt:** "Build the **Admissions + Campus Life + News & Events** sections. Hi-fi, responsive."

---

## Batch 4 — Testimonials, Portals & Final CTA
Testimonials (students/alumni/faculty) + Portals section (Student app · Staff app · Admin console cards with CTAs) + Final CTA band (teal gradient).

> **Prompt:** "Build the **Testimonials + Portals + Final CTA** sections. Portals link to app stores / `/login`. Hi-fi, responsive."

---

## Final QA pass
> **Prompt:** "Run the `ui-ux-pro-max` pre-delivery checklist over the landing (contrast over imagery, alt text, keyboard nav, headings order, LCP/CLS, lazy-loading, SEO meta + structured data, dark mode) and fix issues; run `yarn build`."

### Coverage map (sections → spec §4)
Nav+Hero (1–2) · Stats+About (3–4) · Academics+Features (5–6) · Admissions+Campus+News (7–9) · Testimonials+Portals+CTA (10–12) · Footer (13).
