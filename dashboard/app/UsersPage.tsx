"use client";

import React, { useState } from 'react';
import Sidebar from './Sidebar';
import { usersAPI } from './lib/api';

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

const UsersPage = ({
    onTabChange,
    theme,
    onThemeToggle,
    onLogout,
    users,
    setUsers,
    refreshUsers,
    adminInfo
}: {
    onTabChange: (tab: string) => void;
    theme: 'light' | 'dark';
    onThemeToggle: () => void;
    onLogout?: () => void;
    users: User[];
    setUsers: React.Dispatch<React.SetStateAction<User[]>>;
    refreshUsers: () => Promise<void>;
    adminInfo?: { name: string; role: string } | null;
}) => {
    const [view, setView] = useState<'list' | 'form' | 'view'>('list');
    const [selectedUser, setSelectedUser] = useState<User | null>(null);
    const [isEditing, setIsEditing] = useState(false);
    const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
    const [userToDelete, setUserToDelete] = useState<number | null>(null);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState('');
    // users state removed as it is now a prop
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        phone: '',
        address: '',
        role: 'User',
        profileImage: null as File | null,
        profileImagePreview: null as string | null,
        doc1: null as File | null,
        doc1Name: null as string | null,
        doc2: null as File | null,
        doc2Name: null as string | null,
    });

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>, field: 'profileImage' | 'doc1' | 'doc2') => {
        if (e.target.files && e.target.files[0]) {
            const file = e.target.files[0];
            if (field === 'profileImage') {
                setFormData({ 
                    ...formData, 
                    profileImage: file,
                    profileImagePreview: URL.createObjectURL(file)
                });
            } else if (field === 'doc1') {
                setFormData({ ...formData, doc1: file, doc1Name: file.name });
            } else {
                setFormData({ ...formData, doc2: file, doc2Name: file.name });
            }
        }
    };

    const handleEdit = (user: User) => {
        setFormData({
            name: user.name,
            email: user.email,
            phone: user.phone || '',
            address: user.address || '',
            role: user.role,
            profileImage: null,
            profileImagePreview: user.profileImage,
            doc1: null,
            doc1Name: user.doc1Name,
            doc2: null,
            doc2Name: user.doc2Name,
        });
        setSelectedUser(user);
        setIsEditing(true);
        setError('');
        setView('form');
    };

    const handleView = (user: User) => {
        setSelectedUser(user);
        setView('view');
    };

    const confirmDelete = (id: number) => {
        setUserToDelete(id);
        setShowDeleteConfirm(true);
    };

    const handleDownload = (userId: number, docType: 'doc1' | 'doc2' | 'profile') => {
        usersAPI.downloadDocument(userId, docType);
    };

    const handleDelete = async () => {
        if (userToDelete) {
            try {
                await usersAPI.delete(userToDelete);
                await refreshUsers();
                setShowDeleteConfirm(false);
                setUserToDelete(null);
            } catch (err) {
                console.error('Delete failed:', err);
            }
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsSubmitting(true);
        setError('');

        try {
            const apiFormData = new FormData();
            apiFormData.append('name', formData.name);
            apiFormData.append('email', formData.email);
            apiFormData.append('phone', formData.phone);
            apiFormData.append('address', formData.address);
            apiFormData.append('role', formData.role);
            
            if (formData.profileImage) {
                apiFormData.append('profileImage', formData.profileImage);
            }
            if (formData.doc1) {
                apiFormData.append('doc1', formData.doc1);
            }
            if (formData.doc2) {
                apiFormData.append('doc2', formData.doc2);
            }

            if (isEditing && selectedUser) {
                await usersAPI.update(selectedUser.id, apiFormData);
            } else {
                await usersAPI.create(apiFormData);
            }

            await refreshUsers();
            resetForm();
            setView('list');
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Failed to save user');
        } finally {
            setIsSubmitting(false);
        }
    };

    const resetForm = () => {
        setFormData({ 
            name: '', 
            email: '', 
            phone: '', 
            address: '', 
            role: 'User', 
            profileImage: null, 
            profileImagePreview: null,
            doc1: null, 
            doc1Name: null,
            doc2: null,
            doc2Name: null
        });
        setSelectedUser(null);
        setIsEditing(false);
        setError('');
    };

    return (
        <div className="flex h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-white font-sans selection:bg-indigo-100 overflow-hidden">
            <Sidebar activeTab="Users" onTabChange={onTabChange} theme={theme} onThemeToggle={onThemeToggle} onLogout={onLogout} adminInfo={adminInfo} />

            <main className="flex-1 flex flex-col overflow-hidden relative">
                {/* Header */}
                <header className="h-16 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between px-8 shrink-0">
                    <div>
                        <h2 className="text-xl font-bold text-gray-900 dark:text-white">User Management</h2>
                        <p className="text-sm text-gray-500 dark:text-gray-400">Manage your team and their permissions</p>
                    </div>
                    <button
                        onClick={() => {
                            resetForm();
                            setView('form');
                        }}
                        className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium rounded-lg transition-colors"
                    >
                        Add New User
                    </button>
                </header>

                {/* List View */}
                <div className="flex-1 overflow-y-auto p-8">
                    <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl shadow-sm overflow-hidden text-left">
                        <table className="w-full">
                            <thead>
                                <tr className="bg-gray-50 dark:bg-gray-900/50 border-b border-gray-200 dark:border-gray-700">
                                    <th className="p-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-left">User</th>
                                    <th className="p-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-left">Contact & Address</th>
                                    <th className="p-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-left">Role</th>
                                    <th className="p-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-left">Documents</th>
                                    <th className="p-4 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
                                {users.map(user => (
                                    <tr key={user.id} className="hover:bg-gray-50 dark:hover:bg-gray-900/30 transition-colors">
                                        <td className="p-4">
                                            <div className="flex items-center">
                                                <div className="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-full flex items-center justify-center overflow-hidden shrink-0">
                                                    {user.profileImage ? (
                                                        <img src={user.profileImage} alt="" className="w-full h-full object-cover" />
                                                    ) : (
                                                        <span className="text-sm font-bold text-white">{user.name.charAt(0)}</span>
                                                    )}
                                                </div>
                                                <div className="ml-3">
                                                    <p className="text-sm font-semibold text-gray-900 dark:text-white">{user.name}</p>
                                                    <p className="text-xs text-gray-500 dark:text-gray-400">{user.email}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="p-4">
                                            <div className="space-y-1">
                                                <p className="text-xs font-medium text-gray-900 dark:text-white">{user.phone || 'No phone'}</p>
                                                <p className="text-xs text-gray-500 dark:text-gray-400 leading-tight max-w-[200px]">{user.address || 'No address'}</p>
                                            </div>
                                        </td>
                                        <td className="p-4">
                                            <span className="px-2.5 py-1 text-xs font-medium rounded-full bg-indigo-50 text-indigo-600 dark:bg-indigo-900/30 dark:text-indigo-400">
                                                {user.role}
                                            </span>
                                        </td>
                                        <td className="p-4">
                                            <div className="flex gap-1.5">
                                                {(user.doc1 || user.doc1Url) && <span className="text-[10px] bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 px-2 py-1 rounded-md font-medium">ID</span>}
                                                {(user.doc2 || user.doc2Url) && <span className="text-[10px] bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400 px-2 py-1 rounded-md font-medium">Card</span>}
                                                {!(user.doc1 || user.doc1Url) && !(user.doc2 || user.doc2Url) && <span className="text-xs text-gray-400 dark:text-gray-500">None</span>}
                                            </div>
                                        </td>
                                        <td className="p-4 text-right">
                                            <div className="flex items-center justify-end gap-3">
                                                <button onClick={() => handleView(user)} className="text-sm font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300">View</button>
                                                <button onClick={() => handleEdit(user)} className="text-sm font-medium text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white">Edit</button>
                                                <button onClick={() => confirmDelete(user.id)} className="text-sm font-medium text-red-600 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300">Delete</button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>

                {/* Smooth Slide-over Form Overlay */}
                <div className={`fixed inset-0 z-50 transition-all duration-300 ${view === 'form' ? 'visible' : 'invisible opacity-0'}`}>
                    {/* Backdrop */}
                    <div className="absolute inset-0 bg-gray-900/20 backdrop-blur-sm" onClick={() => setView('list')}></div>

                    {/* Panel */}
                    <div className={`absolute right-0 top-0 bottom-0 w-[500px] bg-white dark:bg-gray-800 border-l border-gray-200 dark:border-gray-700 shadow-2xl transition-transform duration-300 transform ${view === 'form' ? 'translate-x-0' : 'translate-x-full'}`}>
                        <div className="flex flex-col h-full">
                            <div className="h-16 flex items-center justify-between px-6 border-b border-gray-200 dark:border-gray-700">
                                <h3 className="text-lg font-semibold text-gray-900 dark:text-white">{isEditing ? 'Edit User' : 'Add New User'}</h3>
                                <button onClick={() => setView('list')} className="p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                </button>
                            </div>

                            <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-6">
                                {/* Error Message */}
                                {error && (
                                    <div className="p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg text-sm text-red-600 dark:text-red-400">
                                        {error}
                                    </div>
                                )}
                                {/* Top Section: Photo & Role */}
                                <div className="grid grid-cols-2 gap-4 items-start">
                                    <div className="space-y-3 text-left">
                                        <label className="text-xs font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">Profile Photo</label>
                                        <div className="flex items-center space-x-3">
                                            <div className="w-16 h-16 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-full flex items-center justify-center overflow-hidden shrink-0">
                                                {formData.profileImagePreview ? (
                                                    <img src={formData.profileImagePreview} alt="Preview" className="w-full h-full object-cover" />
                                                ) : (
                                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                                )}
                                            </div>
                                            <label className="flex-1 cursor-pointer h-16 flex items-center justify-center border-2 border-dashed border-gray-300 dark:border-gray-600 bg-gray-50 dark:bg-gray-900 text-xs font-medium rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 hover:border-indigo-400 dark:hover:border-indigo-500 transition-colors">
                                                Upload Photo
                                                <input type="file" className="hidden" accept="image/*" onChange={(e) => handleFileChange(e, 'profileImage')} />
                                            </label>
                                        </div>
                                    </div>
                                    <div className="space-y-3 text-left">
                                        <label className="text-xs font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">Select Role</label>
                                        <div className="relative h-16">
                                            <select
                                                value={formData.role}
                                                onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                                                className="w-full h-full px-4 bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg text-sm font-medium focus:outline-none focus:ring-2 focus:ring-indigo-500 dark:focus:ring-indigo-400 focus:border-transparent appearance-none text-gray-900 dark:text-white"
                                            >
                                                <option>Admin</option>
                                                <option>Manager</option>
                                                <option>User</option>
                                            </select>
                                            <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-gray-400 dark:text-gray-500">
                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                {/* Form Fields */}
                                <div className="space-y-4 text-left">
                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="space-y-1.5">
                                            <label className="text-xs font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">Full Name</label>
                                            <input
                                                type="text"
                                                required
                                                value={formData.name}
                                                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                                className="w-full px-4 py-2.5 bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 dark:focus:ring-indigo-400 focus:border-transparent text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                                                placeholder="Enter name"
                                            />
                                        </div>
                                        <div className="space-y-1.5">
                                            <label className="text-xs font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">Phone Number</label>
                                            <input
                                                type="tel"
                                                value={formData.phone}
                                                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                                                className="w-full px-4 py-2.5 bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 dark:focus:ring-indigo-400 focus:border-transparent text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                                                placeholder="+1 (555) 000-0000"
                                            />
                                        </div>
                                    </div>

                                    <div className="space-y-1.5">
                                        <label className="text-xs font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">Email Address</label>
                                        <input
                                            type="email"
                                            required
                                            value={formData.email}
                                            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                            className="w-full px-4 py-2.5 bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 dark:focus:ring-indigo-400 focus:border-transparent text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500"
                                            placeholder="email@example.com"
                                        />
                                    </div>

                                    <div className="space-y-1.5">
                                        <label className="text-xs font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">Physical Address</label>
                                        <textarea
                                            rows={3}
                                            value={formData.address}
                                            onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                                            className="w-full px-4 py-2.5 bg-white dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 dark:focus:ring-indigo-400 focus:border-transparent text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-500 resize-none"
                                            placeholder="Enter full address"
                                        />
                                    </div>

                                </div>

                                {/* Documents */}
                                <div className="space-y-4 pt-4 border-t border-gray-200 dark:border-gray-700 text-left">
                                    <div className="space-y-1.5">
                                        <label className="text-xs font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">Identity Document</label>
                                        <div className="flex items-center space-x-3">
                                            <label className="flex-1 cursor-pointer px-4 py-3 bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg text-sm flex items-center justify-between hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors">
                                                <span className="text-gray-600 dark:text-gray-400 text-sm truncate">
                                                    {formData.doc1 ? formData.doc1.name : formData.doc1Name || 'Choose file...'}
                                                </span>
                                                <span className="text-xs font-medium text-indigo-600 dark:text-indigo-400">Browse</span>
                                                <input type="file" className="hidden" onChange={(e) => handleFileChange(e, 'doc1')} />
                                            </label>
                                        </div>
                                    </div>
                                    <div className="space-y-1.5">
                                        <label className="text-xs font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">Migration Card</label>
                                        <div className="flex items-center space-x-3">
                                            <label className="flex-1 cursor-pointer px-4 py-3 bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg text-sm flex items-center justify-between hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors">
                                                <span className="text-gray-600 dark:text-gray-400 text-sm truncate">
                                                    {formData.doc2 ? formData.doc2.name : formData.doc2Name || 'Choose file...'}
                                                </span>
                                                <span className="text-xs font-medium text-indigo-600 dark:text-indigo-400">Browse</span>
                                                <input type="file" className="hidden" onChange={(e) => handleFileChange(e, 'doc2')} />
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <div className="pt-6 flex gap-3">
                                    <button 
                                        type="submit" 
                                        disabled={isSubmitting}
                                        className="flex-1 py-3 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium rounded-lg transition-colors disabled:opacity-50"
                                    >
                                        {isSubmitting ? 'Saving...' : 'Save User'}
                                    </button>
                                    <button type="button" onClick={() => { resetForm(); setView('list'); }} className="flex-1 py-3 bg-white dark:bg-gray-900 text-gray-700 dark:text-gray-300 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                                        Cancel
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                {/* Smooth Slide-over View Overlay */}
                <div className={`fixed inset-0 z-50 transition-all duration-300 ${view === 'view' ? 'visible' : 'invisible opacity-0'}`}>
                    <div className="absolute inset-0 bg-gray-900/20 backdrop-blur-sm" onClick={() => setView('list')}></div>
                    <div className={`absolute right-0 top-0 bottom-0 w-[500px] bg-white dark:bg-gray-800 border-l border-gray-200 dark:border-gray-700 shadow-2xl transition-transform duration-300 transform ${view === 'view' ? 'translate-x-0' : 'translate-x-full'}`}>
                        <div className="flex flex-col h-full text-left">
                            <div className="h-16 flex items-center justify-between px-6 border-b border-gray-200 dark:border-gray-700">
                                <h3 className="text-lg font-semibold text-gray-900 dark:text-white">User Details</h3>
                                <button onClick={() => setView('list')} className="p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                </button>
                            </div>
                            <div className="p-6 space-y-8 overflow-y-auto">
                                <div className="flex items-center space-x-4">
                                    <div className="w-20 h-20 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-full flex items-center justify-center overflow-hidden shrink-0">
                                        {selectedUser?.profileImage ? (
                                            <img src={selectedUser.profileImage} alt="" className="w-full h-full object-cover" />
                                        ) : (
                                            <span className="text-2xl font-bold text-white">{selectedUser?.name.charAt(0)}</span>
                                        )}
                                    </div>
                                    <div>
                                        <h4 className="text-xl font-bold text-gray-900 dark:text-white">{selectedUser?.name}</h4>
                                        <div className="mt-1.5">
                                            <span className="px-2.5 py-1 text-xs font-medium rounded-full bg-indigo-50 text-indigo-600 dark:bg-indigo-900/30 dark:text-indigo-400">
                                                {selectedUser?.role}
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div className="grid grid-cols-1 gap-6 pt-6 border-t border-gray-200 dark:border-gray-700">
                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="space-y-1">
                                            <p className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Email Address</p>
                                            <p className="font-medium text-gray-900 dark:text-white text-sm">{selectedUser?.email}</p>
                                        </div>
                                        <div className="space-y-1">
                                            <p className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Phone Number</p>
                                            <p className="font-medium text-gray-900 dark:text-white text-sm">{selectedUser?.phone || 'N/A'}</p>
                                        </div>
                                    </div>

                                    <div className="space-y-1">
                                        <p className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Physical Address</p>
                                        <p className="font-medium text-gray-900 dark:text-white text-sm">{selectedUser?.address || 'N/A'}</p>
                                    </div>

                                    <div className="space-y-3">
                                        <p className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">Attachments</p>
                                        <div className="space-y-3">
                                            {(selectedUser?.doc1 || selectedUser?.doc1Url) && (
                                                <div className="space-y-2">
                                                    <p className="text-xs font-medium text-gray-600 dark:text-gray-400">Identity Document</p>
                                                    <div className="flex items-center justify-between p-3 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg gap-3">
                                                        <div className="flex items-center space-x-2 overflow-hidden">
                                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-blue-600 dark:text-blue-400 shrink-0"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>
                                                            <span className="text-sm font-medium text-gray-900 dark:text-white truncate">{selectedUser.doc1Name || 'Document'}</span>
                                                        </div>
                                                        <button onClick={() => handleDownload(selectedUser.id, 'doc1')} className="text-xs font-medium text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 cursor-default shrink-0">Download</button>
                                                    </div>
                                                </div>
                                            )}
                                            {(selectedUser?.doc2 || selectedUser?.doc2Url) && (
                                                <div className="space-y-2">
                                                    <p className="text-xs font-medium text-gray-600 dark:text-gray-400">Migration Card</p>
                                                    <div className="flex items-center justify-between p-3 bg-purple-50 dark:bg-purple-900/20 border border-purple-200 dark:border-purple-800 rounded-lg gap-3">
                                                        <div className="flex items-center space-x-2 overflow-hidden">
                                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-purple-600 dark:text-purple-400 shrink-0"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>
                                                            <span className="text-sm font-medium text-gray-900 dark:text-white truncate">{selectedUser.doc2Name || 'Document'}</span>
                                                        </div>
                                                        <button onClick={() => handleDownload(selectedUser.id, 'doc2')} className="text-xs font-medium text-purple-600 dark:text-purple-400 hover:text-purple-700 dark:hover:text-purple-300 cursor-default shrink-0">Download</button>
                                                    </div>
                                                </div>
                                            )}
                                            {!(selectedUser?.doc1 || selectedUser?.doc1Url) && !(selectedUser?.doc2 || selectedUser?.doc2Url) && <p className="text-sm text-gray-500 dark:text-gray-400">No documents uploaded.</p>}
                                        </div>
                                    </div>
                                </div>

                                <div className="pt-6 flex gap-3">
                                    <button onClick={() => { setView('list'); handleEdit(selectedUser!); }} className="flex-1 py-3 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium rounded-lg transition-colors">
                                        Edit Profile
                                    </button>
                                    <button onClick={() => { resetForm(); setView('list'); }} className="flex-1 py-3 bg-white dark:bg-gray-900 text-gray-700 dark:text-gray-300 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                                        Back to List
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Custom Delete Confirmation Modal */}
                <div className={`fixed inset-0 z-[100] flex items-center justify-center p-6 transition-all duration-300 ${showDeleteConfirm ? 'visible' : 'invisible opacity-0'}`}>
                    {/* Transparent Backdrop with Blur */}
                    <div className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onClick={() => setShowDeleteConfirm(false)}></div>

                    {/* Modal Box */}
                    <div className={`relative w-full max-w-sm bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 p-6 rounded-xl shadow-2xl transition-transform duration-300 transform ${showDeleteConfirm ? 'scale-100' : 'scale-95'}`}>
                        <div className="flex flex-col items-center text-center space-y-5">
                            <div className="w-14 h-14 bg-red-100 dark:bg-red-900/30 rounded-full flex items-center justify-center">
                                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#EF4444" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18"></path><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                            </div>
                            <div className="space-y-2">
                                <h3 className="text-lg font-bold text-gray-900 dark:text-white">Delete User?</h3>
                                <p className="text-sm text-gray-600 dark:text-gray-400">This action cannot be undone. All data associated with this user will be removed.</p>
                            </div>
                            <div className="flex w-full gap-3">
                                <button onClick={handleDelete} className="flex-1 py-2.5 bg-red-600 hover:bg-red-700 text-white text-sm font-medium rounded-lg transition-colors">
                                    Delete
                                </button>
                                <button onClick={() => setShowDeleteConfirm(false)} className="flex-1 py-2.5 bg-white dark:bg-gray-900 text-gray-700 dark:text-gray-300 border border-gray-300 dark:border-gray-600 text-sm font-medium rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                                    Cancel
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
};

export default UsersPage;
