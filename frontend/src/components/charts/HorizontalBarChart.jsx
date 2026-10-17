import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';

// Horizontal bars fit long labels such as service names or "Monday 09:00"
export default function HorizontalBarChart({ data = [], labelKey, valueKey, valueLabel = 'Bookings' }) {
  if (!data.length) return <p className="py-12 text-center text-sm text-slate-500">No bookings in this period.</p>;

  return (
    <div style={{ height: Math.max(data.length * 44, 160) }}>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={data} layout="vertical" margin={{ top: 0, right: 16, left: 0, bottom: 0 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" horizontal={false} />
          <XAxis type="number" allowDecimals={false} tick={{ fontSize: 12, fill: '#64748b' }} tickLine={false} axisLine={false} />
          <YAxis type="category" dataKey={labelKey} width={130} tick={{ fontSize: 12, fill: '#334155' }} tickLine={false} axisLine={false} />
          <Tooltip formatter={(value) => [value, valueLabel]} cursor={{ fill: '#f1f5f9' }} />
          <Bar dataKey={valueKey} fill="#16857f" radius={[0, 4, 4, 0]} barSize={20} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
