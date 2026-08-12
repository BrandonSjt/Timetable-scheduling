# KAI Access-style Bottom Navbar

## Goal

Replace the raised center-home navigation layout with a compact, flat five-item bottom navigation bar inspired by KAI Access while preserving every existing destination and route.

## Layout

Items appear in this order with equal width:

1. Beranda
2. Jadwal
3. Tiket
4. Asisten
5. Akun

The bar uses a white surface, a subtle top separator/shadow, safe-area padding, and no notch or floating action button. Every destination keeps a minimum 48-pixel touch target.

## States

- The selected item uses a solid icon, primary blue, and semibold label.
- Unselected items use outline icons and muted gray labels.
- Existing localized labels, semantic selection state, tap handling, and routes remain unchanged.
- Tapping an already-selected Beranda continues to clear its query parameters.

## Responsive behavior

The bar remains a single row of five equal items. Its height expands for increased system text scaling so localized labels do not clip.

## Verification

- A widget test verifies item order, selected state, navigation behavior, and absence of the old raised circular Home control.
- Flutter analyzer and debug APK build pass.
- The navbar is visually inspected on the Android emulator at a representative screen.
