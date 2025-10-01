
# File 2: Complete Frontend (index.html)
frontend_html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Job Ready Platform - Learn Code, Get Hired</title>
    
    <!-- React and ReactDOM from CDN -->
    <script crossorigin src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Chart.js for visualizations -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
        
        * {
            font-family: 'Inter', sans-serif;
        }
        
        body {
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .glass {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .skill-card {
            transition: all 0.3s ease;
        }
        
        .skill-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        
        .skill-locked {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .skill-completed {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }
        
        .skill-available {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            cursor: pointer;
        }
        
        .pulse {
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        .confetti {
            position: fixed;
            width: 10px;
            height: 10px;
            background: #f0f;
            position: absolute;
            animation: confetti-fall 3s linear infinite;
        }
        
        @keyframes confetti-fall {
            to {
                transform: translateY(100vh) rotate(360deg);
                opacity: 0;
            }
        }
        
        .progress-ring {
            transform: rotate(-90deg);
        }
        
        .progress-ring-circle {
            transition: stroke-dashoffset 0.5s ease;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.7);
        }
        
        .modal.active {
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .badge {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .badge-beginner { background: #4ade80; color: white; }
        .badge-intermediate { background: #fbbf24; color: white; }
        .badge-advanced { background: #f87171; color: white; }
        
        .streak-flame {
            animation: flame 1s infinite alternate;
        }
        
        @keyframes flame {
            0% { transform: scale(1); }
            100% { transform: scale(1.1); }
        }
        
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 16px 24px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            z-index: 2000;
            animation: slideIn 0.3s ease;
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        .skill-tree-node {
            position: relative;
        }
        
        .skill-tree-node::before {
            content: '';
            position: absolute;
            width: 2px;
            height: 30px;
            background: rgba(255,255,255,0.3);
            top: -30px;
            left: 50%;
        }
    </style>
</head>
<body>
    <div id="root"></div>

    <script type="text/babel">
        const { useState, useEffect, useRef } = React;
        
        // API Configuration
        const API_BASE = 'http://localhost:8080/api';
        
        // Main App Component
        function App() {
            const [screen, setScreen] = useState('welcome'); // welcome, dashboard, learning
            const [userId, setUserId] = useState('');
            const [careerPaths, setCareerPaths] = useState([]);
            const [selectedPath, setSelectedPath] = useState(null);
            const [learningPath, setLearningPath] = useState([]);
            const [progress, setProgress] = useState(null);
            const [currentTopic, setCurrentTopic] = useState(null);
            const [showModal, setShowModal] = useState(false);
            const [resources, setResources] = useState([]);
            const [projects, setProjects] = useState([]);
            const [notification, setNotification] = useState(null);
            const [xp, setXp] = useState(0);
            const [streak, setStreak] = useState(0);
            const [level, setLevel] = useState(1);
            
            // Load career paths on mount
            useEffect(() => {
                fetchCareerPaths();
            }, []);
            
            // Calculate level from XP
            useEffect(() => {
                setLevel(Math.floor(xp / 1000) + 1);
            }, [xp]);
            
            // Fetch career paths
            const fetchCareerPaths = async () => {
                try {
                    const response = await fetch(`${API_BASE}/career-paths`);
                    const data = await response.json();
                    if (data.success) {
                        setCareerPaths(data.paths);
                    }
                } catch (error) {
                    console.error('Error fetching career paths:', error);
                }
            };
            
            // Generate learning path
            const generatePath = async (pathId) => {
                const newUserId = 'user_' + Date.now();
                setUserId(newUserId);
                
                try {
                    const response = await fetch(`${API_BASE}/generate-path`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ userId: newUserId, careerPath: pathId })
                    });
                    const data = await response.json();
                    
                    if (data.success) {
                        setLearningPath(data.path);
                        setSelectedPath(pathId);
                        setScreen('dashboard');
                        showNotification('🚀 Your personalized learning path is ready!', 'success');
                        fetchProgress(newUserId);
                    }
                } catch (error) {
                    console.error('Error generating path:', error);
                    showNotification('❌ Error generating path. Make sure backend is running!', 'error');
                }
            };
            
            // Fetch progress
            const fetchProgress = async (uid = userId) => {
                try {
                    const response = await fetch(`${API_BASE}/progress?userId=${uid}`);
                    const data = await response.json();
                    
                    if (data.success) {
                        setProgress(data);
                        setXp(data.xp || 0);
                        setStreak(data.streak || 0);
                    }
                } catch (error) {
                    console.error('Error fetching progress:', error);
                }
            };
            
            // Start learning a topic
            const startLearning = async (topic) => {
                try {
                    const response = await fetch(`${API_BASE}/resources`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ topic: topic.name })
                    });
                    const data = await response.json();
                    
                    if (data.success) {
                        setCurrentTopic(topic);
                        setResources(data.resources);
                        setScreen('learning');
                    }
                } catch (error) {
                    console.error('Error fetching resources:', error);
                }
            };
            
            // Mark topic as complete
            const completeTopic = async () => {
                try {
                    const response = await fetch(`${API_BASE}/update-progress`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ userId, topic: currentTopic.name })
                    });
                    const data = await response.json();
                    
                    if (data.success) {
                        setXp(data.xp);
                        setStreak(data.streak);
                        showNotification(`🎉 +${data.xpGained} XP! ${data.streak} day streak!`, 'success');
                        triggerConfetti();
                        setScreen('dashboard');
                        fetchProgress();
                    }
                } catch (error) {
                    console.error('Error updating progress:', error);
                }
            };
            
            // Show notification
            const showNotification = (message, type) => {
                setNotification({ message, type });
                setTimeout(() => setNotification(null), 4000);
            };
            
            // Trigger confetti animation
            const triggerConfetti = () => {
                for (let i = 0; i < 50; i++) {
                    setTimeout(() => {
                        const confetti = document.createElement('div');
                        confetti.className = 'confetti';
                        confetti.style.left = Math.random() * 100 + '%';
                        confetti.style.background = ['#ff0', '#f0f', '#0ff', '#f00', '#0f0', '#00f'][Math.floor(Math.random() * 6)];
                        confetti.style.animationDelay = Math.random() * 2 + 's';
                        document.body.appendChild(confetti);
                        setTimeout(() => confetti.remove(), 3000);
                    }, i * 30);
                }
            };
            
            // Fetch projects
            const fetchProjects = async (level) => {
                try {
                    const response = await fetch(`${API_BASE}/get-projects?level=${level}`);
                    const data = await response.json();
                    if (data.success) {
                        setProjects(data.projects);
                        setShowModal(true);
                    }
                } catch (error) {
                    console.error('Error fetching projects:', error);
                }
            };
            
            // Render based on screen
            return (
                <div className="min-h-screen">
                    {notification && (
                        <div className={`notification ${notification.type === 'success' ? 'bg-green-500' : 'bg-red-500'} text-white`}>
                            {notification.message}
                        </div>
                    )}
                    
                    {screen === 'welcome' && (
                        <WelcomeScreen careerPaths={careerPaths} onSelectPath={generatePath} />
                    )}
                    
                    {screen === 'dashboard' && (
                        <Dashboard 
                            learningPath={learningPath}
                            progress={progress}
                            xp={xp}
                            streak={streak}
                            level={level}
                            selectedPath={selectedPath}
                            onStartLearning={startLearning}
                            onViewProjects={fetchProjects}
                        />
                    )}
                    
                    {screen === 'learning' && (
                        <LearningScreen 
                            topic={currentTopic}
                            resources={resources}
                            onComplete={completeTopic}
                            onBack={() => setScreen('dashboard')}
                        />
                    )}
                    
                    {showModal && (
                        <ProjectModal 
                            projects={projects}
                            onClose={() => setShowModal(false)}
                        />
                    )}
                </div>
            );
        }
        
        // Welcome Screen Component
        function WelcomeScreen({ careerPaths, onSelectPath }) {
            return (
                <div className="min-h-screen flex items-center justify-center p-8">
                    <div className="glass rounded-3xl p-12 max-w-6xl w-full text-white">
                        <div className="text-center mb-12">
                            <h1 className="text-6xl font-bold mb-4">
                                <i className="fas fa-rocket mr-4"></i>
                                Job Ready Platform
                            </h1>
                            <p className="text-2xl opacity-90">
                                Learn to code. Build projects. Get hired. <span className="font-bold">100% FREE</span>
                            </p>
                            <p className="text-lg mt-4 opacity-75">
                                Powered by AI Knowledge Graphs • Personalized Learning Paths • Real Projects
                            </p>
                        </div>
                        
                        <h2 className="text-3xl font-bold mb-6 text-center">Choose Your Career Path</h2>
                        
                        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {careerPaths.map((path, index) => (
                                <div 
                                    key={index}
                                    onClick={() => onSelectPath(path.id)}
                                    className="skill-card glass rounded-xl p-6 cursor-pointer hover:scale-105"
                                >
                                    <div className="text-center">
                                        <i className={`fas ${getPathIcon(path.id)} text-5xl mb-4`}></i>
                                        <h3 className="text-xl font-bold mb-2">{path.name}</h3>
                                        <div className="space-y-2 text-sm opacity-90">
                                            <p><i className="fas fa-book mr-2"></i>{path.totalSkills} Skills</p>
                                            <p><i className="fas fa-clock mr-2"></i>{path.estimatedHours} Hours</p>
                                        </div>
                                        <button className="mt-4 bg-white text-purple-600 px-6 py-2 rounded-full font-semibold hover:bg-opacity-90">
                                            Start Journey
                                        </button>
                                    </div>
                                </div>
                            ))}
                        </div>
                        
                        <div className="mt-12 grid md:grid-cols-3 gap-6 text-center">
                            <div>
                                <i className="fas fa-brain text-4xl mb-2"></i>
                                <h3 className="font-bold">AI-Powered</h3>
                                <p className="text-sm opacity-75">Knowledge graph reasoning</p>
                            </div>
                            <div>
                                <i className="fas fa-project-diagram text-4xl mb-2"></i>
                                <h3 className="font-bold">Real Projects</h3>
                                <p className="text-sm opacity-75">Build portfolio-worthy apps</p>
                            </div>
                            <div>
                                <i className="fas fa-trophy text-4xl mb-2"></i>
                                <h3 className="font-bold">Gamified</h3>
                                <p className="text-sm opacity-75">XP, streaks, achievements</p>
                            </div>
                        </div>
                    </div>
                </div>
            );
        }
        
        // Dashboard Component
        function Dashboard({ learningPath, progress, xp, streak, level, selectedPath, onStartLearning, onViewProjects }) {
            return (
                <div className="min-h-screen p-8">
                    {/* Header */}
                    <div className="glass rounded-2xl p-6 mb-8 text-white">
                        <div className="flex justify-between items-center flex-wrap gap-4">
                            <div>
                                <h1 className="text-3xl font-bold">
                                    <i className="fas fa-graduation-cap mr-2"></i>
                                    Your Learning Dashboard
                                </h1>
                                <p className="opacity-75 mt-1">{selectedPath?.replace(/_/g, ' ').toUpperCase()}</p>
                            </div>
                            
                            <div className="flex gap-6">
                                <div className="text-center">
                                    <div className="text-3xl font-bold streak-flame">
                                        <i className="fas fa-fire text-orange-400"></i> {streak}
                                    </div>
                                    <div className="text-sm opacity-75">Day Streak</div>
                                </div>
                                
                                <div className="text-center">
                                    <div className="text-3xl font-bold">
                                        <i className="fas fa-star text-yellow-300"></i> {xp}
                                    </div>
                                    <div className="text-sm opacity-75">Total XP</div>
                                </div>
                                
                                <div className="text-center">
                                    <div className="text-3xl font-bold">
                                        <i className="fas fa-level-up-alt text-green-400"></i> {level}
                                    </div>
                                    <div className="text-sm opacity-75">Level</div>
                                </div>
                            </div>
                        </div>
                        
                        {/* Progress Bar */}
                        {progress && (
                            <div className="mt-6">
                                <div className="flex justify-between mb-2">
                                    <span>Overall Progress</span>
                                    <span className="font-bold">{progress.completed}/{progress.totalSkills} skills</span>
                                </div>
                                <div className="w-full bg-white bg-opacity-20 rounded-full h-4">
                                    <div 
                                        className="bg-gradient-to-r from-green-400 to-blue-500 h-4 rounded-full transition-all duration-500"
                                        style={{ width: `${progress.progress}%` }}
                                    ></div>
                                </div>
                                <div className="text-right mt-1 font-bold">{Math.round(progress.progress)}%</div>
                            </div>
                        )}
                    </div>
                    
                    {/* Skills Grid */}
                    <div className="grid md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                        {learningPath.map((skill, index) => {
                            const isCompleted = progress?.completedSkills?.includes(skill.name);
                            const isAvailable = !isCompleted && (index === 0 || progress?.completedSkills?.includes(learningPath[index-1]?.name));
                            const isLocked = !isCompleted && !isAvailable;
                            
                            return (
                                <div 
                                    key={index}
                                    onClick={() => isAvailable && onStartLearning(skill)}
                                    className={`skill-card rounded-xl p-6 text-white ${
                                        isCompleted ? 'skill-completed' :
                                        isAvailable ? 'skill-available' :
                                        'skill-locked glass'
                                    }`}
                                >
                                    <div className="flex justify-between items-start mb-4">
                                        <span className={`badge badge-${skill.difficulty}`}>
                                            {skill.difficulty}
                                        </span>
                                        {isCompleted && <i className="fas fa-check-circle text-2xl"></i>}
                                        {isLocked && <i className="fas fa-lock text-2xl"></i>}
                                        {isAvailable && <i className="fas fa-play-circle text-2xl pulse"></i>}
                                    </div>
                                    
                                    <h3 className="text-xl font-bold mb-2 capitalize">
                                        {skill.name.replace(/_/g, ' ')}
                                    </h3>
                                    
                                    <div className="space-y-2 text-sm">
                                        <p><i className="fas fa-layer-group mr-2"></i>{skill.domain}</p>
                                        <p><i className="fas fa-clock mr-2"></i>{skill.hours} hours</p>
                                        <p><i className="fas fa-star mr-2"></i>{skill.xp} XP</p>
                                    </div>
                                    
                                    {isAvailable && (
                                        <button className="mt-4 w-full bg-white text-blue-600 py-2 rounded-lg font-semibold hover:bg-opacity-90">
                                            Start Learning
                                        </button>
                                    )}
                                </div>
                            );
                        })}
                    </div>
                    
                    {/* Projects Section */}
                    <div className="mt-8 glass rounded-2xl p-6 text-white">
                        <h2 className="text-2xl font-bold mb-4">
                            <i className="fas fa-code mr-2"></i>Practice Projects
                        </h2>
                        <p className="mb-4 opacity-75">Build real-world projects to solidify your skills</p>
                        <div className="flex gap-4 flex-wrap">
                            <button 
                                onClick={() => onViewProjects('beginner')}
                                className="bg-green-500 px-6 py-3 rounded-lg font-semibold hover:bg-green-600"
                            >
                                Beginner Projects
                            </button>
                            <button 
                                onClick={() => onViewProjects('intermediate')}
                                className="bg-yellow-500 px-6 py-3 rounded-lg font-semibold hover:bg-yellow-600"
                            >
                                Intermediate Projects
                            </button>
                            <button 
                                onClick={() => onViewProjects('advanced')}
                                className="bg-red-500 px-6 py-3 rounded-lg font-semibold hover:bg-red-600"
                            >
                                Advanced Projects
                            </button>
                        </div>
                    </div>
                </div>
            );
        }
        
        // Learning Screen Component
        function LearningScreen({ topic, resources, onComplete, onBack }) {
            const [currentResourceIndex, setCurrentResourceIndex] = useState(0);
            
            return (
                <div className="min-h-screen p-8">
                    <div className="max-w-4xl mx-auto">
                        <button 
                            onClick={onBack}
                            className="glass text-white px-4 py-2 rounded-lg mb-4 hover:bg-opacity-20"
                        >
                            <i className="fas fa-arrow-left mr-2"></i>Back to Dashboard
                        </button>
                        
                        <div className="glass rounded-2xl p-8 text-white">
                            <div className="mb-6">
                                <h1 className="text-4xl font-bold capitalize mb-2">
                                    {topic.name.replace(/_/g, ' ')}
                                </h1>
                                <div className="flex gap-4 flex-wrap">
                                    <span className={`badge badge-${topic.difficulty}`}>{topic.difficulty}</span>
                                    <span className="badge" style={{background: '#6366f1'}}>
                                        <i className="fas fa-clock mr-1"></i>{topic.hours} hours
                                    </span>
                                    <span className="badge" style={{background: '#8b5cf6'}}>
                                        <i className="fas fa-star mr-1"></i>{topic.xp} XP
                                    </span>
                                </div>
                            </div>
                            
                            {resources.length > 0 && (
                                <div>
                                    {/* Resource Navigation */}
                                    <div className="flex gap-2 mb-6">
                                        {resources.map((res, index) => (
                                            <button
                                                key={index}
                                                onClick={() => setCurrentResourceIndex(index)}
                                                className={`px-4 py-2 rounded-lg font-semibold ${
                                                    currentResourceIndex === index 
                                                        ? 'bg-white text-purple-600' 
                                                        : 'bg-white bg-opacity-20'
                                                }`}
                                            >
                                                {res.type === 'tutorial' ? 'Tutorial' : 'Exercise'}
                                            </button>
                                        ))}
                                    </div>
                                    
                                    {/* Current Resource */}
                                    <div className="bg-white bg-opacity-10 rounded-xl p-6 mb-6">
                                        <div className="flex items-center gap-3 mb-4">
                                            <i className={`fas ${resources[currentResourceIndex].type === 'tutorial' ? 'fa-book' : 'fa-dumbbell'} text-3xl`}></i>
                                            <h2 className="text-2xl font-bold capitalize">{resources[currentResourceIndex].type}</h2>
                                        </div>
                                        
                                        <div className="space-y-4">
                                            <p className="text-lg leading-relaxed">{resources[currentResourceIndex].content}</p>
                                            
                                            <div className="bg-black bg-opacity-30 rounded-lg p-4">
                                                <pre className="text-green-300 overflow-x-auto">
                                                    <code>{resources[currentResourceIndex].example}</code>
                                                </pre>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    {/* Navigation */}
                                    <div className="flex justify-between">
                                        <button
                                            onClick={() => setCurrentResourceIndex(Math.max(0, currentResourceIndex - 1))}
                                            disabled={currentResourceIndex === 0}
                                            className="bg-white bg-opacity-20 px-6 py-3 rounded-lg font-semibold disabled:opacity-30"
                                        >
                                            <i className="fas fa-chevron-left mr-2"></i>Previous
                                        </button>
                                        
                                        {currentResourceIndex < resources.length - 1 ? (
                                            <button
                                                onClick={() => setCurrentResourceIndex(currentResourceIndex + 1)}
                                                className="bg-blue-500 px-6 py-3 rounded-lg font-semibold hover:bg-blue-600"
                                            >
                                                Next<i className="fas fa-chevron-right ml-2"></i>
                                            </button>
                                        ) : (
                                            <button
                                                onClick={onComplete}
                                                className="bg-green-500 px-6 py-3 rounded-lg font-semibold hover:bg-green-600"
                                            >
                                                <i className="fas fa-check mr-2"></i>Mark Complete
                                            </button>
                                        )}
                                    </div>
                                </div>
                            )}
                        </div>
                        
                        {/* Tips Section */}
                        <div className="glass rounded-xl p-6 mt-6 text-white">
                            <h3 className="text-xl font-bold mb-3">
                                <i className="fas fa-lightbulb mr-2 text-yellow-300"></i>Pro Tips
                            </h3>
                            <ul className="space-y-2 opacity-90">
                                <li><i className="fas fa-check-circle mr-2 text-green-400"></i>Type out all code examples yourself</li>
                                <li><i className="fas fa-check-circle mr-2 text-green-400"></i>Experiment with variations</li>
                                <li><i className="fas fa-check-circle mr-2 text-green-400"></i>Complete all exercises before moving on</li>
                                <li><i className="fas fa-check-circle mr-2 text-green-400"></i>Build small projects to practice</li>
                            </ul>
                        </div>
                    </div>
                </div>
            );
        }
        
        // Project Modal Component
        function ProjectModal({ projects, onClose }) {
            return (
                <div className="modal active" onClick={onClose}>
                    <div 
                        className="glass rounded-2xl p-8 max-w-4xl max-h-[80vh] overflow-y-auto text-white"
                        onClick={(e) => e.stopPropagation()}
                    >
                        <div className="flex justify-between items-center mb-6">
                            <h2 className="text-3xl font-bold">
                                <i className="fas fa-code mr-2"></i>Practice Projects
                            </h2>
                            <button onClick={onClose} className="text-3xl hover:text-red-400">
                                <i className="fas fa-times"></i>
                            </button>
                        </div>
                        
                        <div className="space-y-6">
                            {projects.map((project, index) => (
                                <div key={index} className="bg-white bg-opacity-10 rounded-xl p-6">
                                    <h3 className="text-2xl font-bold mb-3">{project.title}</h3>
                                    
                                    <div className="mb-3">
                                        <span className="text-sm opacity-75">Required Skills:</span>
                                        <div className="flex gap-2 flex-wrap mt-2">
                                            {project.requiredSkills.map((skill, i) => (
                                                <span key={i} className="bg-blue-500 px-3 py-1 rounded-full text-sm">
                                                    {skill.replace(/_/g, ' ')}
                                                </span>
                                            ))}
                                        </div>
                                    </div>
                                    
                                    <p className="mb-3"><strong>Description:</strong> {project.description}</p>
                                    <p><strong>Challenge:</strong> {project.features}</p>
                                    
                                    <button className="mt-4 bg-gradient-to-r from-green-400 to-blue-500 px-6 py-2 rounded-lg font-semibold hover:opacity-90">
                                        <i className="fas fa-rocket mr-2"></i>Start Project
                                    </button>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            );
        }
        
        // Helper function for path icons
        function getPathIcon(pathId) {
            const icons = {
                'frontend_developer': 'fa-palette',
                'backend_developer': 'fa-server',
                'fullstack_developer': 'fa-layer-group',
                'data_structures_algorithms': 'fa-project-diagram',
                'devops_engineer': 'fa-cogs'
            };
            return icons[pathId] || 'fa-code';
        }
        
        // Render App
        ReactDOM.render(<App />, document.getElementById('root'));
    </script>
</body>
</html>
"""

print("✅ Created: index.html (Frontend)")
print(f"   Size: {len(frontend_html)} characters")
print(f"   Lines: {frontend_html.count(chr(10))} lines\n")

# Save the file
with open('index.html', 'w', encoding='utf-8') as f:
    f.write(frontend_html)
