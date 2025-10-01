# 🚀 Job Ready Platform - Production Ready

Complete personalized learning platform that makes students **JOB READY** for FREE!

## 🎯 Features

- **AI-Powered Learning Paths**: Prolog knowledge graph generates personalized paths
- **5 Career Tracks**: Frontend, Backend, Full Stack, DSA, DevOps
- **Gamification**: XP, Levels, Streaks, Achievements
- **Interactive UI**: React + Tailwind CSS with beautiful animations
- **Real Projects**: Practice with real-world project ideas
- **Self-Contained**: No external API dependencies
- **Production Ready**: Docker + Nginx deployment

## 🛠️ Tech Stack

### Backend
- **SWI-Prolog**: Knowledge reasoning engine
- **HTTP Server**: Built-in Prolog HTTP library
- **Docker**: Containerization

### Frontend
- **React 18**: UI framework (via CDN)
- **Tailwind CSS**: Styling (via CDN)
- **Chart.js**: Visualizations
- **Font Awesome**: Icons

### Infrastructure
- **Docker Compose**: Multi-container orchestration
- **Nginx**: Reverse proxy & load balancer

## 🚀 Quick Start

### Option 1: Direct Run (Development)

**Requirements:**
- SWI-Prolog 8.1+ installed
- Modern web browser

**Steps:**

1. Start Prolog backend:
```bash
swipl -s main.pl -g "start_server(8080)" -t halt
```

2. Open `index.html` in browser:
```bash
# Linux/Mac
open index.html

# Windows
start index.html

# Or use Python HTTP server
python3 -m http.server 3000
```

3. Access at `http://localhost:3000`

**Note**: If using file:// protocol, update API_BASE in index.html to your backend URL.

### Option 2: Docker (Production)

**Requirements:**
- Docker 20.10+
- Docker Compose 2.0+

**Steps:**

1. Build and run:
```bash
docker-compose up --build -d
```

2. Access at:
- Frontend: `http://localhost`
- Backend API: `http://localhost/api`

3. Check logs:
```bash
docker-compose logs -f
```

4. Stop:
```bash
docker-compose down
```

### Option 3: Docker Without Compose

```bash
# Build image
docker build -t jobready-platform .

# Run container
docker run -d -p 8080:8080 --name jobready jobready-platform

# Access
open http://localhost:8080/index.html
```

## 📁 Project Structure

```
job-ready-platform/
├── main.pl              # Prolog backend (knowledge engine)
├── index.html           # React frontend (complete app)
├── Dockerfile           # Docker configuration
├── docker-compose.yml   # Multi-container setup
├── nginx.conf           # Nginx configuration
└── README.md           # This file
```

## 🎮 How to Use

### 1. Choose Career Path
- Select from 5 career paths
- View estimated time and skills required

### 2. Start Learning
- Follow personalized learning path
- Skills unlock based on prerequisites
- Complete tutorials and exercises

### 3. Track Progress
- Monitor XP and level
- Maintain daily streaks
- View completion percentage

### 4. Build Projects
- Access beginner to advanced projects
- Practice with real-world applications
- Build portfolio

### 5. Get Job Ready!
- Complete all skills in your path
- Build 5+ projects
- You're ready for interviews! 🎉

## 🔧 Configuration

### Backend Port
Edit `main.pl`:
```prolog
:- initialization(start_server(8080)).  % Change 8080 to your port
```

### Frontend API URL
Edit `index.html`:
```javascript
const API_BASE = 'http://localhost:8080/api';  // Update if needed
```

### Docker Ports
Edit `docker-compose.yml`:
```yaml
ports:
  - "80:80"      # Frontend
  - "8080:8080"  # Backend
```

## 🌐 Production Deployment

### Deploy to Cloud

**AWS EC2 / DigitalOcean / Azure VM:**

1. SSH into server
2. Install Docker & Docker Compose
3. Clone/upload files
4. Run `docker-compose up -d`
5. Configure domain & SSL (Let's Encrypt)

**Docker Commands:**
```bash
# Update
git pull
docker-compose up --build -d

# Restart
docker-compose restart

# View logs
docker-compose logs -f

# Scale (if using load balancer)
docker-compose up -d --scale backend=3
```

### SSL Certificate (Let's Encrypt)

Add to `docker-compose.yml`:
```yaml
  certbot:
    image: certbot/certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"
```

Update `nginx.conf` for HTTPS.

## 📊 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/career-paths` | GET | Get all career paths |
| `/api/generate-path` | POST | Generate learning path |
| `/api/progress` | GET | Get user progress |
| `/api/update-progress` | POST | Mark topic complete |
| `/api/next-topic` | GET | Get next topic |
| `/api/get-projects` | GET | Get project ideas |
| `/api/skill-tree` | POST | Get skill tree with status |
| `/api/resources` | POST | Get learning resources |

## 🎨 Customization

### Add New Career Path

Edit `main.pl`:
```prolog
career_path(mobile_developer,
    [variables, data_types, ..., react_native, flutter],
    350).
```

### Add New Skills

```prolog
skill(flutter, mobile, intermediate, 20, 500).
prerequisite(react_basics, flutter).
```

### Add Resources

```prolog
resource(flutter, tutorial, 'Flutter builds native apps...', 'Code example').
resource(flutter, exercise, 'Build a todo app...', 'Instructions').
```

### Add Projects

```prolog
project(intermediate, 'Mobile Shopping App',
    [flutter, rest_api, state_management],
    'Build e-commerce mobile app',
    'Add cart, payment, push notifications').
```

## 🐛 Troubleshooting

### Backend not starting
```bash
# Check if SWI-Prolog is installed
swipl --version

# Check if port 8080 is available
lsof -i :8080  # Linux/Mac
netstat -ano | findstr :8080  # Windows

# View Docker logs
docker-compose logs backend
```

### Frontend can't connect to backend
- Check API_BASE URL in index.html
- Verify backend is running: `curl http://localhost:8080/api/career-paths`
- Check browser console for CORS errors
- Disable browser CORS (development only)

### Docker build fails
```bash
# Clean Docker cache
docker system prune -a

# Rebuild from scratch
docker-compose build --no-cache
```

## 📈 Performance Optimization

### Prolog Backend
- Enable tabling for memoization
- Use indexing for faster queries
- Increase stack limit in docker-compose.yml

### Frontend
- Enable service worker for offline support
- Add lazy loading for components
- Implement virtual scrolling for large lists
- Use React.memo for expensive components

### Infrastructure
- Add Redis for caching
- Use CDN for static assets
- Implement rate limiting
- Add database for persistent storage

## 🔒 Security

**Production Checklist:**
- [ ] Enable HTTPS with SSL certificate
- [ ] Add authentication & authorization
- [ ] Implement rate limiting
- [ ] Sanitize user inputs
- [ ] Add CSRF protection
- [ ] Enable security headers (Nginx)
- [ ] Regular security updates
- [ ] Backup strategy

## 📱 Mobile App

Convert to mobile app:

**React Native:**
- Reuse logic from index.html
- Native look & feel
- Push notifications

**PWA (Progressive Web App):**
- Add manifest.json
- Service worker for offline
- Installable on mobile
- Push notifications support

## 🤝 Contributing

Want to add more features?

1. Fork the repository
2. Create feature branch
3. Add skills/resources/projects to main.pl
4. Enhance UI in index.html
5. Submit pull request

## 📝 License

MIT License - Free for personal and commercial use

## 🌟 Features Roadmap

- [ ] User authentication & profiles
- [ ] Code editor integration
- [ ] AI code review
- [ ] Community forums
- [ ] Peer code review
- [ ] Job board integration
- [ ] Certificates on completion
- [ ] Mobile apps (iOS/Android)
- [ ] Multi-language support
- [ ] Video tutorials integration

## 💪 Built With Love

Making education accessible to everyone. **100% FREE. Forever.**

---

**Questions? Issues?**
Open an issue or contribute to make education better! 🚀

**Made with** ❤️ **using Prolog + React**
