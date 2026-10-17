import { Link } from 'react-router-dom';
import { formatDuration, formatRupiah } from '../utils/format';
import Badge from './ui/Badge';

export function ServiceImage({ service, className = '' }) {
  if (service.imageUrl) {
    return <img src={service.imageUrl} alt={service.name} className={`object-cover ${className}`} loading="lazy" />;
  }
  // Fallback cover built from the service initials when no image is uploaded
  const initials = service.name
    .split(' ')
    .filter((word) => /^[A-Za-z0-9]/.test(word))
    .slice(0, 2)
    .map((word) => word[0])
    .join('')
    .toUpperCase();
  return (
    <div className={`flex items-center justify-center bg-gradient-to-br from-brand-100 to-brand-200 ${className}`}>
      <span className="text-3xl font-bold text-brand-700/70">{initials}</span>
    </div>
  );
}

export default function ServiceCard({ service }) {
  return (
    <Link
      to={`/services/${service.id}`}
      className="group flex flex-col overflow-hidden rounded-xl border border-slate-200 bg-white transition hover:-translate-y-0.5 hover:shadow-md"
    >
      <ServiceImage service={service} className="h-40 w-full" />
      <div className="flex flex-1 flex-col gap-2 p-4">
        {service.category && <Badge tone="blue">{service.category.name}</Badge>}
        <h3 className="font-semibold text-slate-900 group-hover:text-brand-700">{service.name}</h3>
        <p className="line-clamp-2 flex-1 text-sm text-slate-500">{service.description || 'No description yet.'}</p>
        <div className="flex items-center justify-between pt-2">
          <span className="font-semibold text-brand-700">{formatRupiah(service.price)}</span>
          <span className="text-xs text-slate-500">{formatDuration(service.durationMinutes)}</span>
        </div>
      </div>
    </Link>
  );
}
