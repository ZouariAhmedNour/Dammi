import type { ReactNode } from "react";

export interface Column<T> {
  header: string;
  accessor?: keyof T;
  className?: string;
  render?: (row: T) => ReactNode;
}

interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  emptyMessage?: string;
}

export function DataTable<T extends { id?: number | string }>({
  data,
  columns,
  emptyMessage = "Aucune donnée"
}: DataTableProps<T>) {
  return (
    <div className="table-wrapper">
      <table className="table">
        <thead>
          <tr>
            {columns.map((column) => (
              <th key={column.header} className={column.className}>
                {column.header}
              </th>
            ))}
          </tr>
        </thead>

        <tbody>
          {data.length > 0 ? (
            data.map((row, index) => (
              <tr key={row.id ?? index}>
                {columns.map((column) => (
                  <td key={column.header} className={column.className}>
                    {column.render
                      ? column.render(row)
                      : String(
                          column.accessor ? row[column.accessor] ?? "-" : "-"
                        )}
                  </td>
                ))}
              </tr>
            ))
          ) : (
            <tr>
              <td className="table__empty" colSpan={columns.length}>
                {emptyMessage}
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}