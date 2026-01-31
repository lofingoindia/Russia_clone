"use client";

import { useState, useEffect } from "react";
import Dashboard from "./Dashboard";
import UsersPage from "./UsersPage";
import LoginPage from "./LoginPage";

interface User {
  id: number;
  name: string;
  email: string;
  phone: string;
  address: string;
  role: string;
  profileImage: string | null;
  doc1: string | File | null;
  doc2: string | File | null;
}

export default function Home() {
  const [activeTab, setActiveTab] = useState("Dashboard");
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [mounted, setMounted] = useState(false);
  const [users, setUsers] = useState<User[]>([
    { id: 1, name: 'Alice Johnson', email: 'alice@example.com', phone: '+1 (555) 123-4567', address: '123 Maple St, Springfield, IL', role: 'Admin', profileImage: null, doc1: 'passport.pdf', doc2: 'id_card.png' },
    { id: 2, name: 'Bob Smith', email: 'bob@example.com', phone: '+1 (555) 987-6543', address: '456 Oak Ave, Metropolis, NY', role: 'Manager', profileImage: null, doc1: 'contract.pdf', doc2: null },
  ]);

  // Initialize state from localStorage on mount
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme') as 'light' | 'dark' | null;
    const savedTab = localStorage.getItem('activeTab');
    const savedAuth = localStorage.getItem('isLoggedIn') === 'true';

    if (savedTheme) setTheme(savedTheme);
    if (savedTab) setActiveTab(savedTab);
    if (savedAuth) setIsLoggedIn(true);

    setMounted(true);
  }, []);

  // Sync state to localStorage
  useEffect(() => {
    if (mounted) {
      localStorage.setItem('theme', theme);
      localStorage.setItem('activeTab', activeTab);
      localStorage.setItem('isLoggedIn', isLoggedIn.toString());
    }
  }, [theme, activeTab, isLoggedIn, mounted]);

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  const handleLogin = () => {
    setIsLoggedIn(true);
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    localStorage.removeItem('isLoggedIn');
  };

  // Prevent hydration mismatch
  if (!mounted) {
    return (
      <div className="min-h-screen bg-background text-foreground" style={{ visibility: 'hidden' }}>
        <div className="flex h-screen overflow-hidden">
          <div className="w-72 border-r border-border-custom bg-background flex flex-col shrink-0" />
          <div className="flex-1 bg-background" />
        </div>
      </div>
    );
  }

  // If not logged in, show Login Page
  if (!isLoggedIn) {
    return (
      <div className={theme === 'dark' ? 'dark' : ''}>
        <LoginPage onLogin={handleLogin} theme={theme} onThemeToggle={toggleTheme} />
      </div>
    );
  }

  return (
    <div className={theme === 'dark' ? 'dark text-foreground' : 'text-foreground'}>
      <div className="bg-background min-h-screen">
        {activeTab === "Dashboard" ? (
          <Dashboard onTabChange={setActiveTab} theme={theme} onThemeToggle={toggleTheme} onLogout={handleLogout} users={users} />
        ) : (
          <UsersPage onTabChange={setActiveTab} theme={theme} onThemeToggle={toggleTheme} onLogout={handleLogout} users={users} setUsers={setUsers} />
        )}
      </div>
    </div>
  );
}
