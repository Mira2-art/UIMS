# Trustech **School Landing Page** — Master Design Spec (university-grade)

> Single source of truth for the public marketing site. Self-contained.
> Stack: **Vue 3 + Vite + Tailwind + shadcn-vue + vue-router + vue-i18n** (existing
> `frontend/`). Brand tokens already in `frontend/src/core/constants/app_colors.ts` +
> `src/assets/index.css` — **reuse them, no new hex.** A hero image exists at
> `src/assets/hero.png`. Decisions cite `ui-ux-pro-max` rule IDs.

---

## 1. Context & goals

- **What:** the public, marketing **landing/home page** for the institution — university-grade: authoritative, spacious, imagery-rich, trustworthy.
- **Audience:** prospective students & parents (primary), faculty/partners, current students/staff (find the portals).
- **Primary goals (CTA hierarchy):** 1) **Apply / Admissions**, 2) **Explore Programs**, 3) **Portal login** (student/staff/admin). One primary CTA per section (`primary-action`).
- **Product type:** marketing landing → hero-centric, social proof, content-first.

---

## 2. Design system (reuse existing tokens)

- **Color:** brand teal `#3D7A8C` + amber `#E8A847` accents on a light, airy base (`#FAFAFA`/white, ink `#252525`); dark mode supported via shadcn vars. Use teal for primary CTAs/headers, amber for highlights/accents. Same tokens as the console — **no new hex**.
- **Typography:** a confident editorial pairing — **Display serif or strong grotesque for headings** (e.g. *Fraunces*/*Spectral* or *Geist*/*Inter* bold) + clean sans body (Geist/Inter). University tone = larger headings, generous leading. Scale: Hero 56–72 · H2 36–44 · H3 24–28 · Lead 18–20 · Body 16–18. Limit line length 60–75 chars (`line-length`).
- **Layout:** centered container max ~1200–1400px, 2rem gutters; generous vertical rhythm (96–128px section padding on desktop). Strong grid, lots of whitespace (`whitespace-balance`).
- **Imagery:** real campus/student photography (hero, about, campus life); subtle teal gradient overlays; rounded-`lg` media. Optimize WebP/AVIF, lazy-load below fold (`image-optimization`, `lazy-load-below-fold`), reserve aspect ratio (`image-dimension`).
- **Motion:** subtle scroll-reveal (fade/slide, 150–300ms, staggered), respect `reduced-motion`; no decorative-only motion.

---

## 3. Components

Nav bar (transparent→solid on scroll), buttons (primary teal / outline), stat counters, program/faculty cards, feature cards with lucide icons, testimonial cards, news/event cards, accordion (FAQ), portal cards, newsletter input, footer columns. All shadcn-vue + Tailwind, brand-tokened.

---

## 4. Page sections (information architecture, top → bottom)

1. **Header / Nav** — logo (Trustech wordmark + `school` cap, amber dot), links: About · Academics · Admissions · Campus Life · News · Contact; right side: **Portal Login** (dropdown: Student app · Staff app · Admin console) + **Apply Now** (primary). Sticky, condenses on scroll; mobile = hamburger drawer.
2. **Hero** — institution headline + subcopy + dual CTA (**Apply Now** primary, **Explore Programs** secondary); `hero.png` with teal gradient overlay; optional accreditation badges. Above-the-fold, fast (`critical-css`).
3. **Trust / Stats bar** — 3–4 counters (Students enrolled · Faculties · Programs · Graduate success %) with tabular figures; animated count-up (reduced-motion safe).
4. **About / Mission** — short narrative + supporting image; "Learn more" link; values chips.
5. **Academics / Programs** — faculties & flagship programs as a responsive card grid (icon, name, blurb, "View"); filter by faculty (optional); CTA "Browse all programs".
6. **Why Trustech (platform features)** — the digital experience: student portal, staff tools, real-time grades & attendance, fees & scholarships online, announcements. Feature cards with lucide icons.
7. **Admissions** — simple 3-step path (Apply → Get admitted → Enroll), deadline/intake note, **Start application** CTA. *(Marketing only; the apps' lifecycle begins at enrollment.)*
8. **Campus Life** — photo collage/gallery; brief copy.
9. **News & Events** — latest 3 cards (date, title, excerpt, link); "All news".
10. **Testimonials** — students/alumni/faculty quotes with avatar + role; carousel or grid.
11. **Portals** — three cards: **Student app** (App Store/Play badges), **Staff (Pro) app** (badges), **Admin console** (Open console). Clear who each is for.
12. **Final CTA band** — teal gradient banner: "Ready to join Trustech?" + Apply / Contact.
13. **Footer** — columns (About, Academics, Admissions, Resources, Contact), address/phone/email, social icons, newsletter signup, language switch (en/fr), legal (Privacy, Terms), © line.

---

## 5. Responsive & quality

- **Breakpoints:** mobile-first; 640/768/1024/1280/1400 (`breakpoint-consistency`). Single-column mobile → multi-column desktop; nav → drawer; grids reflow.
- **Accessibility:** semantic landmarks/headings (sequential h1→h6), contrast ≥4.5:1 over imagery (overlay/scrim), focus states, alt text on all images, keyboard-operable nav/carousel, color-not-only.
- **Performance (Core Web Vitals):** optimized responsive images, lazy-load below fold, font-display swap, reserve space (CLS < 0.1), minimal hero JS.
- **SEO:** proper `<title>`/meta/OG tags, descriptive headings, structured data (EducationalOrganization), sitemap.
- **i18n:** en/fr via vue-i18n (scaffolded).

---

## 6. Build & output notes
- Implement in `frontend/` as the public route `/` (and `/about`, `/academics`, `/admissions`, `/news`, `/contact` as needed); console lives under `/admin` (separate spec). Section components under `src/features/landing/` or `src/components/landing/`.
- Reuse brand tokens; hero asset `src/assets/hero.png`; lucide icons.
- Portal CTAs deep-link: Student/Staff → app store links (or `/download`), Admin → `/login`.

## 7. Acceptance checklist
- [ ] University-grade: spacious, editorial type, real imagery, trust signals.
- [ ] Brand tokens reused; light + dark; no new hex.
- [ ] All sections (§4) present; one clear primary CTA per section; Apply is the top CTA.
- [ ] Portals section routes to Student app / Staff app / Admin console.
- [ ] Responsive 640→1400; nav drawer on mobile; grids reflow.
- [ ] A11y (contrast over images, alt text, keyboard, headings) + CWV (LCP/CLS) + SEO meta/structured data.
