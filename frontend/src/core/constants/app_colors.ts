export const AppColors = {
  // Brand Colors
  primary: '#3D7A8C', // Teal
  primaryForeground: '#FBFBFB',
  secondary: '#E8A847', // Amber
  secondaryForeground: '#F7F7F7',

  // Status Colors
  destructive: '#DC3545',
  destructiveForeground: '#FFFFFF',
  success: '#34C759',
  warning: '#E8A847',
  info: '#3D7A8C',

  // Light Mode
  light: {
    background: '#FAFAFA',
    foreground: '#252525',
    card: '#FFFFFF',
    cardForeground: '#252525',
    popover: '#FFFFFF',
    popoverForeground: '#252525',
    muted: '#F7F7F7',
    mutedForeground: '#8E8E8E',
    accent: '#F7F7F7',
    accentForeground: '#343434',
    border: '#EBEBEB',
    input: '#EBEBEB',
    ring: '#B5B5B5',
  },

  // Dark Mode
  dark: {
    background: '#252525',
    foreground: '#FBFBFB',
    card: '#343434',
    cardForeground: '#FBFBFB',
    popover: '#343434',
    popoverForeground: '#FBFBFB',
    muted: '#454545',
    mutedForeground: '#B5B5B5',
    accent: '#454545',
    accentForeground: '#FBFBFB',
    border: '#474747',
    input: '#404040',
    ring: '#B5B5B5',
  },
} as const
