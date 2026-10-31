import { formatDate, formatRupiah } from './format';

const BRAND = [13, 108, 103];

// jsPDF is large, so it is only loaded when the admin actually exports a report
export const exportReportPdf = async ({ summary, revenue, topServices, busiest, groupBy }) => {
  const [{ jsPDF }, { default: autoTable }] = await Promise.all([import('jspdf'), import('jspdf-autotable')]);

  const doc = new jsPDF({ unit: 'pt', format: 'a4' });
  const pageWidth = doc.internal.pageSize.getWidth();
  const margin = 40;
  const tableStyle = { theme: 'striped', headStyles: { fillColor: BRAND }, styles: { fontSize: 9 }, margin: { left: margin, right: margin } };
  const section = (title) => {
    const y = (doc.lastAutoTable?.finalY ?? 150) + 28;
    doc.setFontSize(12).setTextColor(30).text(title, margin, y);
    return y + 8;
  };

  doc.setFillColor(...BRAND).rect(0, 0, pageWidth, 70, 'F');
  doc.setTextColor(255).setFontSize(18).text('ELEFEZ FARM - Booking Report', margin, 38);
  doc.setFontSize(10).text(`Period: ${formatDate(summary.range.start)} - ${formatDate(summary.range.end)}`, margin, 56);

  autoTable(doc, {
    ...tableStyle,
    startY: 90,
    head: [['Total bookings', 'Revenue (paid)', 'Completed', 'Cancellation rate']],
    body: [[summary.totalBookings, formatRupiah(summary.totalRevenue), summary.bookingsByStatus.COMPLETED, `${summary.cancellationRate}%`]],
  });

  autoTable(doc, {
    ...tableStyle,
    startY: section('Bookings by status'),
    head: [['Status', 'Bookings']],
    body: Object.entries(summary.bookingsByStatus).map(([status, count]) => [status, count]),
  });

  autoTable(doc, {
    ...tableStyle,
    startY: section(`Revenue per ${groupBy === 'month' ? 'month' : 'day'}`),
    head: [['Period', 'Transactions', 'Revenue']],
    body: [...(revenue.items || []).map((row) => [row.period, row.transactions, formatRupiah(row.revenue)]), ['Total', '', formatRupiah(revenue.total)]],
    columnStyles: { 1: { halign: 'right' }, 2: { halign: 'right' } },
  });

  autoTable(doc, {
    ...tableStyle,
    startY: section('Most booked services'),
    head: [['Service', 'Category', 'Bookings', 'Revenue']],
    body: (topServices.items || []).map((row) => [row.serviceName, row.categoryName, row.totalBookings, formatRupiah(row.totalRevenue)]),
    columnStyles: { 2: { halign: 'right' }, 3: { halign: 'right' } },
  });

  autoTable(doc, {
    ...tableStyle,
    startY: section('Busiest schedules'),
    head: [['Day and time', 'Bookings']],
    body: (busiest.byDayAndTime || []).map((row) => [`${row.dayName} ${row.startTime}`, row.totalBookings]),
    columnStyles: { 1: { halign: 'right' } },
  });

  autoTable(doc, {
    ...tableStyle,
    startY: section('Busiest dates'),
    head: [['Date', 'Bookings']],
    body: (busiest.byDate || []).map((row) => [formatDate(row.date), row.totalBookings]),
    columnStyles: { 1: { halign: 'right' } },
  });

  const pages = doc.getNumberOfPages();
  for (let page = 1; page <= pages; page += 1) {
    doc.setPage(page);
    doc.setFontSize(8).setTextColor(120).text(`ELEFEZ FARM - ${new Date().toLocaleString('en-GB')} - Page ${page} of ${pages}`, margin, doc.internal.pageSize.getHeight() - 20);
  }

  doc.save(`report-${summary.range.start}-to-${summary.range.end}.pdf`);
};
