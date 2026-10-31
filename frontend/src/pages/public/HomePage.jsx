import { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useCategories, useServices } from '../../hooks/queries';
import ParallaxHero from '../../components/ParallaxHero';
import Reveal from '../../components/Reveal';
import ServiceCard from '../../components/ServiceCard';
import { PageLoader } from '../../components/ui/Spinner';
import { EmptyState, ErrorState } from '../../components/ui/States';
import { ScrollTrigger } from '../../lib/gsap';

const STEPS = [
  { title: 'Choose a service', text: 'Compare site surveys, cage installation, repairs and flock health visits.' },
  { title: 'Pick a visit slot', text: 'Only slots our field team can still take are shown.' },
  { title: 'Track your booking', text: 'Follow the job from pending to completed.' },
];

export default function HomePage() {
  const services = useServices({ limit: 6 });
  const categories = useCategories();

  // Loaded data changes the page height, so scroll triggers must be measured again
  useEffect(() => {
    ScrollTrigger.refresh();
  }, [services.data, categories.data]);

  return (
    <div className="space-y-14">
      <ParallaxHero />

      {categories.data?.items?.length > 0 && (
        <Reveal className="space-y-4">
          <h2 className="text-xl font-bold text-slate-900">Categories</h2>
          <div className="flex flex-wrap gap-2">
            {categories.data.items.map((category) => (
              <Link
                key={category.id}
                to={`/services?categoryId=${category.id}`}
                className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm text-slate-700 hover:border-brand-500 hover:text-brand-700"
              >
                {category.name}
              </Link>
            ))}
          </div>
        </Reveal>
      )}

      <Reveal className="space-y-4">
        <div className="flex items-end justify-between">
          <h2 className="text-xl font-bold text-slate-900">Latest services</h2>
          <Link to="/services" className="text-sm font-medium text-brand-700 hover:underline">
            See all
          </Link>
        </div>
        {services.isLoading && <PageLoader />}
        {services.error && <ErrorState error={services.error} onRetry={services.refetch} />}
        {services.data && !services.data.items.length && <EmptyState title="No services available yet" />}
        {services.data?.items?.length > 0 && (
          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {services.data.items.map((service) => (
              <ServiceCard key={service.id} service={service} />
            ))}
          </div>
        )}
      </Reveal>

      <Reveal className="space-y-4">
        <h2 className="text-xl font-bold text-slate-900">How it works</h2>
        <ol className="grid gap-4 sm:grid-cols-3">
          {STEPS.map((step, index) => (
            <li key={step.title} className="rounded-xl border border-slate-200 bg-white p-5">
              <span className="flex h-8 w-8 items-center justify-center rounded-full bg-brand-50 text-sm font-bold text-brand-700">{index + 1}</span>
              <h3 className="mt-3 font-semibold text-slate-900">{step.title}</h3>
              <p className="mt-1 text-sm text-slate-500">{step.text}</p>
            </li>
          ))}
        </ol>
      </Reveal>
    </div>
  );
}
