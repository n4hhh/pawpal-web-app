import { Bell, PawPrint, Home, Heart, ShoppingBag, MessageCircle, User, Menu, Search, Settings, Moon, Sun, PlusSquare } from "lucide-react";
import { NavLink } from "react-router-dom";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { useState, useEffect } from "react";
import { CreatePost } from "./CreatePost";

const navItems = [
  { icon: Home, label: "Home", path: "/" },
  { icon: Search, label: "Search", path: "/search" },
  { icon: Heart, label: "Match", path: "/match" },
  { icon: ShoppingBag, label: "Shop", path: "/shop" },
  { icon: MessageCircle, label: "Messages", path: "/messages" },
  { icon: Bell, label: "Notifications", path: "/notifications" },
  { icon: PlusSquare, label: "Create", path: "/create", isAction: true },
  { icon: User, label: "Profile", path: "/profile" },
];

export function Navbar() {
  const [open, setOpen] = useState(false);
  const [createPostOpen, setCreatePostOpen] = useState(false);
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  useEffect(() => {
    // Check for saved theme preference or default to light
    const savedTheme = localStorage.getItem('theme') as 'light' | 'dark' || 'light';
    setTheme(savedTheme);
    document.documentElement.classList.toggle('dark', savedTheme === 'dark');
  }, []);

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
    document.documentElement.classList.toggle('dark', newTheme === 'dark');
  };

  return (
    <>
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex flex-col w-20 h-screen sticky top-0 border-r border-border bg-background group z-50">
        <div className="absolute left-0 top-0 h-full w-20 group-hover:w-64 bg-background transition-all duration-300 ease-in-out shadow-sm">
          <div className="p-4 flex flex-col h-full">
            {/* Logo */}
            <div className="mb-8 flex items-center">
              <NavLink to="/" className="hover:opacity-80 transition-opacity ml-1">
                <div className="w-10 h-10 rounded-xl gradient-coral flex items-center justify-center">
                  <PawPrint className="w-6 h-6 text-primary-foreground" />
                </div>
              </NavLink>
              <div className="ml-3 overflow-hidden opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center">
                <h1 className="text-xl font-extrabold text-foreground whitespace-nowrap">PawPals</h1>
              </div>
            </div>

            {/* Navigation */}
            <nav className="flex flex-col gap-1 flex-1">
              {navItems.map((item) => 
                item.isAction ? (
                  <button
                    key={item.path}
                    onClick={() => setCreatePostOpen(true)}
                    className="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-all text-foreground hover:bg-muted"
                  >
                    <item.icon className="w-6 h-6 flex-shrink-0" />
                    <span className="text-base whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity duration-300">{item.label}</span>
                  </button>
                ) : (
                  <NavLink
                    key={item.path}
                    to={item.path}
                    className={({ isActive }) =>
                      cn(
                        "flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-all",
                        isActive
                          ? "bg-primary/10 text-primary"
                          : "text-foreground hover:bg-muted"
                      )
                    }
                  >
                    <item.icon className="w-6 h-6 flex-shrink-0" />
                    <span className="text-base whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity duration-300">{item.label}</span>
                  </NavLink>
                )
              )}
            </nav>

            {/* Settings & Theme Toggle */}
            <div className="border-t border-border pt-4 mt-4">
              <button
                onClick={toggleTheme}
                className="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-all text-foreground hover:bg-muted w-full"
              >
                {theme === 'light' ? (
                  <Moon className="w-6 h-6 flex-shrink-0" />
                ) : (
                  <Sun className="w-6 h-6 flex-shrink-0" />
                )}
                <span className="text-base whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  {theme === 'light' ? 'Dark Mode' : 'Light Mode'}
                </span>
              </button>
            </div>
          </div>
        </div>
      </aside>

      {/* Create Post Dialog */}
      <CreatePost open={createPostOpen} onOpenChange={setCreatePostOpen} />

      {/* Mobile Top Bar */}
      <header className="md:hidden sticky top-0 z-50 bg-background/95 backdrop-blur-md border-b border-border">
        <div className="flex items-center justify-between h-16 px-4">
          {/* Logo */}
          <NavLink to="/" className="flex items-center gap-2 hover:opacity-80 transition-opacity">
            <div className="w-10 h-10 rounded-xl gradient-coral flex items-center justify-center">
              <PawPrint className="w-6 h-6 text-primary-foreground" />
            </div>
            <h1 className="text-2xl font-extrabold text-foreground">PawPals</h1>
          </NavLink>

          {/* Mobile Menu */}
          <Sheet open={open} onOpenChange={setOpen}>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon">
                <Menu className="w-5 h-5" />
              </Button>
            </SheetTrigger>
            <SheetContent side="right" className="w-72">
              <div className="flex flex-col gap-2 mt-8">
                {navItems.map((item) => (
                  <NavLink
                    key={item.path}
                    to={item.path}
                    onClick={() => setOpen(false)}
                    className={({ isActive }) =>
                      cn(
                        "flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-all",
                        isActive
                          ? "bg-primary/10 text-primary"
                          : "text-muted-foreground hover:bg-muted hover:text-foreground"
                      )
                    }
                  >
                    <item.icon className="w-5 h-5" />
                    <span>{item.label}</span>
                  </NavLink>
                ))}
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </header>
    </>
  );
}
