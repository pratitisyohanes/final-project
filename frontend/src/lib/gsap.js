import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { useGSAP } from '@gsap/react';

// Register the plugins once so every component shares the same setup
gsap.registerPlugin(ScrollTrigger, useGSAP);

// Motion is skipped for visitors who ask for less of it
export const MOTION_OK = '(prefers-reduced-motion: no-preference)';
// Parallax needs room to breathe, so phones keep the static hero
export const PARALLAX_OK = `${MOTION_OK} and (min-width: 768px)`;

export { gsap, ScrollTrigger, useGSAP };
