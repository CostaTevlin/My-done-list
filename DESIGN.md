---
version: alpha
name: My Done List
description: Dark-first, monochrome editorial UI with soft graphite glass surfaces, high-contrast white typography, and celebratory confetti accents.

colors:
  primary: "#FFFFFF"
  secondary: "#AAAAAA"
  tertiary: "#666666"
  background: "#000000"
  on-background: "#FFFFFF"
  surface: "#111111"
  on-surface: "#FFFFFF"
  surface-variant: "#1C1C1C"
  outline: "#333333"
  outline-variant: "#1C1C1C"
  error: "#E66666"
  on-error: "#FFFFFF"
  inverse-surface: "#FFFFFF"
  inverse-on-surface: "#161A14"

  token-white-light: "#FFFFFF"
  token-white-dark: "#000000"
  token-off-white-light: "#FAFAFA"
  token-off-white-dark: "#111111"
  token-border-light: "#D1D1D1"
  token-border-dark: "#333333"
  token-border-light-light: "#E8E8E8"
  token-border-light-dark: "#1C1C1C"
  token-charcoal-light: "#161A14"
  token-charcoal-dark: "#FFFFFF"
  token-dark-light: "#32373C"
  token-dark-dark: "#AAAAAA"
  token-mid-light: "#8A8A87"
  token-mid-dark: "#666666"
  token-light-light: "#B8B8B5"
  token-light-dark: "#484848"
  token-danger-light: "#CC4444"
  token-danger-dark: "#E66666"

typography:
  display:
    fontFamily: Outfit
    fontSize: 44px
    fontWeight: "200"
    lineHeight: 39.6px
    letterSpacing: -0.05em
  display-sub:
    fontFamily: Outfit
    fontSize: 28px
    fontWeight: "300"
    lineHeight: 25.2px
    letterSpacing: -0.03em
  big-numeral:
    fontFamily: Outfit
    fontSize: 120px
    fontWeight: "200"
    lineHeight: 98.4px
    letterSpacing: -0.05em
    fontFeature: '"tnum" 1'
  body:
    fontFamily: Outfit
    fontSize: 17px
    fontWeight: "400"
    lineHeight: 24.65px
    letterSpacing: -0.01em
  body-sub:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: "400"
    lineHeight: 20.3px
    letterSpacing: -0.01em
  motivational:
    fontFamily: Outfit
    fontSize: 17px
    fontWeight: "300"
    lineHeight: 25.5px
    letterSpacing: -0.01em
  label:
    fontFamily: Outfit
    fontSize: 11px
    fontWeight: "500"
    lineHeight: 13.2px
    letterSpacing: 0.08em
  rank-num:
    fontFamily: Outfit
    fontSize: 10px
    fontWeight: "500"
    lineHeight: 12px
    letterSpacing: 0em
    fontFeature: '"tnum" 1'
  time:
    fontFamily: Outfit
    fontSize: 11px
    fontWeight: "400"
    lineHeight: 13.2px
    letterSpacing: 0em
    fontFeature: '"tnum" 1'
  chart-count:
    fontFamily: Outfit
    fontSize: 13px
    fontWeight: "500"
    lineHeight: 15.6px
    letterSpacing: 0em
    fontFeature: '"tnum" 1'
  chart-day-label:
    fontFamily: Outfit
    fontSize: 11px
    fontWeight: "400"
    lineHeight: 13.2px
    letterSpacing: 0em

spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  xxl: 28px
  xxxl: 40px
  bottom-safe: 100px
  content-top-inset: 20px
  hero-gap: 32px

rounded:
  chip: 8px
  card: 14px
  focus-ring: 6px
  full: 9999px

motion:
  entrance-duration: 500ms
  entrance-curve: cubic-bezier(0.2, 0.9, 0.3, 1)
  snappy-duration: 250ms
  snappy-curve: cubic-bezier(0.2, 0.9, 0.3, 1)
  stagger: 50ms
  confetti-cleanup-buffer: 200ms
  mic-pulse-duration: 1100ms
  state-swap-duration: 300ms
  reduce-motion-strategy: remove-transforms-and-staggers-use-opacity-or-none

elevation:
  level-0: 0px
  level-1: 1px
  level-2: 4px
  level-3: 10px
  level-fab-offset: 85px

shadows:
  tab-active-pill: 0px 1px 4px #FFFFFF1A
  fab: 0px 4px 10px #00000066
  glass-sheet: 0px 0px 0px #00000000
  none: 0px 0px 0px #00000000

components:
  button-primary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-background}"
    typography: "{typography.body}"
    rounded: "{rounded.full}"
    padding: 14px
    height: 52px
  button-primary-pressed:
    backgroundColor: "#1C1C1C"
    textColor: "{colors.on-background}"
    typography: "{typography.body}"
    rounded: "{rounded.full}"
  button-primary-dark:
    backgroundColor: "#00000000"
    textColor: "{colors.on-background}"
    typography: "{typography.body}"
    rounded: "{rounded.full}"
  tab-pill:
    backgroundColor: "{colors.surface-variant}"
    textColor: "{colors.primary}"
    rounded: "{rounded.full}"
    padding: 8px
    height: 77px
  tab-pill-active:
    backgroundColor: "#4A4A4A"
    textColor: "{colors.primary}"
    rounded: "{rounded.full}"
    padding: 10px
  fab-log:
    backgroundColor: "{colors.surface-variant}"
    textColor: "{colors.on-background}"
    rounded: "{rounded.full}"
    width: 60px
    height: 60px
  chart-track:
    backgroundColor: "{colors.surface-variant}"
    rounded: "{rounded.card}"
    width: 28px
    height: 120px
  chart-bar-today:
    backgroundColor: "{colors.on-background}"
    rounded: "{rounded.card}"
  chart-bar-past:
    backgroundColor: "#5C5C5C"
    rounded: "{rounded.card}"
  sheet-glass:
    backgroundColor: "#2A2A2ECC"
    textColor: "{colors.on-background}"
    rounded: "{rounded.card}"
    padding: "{spacing.xl}"
  input-underline:
    backgroundColor: "{colors.on-background}"
    textColor: "{colors.tertiary}"
    typography: "{typography.body}"
    height: 1px
  destructive-row:
    backgroundColor: "#00000000"
    textColor: "{colors.error}"
    typography: "{typography.body}"
  semantic-secondary-text:
    backgroundColor: "{colors.background}"
    textColor: "{colors.secondary}"
    typography: "{typography.body-sub}"
  app-canvas:
    backgroundColor: "{colors.background}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body}"
  divider-strong:
    backgroundColor: "{colors.outline}"
    textColor: "{colors.on-background}"
    height: 1px
  divider-subtle:
    backgroundColor: "{colors.outline-variant}"
    textColor: "{colors.on-background}"
    height: 1px
  error-chip:
    backgroundColor: "{colors.error}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
    rounded: "{rounded.full}"
    padding: 8px
  inverse-badge:
    backgroundColor: "{colors.inverse-surface}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
    rounded: "{rounded.full}"
    padding: 8px
  palette-token-white-light:
    backgroundColor: "{colors.token-white-light}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
  palette-token-white-dark:
    backgroundColor: "{colors.token-white-dark}"
    textColor: "{colors.on-background}"
    typography: "{typography.label}"
  palette-token-off-white-light:
    backgroundColor: "{colors.token-off-white-light}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
  palette-token-off-white-dark:
    backgroundColor: "{colors.token-off-white-dark}"
    textColor: "{colors.on-background}"
    typography: "{typography.label}"
  palette-token-border-light:
    backgroundColor: "{colors.token-border-light}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
  palette-token-border-dark:
    backgroundColor: "{colors.token-border-dark}"
    textColor: "{colors.on-background}"
    typography: "{typography.label}"
  palette-token-border-light-light:
    backgroundColor: "{colors.token-border-light-light}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
  palette-token-border-light-dark:
    backgroundColor: "{colors.token-border-light-dark}"
    textColor: "{colors.on-background}"
    typography: "{typography.label}"
  palette-token-charcoal-light:
    backgroundColor: "{colors.token-charcoal-light}"
    textColor: "{colors.token-white-light}"
    typography: "{typography.label}"
  palette-token-charcoal-dark:
    backgroundColor: "{colors.token-charcoal-dark}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
  palette-token-dark-light:
    backgroundColor: "{colors.token-dark-light}"
    textColor: "{colors.token-white-light}"
    typography: "{typography.label}"
  palette-token-dark-dark:
    backgroundColor: "{colors.token-dark-dark}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
  palette-token-mid-light:
    backgroundColor: "{colors.token-mid-light}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
  palette-token-mid-dark:
    backgroundColor: "{colors.token-mid-dark}"
    textColor: "{colors.on-background}"
    typography: "{typography.label}"
  palette-token-light-light:
    backgroundColor: "{colors.token-light-light}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
  palette-token-light-dark:
    backgroundColor: "{colors.token-light-dark}"
    textColor: "{colors.on-background}"
    typography: "{typography.label}"
  palette-token-danger-light:
    backgroundColor: "{colors.token-danger-light}"
    textColor: "{colors.on-error}"
    typography: "{typography.label}"
  palette-token-danger-dark:
    backgroundColor: "{colors.token-danger-dark}"
    textColor: "{colors.inverse-on-surface}"
    typography: "{typography.label}"
---

## Overview

The visual identity is quiet, minimal, and emotionally supportive rather than productivity-aggressive. It feels like a personal journal rendered in night mode by default: generous black negative space, soft white editorial type, and low-chroma graphite containers.

The product voice is "gentle accountability." Most of the interface stays still and dim; progress moments (counter updates, selected states, confetti bursts) provide contrast and energy.

## Colors

The palette is almost achromatic and dark-first.

- Core reading contrast comes from white text on black.
- Supporting text fades through mid and light grays to keep primary entries dominant.
- Panels and controls live in layered graphite values (`#111111`, `#1C1C1C`, `#333333`).
- Destructive actions use a single muted red family.
- Confetti is the only intentionally saturated visual element and appears only as a celebration overlay.

Color usage avoids persistent bright accents. Emphasis is achieved with contrast, type scale, and structural positioning.

## Typography

Outfit is the only family, used across all display and body roles to keep the interface coherent and calm.

- Display styles are ultra-light to feel reflective rather than commanding.
- Body styles sit in regular/light weights with tight tracking for a clean reading rhythm.
- Labels and counters rely on uppercase treatment or monospaced digits to make metadata scan quickly.
- The 120px numeral is the emotional focal point and should remain stable during value changes.

Hierarchy depends on size and spacing more than color variation.

## Layout

The system uses a compact spacing scale with generous section breaks:

- Horizontal page rhythm is set by 28px gutters.
- Vertical composition alternates tight local spacing (4-16px) with explicit structural gaps (24-40px).
- Bottom-safe spacing reserves persistent room for floating navigation and input affordances.
- Content width is constrained by alignment blocks rather than explicit cards in most screens.

The result is a single-column editorial flow where each section has clear breathing room and predictable cadence.

## Elevation & Depth

Depth is subtle and sparse, expressed through glass-like tonal layering more than drop shadows.

- The page background remains flat black.
- Elevated controls (tab bar, FAB, modal sheet) separate via tone shifts and translucency.
- The sheet uses a dark translucent material panel with a drag handle and softened edges.
- Shadows are minimal and used only to clarify active or floating controls.

The visual metaphor is dimmed stage + floating controls, not card-heavy dashboards.

## Shapes

Shape language is binary:

- Capsules/circles for actions and navigation (`full` radius).
- Soft rounded rectangles for data containers (`14px` card radius, `8px` micro radius).

There are no sharp corners in interactive elements. This keeps the product approachable and soft, even when typography is stark.

## Components

### Primary actions

Primary calls to action are pill-shaped with low-contrast dark fills and white text. Press feedback is subtle (small scale/opacity change). Disabled states reduce contrast further rather than changing hue.

### Navigation shell

Bottom navigation uses a floating capsule container with three equal tab zones and an adjacent circular log FAB. Active state is a lighter gray pill, inactive state is muted text/icons on darker gray.

### Reflect chart

Weekly bars use a fixed-height rounded track. Today's bar is bright white, past active days are medium gray, and zero-value days preserve structure without adding contrast noise.

### Inputs and log sheet

Text input styling is minimalist: white body text over a single-pixel underline. Voice mode uses a circular mic control with optional pulsing ring to indicate recording. The log sheet itself is a dark glass panel separated from the background with translucency.

## Do's and Don'ts

- Do preserve the dark-first monochrome palette and rely on hierarchy before introducing color.
- Do keep interaction feedback quick, lightweight, and optional under reduced-motion preferences.
- Do maintain generous whitespace, especially around hero typography and section boundaries.
- Don't introduce persistent saturated accents for primary emphasis.
- Don't add heavy card shadows or bright strokes to standard content areas.
- Don't over-animate structural layout changes; motion should support confidence, not spectacle.
