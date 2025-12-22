# 🚀 Deployment Guide - Job Ready Platform

This guide provides step-by-step instructions for deploying the Job Ready Platform to production.

## 📋 Overview

The Job Ready Platform consists of two parts:
1. **Frontend**: Static site deployed on Vercel
2. **Backend**: SWI-Prolog Docker service deployed on Render (or alternative)

## 🎯 Quick Deployment Summary

- **Frontend**: Already deployed at https://job-ready-learner.vercel.app
- **Backend**: Needs to be deployed to Render (or Fly.io/Railway)
- **Configuration**: Use `vercel.json` to proxy `/api` requests to backend

---

## 🔧 Prerequisites

- GitHub account (already set up)
- Vercel account (frontend already deployed)
- Render account (free tier available) - [Sign up](https://render.com)

---

## 📦 Backend Deployment on Render (Recommended)

### Step 1: Create Render Account

1. Go to [render.com](https://render.com)
2. Sign up with GitHub (recommended for automatic deploys)
3. Verify your email

### Step 2: Deploy Backend

**Option A: Using render.yaml (Recommended)**

1. Push this repository to GitHub (if not already done)
2. Go to Render Dashboard: https://dashboard.render.com
3. Click "New +" → "Blueprint"
4. Connect your GitHub repository: `Anamitra-Sarkar/Job_Ready_Learner`
5. Render will automatically detect `render.yaml`
6. Click "Apply" to create the service
7. Wait 5-10 minutes for deployment to complete
8. Copy the backend URL (e.g., `https://job-ready-backend-xxxx.onrender.com`)

**Option B: Manual Deployment**

1. Go to Render Dashboard: https://dashboard.render.com
2. Click "New +" → "Web Service"
3. Connect your GitHub repository: `Anamitra-Sarkar/Job_Ready_Learner`
4. Configure the service:
   - **Name**: `job-ready-backend`
   - **Region**: Oregon (or closest to you)
   - **Branch**: `main`
   - **Runtime**: Docker
   - **Dockerfile Path**: `./Dockerfile`
   - **Docker Build Context**: `.`
5. Add Environment Variables:
   ```
   PROLOG_STACK_LIMIT=4g
   LOG_LEVEL=info
   RATE_LIMIT_ENABLED=true
   MAX_REQUESTS_PER_MINUTE=60
   PORT=8080
   ```
6. Configure Health Check:
   - **Path**: `/api/health`
7. Add Disk (optional, for persistent data):
   - **Name**: `backend-data`
   - **Mount Path**: `/app/data`
   - **Size**: 1 GB (free tier)
8. Click "Create Web Service"
9. Wait 5-10 minutes for deployment
10. Copy the backend URL (e.g., `https://job-ready-backend-xxxx.onrender.com`)

### Step 3: Verify Backend Deployment

Test the health endpoint:

```bash
curl https://your-backend-url.onrender.com/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "job-ready-backend",
  "version": "2.0.0",
  "database": "connected",
  "features": ["videos", "exercises", "hints", "console", "progress-tracking"]
}
```

Test another endpoint:
```bash
curl https://your-backend-url.onrender.com/api/career-paths
```

---

## 🌐 Frontend Configuration on Vercel

### Step 1: Update vercel.json

1. Open `vercel.json` in the repository
2. Replace `YOUR_BACKEND_URL_HERE` with your Render backend URL:
   ```json
   {
     "rewrites": [
       {
         "source": "/api/:path*",
         "destination": "https://job-ready-backend-xxxx.onrender.com/api/:path*"
       }
     ]
   }
   ```
3. Save and commit the changes

### Step 2: Deploy to Vercel

**Option A: Automatic Deployment**

1. Push the changes to GitHub:
   ```bash
   git add vercel.json
   git commit -m "Configure backend URL for production"
   git push origin main
   ```
2. Vercel will automatically detect changes and redeploy
3. Wait 2-3 minutes for deployment

**Option B: Manual Deployment**

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Find your project: `job-ready-learner`
3. Click "Redeploy" on the latest deployment
4. Wait 2-3 minutes for deployment

### Step 3: Verify Frontend

1. Open https://job-ready-learner.vercel.app
2. Open browser console (F12)
3. Click on any feature that makes API calls
4. Check Network tab - all `/api/*` requests should succeed with 200 OK

Test specific endpoints in console:
```javascript
// Test health endpoint
fetch('/api/health').then(r => r.json()).then(console.log)

// Test career paths
fetch('/api/career-paths').then(r => r.json()).then(console.log)
```

---

## 🔒 Security Configuration

### Backend CORS Configuration

The backend is already configured to accept requests from:
- `http://localhost:3000` (development)
- `http://localhost:8080` (local Docker)
- `https://job-ready-learner.vercel.app` (production)

If you use a custom domain, add it to `main.pl`:
```prolog
:- assertz(config_setting(allowed_origins, [
    'http://localhost:3000', 
    'http://localhost:8080',
    'https://job-ready-learner.vercel.app',
    'https://your-custom-domain.com'
])).
```

### Frontend Security Headers

The `vercel.json` includes security headers:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`

---

## 🚨 Troubleshooting

### Backend Issues

**Backend won't start on Render**
- Check logs in Render Dashboard
- Verify Dockerfile builds locally: `docker build -t test .`
- Check environment variables are set correctly

**Health check failing**
- Verify `/api/health` endpoint responds
- Check PROLOG_STACK_LIMIT is set to 4g
- Increase health check timeout in Render settings

**Backend URL returns 502/503**
- Service might be starting (wait 2-3 minutes)
- Check Render logs for errors
- Verify port 8080 is exposed in Dockerfile

### Frontend Issues

**API calls return 404**
- Verify `vercel.json` has correct backend URL
- Check Vercel deployment logs
- Test backend URL directly in browser

**CORS errors in browser console**
- Verify backend `allowed_origins` includes Vercel URL
- Check backend CORS headers in Network tab
- Ensure URL matches exactly (with/without trailing slash)

**Frontend deployed but shows errors**
- Check Vercel deployment logs
- Verify `config.js` is deployed correctly
- Clear browser cache and reload

### Common Issues

**"Failed to fetch" errors**
- Backend might be sleeping (Render free tier)
- First request after sleep takes 30-60 seconds
- Consider keeping backend awake with a cron job

**Rate limiting errors**
- Backend limits 60 requests/minute per IP
- Reduce request frequency or increase limit in backend
- Check Render logs for rate limit messages

---

## 📊 Monitoring & Maintenance

### Health Checks

**Automated Health Check Script** (Optional)

Create a GitHub Action or cron job to ping the backend every 14 minutes (keeps Render free tier awake):

```yaml
# .github/workflows/keep-alive.yml
name: Keep Backend Alive
on:
  schedule:
    - cron: '*/14 * * * *'  # Every 14 minutes
  workflow_dispatch:

jobs:
  ping:
    runs-on: ubuntu-latest
    steps:
      - name: Ping Backend
        run: |
          curl -f https://your-backend-url.onrender.com/api/health || exit 1
```

### Logs

**View Backend Logs:**
- Render Dashboard → Service → Logs tab
- Shows all SWI-Prolog output and errors

**View Frontend Logs:**
- Vercel Dashboard → Deployments → Click deployment → Function Logs
- Shows deployment and runtime logs

### Monitoring

**Backend Metrics (Render):**
- CPU usage
- Memory usage
- Request count
- Response times

**Frontend Metrics (Vercel):**
- Deployment frequency
- Build times
- Bandwidth usage
- Edge requests

---

## 🔄 Alternative Deployment Options

### Fly.io Deployment

1. Install Fly.io CLI: `curl -L https://fly.io/install.sh | sh`
2. Login: `fly auth login`
3. Create app: `fly launch --dockerfile Dockerfile`
4. Deploy: `fly deploy`
5. Get URL: `fly status`

### Railway Deployment

1. Go to [railway.app](https://railway.app)
2. Click "New Project" → "Deploy from GitHub repo"
3. Select `Job_Ready_Learner` repository
4. Railway auto-detects Dockerfile
5. Add environment variables
6. Deploy and get URL

### DigitalOcean App Platform

1. Go to [DigitalOcean](https://cloud.digitalocean.com)
2. Create → Apps → GitHub repository
3. Select `Job_Ready_Learner`
4. Configure as Docker container
5. Add environment variables
6. Deploy and get URL

---

## ✅ Post-Deployment Checklist

- [ ] Backend deployed and accessible via HTTPS
- [ ] Backend health endpoint returns 200 OK
- [ ] Backend CORS allows Vercel origin
- [ ] `vercel.json` updated with correct backend URL
- [ ] Frontend redeployed to Vercel
- [ ] Frontend loads without errors
- [ ] API calls succeed (check browser console)
- [ ] Test user signup and login
- [ ] Test career path generation
- [ ] Test progress tracking
- [ ] Test video lessons
- [ ] Test exercises
- [ ] Set up monitoring/health checks
- [ ] Document backend URL for team
- [ ] Update README with production URLs

---

## 🎉 Success Criteria

Your deployment is successful when:

1. ✅ Frontend loads at https://job-ready-learner.vercel.app
2. ✅ Backend responds at https://your-backend.onrender.com/api/health
3. ✅ Browser console shows no CORS errors
4. ✅ API calls succeed (Network tab shows 200 OK)
5. ✅ Users can sign up and log in
6. ✅ Learning paths generate correctly
7. ✅ Progress saves and persists

---

## 📞 Support

If you encounter issues:

1. **Check logs** (Render + Vercel dashboards)
2. **Review this guide** for missed steps
3. **Test endpoints** directly with curl
4. **Check CORS** configuration
5. **Open an issue** on GitHub with logs

---

## 🚀 Next Steps

After successful deployment:

1. **Set up custom domain** (optional)
2. **Configure SSL certificate** (automatic on Vercel/Render)
3. **Enable analytics** (Firebase already configured)
4. **Set up error monitoring** (Sentry, etc.)
5. **Configure backups** (automatic on Render with disk)
6. **Monitor performance** (Render + Vercel dashboards)

---

## 📝 Notes

- **Render Free Tier**: Backend sleeps after 15 minutes of inactivity
- **First request**: May take 30-60 seconds to wake up
- **Keep-alive**: Consider using a cron job to prevent sleep
- **Scaling**: Upgrade to paid tier for 24/7 uptime
- **Database**: Persistent disk on Render stores user data
- **Backups**: Download data from Render dashboard regularly

---

**Made with ❤️ for learners worldwide**

*Help students become **JOB READY***
