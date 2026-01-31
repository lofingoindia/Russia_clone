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
    doc1: string | null;
    doc1Url: string | null;
    doc1Name: string | null;
    doc2: string | null;
    doc2Url: string | null;
    doc2Name: string | null;
}

const Dashboard = ({
    onTabChange,
    theme,
    onThemeToggle,
    onLogout,
    users,
    adminInfo
}: {
    onTabChange: (tab: string) => void;
    theme: 'light' | 'dark';
    onThemeToggle: () => void;
    onLogout?: () => void;
    users: User[];
    adminInfo?: { name: string; role: string } | null;
}) => {
    // Calculate stats from users data
    const totalUsers = users.length;
    const adminCount = users.filter(u => u.role === 'Admin').length;
    const withDocs = users.filter(u => u.doc1 || u.doc2 || u.doc1Url || u.doc2Url).length;
    const recentUsers = [...users].slice(-4).reverse();

    // Group users by role for the categories chart
    const roleStats = users.reduce((acc, user) => {
        acc[user.role] = (acc[user.role] || 0) + 1;
        return acc;
    }, {} as Record<string, number>);

    return (
        <div className="flex h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-white font-sans selection:bg-indigo-100">
            <Sidebar activeTab="Dashboard" onTabChange={onTabChange} theme={theme} onThemeToggle={onThemeToggle} onLogout={onLogout} adminInfo={adminInfo} />

            <main className="flex-1 flex flex-col overflow-hidden">
                <header className="h-16 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between px-8">
                    <div>
                        <h2 className="text-xl font-bold text-gray-900 dark:text-white">Dashboard Overview</h2>
                        <p className="text-sm text-gray-500 dark:text-gray-400">Real-time analysis of your user base</p>
                    </div>
                    <div className="flex items-center space-x-4">
                        <button 
                            onClick={() => onTabChange("Users")} 
                            className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium rounded-lg transition-colors cursor-default">
                            Manage Users
                        </button>
                    </div>
                </header>

                <div className="flex-1 overflow-y-auto p-8 space-y-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
                        <StatCard label="Total Users" value={totalUsers.toString()} trend="+2.5%" />
                        <StatCard label="Administrators" value={adminCount.toString()} trend="System" />
                        <StatCard label="With Documents" value={withDocs.toString()} trend={`${totalUsers > 0 ? Math.round((withDocs / totalUsers) * 100) : 0}%`} />
                        <StatCard label="Account Health" value="100%" trend="Optimal" />
                    </div>

                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                        <div className="lg:col-span-2 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl shadow-sm flex flex-col">
                            <div className="p-6 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
                                <h3 className="font-semibold text-gray-900 dark:text-white">User Registration Growth</h3>
                                <div className="flex space-x-2">
                                    <span className="text-xs bg-indigo-50 dark:bg-indigo-900/30 text-indigo-600 dark:text-indigo-400 px-3 py-1 rounded-full font-medium">Live Data</span>
                                </div>
                            </div>
                            <div className="p-8 h-80 flex flex-col justify-end space-y-2">
                                <div className="flex items-end justify-between h-64 px-4 pb-2 gap-2">
                                    {/* Mock growth chart that scales with user count */}
                                    {[15, 30, 25, 45, 35, 55, 40, 65, totalUsers * 10, totalUsers * 15, totalUsers * 12, totalUsers * 20].map((val, i) => (
                                        <div key={i} className="flex-1 bg-indigo-500 dark:bg-indigo-600 rounded-t-lg" style={{ height: `${Math.min(val, 100)}%` }}></div>
                                    ))}
                                </div>
                                <div className="flex justify-between px-4 text-[10px] text-gray-500 dark:text-gray-400 font-medium uppercase tracking-wider">
                                    <span>Jan</span><span>Feb</span><span>Mar</span><span>Apr</span><span>May</span><span>Jun</span><span>Jul</span><span>Aug</span><span>Sep</span><span>Oct</span><span>Nov</span><span>Dec</span>
                                </div>
                            </div>
                        </div>

                        <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl shadow-sm flex flex-col">
                            <div className="p-6 border-b border-gray-200 dark:border-gray-700">
                                <h3 className="font-semibold text-gray-900 dark:text-white">Role Distribution</h3>
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
                                {totalUsers === 0 && <p className="text-sm text-gray-500 dark:text-gray-400">No users registered.</p>}
                            </div>
                        </div>
                    </div>

                    <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl shadow-sm">
                        <div className="p-6 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
                            <h3 className="font-semibold text-gray-900 dark:text-white">Recently Added Users</h3>
                            <button onClick={() => onTabChange("Users")} className="text-sm font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 cursor-default">See All →</button>
                        </div>
                        <div className="overflow-x-auto">
                            <table className="w-full text-left">
                                <thead>
                                    <tr className="bg-gray-50 dark:bg-gray-900/50 border-b border-gray-200 dark:border-gray-700">
                                        <th className="p-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Name</th>
                                        <th className="p-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Email</th>
                                        <th className="p-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Role</th>
                                        <th className="p-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Status</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
                                    {recentUsers.map(user => (
                                        <tr key={user.id} className="hover:bg-gray-50 dark:hover:bg-gray-900/30 transition-colors">
                                            <td className="p-4 text-sm font-medium text-gray-900 dark:text-white">{user.name}</td>
                                            <td className="p-4 text-sm text-gray-600 dark:text-gray-400">{user.email}</td>
                                            <td className="p-4 text-sm text-gray-900 dark:text-white">{user.role}</td>
                                            <td className="p-4">
                                                <span className="px-2.5 py-1 text-xs font-medium rounded-full bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400">
                                                    Active
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                    {users.length === 0 && (
                                        <tr>
                                            <td colSpan={4} className="p-10 text-center text-sm text-gray-500 dark:text-gray-400">No users found.</td>
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
    <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 p-6 rounded-xl shadow-sm hover:shadow-md transition-shadow">
        <p className="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2">{label}</p>
        <div className="flex items-end justify-between">
            <h3 className="text-3xl font-bold tracking-tight text-gray-900 dark:text-white">{value}</h3>
            <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${
                color === 'green' 
                    ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' 
                    : 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400'
                }`}>
                {trend}
            </span>
        </div>
    </div>
);

const CategoryItem = ({ label, value, percentage }: { label: string; value: string; percentage: number }) => (
    <div className="space-y-2">
        <div className="flex justify-between text-sm">
            <span className="font-medium text-gray-900 dark:text-white">{label}</span>
            <span className="text-gray-500 dark:text-gray-400">{value}</span>
        </div>
        <div className="h-2 w-full bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
            <div className="h-full bg-indigo-500 dark:bg-indigo-600 rounded-full transition-all duration-500" style={{ width: `${percentage}%` }}></div>
        </div>
    </div>
);

export default Dashboard;
