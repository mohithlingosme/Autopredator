interface SpecTableProps {
  rows: Array<{ label: string; value: string | number }>;
}

export default function SpecTable({ rows }: SpecTableProps) {
  return (
    <div className="overflow-hidden border border-gray-100 rounded-xl">
      <table className="min-w-full text-sm">
        <tbody>
          {rows.map(row => (
            <tr key={row.label} className="even:bg-gray-50">
              <td className="px-4 py-3 font-medium text-gray-600">{row.label}</td>
              <td className="px-4 py-3 text-gray-900">{row.value}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
