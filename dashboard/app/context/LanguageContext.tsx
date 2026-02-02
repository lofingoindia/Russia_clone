"use client";

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import en from '../locales/en.json';
import ru from '../locales/ru.json';

type Language = 'en' | 'ru';

type TranslationsType = typeof en;

interface LanguageContextType {
    language: Language;
    setLanguage: (lang: Language) => void;
    t: TranslationsType;
}

const translations: Record<Language, TranslationsType> = {
    en,
    ru: ru as TranslationsType,
};

// Default context value to prevent hydration mismatch
const defaultContextValue: LanguageContextType = {
    language: 'en',
    setLanguage: () => { },
    t: en,
};

const LanguageContext = createContext<LanguageContextType>(defaultContextValue);

export const LanguageProvider = ({ children }: { children: ReactNode }) => {
    const [language, setLanguageState] = useState<Language>('en');
    const [isHydrated, setIsHydrated] = useState(false);

    useEffect(() => {
        // Only access localStorage after hydration
        const savedLanguage = localStorage.getItem('language') as Language | null;
        if (savedLanguage && (savedLanguage === 'en' || savedLanguage === 'ru')) {
            setLanguageState(savedLanguage);
        }
        setIsHydrated(true);
    }, []);

    const setLanguage = (lang: Language) => {
        setLanguageState(lang);
        if (typeof window !== 'undefined') {
            localStorage.setItem('language', lang);
        }
    };

    const t = translations[language];

    // Always provide the context, but use default 'en' until hydrated
    // This prevents hydration mismatch since server always renders with 'en'
    const contextValue: LanguageContextType = {
        language: isHydrated ? language : 'en',
        setLanguage,
        t: isHydrated ? t : en,
    };

    return (
        <LanguageContext.Provider value={contextValue}>
            {children}
        </LanguageContext.Provider>
    );
};

export const useLanguage = (): LanguageContextType => {
    return useContext(LanguageContext);
};

export default LanguageContext;
