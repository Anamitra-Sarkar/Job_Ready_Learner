# 🚀 Quick Deployment Reference

## One-Command Deployment

### Backend (Render)
```bash
# 1. Sign up at render.com with GitHub
# 2. Create New Web Service → Select this repo → Uses render.yaml automatically
# 3. Copy the URL: https://YOUR-BACKEND.onrender.com
```

### Frontend (Vercel)
```bash
# 1. Update vercel.json with your backend URL
sed -i 's|YOUR_BACKEND_URL_HERE|YOUR-BACKEND|g' vercel.json

# 2. Commit and push
git add vercel.json
git commit -m "Configure production backend URL"
git push origin main

# 3. Vercel auto-deploys in ~2 minutes
```

## Verification Commands

```bash
# Test backend health
curl https://YOUR-BACKEND.onrender.com/api/health

# Test backend endpoints
./test-backend.sh https://YOUR-BACKEND.onrender.com

# Test frontend
curl https://job-ready-learner.vercel.app
```

## GitHub Actions Setup

```bash
# Add secret: BACKEND_URL
# Go to: Settings → Secrets → Actions → New repository secret
# Name: BACKEND_URL
# Value: https://YOUR-BACKEND.onrender.com
```

## Common Issues & Fixes

### Backend sleeping (Render free tier)
- First request takes 30-60 seconds
- GitHub Actions keeps it awake every 14 minutes
- Upgrade to paid tier for 24/7 uptime

### CORS errors
- Check allowed_origins in main.pl includes your domain
- Verify vercel.json proxy is configured
- Test with curl to see CORS headers

### 404 on /api calls
- Check vercel.json is deployed
- Verify backend URL is correct
- Test backend directly (bypass Vercel)

## Monitoring URLs

- **Frontend**: https://job-ready-learner.vercel.app
- **Backend**: https://YOUR-BACKEND.onrender.com/api/health
- **Render Dashboard**: https://dashboard.render.com
- **Vercel Dashboard**: https://vercel.com/dashboard
- **GitHub Actions**: https://github.com/YOUR-REPO/actions

## Quick Status Check

```bash
# One-liner to check everything
echo "Frontend:" && curl -sI https://job-ready-learner.vercel.app | head -1 && \
echo "Backend:" && curl -s https://YOUR-BACKEND.onrender.com/api/health | jq -r .status
```

## Emergency Rollback

```bash
# Render: Dashboard → Deployments → Previous deployment → Deploy
# Vercel: Dashboard → Deployments → Previous deployment → Redeploy
```

## Performance Targets

- Backend response time: <100ms (after wake-up)
- Frontend load time: <2s
- API success rate: >99.9%
- Uptime: >99.5% (free tier with keep-alive)

## Cost Estimate (Free Tier)

- Render: $0/month (sleeps after 15 min)
- Vercel: $0/month (100GB bandwidth, 100 build hours)
- GitHub Actions: $0/month (2,000 minutes included)
- **Total**: $0/month 🎉

## Upgrade Path

**When to upgrade:**
- Backend needs 24/7 uptime
- >100 concurrent users
- >1GB persistent data
- Custom domain needed

**Costs:**
- Render Starter: $7/month (always-on, 512MB RAM)
- Vercel Pro: $20/month (custom domains, analytics)
- Total: ~$27/month

## Support & Documentation

- Full Guide: [DEPLOYMENT.md](DEPLOYMENT.md)
- Repository: https://github.com/Anamitra-Sarkar/Job_Ready_Learner
- Issues: https://github.com/Anamitra-Sarkar/Job_Ready_Learner/issues
