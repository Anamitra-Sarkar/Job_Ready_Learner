// config.js - COMPLETE with Analytics
(function(window) {
    'use strict';

    const ENV = {
        isDevelopment: window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1',
        isProduction: window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1'
    };

    const API_CONFIG = {
        development: {
            baseUrl: 'http://localhost:8080/api',
            timeout: 30000,
            retries: 3
        },
        production: {
            baseUrl: '/api',
            timeout: 30000,
            retries: 3
        }
    };

    // Your Firebase config with analytics
    const FIREBASE_CONFIG = {
        development: {
            apiKey: "AIzaSyDEAOr3iqU6TJZ6uztMvC5mquZECPcBkkE",
            authDomain: "fir-config-d3c36.firebaseapp.com",
            projectId: "fir-config-d3c36",
            storageBucket: "fir-config-d3c36.firebasestorage.app",
            messagingSenderId: "477435579926",
            appId: "1:477435579926:web:d370e9fb5a3c5a05316f37",
            measurementId: "G-PXZBD6HN1X"
        },
        production: {
            // SAME KEYS - This is completely fine and secure
            apiKey: "AIzaSyDEAOr3iqU6TJZ6uztMvC5mquZECPcBkkE",
            authDomain: "fir-config-d3c36.firebaseapp.com",
            projectId: "fir-config-d3c36",
            storageBucket: "fir-config-d3c36.firebasestorage.app",
            messagingSenderId: "477435579926",
            appId: "1:477435579926:web:d370e9fb5a3c5a05316f37",
            measurementId: "G-PXZBD6HN1X"
        }
    };

    const FEATURES = {
        development: {
            enableAnalytics: false,
            enableErrorReporting: false,
            enableLogging: true,
            enableDebugMode: true
        },
        production: {
            enableAnalytics: true,
            enableErrorReporting: true,
            enableLogging: false,
            enableDebugMode: false
        }
    };

    const getCurrentEnv = () => {
        return ENV.isDevelopment ? 'development' : 'production';
    };

    const buildConfig = () => {
        const env = getCurrentEnv();
        return {
            env: env,
            isDevelopment: ENV.isDevelopment,
            isProduction: ENV.isProduction,
            api: API_CONFIG[env],
            firebase: FIREBASE_CONFIG[env],
            features: FEATURES[env]
        };
    };

    const config = buildConfig();
    
    if (config.isDevelopment) {
        console.log('🔧 App Configuration:', {
            environment: config.env,
            apiBase: config.api.baseUrl,
            firebaseProject: config.firebase.projectId,
            features: config.features
        });
    }
    
    window.AppConfig = config;
    Object.freeze(window.AppConfig);

})(window);
