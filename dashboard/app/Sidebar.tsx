interface NavItemProps {
    label: string;
    active?: boolean;
    onClick?: () => void;
}

const NavItem = ({ label, active = false, onClick }: NavItemProps) => (
    <div
        onClick={onClick}
        className={`px-4 py-3 rounded-sm text-sm font-bold flex items-center space-x-3 cursor-pointer transition-none ${active ? 'bg-[#0F172A] text-white dark:bg-[#F8FAFC] dark:text-[#0F172A]' : 'text-[#64748B] dark:text-[#94A3B8]'
            }`}
    >
        <div className={`w-1.5 h-1.5 rounded-full ${active ? 'bg-white dark:bg-[#0F172A]' : 'bg-transparent'}`}></div>
        <span>{label}</span>
    </div>
);

interface SidebarProps {
    activeTab: string;
    onTabChange?: (tab: string) => void;
    theme: 'light' | 'dark';
    onThemeToggle?: () => void;
    onLogout?: () => void;
}

const Sidebar = ({ activeTab, onTabChange, theme, onThemeToggle, onLogout }: SidebarProps) => {
    return (
        <aside className="w-72 border-r border-border-custom bg-background flex flex-col shrink-0">
            <div className="h-20 flex items-center px-8 border-b border-border-custom">
                <div className="w-8 h-8 bg-foreground rounded-sm flex items-center justify-center mr-3">
                    <div className="w-4 h-4 border-2 border-background"></div>
                </div>
                <h1 className="text-xl font-bold tracking-tight uppercase">Russia App</h1>
            </div>

            <div className="flex-1 py-8 px-4 space-y-1">
                <p className="px-4 text-[11px] font-bold text-muted-custom uppercase tracking-widest mb-4">Main Menu</p>
                <NavItem
                    label="Dashboard"
                    active={activeTab === 'Dashboard'}
                    onClick={() => onTabChange?.('Dashboard')}
                />
                <NavItem
                    label="Users"
                    active={activeTab === 'Users'}
                    onClick={() => onTabChange?.('Users')}
                />
            </div>

            <div className="p-4 border-t border-border-custom">
                <div className="flex items-center justify-between px-4 py-2 bg-surface-custom border border-border-custom rounded-sm">
                    <span className="text-xs font-bold text-muted-custom uppercase tracking-widest">Theme</span>
                    <button
                        onClick={onThemeToggle}
                        className="flex items-center space-x-2 p-1 bg-background border border-border-custom rounded-sm cursor-pointer"
                    >
                        {theme === 'light' ? (
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                        ) : (
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                        )}
                        <span className="text-[10px] font-bold uppercase tracking-tight">{theme === 'light' ? 'Light' : 'Dark'}</span>
                    </button>
                </div>
            </div>

            <div className="px-6 pb-6 space-y-4">
                <div className="flex items-center">
                    <div className="w-10 h-10 bg-surface-custom border border-border-custom rounded-sm flex items-center justify-center">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-muted-custom">
                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                        </svg>
                    </div>
                    <div className="ml-3 flex-1">
                        <p className="text-sm font-bold text-foreground">John Doe</p>
                        <p className="text-xs text-muted-custom">Admin Account</p>
                    </div>
                </div>

                <button
                    onClick={onLogout}
                    className="w-full flex items-center justify-center space-x-2 py-3 bg-surface-custom border border-border-custom rounded-sm text-xs font-bold text-[#EF4444] uppercase tracking-widest cursor-default"
                >
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
                    <span>Logout</span>
                </button>
            </div>
        </aside>
    );
};

export default Sidebar;
