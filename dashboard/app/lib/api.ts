// API Configuration and Service
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://cloneapp.mosrek.com/api';

// Token management
export const getToken = (): string | null => {
    if (typeof window !== 'undefined') {
        return localStorage.getItem('authToken');
    }
    return null;
};

export const setToken = (token: string): void => {
    if (typeof window !== 'undefined') {
        localStorage.setItem('authToken', token);
    }
};

export const removeToken = (): void => {
    if (typeof window !== 'undefined') {
        localStorage.removeItem('authToken');
    }
};

// Admin info management
export const getAdminInfo = () => {
    if (typeof window !== 'undefined') {
        const info = localStorage.getItem('adminInfo');
        return info ? JSON.parse(info) : null;
    }
    return null;
};

export const setAdminInfo = (admin: { id: number; name: string; email: string; role: string }): void => {
    if (typeof window !== 'undefined') {
        localStorage.setItem('adminInfo', JSON.stringify(admin));
    }
};

export const removeAdminInfo = (): void => {
    if (typeof window !== 'undefined') {
        localStorage.removeItem('adminInfo');
    }
};

// API request helper
const apiRequest = async (
    endpoint: string,
    options: RequestInit = {}
): Promise<{ success: boolean; data?: unknown; message?: string; count?: number }> => {
    const token = getToken();

    const headers: HeadersInit = {
        ...(options.headers || {}),
    };

    // Only add Content-Type if not FormData
    if (!(options.body instanceof FormData)) {
        (headers as Record<string, string>)['Content-Type'] = 'application/json';
    }

    if (token) {
        (headers as Record<string, string>)['Authorization'] = `Bearer ${token}`;
    }

    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, {
            ...options,
            headers,
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.message || 'Request failed');
        }

        return data;
    } catch (error) {
        if (error instanceof Error) {
            throw error;
        }
        throw new Error('Network error');
    }
};

// Auth API
export const authAPI = {
    login: async (email: string, password: string) => {
        const response = await apiRequest('/auth/login', {
            method: 'POST',
            body: JSON.stringify({ email, password }),
        });

        if (response.success && response.data) {
            const { token, admin } = response.data as { token: string; admin: { id: number; name: string; email: string; role: string } };
            setToken(token);
            setAdminInfo(admin);
        }

        return response;
    },

    logout: async () => {
        try {
            await apiRequest('/auth/logout', { method: 'POST' });
        } catch {
            // Ignore errors on logout
        }
        removeToken();
        removeAdminInfo();
    },

    getMe: async () => {
        return apiRequest('/auth/me');
    },

    changePassword: async (currentPassword: string, newPassword: string) => {
        return apiRequest('/auth/change-password', {
            method: 'POST',
            body: JSON.stringify({ currentPassword, newPassword }),
        });
    },
};

// User type matching the backend
export interface User {
    id: number;
    name: string;
    email: string;
    phone: string | null;
    address: string | null;
    role: 'Admin' | 'Manager' | 'User';
    profile_image: string | null;
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
    doc4: string | null;
    doc4Urls: string[] | null;
    doc4Names: string[] | null;
    is_active: number;
    created_at: string;
    updated_at: string;
}

export interface DashboardStats {
    totalUsers: number;
    roleDistribution: Array<{ role: string; count: number }>;
    usersWithDocuments: number;
    recentUsers: number;
}

// Users API
export const usersAPI = {
    getAll: async (): Promise<{ success: boolean; data: User[]; count: number }> => {
        const response = await apiRequest('/users');
        return response as { success: boolean; data: User[]; count: number };
    },

    getStats: async (): Promise<{ success: boolean; data: DashboardStats }> => {
        const response = await apiRequest('/users/stats');
        return response as { success: boolean; data: DashboardStats };
    },

    getById: async (id: number): Promise<{ success: boolean; data: User }> => {
        const response = await apiRequest(`/users/${id}`);
        return response as { success: boolean; data: User };
    },

    create: async (formData: FormData): Promise<{ success: boolean; data: User; message?: string }> => {
        const response = await apiRequest('/users', {
            method: 'POST',
            body: formData,
        });
        return response as { success: boolean; data: User; message?: string };
    },

    update: async (id: number, formData: FormData): Promise<{ success: boolean; data: User; message?: string }> => {
        const response = await apiRequest(`/users/${id}`, {
            method: 'PUT',
            body: formData,
        });
        return response as { success: boolean; data: User; message?: string };
    },

    delete: async (id: number): Promise<{ success: boolean; message?: string }> => {
        const response = await apiRequest(`/users/${id}`, {
            method: 'DELETE',
        });
        return response as { success: boolean; message?: string };
    },

    downloadDocument: (id: number, docType: string) => {
        const token = getToken();
        const url = `${API_BASE_URL}/users/${id}/download/${docType}`;

        // Create a temporary link and download
        const link = document.createElement('a');
        link.href = url;
        link.setAttribute('download', '');

        // We need to add auth header for protected route, so we'll use fetch
        fetch(url, {
            headers: {
                'Authorization': `Bearer ${token}`,
            },
        })
            .then(response => response.blob())
            .then(blob => {
                const blobUrl = URL.createObjectURL(blob);
                link.href = blobUrl;
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                URL.revokeObjectURL(blobUrl);
            });
    },
};

export default { authAPI, usersAPI };
