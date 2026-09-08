import { createApp } from 'vue'
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'
import router from './router'
import './style.css'
import App from './App.vue'

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

const app = createApp(App)
app.use(pinia)
app.use(router)
app.mount('#app')

// Backward-compatible bridge: the current Login.vue still renders the old
// mailto forgot-password link. Intercept it and send users to the real flow.
document.addEventListener('click', (event) => {
  const link = event.target.closest('a[href="mailto:admin@mcfoption.com"]')
  if (!link) return
  event.preventDefault()
  router.push('/forgot-password')
})
