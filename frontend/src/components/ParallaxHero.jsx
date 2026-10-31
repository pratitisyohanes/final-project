import { useRef } from 'react';
import { Link } from 'react-router-dom';
import { gsap, useGSAP, MOTION_OK, PARALLAX_OK } from '../lib/gsap';

// Back to front. `extra` is how much taller than the hero a layer is; the layer
// slides down by exactly that amount, so its edges never show an empty gap.
const LAYERS = [
  { src: '/parallax/sky.svg', extra: 0.3 },
  { src: '/parallax/barn.svg', extra: 0.18 },
  { src: '/parallax/cages.svg', extra: 0.08 },
];

const layerStyle = ({ extra }) => ({
  top: `${-extra * 100}%`,
  height: `${(1 + extra) * 100}%`,
});

// Share of the layer's own height it travels to land flush with the hero top
const travelPercent = (extra) => (extra / (1 + extra)) * 100;

export default function ParallaxHero() {
  const root = useRef(null);

  useGSAP(
    () => {
      const mm = gsap.matchMedia();

      mm.add(MOTION_OK, () => {
        gsap.from('[data-intro]', { y: 24, opacity: 0, duration: 0.7, stagger: 0.12, ease: 'power2.out' });
      });

      mm.add(PARALLAX_OK, () => {
        gsap.utils.toArray('[data-extra]').forEach((layer) => {
          gsap.to(layer, {
            yPercent: travelPercent(Number(layer.dataset.extra)),
            ease: 'none',
            scrollTrigger: { trigger: root.current, start: 'top top', end: 'bottom top', scrub: 0.5 },
          });
        });
      });
    },
    { scope: root },
  );

  return (
    <section ref={root} className="relative overflow-hidden rounded-2xl bg-brand-900 text-white">
      {LAYERS.map((layer) => (
        <img
          key={layer.src}
          src={layer.src}
          alt=""
          aria-hidden="true"
          data-extra={layer.extra}
          style={layerStyle(layer)}
          className="pointer-events-none absolute left-0 w-full object-cover will-change-transform"
        />
      ))}
      {/* Keeps the headline readable over the artwork */}
      <div className="absolute inset-0 bg-gradient-to-r from-brand-900/85 via-brand-900/50 to-transparent" />

      <div className="relative px-6 py-14 sm:px-10 sm:py-24">
        <p data-intro className="text-sm font-semibold uppercase tracking-wider text-brand-200">
          Layer farm services
        </p>
        <h1 data-intro className="mt-3 max-w-2xl text-3xl font-bold leading-tight sm:text-4xl">
          Book cage installation and farm visits at a time that suits you.
        </h1>
        <p data-intro className="mt-4 max-w-xl text-brand-100">
          See when our field team is free, reserve a visit in a few clicks, and keep every job for your layer farm in one place.
        </p>
        <div data-intro className="mt-8 flex flex-wrap gap-3">
          <Link to="/services" className="rounded-lg bg-white px-5 py-2.5 font-semibold text-brand-900 hover:bg-brand-50">
            Browse services
          </Link>
          <Link to="/register" className="rounded-lg border border-white/30 px-5 py-2.5 font-semibold text-white hover:bg-white/10">
            Create an account
          </Link>
        </div>
      </div>
    </section>
  );
}
