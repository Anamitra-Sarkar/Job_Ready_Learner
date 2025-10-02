# 🚀 Job Ready Platform

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/Anamitra-Sarkar/Job_Ready_Learner)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/Anamitra-Sarkar/Job_Ready_Learner/pulls)

AI-powered personalized learning platform using Prolog knowledge graphs to create adaptive learning paths. Help students become **JOB READY** through intelligent skill progression and real-world projects.

<div align="center">
  <img src="https://img.shields.io/badge/Prolog-SWI--Prolog-red?style=for-the-badge&logo=prolog" />
  <img src="https://img.shields.io/badge/React-18-blue?style=for-the-badge&logo=react" />
  <img src="https://img.shields.io/badge/Firebase-Auth-orange?style=for-the-badge&logo=firebase" />
  <img src="https://img.shields.io/badge/Docker-Ready-blue?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/Nginx-Production-green?style=for-the-badge&logo=nginx" />
</div>

---

## ✨ Features

- 🧠 **AI-Powered Learning Paths** - Prolog knowledge graphs generate personalized skill progression
- 🎯 **5 Career Tracks** - Frontend, Backend, Full Stack, DSA, DevOps
- 🔐 **Firebase Authentication** - Secure user management with persistent sessions
- 📊 **Progress Tracking** - XP, streaks, levels, and achievements
- 🎨 **Dark/Light Theme** - Persistent theme preferences
- 💾 **Data Persistence** - SQLite-based storage with automatic backups
- 🐳 **Docker Ready** - One-command deployment
- 🔒 **Production Security** - Rate limiting, input validation, HTTPS ready
- 📱 **Mobile Responsive** - Works seamlessly on all devices
- 🚦 **Health Monitoring** - Built-in health checks and logging

---

## 🛠️ Tech Stack

### Backend
- **SWI-Prolog** - Knowledge reasoning engine
- **HTTP Server** - Built-in thread_httpd
- **Persistency** - library(persistency) for data storage
- **CORS** - Cross-origin resource sharing
- **Rate Limiting** - 60 requests/minute per IP

### Frontend
- **React 18** - Modern UI library (CDN)
- **TailwindCSS** - Utility-first styling
- **Firebase Auth** - User authentication
- **Chart.js** - Data visualization
- **Font Awesome** - Icons

### DevOps
- **Docker & Docker Compose** - Containerization
- **Nginx** - Reverse proxy with SSL
- **Automated Backups** - Daily with 30-day retention
- **Health Checks** - Service monitoring
- **Logging** - Structured logs with rotation

---

## 📦 Installation

### Prerequisites

- **SWI-Prolog** 9.0.4+ ([Download](https://www.swi-prolog.org/download/stable))
- **Python 3** ([Download](https://www.python.org/downloads/))
- **Docker & Docker Compose** (optional, [Install](https://docs.docker.com/get-docker/))

### Quick Start

#### Option 1: Local Development

**Linux/Mac:**

git clone https://github.com/Anamitra-Sarkar/Job_Ready_Learner.git
cd Job_Ready_Learner
chmod +x start.sh
./start.sh


**Windows:**

git clone https://github.com/Anamitra-Sarkar/Job_Ready_Learner.git
cd Job_Ready_Learner
start.bat


**Access:** http://localhost:3000

#### Option 2: Docker Deployment

git clone https://github.com/Anamitra-Sarkar/Job_Ready_Learner.git
cd Job_Ready_Learner
chmod +x docker-start.sh
./docker-start.sh


**Access:** http://localhost

---

## 📁 Project Structure

Job_Ready_Learner/
├── 📄 main.pl # Prolog backend (knowledge engine)
├── 📄 index.html # React frontend (single-page app)
├── 📄 config.js # Configuration management
├── 📄 nginx.conf # Nginx reverse proxy config
├── 📄 Dockerfile # Backend container
├── 📄 docker-compose.yml # Multi-container orchestration
├── 📄 .env.example # Environment variables template
├── 📄 .gitignore # Git ignore rules
│
├── 🔧 Scripts
│ ├── start.sh # Local start (Linux/Mac)
│ ├── start.bat # Local start (Windows)
│ ├── docker-start.sh # Docker deployment
│ ├── backup.sh # Automated backup
│ └── restore.sh # Restore from backup
│
├── 📂 data/ # User data & database
├── 📂 logs/ # Application logs
├── 📂 backups/ # Automated backups
├── 📂 ssl/ # SSL certificates
│
└── 📚 README.md # This file


---

## 🔧 Configuration

### Environment Variables

Create a `.env` file from `.env.example`:

cp .env.example .env


**Key Configuration:**

Backend
BACKEND_PORT=8080
PROLOG_STACK_LIMIT=4g
LOG_LEVEL=info

CORS (Update for production)
ALLOWED_ORIGINS=https://yourdomain.com

Rate Limiting
RATE_LIMIT_ENABLED=true
MAX_REQUESTS_PER_MINUTE=60

Firebase (Get from Firebase Console)
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id

SSL (Production)
SSL_ENABLED=true
SSL_CERTIFICATE_PATH=/etc/ssl/certs/your-cert.pem
SSL_CERTIFICATE_KEY_PATH=/etc/ssl/private/your-key.pem

Backups
BACKUP_ENABLED=true
BACKUP_RETENTION_DAYS=30


### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing)
3. Enable **Authentication** → Email/Password
4. Get your config from **Project Settings** → **General**
5. Update `config.js` with your Firebase keys

**Important:** Firebase keys are PUBLIC and safe in frontend code. Security is handled by Firebase Security Rules.

---

## 🔐 Security Features

### Backend Security
✅ **Rate Limiting** - 60 requests/min per IP per endpoint  
✅ **Input Validation** - Sanitization of all user inputs  
✅ **CORS Configuration** - Restrict allowed origins  
✅ **Non-root User** - Docker runs as `appuser`  
✅ **Error Handling** - Comprehensive error catching  

### Frontend Security
✅ **Firebase Auth** - Industry-standard authentication  
✅ **HTTPS Ready** - SSL/TLS 1.2+ support  
✅ **CSP Headers** - Content Security Policy  
✅ **XSS Protection** - Security headers enabled  

### Production Checklist

Before deploying to production:

- [ ] Update `ALLOWED_ORIGINS` in `.env`
- [ ] Set up SSL certificates (Let's Encrypt recommended)
- [ ] Change Firebase to production project
- [ ] Enable HTTPS in `nginx.conf`
- [ ] Set strong admin passwords
- [ ] Configure automated backups
- [ ] Enable monitoring (Prometheus/Grafana)
- [ ] Review Firebase Security Rules
- [ ] Test rate limiting
- [ ] Enable error reporting (Sentry)

---

## 📊 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check |
| `/api/career-paths` | GET | Get all career paths |
| `/api/generate-path` | POST | Generate personalized learning path |
| `/api/progress` | GET | Get user progress |
| `/api/update-progress` | POST | Update topic completion |
| `/api/resources` | POST | Get learning resources |
| `/api/get-projects` | GET | Get practice projects |
| `/api/skill-tree` | POST | Get skill tree with status |

### Example Request

Get career paths
curl http://localhost:8080/api/career-paths

Generate learning path
curl -X POST http://localhost:8080/api/generate-path
-H "Content-Type: application/json"
-d '{"userId": "user123", "careerPath": "frontend_developer"}'


---

## 💾 Backup & Restore

### Automated Backups

Backups run daily at 2 AM (configurable):

Manual backup
./backup.sh

Schedule with cron
crontab -e
0 2 * * * /path/to/Job_Ready_Learner/backup.sh


### Restore from Backup

./restore.sh

Select backup from list
Confirm restoration


### Docker Volume Backup

docker run --rm
-v backend-data:/data
-v $(pwd)/backups:/backup
alpine tar czf /backup/volume-backup.tar.gz /data


---

## 📋 Usage

### For Students

1. **Sign up** with email and password
2. **Choose a career path** (Frontend, Backend, Full Stack, DSA, DevOps)
3. **Start learning** - Skills unlock as prerequisites are completed
4. **Earn XP and streaks** - Gamified learning experience
5. **Build projects** - Apply skills with real-world projects
6. **Track progress** - Monitor your learning journey

### Career Paths

| Path | Skills | Hours | Best For |
|------|--------|-------|----------|
| **Frontend Developer** | HTML, CSS, JS, React, Git | 300 | UI/UX enthusiasts |
| **Backend Developer** | Node.js, Express, DB, Auth | 350 | Server-side lovers |
| **Full Stack Developer** | Frontend + Backend | 400 | Versatile developers |
| **DSA Expert** | Data Structures, Algorithms | 450 | FAANG preparation |
| **DevOps Engineer** | Docker, K8s, CI/CD | 300 | Infrastructure pros |

---

## 🐛 Troubleshooting

### Backend won't start

Check if port 8080 is free
lsof -i:8080

Kill process if needed
kill -9 <PID>

Check logs
tail -f logs/backend.log


### Frontend not loading

Check if port 3000 is free
lsof -i:3000

Kill process if needed
kill -9 <PID>


### Docker issues

View logs
docker-compose logs -f

Restart containers
docker-compose restart

Clean rebuild
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d


### Permission denied (Linux/Mac)

Make scripts executable
chmod +x start.sh docker-start.sh backup.sh restore.sh


---

## 📈 Performance

- **Backend Response Time:** < 50ms
- **Concurrent Users:** 100+ simultaneous
- **Data Storage:** ~1KB per user
- **Memory Usage:** ~200MB backend, ~50MB frontend
- **Startup Time:** ~5 seconds local, ~30 seconds Docker

---

## 🤝 Contributing

We welcome contributions! Here's how:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow existing code style
- Add tests for new features
- Update documentation
- Keep commits atomic and descriptive

---

## 🧪 Testing

Test backend health
curl http://localhost:8080/api/health

Test career paths endpoint
curl http://localhost:8080/api/career-paths

Load test (install apache2-utils)
ab -n 1000 -c 10 http://localhost:8080/api/career-paths


---

## 📄 License

This project is licensed under the **Apache License 2.0** - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Anamitra Sarkar**

- GitHub: [@Anamitra-Sarkar](https://github.com/Anamitra-Sarkar)
- Repository: [Job_Ready_Learner](https://github.com/Anamitra-Sarkar/Job_Ready_Learner)

---

## 🙏 Acknowledgments

- **SWI-Prolog Community** - For the powerful logic programming engine
- **React Team** - For the amazing UI library
- **Firebase Team** - For authentication services
- **TailwindCSS Team** - For utility-first CSS
- **Open Source Community** - For inspiration and support

---

## 🌟 Star History

If this project helped you, please ⭐ star the repository!

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/Anamitra-Sarkar/Job_Ready_Learner/issues)
- **Discussions:** [GitHub Discussions](https://github.com/Anamitra-Sarkar/Job_Ready_Learner/discussions)
- **Email:** Contact via GitHub profile

---

## 🎯 Roadmap

- [ ] Add more career paths (Mobile, ML, Cloud)
- [ ] Implement code playground
- [ ] Add peer-to-peer learning
- [ ] Create mobile app
- [ ] Add certification system
- [ ] Integrate with job platforms
- [ ] Multi-language support
- [ ] AI-powered code review

---

## 📊 Stats

![GitHub stars](https://img.shields.io/github/stars/Anamitra-Sarkar/Job_Ready_Learner?style=social)
![GitHub forks](https://img.shields.io/github/forks/Anamitra-Sarkar/Job_Ready_Learner?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/Anamitra-Sarkar/Job_Ready_Learner?style=social)

---

<div align="center">
  <h3>Made with ❤️ for learners worldwide</h3>
  <p>Help students become <strong>JOB READY</strong></p>
</div>
