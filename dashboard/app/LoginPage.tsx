"use client";

import React, { useState } from 'react';
import { useLanguage } from './context/LanguageContext';

interface LoginPageProps {
    onLogin: (email: string, password: string) => Promise<boolean>;
    theme: 'light' | 'dark';
    onThemeToggle: () => void;
}

const LoginPage = ({ onLogin, theme, onThemeToggle }: LoginPageProps) => {
    const { t, language, setLanguage } = useLanguage();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');
        setIsLoading(true);

        try {
            const success = await onLogin(email, password);
            if (!success) {
                setError(t.login.invalidCredentials);
            }
        } catch {
            setError(t.login.loginFailed);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-[#D1DFFF] dark:bg-[#0F172A] flex items-center justify-center p-4 font-sans selection:bg-indigo-100">
            {/* Theme Toggle & Language Switcher */}
            <div className="absolute top-8 right-8 flex items-center space-x-3">
                {/* Language Switcher */}
                <div className="flex items-center space-x-1 bg-surface-custom border border-border-custom rounded-sm px-2 py-2">
                    <button
                        onClick={() => setLanguage('en')}
                        className={`flex items-center space-x-1.5 px-2 py-1 rounded text-xs font-bold transition-colors ${language === 'en' ? 'bg-indigo-600 text-white' : 'text-foreground hover:bg-gray-100 dark:hover:bg-gray-700'}`}
                    >
                        <span>🇺🇸</span>
                        <span>EN</span>
                    </button>
                    <button
                        onClick={() => setLanguage('ru')}
                        className={`flex items-center space-x-1.5 px-2 py-1 rounded text-xs font-bold transition-colors ${language === 'ru' ? 'bg-indigo-600 text-white' : 'text-foreground hover:bg-gray-100 dark:hover:bg-gray-700'}`}
                    >
                        <span>🇷🇺</span>
                        <span>RU</span>
                    </button>
                </div>
                {/* Theme Toggle */}
                <button
                    onClick={onThemeToggle}
                    className="flex items-center space-x-2 px-4 py-2 bg-surface-custom border border-border-custom rounded-sm cursor-default text-foreground"
                >
                    {theme === 'light' ? (
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-foreground"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                    ) : (
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-foreground"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                    )}
                    <span className="text-[10px] font-bold uppercase tracking-widest text-foreground">{theme === 'light' ? t.common.light : t.common.dark}</span>
                </button>
            </div>

            {/* Main Login Card */}
            <div className="w-full max-w-[950px] bg-background border border-border-custom rounded-[20px] overflow-hidden flex flex-col md:flex-row min-h-[550px]">

                {/* Left Side: Illustration */}
                <div className="w-full md:w-1/2 bg-[#D1DFFF] dark:bg-[#1E293B] p-8 flex items-center justify-center">
                    <img
                        src="/login-illustration.png"
                        alt="Illustration"
                        className="w-full max-w-[400px] h-auto rounded-[15px]"
                    />
                </div>

                {/* Right Side: Form */}
                <div className="w-full md:w-1/2 p-12 lg:p-16 flex flex-col justify-center">
                    <div className="max-w-[400px] w-full mx-auto">
                        <div className="text-center mb-10">
                            <h2 className="text-[32px] font-bold text-foreground mb-2">{t.login.signIn}</h2>
                            <p className="text-[#64748B] dark:text-[#94A3B8] text-sm">{t.login.unlockWorld}</p>
                        </div>

                        <form onSubmit={handleSubmit} className="space-y-6">
                            <div className="space-y-2">
                                <label className="text-sm font-bold text-foreground">
                                    <span className="text-red-500 mr-1">*</span>{t.login.email}
                                </label>
                                <input
                                    type="email"
                                    required
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    placeholder={t.login.enterEmail}
                                    className="w-full px-4 py-3.5 bg-background border border-[#E2E8F0] dark:border-[#1E293B] rounded-[10px] text-sm focus:outline-none focus:border-[#3B82F6] text-foreground placeholder-[#94A3B8]"
                                />
                            </div>

                            <div className="space-y-2 relative">
                                <label className="text-sm font-bold text-foreground">
                                    <span className="text-red-500 mr-1">*</span>{t.login.password}
                                </label>
                                <div className="relative">
                                    <input
                                        type={showPassword ? "text" : "password"}
                                        required
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        placeholder={t.login.enterPassword}
                                        className="w-full px-4 py-3.5 bg-background border border-[#E2E8F0] dark:border-[#1E293B] rounded-[10px] text-sm focus:outline-none focus:border-[#3B82F6] text-foreground placeholder-[#94A3B8] pr-12"
                                    />
                                    <button
                                        type="button"
                                        onClick={() => setShowPassword(!showPassword)}
                                        className="absolute right-4 top-1/2 -translate-y-1/2 text-[#94A3B8] cursor-default"
                                    >
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            {showPassword ? (
                                                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                                            ) : (
                                                <>
                                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                    <circle cx="12" cy="12" r="3"></circle>
                                                </>
                                            )}
                                        </svg>
                                    </button>
                                </div>
                            </div>

                            <div className="pt-4 space-y-4">
                                {error && (
                                    <div className="p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-[10px] text-sm text-red-600 dark:text-red-400">
                                        {error}
                                    </div>
                                )}
                                <button
                                    type="submit"
                                    disabled={isLoading}
                                    className="w-full py-3.5 bg-[#3B82F6] text-white text-sm font-bold rounded-[10px] border border-[#3B82F6] cursor-default disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    {isLoading ? t.login.signingIn : t.login.signIn}
                                </button>

                            </div>
                        </form>

                        {/* Credentials helper at the bottom of the form area */}
                        <div className="mt-8 pt-6 border-t border-border-custom text-center">
                            <p className="text-[10px] font-bold text-[#64748B] uppercase tracking-widest mb-3">{t.login.adminCredentials}</p>
                            <div className="flex flex-col space-y-1 text-[11px] font-bold text-foreground">
                                <span>{t.login.email}: admin@russiaapp.com</span>
                                <span>{t.login.password}: admin123</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default LoginPage;
