import { useCategories, useServices } from '../../hooks/queries';
import { useUrlFilters } from '../../hooks/useUrlFilters';
import ServiceCard from '../../components/ServiceCard';
import PageHeader from '../../components/ui/PageHeader';
import SearchInput from '../../components/ui/SearchInput';
import Pagination from '../../components/ui/Pagination';
import { Input, Select } from '../../components/ui/FormField';
import { PageLoader } from '../../components/ui/Spinner';
import { EmptyState, ErrorState } from '../../components/ui/States';

const SORT_OPTIONS = [
  { value: 'createdAt:desc', label: 'Newest' },
  { value: 'price:asc', label: 'Lowest price' },
  { value: 'price:desc', label: 'Highest price' },
  { value: 'name:asc', label: 'Name A-Z' },
];

const PAGE_SIZE = 9;

export default function ServicesPage() {
  const [filters, setFilters] = useUrlFilters({ sort: 'createdAt:desc' });
  const categories = useCategories();
  const services = useServices({ ...filters, limit: PAGE_SIZE });

  const categoryOptions = (categories.data?.items || []).map((category) => ({ value: category.id, label: category.name }));

  return (
    <div className="space-y-6">
      <PageHeader title="Services" description="Find a service, then pick an available schedule." />

      <div className="grid gap-3 rounded-xl border border-slate-200 bg-white p-4 sm:grid-cols-2 lg:grid-cols-5">
        <div className="sm:col-span-2 lg:col-span-2">
          <SearchInput value={filters.search || ''} onChange={(search) => setFilters({ search })} placeholder="Search name, description or category" />
        </div>
        <Select
          id="categoryId"
          aria-label="Category"
          options={categoryOptions}
          placeholder="All categories"
          value={filters.categoryId || ''}
          onChange={(event) => setFilters({ categoryId: event.target.value })}
        />
        <div className="grid grid-cols-2 gap-2">
          <Input id="minPrice" type="number" min="0" placeholder="Min price" aria-label="Minimum price" value={filters.minPrice || ''} onChange={(event) => setFilters({ minPrice: event.target.value })} />
          <Input id="maxPrice" type="number" min="0" placeholder="Max price" aria-label="Maximum price" value={filters.maxPrice || ''} onChange={(event) => setFilters({ maxPrice: event.target.value })} />
        </div>
        <Select id="sort" aria-label="Sort by" options={SORT_OPTIONS} value={filters.sort} onChange={(event) => setFilters({ sort: event.target.value })} />
      </div>

      {services.isLoading && <PageLoader />}
      {services.error && <ErrorState error={services.error} onRetry={services.refetch} />}
      {services.data && !services.data.items.length && (
        <EmptyState title="No services match your filters" description="Try another keyword or clear the filters." />
      )}
      {services.data?.items?.length > 0 && (
        <div className={`grid gap-5 sm:grid-cols-2 lg:grid-cols-3 ${services.isFetching ? 'opacity-60' : ''}`}>
          {services.data.items.map((service) => (
            <ServiceCard key={service.id} service={service} />
          ))}
        </div>
      )}

      <Pagination meta={services.data?.meta} onPageChange={(page) => setFilters({ page })} />
    </div>
  );
}
