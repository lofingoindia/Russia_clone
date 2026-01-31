import React from 'react';
import Sidebar from './Sidebar';

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

const Dashboard = ({
    onTabChange,
    theme,
    onThemeToggle,
    onLogout,
    users
}: {
    onTabChange: (tab: string) => void;
    theme: 'light' | 'dark';
    onThemeToggle: () => void;
    onLogout?: () => void;
    users: User[];
}) => {
    // Calculate stats from users data
    const totalUsers = users.length;
    const adminCount = users.filter(u => u.role === 'Admin').length;
    const withDocs = users.filter(u => u.doc1 || u.doc2).length;
    const recentUsers = [...users].slice(-4).reverse();

    // Group users by role for the categories chart
    const roleStats = users.reduce((acc, user) => {
        acc[user.role] = (acc[user.role] || 0) + 1;
        return acc;
    }, {} as Record<string, number>);

    return (
        <div className="flex h-screen bg-background text-foreground font-sans selection:bg-indigo-100">
            <Sidebar activeTab="Dashboard" onTabChange={onTabChange} theme={theme} onThemeToggle={onThemeToggle} onLogout={onLogout} />

            <main className="flex-1 flex flex-col overflow-hidden">
                <header className="h-20 bg-background border-b border-border-custom flex items-center justify-between px-10">
                    <div>
                        <h2 className="text-xl font-bold">Dashboard Overview</h2>
                        <p className="text-sm text-muted-custom">Real-time analysis of your user base.</p>
                    </div>
                    <div className="flex items-center space-x-4">
                        <button onClick={() => onTabChange("Users")} className="px-4 py-2 bg-foreground text-background text-sm font-bold rounded-sm border border-foreground cursor-default">
                            Manage Users
                        </button>
                    </div>
                </header>

                <div className="flex-1 overflow-y-auto p-10 space-y-8">
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                        <StatCard label="Total Users" value={totalUsers.toString()} trend="+2.5%" />
                        <StatCard label="Administrators" value={adminCount.toString()} trend="System" />
                        <StatCard label="With Documents" value={withDocs.toString()} trend={`${totalUsers > 0 ? Math.round((withDocs / totalUsers) * 100) : 0}%`} />
                        <StatCard label="Account Health" value="100%" trend="Optimal" />
                    </div>

                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                        <div className="lg:col-span-2 bg-background border border-border-custom rounded-sm flex flex-col">
                            <div className="p-6 border-b border-border-custom flex items-center justify-between">
                                <h3 className="font-bold">User Registration Growth</h3>
                                <div className="flex space-x-2">
                                    <span className="text-xs bg-surface-custom border border-border-custom px-2 py-1 rounded-sm font-bold">Activity Sync</span>
                                </div>
                            </div>
                            <div className="p-8 h-80 flex flex-col justify-end space-y-2">
                                <div className="flex items-end justify-between h-64 px-4 pb-2">
                                    {/* Mock growth chart that scales with user count */}
                                    {[15, 30, 25, 45, 35, 55, 40, 65, totalUsers * 10, totalUsers * 15, totalUsers * 12, totalUsers * 20].map((val, i) => (
                                        <div key={i} className="w-8 bg-foreground rounded-t-sm" style={{ height: `${Math.min(val, 100)}%` }}></div>
                                    ))}
                                </div>
                                <div className="flex justify-between px-4 text-[10px] text-muted-custom font-bold uppercase tracking-tighter">
                                    <span>Jan</span><span>Feb</span><span>Mar</span><span>Apr</span><span>May</span><span>Jun</span><span>Jul</span><span>Aug</span><span>Sep</span><span>Oct</span><span>Nov</span><span>Dec</span>
                                </div>
                            </div>
                        </div>

                        <div className="bg-background border border-border-custom rounded-sm flex flex-col">
                            <div className="p-6 border-b border-border-custom">
                                <h3 className="font-bold">Role Distribution</h3>
                            </div>
                            <div className="p-6 space-y-6">
                                {Object.entries(roleStats).map(([role, count]) => (
                                    <CategoryItem
                                        key={role}
                                        label={role}
                                        value={`${count} Users`}
                                        percentage={totalUsers > 0 ? (count / totalUsers) * 100 : 0}
                                    />
                                ))}
                                {totalUsers === 0 && <p className="text-sm text-muted-custom">No users registered.</p>}
                            </div>
                        </div>
                    </div>

                    <div className="bg-background border border-border-custom rounded-sm">
                        <div className="p-6 border-b border-border-custom flex items-center justify-between">
                            <h3 className="font-bold">Recently Added Users</h3>
                            <button onClick={() => onTabChange("Users")} className="text-sm font-bold text-[#3B82F6] cursor-default">See All</button>
                        </div>
                        <div className="overflow-x-auto">
                            <table className="w-full text-left">
                                <thead>
                                    <tr className="bg-surface-custom border-b border-border-custom">
                                        <th className="p-6 text-xs font-bold text-muted-custom uppercase tracking-widest">Name</th>
                                        <th className="p-6 text-xs font-bold text-muted-custom uppercase tracking-widest">Email</th>
                                        <th className="p-6 text-xs font-bold text-muted-custom uppercase tracking-widest">Role</th>
                                        <th className="p-6 text-xs font-bold text-muted-custom uppercase tracking-widest">Status</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-border-custom">
                                    {recentUsers.map(user => (
                                        <tr key={user.id}>
                                            <td className="p-6 text-sm font-bold text-foreground">{user.name}</td>
                                            <td className="p-6 text-sm text-muted-custom">{user.email}</td>
                                            <td className="p-6 text-sm text-foreground">{user.role}</td>
                                            <td className="p-6">
                                                <span className="px-2 py-1 text-[10px] font-bold rounded-sm uppercase tracking-widest bg-[#DCFCE7] text-[#166534] dark:bg-[#064E3B] dark:text-[#D1FAE5]">
                                                    Active
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                    {users.length === 0 && (
                                        <tr>
                                            <td colSpan={4} className="p-10 text-center text-sm text-muted-custom">No users found.</td>
                                        </tr>
                                    )}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
};

const StatCard = ({ label, value, trend, color = 'green' }: { label: string; value: string; trend: string; color?: 'green' | 'red' }) => (
    <div className="bg-background border border-border-custom p-8 rounded-sm">
        <p className="text-xs font-bold text-muted-custom uppercase tracking-widest mb-3">{label}</p>
        <div className="flex items-end justify-between">
            <h3 className="text-2xl font-bold tracking-tight">{value}</h3>
            <span className={`text-[11px] font-bold px-2 py-1 rounded-sm ${color === 'green' ? 'bg-[#DCFCE7] text-[#166534] dark:bg-[#064E3B] dark:text-[#D1FAE5]' : 'bg-[#FEE2E2] text-[#991B1B] dark:bg-[#7F1D1D] dark:text-[#FEE2E2]'
                }`}>
                {trend}
            </span>
        </div>
    </div>
);

const CategoryItem = ({ label, value, percentage }: { label: string; value: string; percentage: number }) => (
    <div className="space-y-2">
        <div className="flex justify-between text-sm">
            <span className="font-bold">{label}</span>
            <span className="text-muted-custom font-medium">{value}</span>
        </div>
        <div className="h-1.5 w-full bg-surface-custom border border-border-custom rounded-full overflow-hidden">
            <div className="h-full bg-foreground rounded-full" style={{ width: `${percentage}%` }}></div>
        </div>
    </div>
);

export default Dashboard;
