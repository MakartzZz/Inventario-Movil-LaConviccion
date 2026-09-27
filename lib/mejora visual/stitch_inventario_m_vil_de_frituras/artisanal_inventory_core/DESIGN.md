---
name: Artisanal Inventory Core
colors:
  surface: '#fff8f5'
  surface-dim: '#f5d3c0'
  surface-bright: '#fff8f5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff1ea'
  surface-container: '#ffeadf'
  surface-container-high: '#ffe3d3'
  surface-container-highest: '#fedcc8'
  on-surface: '#29170c'
  on-surface-variant: '#504534'
  inverse-surface: '#402c1f'
  inverse-on-surface: '#ffede4'
  outline: '#827561'
  outline-variant: '#d4c4ad'
  surface-tint: '#7c5800'
  primary: '#7c5800'
  on-primary: '#ffffff'
  primary-container: '#e6a817'
  on-primary-container: '#5c4000'
  inverse-primary: '#fcbb2f'
  secondary: '#8c4f00'
  on-secondary: '#ffffff'
  secondary-container: '#fd9d33'
  on-secondary-container: '#693a00'
  tertiary: '#934b19'
  on-tertiary: '#ffffff'
  tertiary-container: '#f89c64'
  on-tertiary-container: '#723200'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdea7'
  primary-fixed-dim: '#fcbb2f'
  on-primary-fixed: '#271900'
  on-primary-fixed-variant: '#5e4200'
  secondary-fixed: '#ffdcbf'
  secondary-fixed-dim: '#ffb874'
  on-secondary-fixed: '#2d1600'
  on-secondary-fixed-variant: '#6b3b00'
  tertiary-fixed: '#ffdbc9'
  tertiary-fixed-dim: '#ffb68c'
  on-tertiary-fixed: '#321200'
  on-tertiary-fixed-variant: '#753401'
  background: '#fff8f5'
  on-background: '#29170c'
  surface-variant: '#fedcc8'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-mobile: 1.25rem
  gutter-mobile: 1rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 1.5rem
  inset-squish: 0.75rem 1.25rem
---

## Brand & Style

The visual identity of this design system is rooted in the warmth of artisanal craftsmanship and the precision of modern logistics. Designed for a plantain snacks business, the system evokes a sense of sun-drenched harvests and earthy reliability. It moves away from the cold, sterile nature of traditional inventory software, embracing a **Modern-Tactile** aesthetic that feels approachable for field operators while maintaining professional rigor.

The UI leverages a soft, high-contrast palette to ensure legibility in various lighting conditions—from bright delivery routes to dimly lit warehouses. The emotional response is one of confidence and warmth, utilizing organic curves and generous whitespace to reduce the cognitive load of data-heavy inventory tasks.

## Colors

The color strategy uses an earthy, sun-ripened spectrum to reflect the product's origin. 

*   **Primary (Golden Yellow):** Reserved for high-priority actions, app bars, and brand moments. It provides high visibility and energy.
*   **Secondary (Orange-Brown):** Used for interactive elements that require distinction from the primary path, such as "Edit" or "Filter" actions.
*   **Accent (Saddle Brown):** Utilized for status indicators and high-contrast snackbars to ensure critical system feedback is never missed.
*   **Hierarchy of Browns:** Instead of traditional grays, this system uses `Main Text` (#2C1A0E) and `Secondary Text` (#6B4226) to maintain the warm, organic atmosphere while ensuring AAA accessibility standards for legibility.

## Typography

**Plus Jakarta Sans** is the sole typeface for this design system, chosen for its modern geometric structure and warm, open apertures. It excels in readability for both quick inventory scanning and long-form data entry.

Headlines should use the Bold or SemiBold weights to create a strong clear hierarchy against the softer cream backgrounds. Body text is kept primarily at 16px to ensure accessibility for users in high-movement environments. Labels utilize a slightly tighter tracking and medium weights to differentiate themselves from interactive body text.

## Layout & Spacing

This system utilizes a **Fluid Grid** model optimized for mobile-first interactions. On mobile devices, a 4-column grid is standard with 20px (1.25rem) side margins to prevent thumbs from obscuring content. 

The vertical rhythm is based on an 8px base unit. Elements are grouped using "Stack" spacing to create clear semantic relationships:
*   **8px (sm):** Related items (e.g., input label to input field).
*   **16px (md):** Standard component spacing (e.g., card to card).
*   **24px (lg):** Section breaks and header-to-content spacing.

Containers use "squished" padding (where horizontal padding is greater than vertical) to provide a more balanced, professional look for buttons and input fields.

## Elevation & Depth

Visual hierarchy is established through **Ambient Shadows** and **Tonal Layering**. 

*   **Base Layer:** The Soft Cream (#FFFBF2) background acts as the canvas.
*   **Surface Layer:** Cards and secondary surfaces use Pure White (#FFFFFF).
*   **Elevation 1:** Low-intensity, highly diffused shadows (8% opacity of #2C1A0E) are used for static cards and input containers to lift them slightly from the cream background.
*   **Elevation 2:** Floating Action Buttons (FABs) and active snackbars use a more pronounced shadow (12% opacity) with a 4px vertical offset to indicate their immediate interactivity and importance.

Avoid using harsh black shadows; always tint shadows with the Dark Brown text color to maintain the warm aesthetic.

## Shapes

The shape language is defined by a **Rounded (Level 2)** philosophy. This softens the technical nature of inventory management and aligns with the organic nature of the product.

*   **Standard Components:** Buttons, Input Fields, and Checkboxes use a 0.5rem (8px) corner radius.
*   **Large Components:** Main surface cards and modals use 1rem (16px) to create a distinct containerized feel.
*   **Pill Elements:** Status chips and search bars should use a fully rounded (pill) radius to distinguish them from actionable buttons.

## Components

### Buttons
*   **Primary:** Solid Golden Yellow (#E6A817) with Dark Brown text. High roundedness.
*   **Secondary:** Outlined with Orange-Brown (#D47C0A) or ghost style for subtle actions.
*   **FAB:** Always Primary color, anchored to the bottom right for "New Entry" or "Scan" actions.

### Input Fields
*   **Style:** White surface with a thin 1px border in Medium Brown (#6B4226). 
*   **Focus State:** Border thickens to 2px and changes to Primary Golden Yellow. Labels are persistent or use the "Floating Label" pattern shown in the reference.

### Cards
*   **Inventory Cards:** White background, 16px padding, 8px rounded corners. Use a subtle shadow to separate from the cream background. 
*   **Header:** Use Headline-sm for product names within cards.

### Feedback
*   **Snackbars:** Dark Brown (#2C1A0E) background with White text and Golden Yellow action links.
*   **Errors:** Use #B00020 for error text and field validation borders to ensure immediate recognition.

### Inventory-Specific Elements
*   **Quantity Toggles:** Large '+' and '-' buttons with a minimum 44x44px hit area for easy use in the field.
*   **Scan Indicators:** A persistent scan icon in the search bar to trigger camera-based barcode entry.