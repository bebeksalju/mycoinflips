import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Dashboard from '../views/Dashboard.vue'
import HomePage from '../views/HomePage.vue'
import LandingPage from '../views/LandingPage.vue'

import UserProfile from '../views/UserProfile.vue'
import Settings from '../views/Settings.vue'
import Deposit from '../views/Deposit.vue'
import Withdrawal from '../views/Withdrawal.vue'
import KYC from '../views/KYC.vue'
import Banned from '../views/Banned.vue'
import { useAuthStore } from '../stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login
    },
    {
      path: '/forgot-password',
      name: 'forgot-password',
      component: () => import('../views/ForgotPassword.vue')
    },
    {
      path: '/reset-password',
      name: 'reset-password',
      component: () => import('../views/ResetPassword.vue')
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('../views/Register.vue')
    },
    {
      path: '/',
      name: 'landing',
      component: LandingPage
    },
    {
      path: '/banned',
      name: 'banned',
      component: Banned
    },
    {
      path: '/home',
      name: 'home',
      component: HomePage,
      meta: { requiresAuth: true }
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: Dashboard,
      meta: { requiresAuth: true }
    },
    {
      path: '/profile',
      name: 'profile',
      component: UserProfile,
      meta: { requiresAuth: true }
    },
    {
      path: '/settings',
      name: 'settings',
      component: Settings,
      meta: { requiresAuth: true }
    },
    {
      path: '/deposit',
      name: 'deposit',
      component: Deposit,
      meta: { requiresAuth: true }
    },
    {
      path: '/chat',
      name: 'chat',
      component: () => import('../views/ChatPage.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/withdrawal',
      name: 'withdrawal',
      component: Withdrawal,
      meta: { requiresAuth: true }
    },
    {
      path: '/kyc',
      name: 'kyc',
      component: KYC,
      meta: { requiresAuth: true }
    },
    {
      path: '/wallet',
      name: 'wallet',
      component: () => import('../views/Wallet.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/admin/login',
      name: 'admin-login',
      component: () => import('../views/admin/AdminLogin.vue')
    },
    {
      path: '/admin',
      component: () => import('../layouts/AdminLayout.vue'),
      meta: { requiresAdmin: true },
      children: [
        {
          path: '',
          redirect: '/admin/dashboard'
        },
        {
          path: 'dashboard',
          name: 'admin-dashboard',
          component: () => import('../views/admin/AdminDashboard.vue')
        },
        {
          path: 'finance',
          name: 'admin-finance',
          component: () => import('../views/admin/AdminFinance.vue')
        },
        {
          path: 'settings',
          name: 'admin-settings',
          component: () => import('../views/admin/AdminSettings.vue')
        },
        {
          path: 'profile',
          name: 'admin-profile',
          component: () => import('../views/admin/AdminProfile.vue')
        },
        {
          path: 'users',
          name: 'admin-users',
          component: () => import('../views/admin/AdminUsers.vue')
        },
        {
          path: 'kyc',
          name: 'admin-kyc',
          component: () => import('../views/admin/AdminKYC.vue')
        },
        {
          path: 'admins',
          name: 'admin-admins',
          component: () => import('../views/admin/AdminAdmins.vue')
        },
        {
          path: 'logs',
          name: 'admin-logs',
          component: () => import('../views/admin/AdminLogs.vue')
        },
        {
          path: 'user-activity',
          name: 'admin-user-activity',
          component: () => import('../views/admin/AdminUserActivity.vue')
        },
        {
          path: 'email',
          name: 'admin-email',
          component: () => import('../views/admin/AdminEmail.vue')
        },
        {
          path: 'wallet',
          name: 'admin-wallet',
          component: () => import('../views/admin/AdminWallet.vue'),
          meta: { requiresSuperuser: true }
        },
        {
          path: 'chat',
          name: 'admin-chat',
          component: () => import('../views/admin/AdminChat.vue'),
          meta: { requiresSuperuser: true }
        }
      ]
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/'
    }
  ]
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore();

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login');
  }
  else if (to.meta.requiresAdmin || to.meta.requiresSuperuser) {
    if (!authStore.isAuthenticated) {
      next('/admin/login');
    } else if (!authStore.user.isAdmin) {
      next('/dashboard');
    } else if (to.meta.requiresSuperuser && authStore.user.role !== 'SUPERUSER') {
      next('/admin/dashboard');
    } else {
      next();
    }
  }
  else {
    next();
  }
});

export default router
