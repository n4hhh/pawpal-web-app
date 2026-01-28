import { Navbar } from "./Navbar";

interface LayoutProps {
  children: React.ReactNode;
}

export function Layout({ children }: LayoutProps) {
  return (
    <div className="min-h-screen bg-background flex">
      <Navbar />
      <main className="flex-1">{children}</main>
    </div>
  );
}
