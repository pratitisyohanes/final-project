import { useRef } from 'react';
import { gsap, useGSAP, MOTION_OK } from '../lib/gsap';

// Fades its children in and lifts them once, the first time they scroll into view
export default function Reveal({ children, className }) {
  const ref = useRef(null);

  useGSAP(
    () => {
      const mm = gsap.matchMedia();
      mm.add(MOTION_OK, () => {
        gsap.from(ref.current, {
          y: 32,
          opacity: 0,
          duration: 0.6,
          ease: 'power2.out',
          scrollTrigger: { trigger: ref.current, start: 'top 88%', once: true },
        });
      });
    },
    { scope: ref },
  );

  return (
    <div ref={ref} className={className}>
      {children}
    </div>
  );
}
