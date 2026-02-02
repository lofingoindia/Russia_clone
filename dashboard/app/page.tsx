"use client";

import { useState, useEffect } from "react";
import Dashboard from "./Dashboard";
import UsersPage from "./UsersPage";
import LoginPage from "./LoginPage";
import { authAPI, usersAPI, getToken, getAdminInfo, User as APIUser } from "./lib/api";

interface User {
  id: number;
  name: string;
  email: string;
  phone: string;
  address: string;
  role: string;
  profileImage: string | null;
  doc1: string | null;
  doc1Url: string | null;
  doc1Name: string | null;
  doc2: string | null;
  doc2Url: string | null;
  doc2Name: string | null;
  doc3: string | null;
  doc3Urls: string[] | null;
  doc3Names: string[] | null;
}

export default function Home() {
  const [activeTab, setActiveTab] = useState("Dashboard");
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [mounted, setMounted] = useState(false);
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [adminInfo, setAdminInfoState] = useState<{ name: string; role: string } | null>(null);

  // Convert API User to local User format
  const mapApiUser = (apiUser: APIUser): User => ({
    id: apiUser.id,
    name: apiUser.name,
    email: apiUser.email,
    phone: apiUser.phone || '',
    address: apiUser.address || '',
    role: apiUser.role,
    profileImage: apiUser.profileImage,
    doc1: apiUser.doc1,
    doc1Url: apiUser.doc1Url,
    doc1Name: apiUser.doc1Name,
    doc2: apiUser.doc2,
    doc2Url: apiUser.doc2Url,
    doc2Name: apiUser.doc2Name,
    doc3: apiUser.doc3,
    doc3Urls: apiUser.doc3Urls,
    doc3Names: apiUser.doc3Names,
  });

  // Fetch users from API
  const fetchUsers = async () => {
    try {
      const response = await usersAPI.getAll();
      if (response.success && response.data) {
        setUsers(response.data.map(mapApiUser));
      }
    } catch (error) {
      console.error('Failed to fetch users:', error);
    }
  };

  // Initialize state from localStorage on mount
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme') as 'light' | 'dark' | null;
    const savedTab = localStorage.getItem('activeTab');
    const token = getToken();
    const admin = getAdminInfo();

    if (savedTheme) setTheme(savedTheme);
    if (savedTab) setActiveTab(savedTab);

    if (token && admin) {
      setIsLoggedIn(true);
      setAdminInfoState(admin);
    }

    setMounted(true);
    setLoading(false);
  }, []);

  // Fetch users when logged in
  useEffect(() => {
    if (isLoggedIn && mounted) {
      fetchUsers();
    }
  }, [isLoggedIn, mounted]);

  // Sync state to localStorage
  useEffect(() => {
    if (mounted) {
      localStorage.setItem('theme', theme);
      localStorage.setItem('activeTab', activeTab);
    }
  }, [theme, activeTab, mounted]);

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  const handleLogin = async (email: string, password: string): Promise<boolean> => {
    try {
      const response = await authAPI.login(email, password);
      if (response.success && response.data) {
        const { admin } = response.data as { admin: { name: string; role: string } };
        setIsLoggedIn(true);
        setAdminInfoState(admin);
        await fetchUsers();
        return true;
      }
      return false;
    } catch {
      return false;
    }
  };

  const handleLogout = async () => {
    await authAPI.logout();
    setIsLoggedIn(false);
    setAdminInfoState(null);
    setUsers([]);
    localStorage.removeItem('isLoggedIn');
  };

  // Prevent hydration mismatch
  if (!mounted || loading) {
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
          <Dashboard
            onTabChange={setActiveTab}
            theme={theme}
            onThemeToggle={toggleTheme}
            onLogout={handleLogout}
            users={users}
            adminInfo={adminInfo}
          />
        ) : (
          <UsersPage
            onTabChange={setActiveTab}
            theme={theme}
            onThemeToggle={toggleTheme}
            onLogout={handleLogout}
            users={users}
            setUsers={setUsers}
            refreshUsers={fetchUsers}
            adminInfo={adminInfo}
          />
        )}
      </div>
    </div>
  );
}
