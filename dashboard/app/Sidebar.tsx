"use client";

import { useLanguage } from './context/LanguageContext';

interface NavItemProps {
    label: string;
    active?: boolean;
    onClick?: () => void;
}

const NavItem = ({ label, active = false, onClick }: NavItemProps) => (
    <div
        onClick={onClick}
        className={`px-4 py-2.5 rounded-lg text-sm font-medium flex items-center space-x-3 cursor-pointer transition-all duration-200 relative ${active
            ? 'bg-indigo-50 text-indigo-600 dark:bg-indigo-900/30 dark:text-indigo-400'
            : 'text-gray-600 hover:bg-gray-50 dark:text-gray-400 dark:hover:bg-gray-800/50'
            }`}
    >
        {active && <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-8 bg-indigo-600 dark:bg-indigo-400 rounded-r-full"></div>}
        <span>{label}</span>
    </div>
);

interface SidebarProps {
    activeTab: string;
    onTabChange?: (tab: string) => void;
    theme: 'light' | 'dark';
    onThemeToggle?: () => void;
    onLogout?: () => void;
    adminInfo?: { name: string; role: string } | null;
}

const Sidebar = ({ activeTab, onTabChange, theme, onThemeToggle, onLogout, adminInfo }: SidebarProps) => {
    const { language, setLanguage, t } = useLanguage();

    const displayName = adminInfo?.name || 'Admin';
    const displayRole = adminInfo?.role || 'Administrator';
    const initials = displayName.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);

    const handleLanguageChange = (lang: 'en' | 'ru') => {
        setLanguage(lang);
    };

    return (
        <aside className="w-64 border-r border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 flex flex-col shrink-0">
            <div className="h-16 flex items-center px-6 border-b border-gray-200 dark:border-gray-800">
                <div className="w-9 h-9 bg-gradient-to-br from-indigo-500 to-indigo-600 rounded-xl flex items-center justify-center mr-3">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                        <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="9" y1="9" x2="15" y2="15"></line>
                        <line x1="15" y1="9" x2="9" y2="15"></line>
                    </svg>
                </div>
                <h1 className="text-lg font-bold tracking-tight text-gray-900 dark:text-white">{t.common.appName}</h1>
            </div>

            <div className="flex-1 py-6 px-3 space-y-1 overflow-y-auto">
                <p className="px-4 text-[10px] font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-3">{t.common.navigation}</p>
                <NavItem
                    label={t.sidebar.dashboard}
                    active={activeTab === 'Dashboard'}
                    onClick={() => onTabChange?.('Dashboard')}
                />
                <NavItem
                    label={t.sidebar.users}
                    active={activeTab === 'Users'}
                    onClick={() => onTabChange?.('Users')}
                />
            </div>

            {/* Language Switcher - Simple Toggle Buttons */}
            <div className="p-3 border-t border-gray-200 dark:border-gray-800">
                <div className="flex items-center justify-between px-2 mb-2">
                    <div className="flex items-center space-x-2">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-gray-500 dark:text-gray-400">
                            <circle cx="12" cy="12" r="10"></circle>
                            <line x1="2" y1="12" x2="22" y2="12"></line>
                            <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
                        </svg>
                        <span className="text-xs font-medium text-gray-600 dark:text-gray-400">{t.common.language}</span>
                    </div>
                </div>
                <div className="flex gap-2">
                    <div
                        onClick={() => handleLanguageChange('en')}
                        className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-semibold cursor-pointer transition-all ${language === 'en'
                                ? 'bg-indigo-600 text-white shadow-md'
                                : 'bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400 hover:bg-gray-200 dark:hover:bg-gray-700'
                            }`}
                    >
                        <span>EN</span>
                    </div>
                    <div
                        onClick={() => handleLanguageChange('ru')}
                        className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-semibold cursor-pointer transition-all ${language === 'ru'
                                ? 'bg-indigo-600 text-white shadow-md'
                                : 'bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400 hover:bg-gray-200 dark:hover:bg-gray-700'
                            }`}
                    >
                        <span>RU</span>
                    </div>
                </div>
            </div>

            <div className="p-3 border-t border-gray-200 dark:border-gray-800">
                <div
                    onClick={onThemeToggle}
                    className="w-full flex items-center justify-between px-4 py-2.5 bg-gray-50 dark:bg-gray-800 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors cursor-pointer"
                >
                    <span className="text-sm font-medium text-gray-700 dark:text-gray-300">{t.common.theme}</span>
                    <div className="flex items-center space-x-2">
                        {theme === 'light' ? (
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-gray-600 dark:text-gray-400">
                                <circle cx="12" cy="12" r="5"></circle>
                                <line x1="12" y1="1" x2="12" y2="3"></line>
                                <line x1="12" y1="21" x2="12" y2="23"></line>
                                <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                                <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                                <line x1="1" y1="12" x2="3" y2="12"></line>
                                <line x1="21" y1="12" x2="23" y2="12"></line>
                                <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                                <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
                            </svg>
                        ) : (
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-gray-600 dark:text-gray-400">
                                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
                            </svg>
                        )}
                    </div>
                </div>
            </div>

            <div className="p-3 border-t border-gray-200 dark:border-gray-800 space-y-3">
                <div className="flex items-center px-2">
                    <div className="w-9 h-9 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center">
                        <span className="text-white text-sm font-bold">{initials}</span>
                    </div>
                    <div className="ml-3 flex-1 min-w-0">
                        <p className="text-sm font-semibold text-gray-900 dark:text-white truncate">{displayName}</p>
                        <p className="text-xs text-gray-500 dark:text-gray-400 truncate">{displayRole}</p>
                    </div>
                </div>

                <div
                    onClick={onLogout}
                    className="w-full flex items-center justify-center space-x-2 py-2.5 rounded-lg text-sm font-medium text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors cursor-pointer"
                >
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                        <polyline points="16 17 21 12 16 7"></polyline>
                        <line x1="21" y1="12" x2="9" y2="12"></line>
                    </svg>
                    <span>{t.common.logout}</span>
                </div>
            </div>
        </aside>
    );
};

export default Sidebar;
