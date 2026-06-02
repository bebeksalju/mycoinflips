<script setup>
import { onMounted, ref } from 'vue';

const container = ref(null);

onMounted(() => {
  try {
    const script = document.createElement('script');
    script.src = 'https://s3.tradingview.com/external-embedding/embed-widget-ticker-tape.js';
    script.async = true;
    script.innerHTML = JSON.stringify({
      "symbols": [
        { "proName": "BINANCE:BTCUSDT", "title": "Bitcoin" },
        { "proName": "BINANCE:ETHUSDT", "title": "Ethereum" },
        { "proName": "BINANCE:BNBUSDT", "title": "BNB" },
        { "proName": "BINANCE:SOLUSDT", "title": "Solana" },
        { "proName": "BINANCE:XRPUSDT", "title": "XRP" }
      ],
      "showSymbolLogo": true,
      "colorTheme": "dark",
      "isTransparent": false, 
      "displayMode": "adaptive",
      "locale": "en"
    });
    
    // Add event listener to silently catch load errors if adblocker blocks it
    script.onerror = (e) => {
        console.warn('TVTickerWidget script blocked by client (likely adblocker). Skipping load.');
    };
    
    container.value.appendChild(script);
  } catch (e) {
    console.warn('Failed to load TVTickerWidget', e);
  }
});
</script>

<template>
  <div class="tradingview-widget-container w-full h-12 border-b border-gray-800 bg-gray-900">
    <div ref="container" class="tradingview-widget-container__widget"></div>
  </div>
</template>