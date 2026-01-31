"use client";

import React, { useState } from 'react';
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

const UsersPage = ({
    onTabChange,
    theme,
    onThemeToggle,
    onLogout,
    users,
    setUsers
}: {
    onTabChange: (tab: string) => void;
    theme: 'light' | 'dark';
    onThemeToggle: () => void;
    onLogout?: () => void;
    users: User[];
    setUsers: React.Dispatch<React.SetStateAction<User[]>>;
}) => {
    const [view, setView] = useState<'list' | 'form' | 'view'>('list');
    const [selectedUser, setSelectedUser] = useState<User | null>(null);
    const [isEditing, setIsEditing] = useState(false);
    const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
    const [userToDelete, setUserToDelete] = useState<number | null>(null);
    // users state removed as it is now a prop
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        phone: '',
        address: '',
        role: 'User',
        profileImage: null as File | string | null,
        doc1: null as File | string | null,
        doc2: null as File | string | null,
    });

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>, field: 'profileImage' | 'doc1' | 'doc2') => {
        if (e.target.files && e.target.files[0]) {
            setFormData({ ...formData, [field]: e.target.files[0] });
        }
    };

    const handleEdit = (user: User) => {
        setFormData({
            name: user.name,
            email: user.email,
            phone: user.phone,
            address: user.address,
            role: user.role,
            profileImage: user.profileImage,
            doc1: user.doc1,
            doc2: user.doc2,
        });
        setSelectedUser(user);
        setIsEditing(true);
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

    const handleDownload = (file: File | string | null) => {
        if (!file) return;

        let url: string;
        let filename: string;

        if (file instanceof File) {
            url = URL.createObjectURL(file);
            filename = file.name;
        } else {
            // For mock/string files, create a mock blob
            const blob = new Blob([`Content of ${file}`], { type: 'text/plain' });
            url = URL.createObjectURL(blob);
            filename = file;
        }

        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    };

    const handleDelete = () => {
        if (userToDelete) {
            setUsers(users.filter(u => u.id !== userToDelete));
            setShowDeleteConfirm(false);
            setUserToDelete(null);
        }
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        if (isEditing && selectedUser) {
            setUsers(users.map(u => u.id === selectedUser.id ? {
                ...u,
                name: formData.name,
                email: formData.email,
                phone: formData.phone,
                address: formData.address,
                role: formData.role,
                profileImage: typeof formData.profileImage === 'string' ? formData.profileImage : formData.profileImage ? URL.createObjectURL(formData.profileImage) : u.profileImage,
                doc1: formData.doc1 || u.doc1,
                doc2: formData.doc2 || u.doc2,
            } : u));
        } else {
            const newUser: User = {
                id: Date.now(),
                name: formData.name,
                email: formData.email,
                phone: formData.phone,
                address: formData.address,
                role: formData.role,
                profileImage: formData.profileImage instanceof File ? URL.createObjectURL(formData.profileImage) : null,
                doc1: formData.doc1,
                doc2: formData.doc2,
            };
            setUsers([...users, newUser]);
        }

        setFormData({ name: '', email: '', phone: '', address: '', role: 'User', profileImage: null, doc1: null, doc2: null });
        setSelectedUser(null);
        setIsEditing(false);
        setView('list');
    };

    return (
        <div className="flex h-screen bg-background text-foreground font-sans selection:bg-indigo-100 overflow-hidden">
            <Sidebar activeTab="Users" onTabChange={onTabChange} theme={theme} onThemeToggle={onThemeToggle} onLogout={onLogout} />

            <main className="flex-1 flex flex-col overflow-hidden relative">
                {/* Header */}
                <header className="h-20 bg-background border-b border-border-custom flex items-center justify-between px-10 shrink-0">
                    <div>
                        <h2 className="text-xl font-bold">User Management</h2>
                        <p className="text-sm text-muted-custom">Manage your team and their permissions.</p>
                    </div>
                    <button
                        onClick={() => {
                            setFormData({ name: '', email: '', phone: '', address: '', role: 'User', profileImage: null, doc1: null, doc2: null });
                            setIsEditing(false);
                            setView('form');
                        }}
                        className="px-6 py-2.5 bg-foreground text-background text-sm font-bold rounded-sm border border-foreground"
                    >
                        Add New User
                    </button>
                </header>

                {/* List View */}
                <div className="flex-1 overflow-y-auto p-10">
                    <div className="bg-background border border-border-custom rounded-sm overflow-hidden text-left">
                        <table className="w-full">
                            <thead>
                                <tr className="bg-surface-custom border-b border-border-custom">
                                    <th className="p-6 text-xs font-bold text-muted-custom uppercase tracking-widest text-left">User</th>
                                    <th className="p-6 text-xs font-bold text-muted-custom uppercase tracking-widest text-left">Contact & Address</th>
                                    <th className="p-6 text-xs font-bold text-muted-custom uppercase tracking-widest text-left">Role</th>
                                    <th className="p-6 text-xs font-bold text-muted-custom uppercase tracking-widest text-left">Documents</th>
                                    <th className="p-6 text-xs font-bold text-muted-custom uppercase tracking-widest text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-border-custom">
                                {users.map(user => (
                                    <tr key={user.id} className="bg-background hover:bg-surface-custom/50 transition-colors">
                                        <td className="p-6">
                                            <div className="flex items-center">
                                                <div className="w-10 h-10 bg-surface-custom border border-border-custom rounded-sm flex items-center justify-center overflow-hidden shrink-0">
                                                    {user.profileImage ? (
                                                        <img src={user.profileImage} alt="" className="w-full h-full object-cover" />
                                                    ) : (
                                                        <span className="text-xs font-bold text-muted-custom">{user.name.charAt(0)}</span>
                                                    )}
                                                </div>
                                                <div className="ml-4">
                                                    <p className="text-sm font-bold text-foreground">{user.name}</p>
                                                    <p className="text-xs text-muted-custom">{user.email}</p>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="p-6">
                                            <div className="space-y-1">
                                                <p className="text-xs font-bold text-foreground">{user.phone || 'No phone'}</p>
                                                <p className="text-[11px] text-muted-custom leading-tight max-w-[200px]">{user.address || 'No address'}</p>
                                            </div>
                                        </td>
                                        <td className="p-6">
                                            <span className="px-2 py-1 text-[10px] font-bold rounded-sm uppercase tracking-widest bg-surface-custom text-muted-custom border border-border-custom">
                                                {user.role}
                                            </span>
                                        </td>
                                        <td className="p-6">
                                            <div className="flex space-x-2">
                                                {user.doc1 && <span className="text-[10px] bg-[#E0F2FE] text-[#0369A1] dark:bg-[#0369A1] dark:text-[#E0F2FE] px-1.5 py-0.5 rounded-sm font-bold uppercase">Identity</span>}
                                                {user.doc2 && <span className="text-[10px] bg-[#F3E8FF] text-[#7E22CE] dark:bg-[#7E22CE] dark:text-[#F3E8FF] px-1.5 py-0.5 rounded-sm font-bold uppercase">Migration</span>}
                                                {!user.doc1 && !user.doc2 && <span className="text-xs text-muted-custom">None</span>}
                                            </div>
                                        </td>
                                        <td className="p-6 text-right">
                                            <div className="flex items-center justify-end space-x-4">
                                                <button onClick={() => handleView(user)} className="text-xs font-bold text-[#3B82F6] uppercase tracking-wider">View</button>
                                                <button onClick={() => handleEdit(user)} className="text-xs font-bold text-foreground uppercase tracking-wider">Edit</button>
                                                <button onClick={() => confirmDelete(user.id)} className="text-xs font-bold text-[#EF4444] uppercase tracking-wider">Delete</button>
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
                    <div className="absolute inset-0 bg-foreground/10 backdrop-blur-[2px]" onClick={() => setView('list')}></div>

                    {/* Panel */}
                    <div className={`absolute right-0 top-0 bottom-0 w-[500px] bg-background border-l border-border-custom transition-transform duration-300 transform ${view === 'form' ? 'translate-x-0' : 'translate-x-full'}`}>
                        <div className="flex flex-col h-full">
                            <div className="h-20 flex items-center justify-between px-8 border-b border-border-custom">
                                <h3 className="text-lg font-bold text-foreground">{isEditing ? 'Edit User' : 'Add New User'}</h3>
                                <button onClick={() => setView('list')} className="p-2 text-muted-custom">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                </button>
                            </div>

                            <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-10 space-y-8">
                                {/* Top Section: Photo & Role */}
                                <div className="grid grid-cols-2 gap-8 items-start">
                                    <div className="space-y-4 text-left">
                                        <label className="text-xs font-bold text-muted-custom uppercase tracking-widest">Profile Photo</label>
                                        <div className="flex items-center space-x-4">
                                            <div className="w-16 h-16 bg-surface-custom border border-border-custom rounded-sm flex items-center justify-center overflow-hidden shrink-0">
                                                {formData.profileImage ? (
                                                    <img src={typeof formData.profileImage === 'string' ? formData.profileImage : URL.createObjectURL(formData.profileImage)} alt="Preview" className="w-full h-full object-cover" />
                                                ) : (
                                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" className="text-muted-custom"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                                                )}
                                            </div>
                                            <label className="flex-1 cursor-pointer h-16 flex items-center justify-center border border-border-custom bg-background text-[10px] font-bold uppercase tracking-widest rounded-sm text-foreground hover:bg-surface-custom transition-colors">
                                                Upload Photo
                                                <input type="file" className="hidden" accept="image/*" onChange={(e) => handleFileChange(e, 'profileImage')} />
                                            </label>
                                        </div>
                                    </div>
                                    <div className="space-y-4 text-left">
                                        <label className="text-xs font-bold text-muted-custom uppercase tracking-widest">Select Role</label>
                                        <div className="relative h-16">
                                            <select
                                                value={formData.role}
                                                onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                                                className="w-full h-full px-4 bg-background border border-border-custom rounded-sm text-sm font-medium focus:outline-none focus:border-foreground appearance-none text-foreground"
                                            >
                                                <option>Admin</option>
                                                <option>Manager</option>
                                                <option>User</option>
                                            </select>
                                            <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-muted-custom">
                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                {/* Form Fields */}
                                <div className="space-y-6 text-left">
                                    <div className="grid grid-cols-2 gap-6">
                                        <div className="space-y-2">
                                            <label className="text-xs font-bold text-muted-custom uppercase tracking-widest">Full Name</label>
                                            <input
                                                type="text"
                                                required
                                                value={formData.name}
                                                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                                className="w-full px-4 py-3 bg-background border border-border-custom rounded-sm text-sm focus:outline-none focus:border-foreground text-foreground"
                                                placeholder="Enter name"
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <label className="text-xs font-bold text-muted-custom uppercase tracking-widest">Phone Number</label>
                                            <input
                                                type="tel"
                                                value={formData.phone}
                                                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                                                className="w-full px-4 py-3 bg-background border border-border-custom rounded-sm text-sm focus:outline-none focus:border-foreground text-foreground"
                                                placeholder="+1 (555) 000-0000"
                                            />
                                        </div>
                                    </div>

                                    <div className="space-y-2">
                                        <label className="text-xs font-bold text-muted-custom uppercase tracking-widest">Email Address</label>
                                        <input
                                            type="email"
                                            required
                                            value={formData.email}
                                            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                            className="w-full px-4 py-3 bg-background border border-border-custom rounded-sm text-sm focus:outline-none focus:border-foreground text-foreground"
                                            placeholder="email@example.com"
                                        />
                                    </div>

                                    <div className="space-y-2">
                                        <label className="text-xs font-bold text-muted-custom uppercase tracking-widest">Physical Address</label>
                                        <textarea
                                            rows={3}
                                            value={formData.address}
                                            onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                                            className="w-full px-4 py-3 bg-background border border-border-custom rounded-sm text-sm focus:outline-none focus:border-foreground text-foreground resize-none"
                                            placeholder="Enter full address"
                                        />
                                    </div>

                                </div>

                                {/* Documents */}
                                <div className="space-y-6 pt-6 border-t border-border-custom text-left">
                                    <div className="space-y-2">
                                        <label className="text-xs font-bold text-muted-custom uppercase tracking-widest">Identity Document</label>
                                        <div className="flex items-center space-x-3">
                                            <label className="flex-1 cursor-pointer px-4 py-3 bg-surface-custom border border-border-custom rounded-sm text-sm flex items-center justify-between">
                                                <span className="text-muted-custom text-sm">
                                                    {formData.doc1 instanceof File ? formData.doc1.name : typeof formData.doc1 === 'string' ? formData.doc1 : 'Choose file...'}
                                                </span>
                                                <span className="text-[10px] font-bold uppercase text-foreground">Browse</span>
                                                <input type="file" className="hidden" onChange={(e) => handleFileChange(e, 'doc1')} />
                                            </label>
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-xs font-bold text-muted-custom uppercase tracking-widest">Migration Card</label>
                                        <div className="flex items-center space-x-3">
                                            <label className="flex-1 cursor-pointer px-4 py-3 bg-surface-custom border border-border-custom rounded-sm text-sm flex items-center justify-between">
                                                <span className="text-muted-custom text-sm">
                                                    {formData.doc2 instanceof File ? formData.doc2.name : typeof formData.doc2 === 'string' ? formData.doc2 : 'Choose file...'}
                                                </span>
                                                <span className="text-[10px] font-bold uppercase text-foreground">Browse</span>
                                                <input type="file" className="hidden" onChange={(e) => handleFileChange(e, 'doc2')} />
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <div className="pt-8 flex space-x-4">
                                    <button type="submit" className="flex-1 py-4 bg-foreground text-background text-xs font-bold uppercase tracking-widest rounded-sm border border-foreground">
                                        Save User
                                    </button>
                                    <button type="button" onClick={() => setView('list')} className="flex-1 py-4 bg-background text-foreground text-xs font-bold uppercase tracking-widest rounded-sm border border-border-custom">
                                        Cancel
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                {/* Smooth Slide-over View Overlay */}
                <div className={`fixed inset-0 z-50 transition-all duration-300 ${view === 'view' ? 'visible' : 'invisible opacity-0'}`}>
                    <div className="absolute inset-0 bg-foreground/10 backdrop-blur-[2px]" onClick={() => setView('list')}></div>
                    <div className={`absolute right-0 top-0 bottom-0 w-[500px] bg-background border-l border-border-custom transition-transform duration-300 transform ${view === 'view' ? 'translate-x-0' : 'translate-x-full'}`}>
                        <div className="flex flex-col h-full text-left">
                            <div className="h-20 flex items-center justify-between px-8 border-b border-border-custom">
                                <h3 className="text-lg font-bold text-foreground">User Details</h3>
                                <button onClick={() => setView('list')} className="p-2 text-muted-custom">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                </button>
                            </div>
                            <div className="p-10 space-y-10 overflow-y-auto">
                                <div className="flex items-center space-x-6">
                                    <div className="w-24 h-24 bg-surface-custom border border-border-custom rounded-sm flex items-center justify-center overflow-hidden">
                                        {selectedUser?.profileImage ? (
                                            <img src={selectedUser.profileImage} alt="" className="w-full h-full object-cover" />
                                        ) : (
                                            <span className="text-2xl font-bold text-muted-custom">{selectedUser?.name.charAt(0)}</span>
                                        )}
                                    </div>
                                    <div>
                                        <h4 className="text-2xl font-bold text-foreground">{selectedUser?.name}</h4>
                                        <div className="mt-1">
                                            <span className="px-2 py-1 text-[10px] font-bold rounded-sm uppercase tracking-widest bg-foreground text-background border border-foreground">
                                                {selectedUser?.role}
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div className="grid grid-cols-1 gap-8 pt-6 border-t border-border-custom">
                                    <div className="grid grid-cols-2 gap-6">
                                        <div className="space-y-1">
                                            <p className="text-[10px] font-bold text-muted-custom uppercase tracking-widest">Email Address</p>
                                            <p className="font-bold text-foreground text-sm">{selectedUser?.email}</p>
                                        </div>
                                        <div className="space-y-1">
                                            <p className="text-[10px] font-bold text-muted-custom uppercase tracking-widest">Phone Number</p>
                                            <p className="font-bold text-foreground text-sm">{selectedUser?.phone || 'N/A'}</p>
                                        </div>
                                    </div>

                                    <div className="space-y-1">
                                        <p className="text-[10px] font-bold text-muted-custom uppercase tracking-widest">Physical Address</p>
                                        <p className="font-bold text-foreground text-sm">{selectedUser?.address || 'N/A'}</p>
                                    </div>

                                    <div className="space-y-4">
                                        <p className="text-[10px] font-bold text-muted-custom uppercase tracking-widest">Attachments</p>
                                        <div className="space-y-3">
                                            {selectedUser?.doc1 && (
                                                <div className="space-y-2">
                                                    <p className="text-[9px] font-bold text-muted-custom uppercase tracking-widest pl-1">Identity Document</p>
                                                    <div className="flex items-center justify-between p-4 bg-surface-custom border border-border-custom rounded-sm gap-4">
                                                        <div className="flex items-center space-x-3 overflow-hidden">
                                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-[#3B82F6] shrink-0"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>
                                                            <span className="text-sm font-bold text-foreground truncate">{selectedUser.doc1 instanceof File ? selectedUser.doc1.name : selectedUser.doc1}</span>
                                                        </div>
                                                        <button onClick={() => handleDownload(selectedUser.doc1)} className="text-[10px] font-bold text-[#3B82F6] uppercase cursor-default shrink-0">Download</button>
                                                    </div>
                                                </div>
                                            )}
                                            {selectedUser?.doc2 && (
                                                <div className="space-y-2">
                                                    <p className="text-[9px] font-bold text-muted-custom uppercase tracking-widest pl-1">Migration Card</p>
                                                    <div className="flex items-center justify-between p-4 bg-surface-custom border border-border-custom rounded-sm gap-4">
                                                        <div className="flex items-center space-x-3 overflow-hidden">
                                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-[#A855F7] shrink-0"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>
                                                            <span className="text-sm font-bold text-foreground truncate">{selectedUser.doc2 instanceof File ? selectedUser.doc2.name : selectedUser.doc2}</span>
                                                        </div>
                                                        <button onClick={() => handleDownload(selectedUser.doc2)} className="text-[10px] font-bold text-[#3B82F6] uppercase cursor-default shrink-0">Download</button>
                                                    </div>
                                                </div>
                                            )}
                                            {!selectedUser?.doc1 && !selectedUser?.doc2 && <p className="text-sm text-muted-custom">No documents uploaded.</p>}
                                        </div>
                                    </div>
                                </div>

                                <div className="pt-10 flex space-x-4">
                                    <button onClick={() => { setView('list'); handleEdit(selectedUser!); }} className="flex-1 py-4 bg-foreground text-background text-xs font-bold uppercase tracking-widest rounded-sm">
                                        Edit Profile
                                    </button>
                                    <button onClick={() => setView('list')} className="flex-1 py-4 bg-background text-foreground text-xs font-bold uppercase tracking-widest rounded-sm border border-border-custom">
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
                    <div className="absolute inset-0 bg-foreground/10 backdrop-blur-md" onClick={() => setShowDeleteConfirm(false)}></div>

                    {/* Modal Box */}
                    <div className={`relative w-full max-w-sm bg-background border border-border-custom p-8 rounded-sm transition-transform duration-300 transform ${showDeleteConfirm ? 'scale-100' : 'scale-95'}`}>
                        <div className="flex flex-col items-center text-center space-y-6">
                            <div className="w-16 h-16 bg-[#FEE2E2] dark:bg-[#7F1D1D] rounded-sm flex items-center justify-center">
                                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#EF4444" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18"></path><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                            </div>
                            <div className="space-y-2">
                                <h3 className="text-lg font-bold text-foreground">Delete User?</h3>
                                <p className="text-sm text-muted-custom">This action cannot be undone. All data associated with this user will be removed.</p>
                            </div>
                            <div className="flex w-full space-x-3">
                                <button onClick={handleDelete} className="flex-1 py-3 bg-[#EF4444] text-white text-xs font-bold uppercase tracking-widest rounded-sm">
                                    Delete
                                </button>
                                <button onClick={() => setShowDeleteConfirm(false)} className="flex-1 py-3 bg-background text-foreground border border-border-custom text-xs font-bold uppercase tracking-widest rounded-sm">
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
