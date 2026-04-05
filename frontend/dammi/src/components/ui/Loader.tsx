export function Loader({ fullPage = false }: { fullPage?: boolean }) {
  return (
    <div className={fullPage ? "loader loader--page" : "loader"}>
      <div className="spinner" />
    </div>
  );
}