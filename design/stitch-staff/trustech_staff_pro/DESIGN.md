---
name: Trustech Staff Pro
colors:
  surface: '#f8f9fb'
  surface-dim: '#d8dadb'
  surface-bright: '#f8f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f5'
  surface-container: '#eceeef'
  surface-container-high: '#e7e8ea'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#40484b'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#eff1f2'
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
  tertiary: '#7e4f23'
  on-tertiary: '#ffffff'
  tertiary-container: '#9a6739'
  on-tertiary-container: '#fff7f4'
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
  tertiary-fixed: '#ffdcc1'
  tertiary-fixed-dim: '#f9ba84'
  on-tertiary-fixed: '#2e1500'
  on-tertiary-fixed-variant: '#673d12'
  background: '#f8f9fb'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display:
    fontFamily: Geist
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  h1:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  h2:
    fontFamily: Geist
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  h3:
    fontFamily: Geist
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  caption:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  overline:
    fontFamily: Geist
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  screen-padding: 16px
  gutter: 12px
---

## Brand & Style
The design system is engineered for educators and administrative staff who require high utility and clarity in fast-paced school environments. The brand personality is **Professional, Calm, and Data-Dense**, prioritizing information hierarchy over decorative elements.

The style is **Corporate Modern with a Flat Aesthetic**, utilizing precise 1px borders and tonal layering rather than shadows to define depth. This approach ensures maximum legibility and a systematic feel that mirrors the structured nature of academic data. The interface should feel like a high-performance tool: reliable, unobtrusive, and efficient.

## Colors
This design system utilizes a sophisticated Teal as its primary driver, representing stability and growth. A subtle gradient is applied to primary actions to provide a sense of "pressable" depth without breaking the flat aesthetic.

- **Primary:** Use for main actions, headers, and the school cap brand mark.
- **Secondary (Amber):** Use sparingly for "attention" states, such as pending approvals or urgent notifications.
- **Data Status:** Success (Green) and Destructive (Red) follow standard semantic patterns but are slightly desaturated to maintain the calm professional tone.
- **Surface Strategy:** In Light mode, use the pure white surface for cards against the off-white background to create a clean "sheet" effect. In Dark mode, use the elevated charcoal surface to maintain contrast.

## Typography
The system relies on **Geist**, a typeface designed for precision and technical clarity. The scale is optimized for high-density mobile layouts where screen real estate is at a premium.

- **Display & Headlines:** Use for page titles and critical data points (e.g., total student count).
- **Body-sm:** The workhorse for list items, descriptions, and data tables.
- **Overline:** Use for categorization labels above headers to provide context without occupying significant vertical space.
- **Weight Usage:** Stick to Regular (400) for body text and SemiBold/Bold (600/700) for emphasis and headers to ensure a clear visual hierarchy.

## Layout & Spacing
The layout follows a **4/8-pt soft grid system** to maintain mathematical harmony.

- **Screen Margins:** A consistent 16px horizontal padding is required for all mobile screens.
- **Data Density:** Elements within cards should use 8px or 12px spacing to maximize information density while remaining touch-friendly.
- **Grid model:** While primarily a single-column flow for mobile lists, use a 2-column grid for dashboard widgets to allow for quick scanning of KPIs.

## Elevation & Depth
This design system avoids traditional drop shadows in favor of a **Flat-Stroke Model**. 

- **Structural Borders:** Use a 1px border (`#EBEBEB` light / `#474747` dark) to define the perimeter of cards, inputs, and containers.
- **Tonal Elevation:** Instead of lifting objects with shadows, use the "Surface" color to distinguish elements from the "Background."
- **Focus State:** Active or focused elements (like a selected input or active tab) should use a thicker 2px primary teal border or a subtle background tint change to signal interaction.

## Shapes
The shape language balances professional rigidity with approachable softness. 

- **Small Components:** Buttons and Input fields use an 8px radius for a precise, "tech" look.
- **Large Containers:** Cards, bottom sheets, and modals use a 12px radius to feel distinct from the background.
- **Status Indicators:** Use 999px (Pill) for status chips (e.g., "Present", "Absent") to differentiate them from actionable buttons.

## Components

- **Buttons:** 52px fixed height for primary actions. Apply the Teal gradient (`#3D7A8C` to `#2D5A68`). Text should be Geist SemiBold 16px.
- **Input Fields:** 52px height with a 1px border. Use the "Input Fill" variable for the background. Labels should use the `Caption` style positioned above the field.
- **Cards:** White surface with a 1px border and 12px corner radius. Group related data points using `Body-sm` for values and `Overline` for descriptions.
- **Status Chips:** Pill-shaped, using a light tint of the semantic color (Success/Secondary/Destructive) with a matching dark text color.
- **Bottom Navigation:** 4 tabs with 24pt Material Symbols (Outlined). The active state uses the Primary Teal color for both icon and label.
- **Navigation Drawer:** Accessible via the top-left hamburger. Should feature a header with the "School Cap" brand mark and the staff member's profile summary.
- **Iconography:** Use Material Symbols (Outlined) with a 2px stroke weight for consistency.