"use client";

import React, { useState, useEffect } from 'react';
import Sidebar from './Sidebar';
import { authAPI, adminsAPI, setAdminInfo, getAdminInfo, Admin } from './lib/api';
import { useLanguage } from './context/LanguageContext';

const ProfilePage = ({
    onTabChange,
    theme,
    onThemeToggle,
    onLogout,
    adminInfo: initialAdminInfo
}: {
    onTabChange: (tab: string) => void;
    theme: 'light' | 'dark';
    onThemeToggle: () => void;
    onLogout?: () => void;
    adminInfo?: { id: number; name: string; email: string; role: string } | null;
}) => {
    const { t } = useLanguage();
    const [admins, setAdmins] = useState<Admin[]>([]);
    const [loading, setLoading] = useState(true);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    // Manage Current Admin Info
    const [currentAdmin, setCurrentAdmin] = useState(initialAdminInfo);

    // Profile Edit State
    const [profileData, setProfileData] = useState({
        name: initialAdminInfo?.name || '',
        email: initialAdminInfo?.email || '',
    });

    // Password Change State
    const [passwordData, setPasswordData] = useState({
        currentPassword: '',
        newPassword: '',
        confirmPassword: '',
    });

    // Admin List View/Form State
    const [view, setView] = useState<'settings' | 'admins'>('settings');
    const [showAdminForm, setShowAdminForm] = useState(false);
    const [isEditingAdmin, setIsEditingAdmin] = useState(false);
    const [selectedAdmin, setSelectedAdmin] = useState<Admin | null>(null);
    const [adminFormData, setAdminFormData] = useState({
        name: '',
        email: '',
        password: '',
        role: 'super_admin' as 'super_admin' | 'admin' | 'moderator',
    });

    const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
    const [adminToDelete, setAdminToDelete] = useState<number | null>(null);

    useEffect(() => {
        fetchAdmins();
    }, []);

    const fetchAdmins = async () => {
        try {
            const response = await adminsAPI.getAll();
            if (response.success) {
                setAdmins(response.data);
            }
        } catch (err) {
            console.error('Failed to fetch admins:', err);
        } finally {
            setLoading(false);
        }
    };

    const handleProfileUpdate = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsSubmitting(true);
        setError('');
        setSuccess('');

        try {
            const adminId = currentAdmin?.id;
            if (!adminId) throw new Error('Admin ID not found');

            const response = await adminsAPI.update(adminId, {
                name: profileData.name,
                email: profileData.email
            });

            if (response.success) {
                const updatedAdmin = { ...currentAdmin!, name: profileData.name, email: profileData.email };
                setCurrentAdmin(updatedAdmin);
                setAdminInfo(updatedAdmin);
                setSuccess(t.profilePage.profileUpdated);
            }
        } catch (err) {
            setError(err instanceof Error ? err.message : t.usersPage.failedToSave);
        } finally {
            setIsSubmitting(false);
        }
    };

    const handlePasswordChange = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsSubmitting(true);
        setError('');
        setSuccess('');

        if (passwordData.newPassword !== passwordData.confirmPassword) {
            setError(t.profilePage.passwordMustMatch);
            setIsSubmitting(false);
            return;
        }

        try {
            const response = await authAPI.changePassword(
                passwordData.currentPassword,
                passwordData.newPassword
            );

            if (response.success) {
                setSuccess(t.profilePage.passwordChanged);
                setPasswordData({
                    currentPassword: '',
                    newPassword: '',
                    confirmPassword: '',
                });
            }
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Failed to change password');
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleAdminSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsSubmitting(true);
        setError('');

        try {
            if (isEditingAdmin && selectedAdmin) {
                await adminsAPI.update(selectedAdmin.id, {
                    name: adminFormData.name,
                    email: adminFormData.email,
                    role: 'super_admin'
                });
            } else {
                await adminsAPI.create({
                    ...adminFormData,
                    role: 'super_admin'
                });
            }

            await fetchAdmins();
            setShowAdminForm(false);
            resetAdminForm();
        } catch (err) {
            setError(err instanceof Error ? err.message : t.usersPage.failedToSave);
        } finally {
            setIsSubmitting(false);
        }
    };

    const handleEditAdmin = (admin: Admin) => {
        setAdminFormData({
            name: admin.name,
            email: admin.email,
            password: '',
            role: 'super_admin',
        });
        setSelectedAdmin(admin);
        setIsEditingAdmin(true);
        setShowAdminForm(true);
    };

    const confirmDeleteAdmin = (id: number) => {
        setAdminToDelete(id);
        setShowDeleteConfirm(true);
    };

    const handleDeleteAdmin = async () => {
        if (adminToDelete) {
            try {
                await adminsAPI.delete(adminToDelete);
                await fetchAdmins();
                setShowDeleteConfirm(false);
                setAdminToDelete(null);
            } catch (err) {
                console.error('Delete failed:', err);
            }
        }
    };

    const resetAdminForm = () => {
        setAdminFormData({
            name: '',
            email: '',
            password: '',
            role: 'super_admin',
        });
        setIsEditingAdmin(false);
        setSelectedAdmin(null);
    };

    return (
        <div className="flex h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-white font-sans selection:bg-indigo-100 overflow-hidden">
            <Sidebar activeTab="Profile" onTabChange={onTabChange} theme={theme} onThemeToggle={onThemeToggle} onLogout={onLogout} adminInfo={currentAdmin} />

            <main className="flex-1 flex flex-col overflow-hidden relative">
                <header className="h-16 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between px-8 shrink-0">
                    <div>
                        <h2 className="text-xl font-bold text-gray-900 dark:text-white">{t.profilePage.profileSettings}</h2>
                        <p className="text-sm text-gray-500 dark:text-gray-400">{t.common.appName} / {t.sidebar.profile}</p>
                    </div>
                </header>

                <div className="flex-1 overflow-y-auto p-8">
                    <div className="max-w-5xl mx-auto space-y-8">
                        {/* Tab Switcher */}
                        <div className="flex border-b border-gray-200 dark:border-gray-700">
                            <button
                                onClick={() => setView('settings')}
                                className={`px-6 py-3 text-sm font-medium border-b-2 transition-colors ${view === 'settings'
                                    ? 'border-indigo-600 text-indigo-600 dark:text-indigo-400'
                                    : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300'
                                    }`}
                            >
                                {t.profilePage.personalInfo}
                            </button>
                            <button
                                onClick={() => setView('admins')}
                                className={`px-6 py-3 text-sm font-medium border-b-2 transition-colors ${view === 'admins'
                                    ? 'border-indigo-600 text-indigo-600 dark:text-indigo-400'
                                    : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300'
                                    }`}
                            >
                                {t.profilePage.adminManagement}
                            </button>
                        </div>

                        {error && (
                            <div className="p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl text-sm text-red-600 dark:text-red-400 animate-in fade-in slide-in-from-top-2">
                                {error}
                            </div>
                        )}
                        {success && (
                            <div className="p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-xl text-sm text-green-600 dark:text-green-400 animate-in fade-in slide-in-from-top-2">
                                {success}
                            </div>
                        )}

                        {view === 'settings' ? (
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 animate-in fade-in slide-in-from-bottom-4">
                                {/* Edit Profile */}
                                <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-2xl p-6 shadow-sm">
                                    <h3 className="text-lg font-bold mb-6 flex items-center">
                                        <svg className="w-5 h-5 mr-2 text-indigo-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
                                        {t.profilePage.personalInfo}
                                    </h3>
                                    <form onSubmit={handleProfileUpdate} className="space-y-4">
                                        <div className="space-y-1.5">
                                            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{t.profilePage.name}</label>
                                            <input
                                                type="text"
                                                value={profileData.name}
                                                onChange={(e) => setProfileData({ ...profileData, name: e.target.value })}
                                                className="w-full px-4 py-2.5 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 outline-none transition-all"
                                                required
                                            />
                                        </div>
                                        <div className="space-y-1.5">
                                            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{t.profilePage.email}</label>
                                            <input
                                                type="email"
                                                value={profileData.email}
                                                onChange={(e) => setProfileData({ ...profileData, email: e.target.value })}
                                                className="w-full px-4 py-2.5 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 outline-none transition-all"
                                                required
                                            />
                                        </div>
                                        <button
                                            type="submit"
                                            disabled={isSubmitting}
                                            className="w-full py-3 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold rounded-xl transition-all shadow-lg shadow-indigo-200 dark:shadow-none disabled:opacity-50"
                                        >
                                            {isSubmitting ? t.usersPage.saving : t.profilePage.updateProfile}
                                        </button>
                                    </form>
                                </div>

                                {/* Change Password */}
                                <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-2xl p-6 shadow-sm">
                                    <h3 className="text-lg font-bold mb-6 flex items-center">
                                        <svg className="w-5 h-5 mr-2 text-indigo-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
                                        {t.profilePage.changePassword}
                                    </h3>
                                    <form onSubmit={handlePasswordChange} className="space-y-4">
                                        <div className="space-y-1.5">
                                            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{t.profilePage.currentPassword}</label>
                                            <input
                                                type="password"
                                                value={passwordData.currentPassword}
                                                onChange={(e) => setPasswordData({ ...passwordData, currentPassword: e.target.value })}
                                                className="w-full px-4 py-2.5 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 outline-none transition-all"
                                                required
                                            />
                                        </div>
                                        <div className="space-y-1.5">
                                            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{t.profilePage.newPassword}</label>
                                            <input
                                                type="password"
                                                value={passwordData.newPassword}
                                                onChange={(e) => setPasswordData({ ...passwordData, newPassword: e.target.value })}
                                                className="w-full px-4 py-2.5 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 outline-none transition-all"
                                                required
                                                minLength={6}
                                            />
                                        </div>
                                        <div className="space-y-1.5">
                                            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{t.profilePage.confirmPassword}</label>
                                            <input
                                                type="password"
                                                value={passwordData.confirmPassword}
                                                onChange={(e) => setPasswordData({ ...passwordData, confirmPassword: e.target.value })}
                                                className="w-full px-4 py-2.5 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 outline-none transition-all"
                                                required
                                                minLength={6}
                                            />
                                        </div>
                                        <button
                                            type="submit"
                                            disabled={isSubmitting}
                                            className="w-full py-3 bg-white dark:bg-gray-900 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-900 dark:text-white text-sm font-semibold border border-gray-200 dark:border-gray-700 rounded-xl transition-all disabled:opacity-50"
                                        >
                                            {isSubmitting ? t.usersPage.saving : t.profilePage.changePassword}
                                        </button>
                                    </form>
                                </div>
                            </div>
                        ) : (
                            <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4">
                                <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-2xl shadow-sm overflow-hidden">
                                    <div className="p-6 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center">
                                        <h3 className="text-lg font-bold">{t.profilePage.manageAdmins}</h3>
                                        <button
                                            onClick={() => {
                                                resetAdminForm();
                                                setShowAdminForm(true);
                                            }}
                                            className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold rounded-lg transition-all"
                                        >
                                            {t.profilePage.addNewAdmin}
                                        </button>
                                    </div>
                                    <div className="overflow-x-auto text-left">
                                        <table className="w-full">
                                            <thead>
                                                <tr className="bg-gray-50 dark:bg-gray-900/50 border-b border-gray-200 dark:border-gray-700">
                                                    <th className="px-6 py-4 text-xs font-bold text-gray-500 uppercase tracking-wider">{t.profilePage.name}</th>
                                                    <th className="px-6 py-4 text-xs font-bold text-gray-500 uppercase tracking-wider">{t.profilePage.email}</th>
                                                    <th className="px-6 py-4 text-xs font-bold text-gray-500 uppercase tracking-wider text-right">{t.usersPage.actions}</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
                                                {admins.map(admin => (
                                                    <tr key={admin.id} className="hover:bg-gray-50 dark:hover:bg-gray-900/30 transition-colors">
                                                        <td className="px-6 py-4 text-sm font-medium">{admin.name}</td>
                                                        <td className="px-6 py-4 text-sm text-gray-500 dark:text-gray-400">{admin.email}</td>
                                                        <td className="px-6 py-4 text-right space-x-3">
                                                            <button onClick={() => handleEditAdmin(admin)} className="text-sm font-semibold text-gray-600 dark:text-gray-400 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors">{t.common.edit}</button>
                                                            {admin.id !== currentAdmin?.id && (
                                                                <button onClick={() => confirmDeleteAdmin(admin.id)} className="text-sm font-semibold text-red-600 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300 transition-colors">{t.common.delete}</button>
                                                            )}
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                </div>

                {/* Admin Form Modal */}
                {showAdminForm && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center p-6">
                        <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => setShowAdminForm(false)}></div>
                        <div className="relative w-full max-w-md bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-2xl shadow-2xl p-6 animate-in zoom-in-95 duration-200">
                            <h3 className="text-xl font-bold mb-6">{isEditingAdmin ? t.profilePage.editAdmin : t.profilePage.addNewAdmin}</h3>
                            <form onSubmit={handleAdminSubmit} className="space-y-4">
                                <div className="space-y-1.5 text-left">
                                    <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{t.profilePage.name}</label>
                                    <input
                                        type="text"
                                        value={adminFormData.name}
                                        onChange={(e) => setAdminFormData({ ...adminFormData, name: e.target.value })}
                                        className="w-full px-4 py-2.5 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 outline-none transition-all"
                                        required
                                    />
                                </div>
                                <div className="space-y-1.5 text-left">
                                    <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{t.profilePage.email}</label>
                                    <input
                                        type="email"
                                        value={adminFormData.email}
                                        onChange={(e) => setAdminFormData({ ...adminFormData, email: e.target.value })}
                                        className="w-full px-4 py-2.5 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 outline-none transition-all"
                                        required
                                    />
                                </div>
                                {!isEditingAdmin && (
                                    <div className="space-y-1.5 text-left">
                                        <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{t.login.password}</label>
                                        <input
                                            type="password"
                                            value={adminFormData.password}
                                            onChange={(e) => setAdminFormData({ ...adminFormData, password: e.target.value })}
                                            className="w-full px-4 py-2.5 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl text-sm focus:ring-2 focus:ring-indigo-500 outline-none transition-all"
                                            required={!isEditingAdmin}
                                            minLength={6}
                                        />
                                    </div>
                                )}
                                <div className="flex gap-3 pt-2">
                                    <button
                                        type="submit"
                                        disabled={isSubmitting}
                                        className="flex-1 py-3 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold rounded-xl transition-all disabled:opacity-50"
                                    >
                                        {isSubmitting ? t.usersPage.saving : t.common.save}
                                    </button>
                                    <button
                                        type="button"
                                        onClick={() => setShowAdminForm(false)}
                                        className="flex-1 py-3 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 text-gray-700 dark:text-white text-sm font-semibold rounded-xl transition-all"
                                    >
                                        {t.common.cancel}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                )}

                {/* Delete Confirmation Modal */}
                {showDeleteConfirm && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 transition-all duration-300">
                        <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => setShowDeleteConfirm(false)}></div>
                        <div className="relative w-full max-w-sm bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 p-6 rounded-2xl shadow-2xl scale-100 transition-transform duration-300">
                            <div className="flex flex-col items-center text-center space-y-5">
                                <div className="w-14 h-14 bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center">
                                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#EF4444" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18"></path><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                                </div>
                                <div className="space-y-2">
                                    <h3 className="text-lg font-bold text-gray-900 dark:text-white">{t.profilePage.deleteAdmin}</h3>
                                    <p className="text-sm text-gray-600 dark:text-gray-400">{t.profilePage.deleteAdminConfirmation}</p>
                                </div>
                                <div className="flex w-full gap-3">
                                    <button onClick={handleDeleteAdmin} className="flex-1 py-2.5 bg-red-600 hover:bg-red-700 text-white text-sm font-medium rounded-lg transition-colors">
                                        {t.common.delete}
                                    </button>
                                    <button onClick={() => setShowDeleteConfirm(false)} className="flex-1 py-2.5 bg-white dark:bg-gray-900 text-gray-700 dark:text-gray-300 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                                        {t.common.cancel}
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
};

export default ProfilePage;
