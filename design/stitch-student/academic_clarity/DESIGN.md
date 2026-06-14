---
name: Academic Clarity
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e4e2e1'
  on-surface: '#1b1c1c'
  on-surface-variant: '#40484b'
  inverse-surface: '#303030'
  inverse-on-surface: '#f3f0ef'
  outline: '#70787c'
  outline-variant: '#bfc8cb'
  surface-tint: '#266677'
  primary: '#206172'
  on-primary: '#ffffff'
  primary-container: '#3d7a8c'
  on-primary-container: '#effaff'
  inverse-primary: '#94cfe3'
  secondary: '#825500'
  on-secondary: '#ffffff'
  secondary-container: '#fdba57'
  on-secondary-container: '#724a00'
  tertiary: '#335f6d'
  on-tertiary: '#ffffff'
  tertiary-container: '#4c7887'
  on-tertiary-container: '#eefaff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b2ebff'
  primary-fixed-dim: '#94cfe3'
  on-primary-fixed: '#001f27'
  on-primary-fixed-variant: '#004e5e'
  secondary-fixed: '#ffddb3'
  secondary-fixed-dim: '#fdba57'
  on-secondary-fixed: '#291800'
  on-secondary-fixed-variant: '#633f00'
  tertiary-fixed: '#bceafa'
  tertiary-fixed-dim: '#a1cdde'
  on-tertiary-fixed: '#001f27'
  on-tertiary-fixed-variant: '#1e4c5a'
  background: '#fcf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e1'
typography:
  display:
    fontFamily: Geist
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.5px
  h1:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.4px
  h2:
    fontFamily: Geist
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.3px
  h3:
    fontFamily: Geist
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.2px
  body-lg:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-sm:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  caption:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  overline:
    fontFamily: Geist
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.8px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  padding-screen: 16px
  gutter: 12px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style

The design system is centered on **Academic Clarity**—a philosophy that balances the rigor of education with a calming, supportive interface. The brand personality is friendly and motivating, designed to reduce the cognitive load of student life. It targets university-level students who require a tool that feels both professional and approachable.

The visual style is a blend of **Corporate Modern** and **Minimalism**. It utilizes a "Flat-Plus" approach: primarily flat surfaces with subtle 1px borders for definition, ensuring a crisp, high-end feel that performs exceptionally well on high-density mobile displays. The presence of the "amber dot" in the branding signifies a spark of insight or a point of focus amidst a sea of calm teal, serving as a recurring motif for interactive or highlighted elements.

## Colors

The color palette is anchored by a sophisticated Teal (`#3D7A8C`), providing a stable, academic foundation. Amber (`#E8A847`) acts as a tactical secondary color, used sparingly for emphasis, progress indicators, and the signature branding dot. 

The system supports a full Dark Mode. In dark themes, surfaces use a tiered grayscale (`#252525` to `#454545`) to maintain depth without relying on heavy shadows. The "On-Primary" color is strictly `#FBFBFB` to ensure AAA accessibility against the teal background. Status colors for success and destruction follow standard semiotics but are slightly desaturated to fit the calm aesthetic of the design system.

## Typography

This design system utilizes **Geist** for all typographic needs, capitalizing on its precise, technical, and developer-friendly aesthetic which aligns with the academic focus. 

Headings use tight negative letter-spacing to create a compact, modern feel that looks excellent on mobile displays. The `overline` style is high-contrast, using heavy weight and wide tracking to clearly delineate sections without taking up significant vertical space. Body text maintains a 500 weight by default to ensure legibility on mobile screens where thin fonts often wash out against various backgrounds.

## Layout & Spacing

The design system follows a strict **8pt grid** (with 4px increments for micro-adjustments). As a mobile-first system, it assumes a base viewport width of 390px.

The layout is characterized by:
- **Consistent Edge Margins:** All screens use a 16px horizontal safe area.
- **Vertical Rhythm:** Content blocks are separated by 24px, while related items within a card use 8px or 12px spacing.
- **Fluid Verticals:** Since student apps are often data-dense (grades, finance logs), the layout prioritizes vertical scrolling with fixed headers and footers.
- **Grid Context:** Cards typically span the full width of the screen (minus margins) to maximize horizontal real estate for text-heavy content.

## Elevation & Depth

This design system avoids heavy shadows, instead utilizing **Tonal Layers** and **1px Outlines** to communicate depth.

- **Level 0 (Background):** `#FAFAFA` (Light) / `#252525` (Dark).
- **Level 1 (Cards/Sheets):** White surface with a 1px border (`#EBEBEB` light / `#474747` dark). 
- **Interaction:** On press, elements do not lift. Instead, they use a subtle scale-down (98%) or a slight darkening of the surface color to provide tactile feedback.
- **Modals:** Use a 20% opacity black scrim. Bottom sheets emerge with a 12px top-radius and no border, relying on a subtle ambient shadow (Blur: 20px, Y: -4, Opacity: 0.05) to separate them from the content below.

## Shapes

The shape language is "Soft-Modern." It avoids the extreme roundness of casual social apps while steering clear of the harsh corners of traditional enterprise software.

- **Primary Components:** Buttons, text inputs, and chips use an 8px radius.
- **Containers:** Dashboard cards, modal sheets, and large content blocks use a 12px radius.
- **Avatars & Indicators:** Profile images and status dots use a full pill/circle radius.
- **Selection:** Checkboxes maintain a slight 4px radius to match the overall soft aesthetic.

## Components

### Buttons
- **Primary:** 52px height, solid Teal background, white text, 8px radius. 
- **Secondary:** 52px height, 1px Teal border, Teal text.
- **Icon Buttons:** 44x44px touch target, centered 'school' cap or relevant glyph.

### Navigation & App Bar
- **App Bar:** Flat background matching the screen level, title aligned left in `H2` style.
- **Bottom Navigation:** 5 tabs with active state indicated by the Primary Teal color. Labels use `Caption` style. Icons are 24px.

### Inputs
- **Text Fields:** 52px height, filled with `#FFFFFF` (Light) / `#404040` (Dark). 1px border that turns Teal on focus.
- **Chips/Status:** Pill-shaped (`999px`). Backgrounds use a 10-15% opacity tint of the status color (e.g., light green for Success) with text in the full-saturation color.

### Data Display
- **Lists:** Clean rows with 16px internal padding. 1px bottom divider, excluding the last item.
- **Cards:** 12px radius, 1px border. No heavy drop shadows. Used for course summaries and finance overviews.
- **Progress Bars:** Thin 4px height bars. Background in `Muted Surface`, fill in `Secondary Amber` or `Primary Teal`.