/*
==============================================
JOB READY PLATFORM - COMPLETE PROLOG BACKEND
ALL skills, resources, projects, handlers, CORS fixes
==============================================
*/

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/cors)).
:- use_module(library(http/json)).
:- use_module(library(http/http_header)).

frontend_origin('http://localhost:3000').

:- http_handler(root(.), http_redirect(moved, '/index.html'), []).
:- http_handler('/api/generate-path', handle_generate_path, [method(post)]).
:- http_handler('/api/progress', handle_get_progress, [method(get)]).
:- http_handler('/api/update-progress', handle_update_progress, [method(post)]).
:- http_handler('/api/next-topic', handle_next_topic, [method(get)]).
:- http_handler('/api/get-projects', handle_get_projects, [method(get)]).
:- http_handler('/api/career-paths', handle_career_paths, [method(get)]).
:- http_handler('/api/skill-tree', handle_skill_tree, [method(post)]).
:- http_handler('/api/resources', handle_get_resources, [method(post)]).
:- http_handler(root(api/), handle_options, [method(options), prefix]).

handle_options(Request) :-
    frontend_origin(Origin),
    cors_enable(Request, [methods([get,post,options]), origins([Origin]), headers(['content-type','authorization'])]),
    throw(http_reply(no_content)).

:- dynamic user_progress/3, user_path/2, user_xp/2, user_streak/2.

prerequisite(variables, data_types).
prerequisite(data_types, operators).
prerequisite(operators, conditionals).
prerequisite(conditionals, loops).
prerequisite(loops, arrays).
prerequisite(arrays, strings).
prerequisite(loops, functions).
prerequisite(functions, recursion).
prerequisite(arrays, lists).
prerequisite(functions, scope).
prerequisite(scope, closures).
prerequisite(variables, classes).
prerequisite(classes, objects).
prerequisite(objects, inheritance).
prerequisite(inheritance, polymorphism).
prerequisite(polymorphism, abstraction).
prerequisite(classes, encapsulation).
prerequisite(arrays, linked_lists).
prerequisite(linked_lists, stacks).
prerequisite(linked_lists, queues).
prerequisite(arrays, hash_tables).
prerequisite(stacks, trees).
prerequisite(trees, binary_trees).
prerequisite(binary_trees, bst).
prerequisite(trees, heaps).
prerequisite(arrays, graphs).
prerequisite(loops, searching).
prerequisite(searching, sorting).
prerequisite(recursion, divide_conquer).
prerequisite(divide_conquer, dynamic_programming).
prerequisite(graphs, graph_algorithms).
prerequisite(trees, tree_traversal).
prerequisite(variables, html_basics).
prerequisite(html_basics, css_basics).
prerequisite(css_basics, javascript_basics).
prerequisite(javascript_basics, dom_manipulation).
prerequisite(dom_manipulation, events).
prerequisite(events, async_js).
prerequisite(async_js, fetch_api).
prerequisite(functions, react_basics).
prerequisite(react_basics, react_hooks).
prerequisite(react_hooks, state_management).
prerequisite(javascript_basics, nodejs_basics).
prerequisite(nodejs_basics, express_js).
prerequisite(express_js, rest_api).
prerequisite(rest_api, databases).
prerequisite(databases, sql).
prerequisite(databases, mongodb).
prerequisite(rest_api, authentication).
prerequisite(variables, git_basics).
prerequisite(git_basics, github).
prerequisite(nodejs_basics, docker_basics).
prerequisite(docker_basics, docker_compose).
prerequisite(docker_compose, kubernetes).
prerequisite(git_basics, ci_cd).

skill(variables, programming_basics, beginner, 2, 50).
skill(data_types, programming_basics, beginner, 2, 50).
skill(operators, programming_basics, beginner, 2, 50).
skill(conditionals, programming_basics, beginner, 3, 75).
skill(loops, programming_basics, beginner, 4, 100).
skill(arrays, programming_basics, beginner, 5, 125).
skill(strings, programming_basics, beginner, 3, 75).
skill(functions, programming_basics, intermediate, 6, 150).
skill(recursion, programming_basics, intermediate, 8, 200).
skill(lists, programming_basics, intermediate, 4, 100).
skill(scope, programming_basics, intermediate, 3, 75).
skill(closures, programming_basics, advanced, 5, 150).
skill(classes, oop, intermediate, 5, 125).
skill(objects, oop, intermediate, 4, 100).
skill(inheritance, oop, intermediate, 6, 150).
skill(polymorphism, oop, advanced, 7, 175).
skill(abstraction, oop, advanced, 6, 150).
skill(encapsulation, oop, intermediate, 5, 125).
skill(linked_lists, data_structures, intermediate, 8, 200).
skill(stacks, data_structures, intermediate, 6, 150).
skill(queues, data_structures, intermediate, 6, 150).
skill(hash_tables, data_structures, intermediate, 8, 200).
skill(trees, data_structures, advanced, 10, 250).
skill(binary_trees, data_structures, advanced, 8, 200).
skill(bst, data_structures, advanced, 10, 250).
skill(heaps, data_structures, advanced, 10, 250).
skill(graphs, data_structures, advanced, 12, 300).
skill(searching, algorithms, beginner, 6, 150).
skill(sorting, algorithms, intermediate, 10, 250).
skill(divide_conquer, algorithms, advanced, 12, 300).
skill(dynamic_programming, algorithms, advanced, 20, 500).
skill(graph_algorithms, algorithms, advanced, 15, 375).
skill(tree_traversal, algorithms, intermediate, 8, 200).
skill(html_basics, web_development, beginner, 8, 200).
skill(css_basics, web_development, beginner, 10, 250).
skill(javascript_basics, web_development, beginner, 15, 375).
skill(dom_manipulation, web_development, intermediate, 8, 200).
skill(events, web_development, intermediate, 6, 150).
skill(async_js, web_development, intermediate, 10, 250).
skill(fetch_api, web_development, intermediate, 6, 150).
skill(react_basics, web_development, intermediate, 15, 375).
skill(react_hooks, web_development, intermediate, 10, 250).
skill(state_management, web_development, advanced, 12, 300).
skill(nodejs_basics, backend, intermediate, 12, 300).
skill(express_js, backend, intermediate, 15, 375).
skill(rest_api, backend, intermediate, 12, 300).
skill(databases, backend, intermediate, 10, 250).
skill(sql, backend, intermediate, 15, 375).
skill(mongodb, backend, intermediate, 12, 300).
skill(authentication, backend, advanced, 10, 250).
skill(git_basics, devops, beginner, 5, 125).
skill(github, devops, beginner, 4, 100).
skill(docker_basics, devops, intermediate, 10, 250).
skill(docker_compose, devops, intermediate, 8, 200).
skill(kubernetes, devops, advanced, 20, 500).
skill(ci_cd, devops, advanced, 15, 375).

career_path(frontend_developer, [variables,data_types,operators,conditionals,loops,arrays,functions,html_basics,css_basics,javascript_basics,dom_manipulation,events,async_js,fetch_api,react_basics,react_hooks,state_management,git_basics,github], 300).
career_path(backend_developer, [variables,data_types,operators,conditionals,loops,arrays,functions,classes,objects,nodejs_basics,express_js,rest_api,databases,sql,mongodb,authentication,git_basics,github,docker_basics], 350).
career_path(fullstack_developer, [variables,data_types,operators,conditionals,loops,arrays,functions,html_basics,css_basics,javascript_basics,dom_manipulation,events,async_js,fetch_api,react_basics,react_hooks,state_management,nodejs_basics,express_js,rest_api,databases,sql,mongodb,authentication,git_basics,github,docker_basics], 400).
career_path(data_structures_algorithms, [variables,data_types,operators,conditionals,loops,arrays,functions,recursion,linked_lists,stacks,queues,hash_tables,trees,binary_trees,bst,heaps,graphs,searching,sorting,divide_conquer,dynamic_programming,graph_algorithms,tree_traversal], 450).
career_path(devops_engineer, [variables,data_types,operators,conditionals,loops,functions,nodejs_basics,databases,git_basics,github,docker_basics,docker_compose,kubernetes,ci_cd], 300).

resource(variables, tutorial, 'Variables store data in memory. They are named containers.', 'let name = "value"; const PI = 3.14; var count = 0;').
resource(variables, exercise, 'Create 5 variables: name, age, city, country, hobby', 'Store your personal information').
resource(data_types, tutorial, 'Data types: Number, String, Boolean, Array, Object, null, undefined', 'let num = 42; let text = "hello"; let flag = true;').
resource(data_types, exercise, 'Create variables of each data type and print them', 'Practice type conversion').
resource(operators, tutorial, 'Operators: arithmetic (+,-,*,/), comparison (==,===,!=), logical (&&,||,!)', 'let sum = 5 + 3; let isEqual = (5 === 5);').
resource(operators, exercise, 'Write expressions using all operator types', 'Create a calculator function').
resource(conditionals, tutorial, 'if-else statements control program flow based on conditions', 'if(age >= 18) { console.log("Adult"); } else { console.log("Minor"); }').
resource(conditionals, exercise, 'Create a grade calculator: A(90-100), B(80-89), C(70-79)', 'Use nested if-else').
resource(loops, tutorial, 'Loops repeat code: for, while, do-while', 'for(let i=0; i<10; i++) { console.log(i); }').
resource(loops, exercise, 'Print multiplication table of any number', 'Use for loop and ask user input').
resource(arrays, tutorial, 'Arrays store multiple values in ordered list', 'let fruits = ["apple", "banana", "orange"]; fruits[0] => "apple"').
resource(arrays, exercise, 'Create array of 10 numbers and find sum, average, max, min', 'Use array methods').
resource(strings, tutorial, 'Strings are text data. Use quotes.', 'let greeting = "Hello World"; greeting.length; greeting.toUpperCase();').
resource(strings, exercise, 'Reverse a string, count vowels, check palindrome', 'String manipulation practice').
resource(functions, tutorial, 'Functions are reusable code blocks', 'function add(a, b) { return a + b; }').
resource(functions, exercise, 'Create functions: isPrime, factorial, fibonacci', 'Practice recursion').
resource(recursion, tutorial, 'Recursion: function calls itself', 'function factorial(n) { return n <= 1 ? 1 : n * factorial(n-1); }').
resource(recursion, exercise, 'Implement recursive: sum, power, GCD', 'Base case is critical').
resource(lists, tutorial, 'Lists are ordered collections', 'Similar to arrays but with list operations').
resource(lists, exercise, 'Implement list operations: append, reverse, filter', 'Practice list methods').
resource(scope, tutorial, 'Scope defines variable visibility', 'Global vs local scope, block scope with let/const').
resource(scope, exercise, 'Debug scope issues in nested functions', 'Understand hoisting').
resource(closures, tutorial, 'Closures: inner function accesses outer variables', 'function outer() { let x=10; return function() { return x; } }').
resource(closures, exercise, 'Create counter with closure, private variables', 'Module pattern').
resource(classes, tutorial, 'Classes are blueprints for objects', 'class Person { constructor(name) { this.name = name; } }').
resource(classes, exercise, 'Create class hierarchy: Animal -> Dog, Cat', 'Methods and properties').
resource(objects, tutorial, 'Objects store key-value pairs', 'let person = { name: "John", age: 30 };').
resource(objects, exercise, 'Create objects, access properties, methods', 'Object manipulation').
resource(inheritance, tutorial, 'Inheritance: child class extends parent', 'class Dog extends Animal { bark() {...} }').
resource(inheritance, exercise, 'Build class hierarchy with inheritance', 'Override methods').
resource(polymorphism, tutorial, 'Polymorphism: same method, different behavior', 'Method overriding in subclasses').
resource(polymorphism, exercise, 'Implement polymorphic shape area calculator', 'Circle, Rectangle, Triangle').
resource(abstraction, tutorial, 'Abstraction hides complexity', 'Expose only necessary details').
resource(abstraction, exercise, 'Create abstract base class', 'Force subclasses to implement').
resource(encapsulation, tutorial, 'Encapsulation bundles data and methods', 'Private fields with #field').
resource(encapsulation, exercise, 'Create class with private fields', 'Getters and setters').
resource(linked_lists, tutorial, 'Linked list: nodes with data and pointer to next', 'class Node { constructor(data) { this.data=data; this.next=null; }}').
resource(linked_lists, exercise, 'Implement: insert, delete, search, reverse linked list', 'Practice pointer manipulation').
resource(stacks, tutorial, 'Stack: LIFO (Last In First Out)', 'push, pop, peek operations').
resource(stacks, exercise, 'Implement stack, solve balanced parentheses', 'Stack applications').
resource(queues, tutorial, 'Queue: FIFO (First In First Out)', 'enqueue, dequeue operations').
resource(queues, exercise, 'Implement queue, simulate print queue', 'Circular queue').
resource(hash_tables, tutorial, 'Hash table: key-value pairs with O(1) lookup', 'Hashing function maps keys to indices').
resource(hash_tables, exercise, 'Implement hash table, handle collisions', 'Chaining vs open addressing').
resource(trees, tutorial, 'Tree: hierarchical data structure', 'Root, parent, child, leaf nodes').
resource(trees, exercise, 'Implement tree, traversals (pre/in/post order)', 'Tree operations').
resource(binary_trees, tutorial, 'Binary tree: each node has max 2 children', 'Left and right subtrees').
resource(binary_trees, exercise, 'Implement binary tree operations', 'Height, depth, level order').
resource(bst, tutorial, 'Binary Search Tree: left < root < right', 'Efficient search O(log n)').
resource(bst, exercise, 'Implement BST: insert, delete, search', 'Balance considerations').
resource(heaps, tutorial, 'Heap: complete binary tree (min/max heap)', 'Priority queue implementation').
resource(heaps, exercise, 'Implement heap, heapify, heap sort', 'Parent-child relationships').
resource(graphs, tutorial, 'Graph: nodes connected by edges', 'Directed vs undirected, weighted vs unweighted').
resource(graphs, exercise, 'Implement graph with adjacency list/matrix', 'Graph traversals').
resource(searching, tutorial, 'Searching algorithms: linear, binary', 'Binary search requires sorted array').
resource(searching, exercise, 'Implement linear and binary search', 'Compare performance').
resource(sorting, tutorial, 'Sorting algorithms: bubble, selection, insertion, merge, quick', 'Time complexity varies').
resource(sorting, exercise, 'Implement 5 sorting algorithms', 'Analyze time/space complexity').
resource(divide_conquer, tutorial, 'Divide and conquer: break into subproblems', 'Merge sort, quick sort examples').
resource(divide_conquer, exercise, 'Solve problems using divide and conquer', 'Binary search, merge sort').
resource(dynamic_programming, tutorial, 'DP: solve by breaking into overlapping subproblems', 'Memoization and tabulation').
resource(dynamic_programming, exercise, 'Solve: fibonacci, knapsack, LCS', 'Identify optimal substructure').
resource(graph_algorithms, tutorial, 'Graph algorithms: BFS, DFS, Dijkstra, MST', 'Shortest path, spanning tree').
resource(graph_algorithms, exercise, 'Implement BFS, DFS, Dijkstra', 'Find shortest paths').
resource(tree_traversal, tutorial, 'Tree traversal: inorder, preorder, postorder, level order', 'Recursive and iterative').
resource(tree_traversal, exercise, 'Implement all tree traversals', 'Use stack/queue').
resource(html_basics, tutorial, 'HTML structures web content with tags', '<html><body><h1>Title</h1><p>Text</p></body></html>').
resource(html_basics, exercise, 'Create a resume page with headings, lists, links, images', 'Use semantic HTML5 tags').
resource(css_basics, tutorial, 'CSS styles HTML elements', 'h1 { color: blue; font-size: 24px; }').
resource(css_basics, exercise, 'Style your resume: colors, fonts, layout', 'Use flexbox or grid').
resource(javascript_basics, tutorial, 'JavaScript adds interactivity', 'document.getElementById("btn").addEventListener("click", () => alert("Hi"))').
resource(javascript_basics, exercise, 'Create a calculator with buttons', 'Use DOM manipulation').
resource(dom_manipulation, tutorial, 'DOM: Document Object Model', 'Access and modify HTML elements with JS').
resource(dom_manipulation, exercise, 'Build interactive todo list', 'Add, remove, toggle items').
resource(events, tutorial, 'Events: user actions (click, hover, keypress)', 'addEventListener for handling events').
resource(events, exercise, 'Create interactive form with validation', 'Prevent default, event bubbling').
resource(async_js, tutorial, 'Async JS: callbacks, promises, async/await', 'Handle asynchronous operations').
resource(async_js, exercise, 'Fetch data from API using promises', 'Error handling with catch').
resource(fetch_api, tutorial, 'Fetch API: make HTTP requests', 'fetch(url).then(res => res.json()).then(data => ...)').
resource(fetch_api, exercise, 'Build weather app using fetch API', 'Display data from external API').
resource(react_basics, tutorial, 'React builds UI with components', 'function App() { return <div><h1>Hello</h1></div>; }').
resource(react_basics, exercise, 'Create reusable components', 'Props and composition').
resource(react_hooks, tutorial, 'Hooks: useState, useEffect, useContext', 'Add state to functional components').
resource(react_hooks, exercise, 'Build counter and timer with hooks', 'Side effects with useEffect').
resource(state_management, tutorial, 'State management: Context API, Redux', 'Global state across components').
resource(state_management, exercise, 'Implement shopping cart with context', 'Add, remove, update items').
resource(nodejs_basics, tutorial, 'Node.js runs JavaScript on server', 'const http = require("http"); server.listen(3000)').
resource(nodejs_basics, exercise, 'Create HTTP server responding with JSON', 'Handle routes').
resource(express_js, tutorial, 'Express: Node.js web framework', 'app.get("/", (req, res) => res.send("Hello"))').
resource(express_js, exercise, 'Build REST API with Express', 'CRUD operations').
resource(rest_api, tutorial, 'REST API: HTTP methods (GET, POST, PUT, DELETE)', 'RESTful architecture principles').
resource(rest_api, exercise, 'Design and implement RESTful API', 'Endpoints for resource management').
resource(databases, tutorial, 'Databases store structured data', 'SQL (relational) vs NoSQL (document)').
resource(databases, exercise, 'Design database schema for blog', 'Users, posts, comments tables').
resource(sql, tutorial, 'SQL: query relational databases', 'SELECT * FROM users WHERE age > 18').
resource(sql, exercise, 'Write queries: JOIN, GROUP BY, aggregate', 'Complex queries').
resource(mongodb, tutorial, 'MongoDB: NoSQL document database', 'JSON-like documents, collections').
resource(mongodb, exercise, 'CRUD operations with MongoDB', 'Queries and updates').
resource(authentication, tutorial, 'Authentication: verify user identity', 'JWT tokens, sessions, OAuth').
resource(authentication, exercise, 'Implement JWT authentication', 'Login, protected routes').
resource(git_basics, tutorial, 'Git tracks code changes', 'git init, add, commit, push, pull').
resource(git_basics, exercise, 'Create repo, make commits, push to GitHub', 'Branching workflow').
resource(github, tutorial, 'GitHub: host Git repositories', 'Collaboration, pull requests, issues').
resource(github, exercise, 'Contribute to open source project', 'Fork, PR workflow').
resource(docker_basics, tutorial, 'Docker: containerize applications', 'Dockerfile, build, run containers').
resource(docker_basics, exercise, 'Dockerize Node.js app', 'Create Dockerfile and run').
resource(docker_compose, tutorial, 'Docker Compose: multi-container apps', 'docker-compose.yml file').
resource(docker_compose, exercise, 'Setup app with database using compose', 'Services, networks, volumes').
resource(kubernetes, tutorial, 'Kubernetes: container orchestration', 'Pods, deployments, services').
resource(kubernetes, exercise, 'Deploy app to Kubernetes cluster', 'Scale and manage containers').
resource(ci_cd, tutorial, 'CI/CD: automate testing and deployment', 'GitHub Actions, Jenkins, GitLab CI').
resource(ci_cd, exercise, 'Setup CI/CD pipeline', 'Auto test and deploy on push').

project(beginner, 'Personal Portfolio Website', [html_basics, css_basics, javascript_basics], 'Create responsive portfolio with about, skills, projects sections', 'Use flexbox, add contact form, deploy to GitHub Pages').
project(beginner, 'Calculator App', [javascript_basics, dom_manipulation, events], 'Build calculator with basic operations', 'Add keyboard support and history feature').
project(beginner, 'Todo List App', [javascript_basics, dom_manipulation, events], 'Create todo app with add, delete, mark complete', 'Store in localStorage for persistence').
project(intermediate, 'Weather Dashboard', [javascript_basics, async_js, fetch_api], 'Fetch weather data and display beautifully', 'Add 5-day forecast, geolocation, search cities').
project(intermediate, 'E-commerce Product Page', [react_basics, react_hooks, state_management], 'Product listing with cart, filters, search', 'Add wishlist, reviews, image zoom').
project(intermediate, 'Blog Platform', [react_basics, nodejs_basics, express_js, databases], 'Full-stack blog with auth, CRUD operations', 'Add comments, likes, markdown support').
project(advanced, 'Social Media Clone', [fullstack_developer], 'Build Twitter/Instagram clone with posts, follows, feed', 'Real-time updates, image upload, notifications').
project(advanced, 'Project Management Tool', [fullstack_developer], 'Trello-like board with drag-drop, teams, tasks', 'Real-time collaboration, file attachments').
project(advanced, 'Code Editor Online', [react_basics, nodejs_basics, state_management], 'Browser-based code editor with syntax highlighting', 'Multiple languages, themes, save/load files').

require_field(Dict, Field) :- get_dict(Field, Dict, Value), Value \== "", !.
require_field(_, Field) :- throw(http_reply(bad_request(Field))).

handle_generate_path(Request) :-
    cors_enable_with_origin(Request),
    http_read_json_dict(Request, Data),
    require_field(Data, userId), require_field(Data, careerPath),
    UserId = Data.userId, CareerPath = Data.careerPath,
    atom_string(CareerPathAtom, CareerPath),
    generate_learning_path(CareerPathAtom, OrderedSkills),
    retractall(user_path(UserId, _)), assertz(user_path(UserId, OrderedSkills)),
    retractall(user_xp(UserId, _)), assertz(user_xp(UserId, 0)),
    retractall(user_streak(UserId, _)), assertz(user_streak(UserId, 0)),
    total_xp_for_skills(OrderedSkills, TotalXP), length(OrderedSkills, TotalSkills),
    maplist(skill_to_json, OrderedSkills, SkillsJson),
    reply_json_dict(json{ success: true, path: SkillsJson, totalSkills: TotalSkills, totalXP: TotalXP, careerPath: CareerPath }).

skill_to_json(Skill, Json) :- skill(Skill, Domain, Difficulty, Hours, XP),
    atom_string(SkillStr, Skill), atom_string(DomainStr, Domain), atom_string(Difficulty, DiffStr),
    Json = json{ name: SkillStr, domain: DomainStr, difficulty: DiffStr, hours: Hours, xp: XP }.

handle_get_progress(Request) :- cors_enable_with_origin(Request),
    http_parameters(Request, [userId(UserId, [])]),
    (user_path(UserId, Path) -> (
        findall(T, user_progress(UserId, T, completed), Completed),
        length(Path, Total), length(Completed, CompletedCount),
        Progress is (CompletedCount * 100) / Total, (user_xp(UserId, XP) -> true ; XP = 0),
        (user_streak(UserId, Streak) -> true ; Streak = 0), maplist(atom_string, Completed, CompletedStr),
        reply_json_dict(json{success: true, totalSkills: Total, completed: CompletedCount, progress: Progress, xp: XP, streak: Streak, completedSkills: CompletedStr}))
    ; reply_json_dict(json{success: false, message: "No path for user"})
    ).

handle_update_progress(Request) :- cors_enable_with_origin(Request),
    http_read_json_dict(Request, Data),
    require_field(Data, userId), require_field(Data, topic),
    UserId = Data.userId, Topic = Data.topic, atom_string(TopicAtom, Topic),
    retractall(user_progress(UserId, TopicAtom, _)), assertz(user_progress(UserId, TopicAtom, completed)),
    skill(TopicAtom, _, _, _, XP),
    (user_xp(UserId, CurrentXP) -> NewXP is CurrentXP + XP, retract(user_xp(UserId, CurrentXP)), assertz(user_xp(UserId, NewXP)) ; assertz(user_xp(UserId, XP)), NewXP = XP),
    (user_streak(UserId, Streak) -> NewStreak is Streak + 1, retract(user_streak(UserId, Streak)), assertz(user_streak(UserId, NewStreak)) ; assertz(user_streak(UserId, 1)), NewStreak = 1),
    reply_json_dict(json{ success: true, xp: NewXP, xpGained: XP, streak: NewStreak, message: "Progress updated!" }).

handle_next_topic(Request) :- cors_enable_with_origin(Request),
    http_parameters(Request, [userId(UserId, [])]),
    (get_next_topic(UserId, NextTopic) -> atom_string(NextTopic, NextTopicStr),
        skill(NextTopic, Domain, Difficulty, Hours, XP),
        atom_string(Domain, DomainStr), atom_string(Difficulty, DiffStr),
        reply_json_dict(json{success: true, nextTopic: NextTopicStr, domain: DomainStr, difficulty: DiffStr, hours: Hours, xp: XP})
      ; reply_json_dict(json{ success: false, message: "All done! You are JOB READY!" })).

handle_get_projects(Request) :- cors_enable_with_origin(Request),
    http_parameters(Request, [level(Level, [])]), atom_string(LevelAtom, Level),
    findall(json{
        title: Title, requiredSkills: ReqSkillsStr, description: Desc, features: Features
      }, (project(LevelAtom, Title, ReqSkills, Desc, Features), maplist(atom_string, ReqSkills, ReqSkillsStr)), Projects),
    reply_json_dict(json{success: true, projects: Projects}).

handle_career_paths(Request) :- cors_enable_with_origin(Request),
    findall(json{
        id: PathStr, name: NameStr, totalSkills: Total, estimatedHours: Hours
      }, (career_path(Path, Skills, Hours), atom_string(Path, PathStr), format_career_name(Path, NameStr), length(Skills, Total)), Paths),
    reply_json_dict(json{success: true, paths: Paths}).

format_career_name(frontend_developer, "Frontend Developer").
format_career_name(backend_developer, "Backend Developer").
format_career_name(fullstack_developer, "Full Stack Developer").
format_career_name(data_structures_algorithms, "DSA Expert").
format_career_name(devops_engineer, "DevOps Engineer").

skill_tree_with_status(UserId, CareerPath, SkillTree) :-
    career_path(CareerPath, Skills, _),
    maplist(skill_with_status(UserId), Skills, SkillTree).

skill_with_status(UserId, Skill, json{
    skill: Skill,
    status: Status,
    prerequisites: Prereqs,
    domain: Domain,
    difficulty: Difficulty,
    hours: Hours,
    xp: XP
}) :-
    (user_progress(UserId, Skill, completed) -> Status = completed ;
     (all_prerequisites(Skill, AllPrereqs),
      forall(member(P, AllPrereqs), user_progress(UserId, P, completed))
      -> Status = available ; Status = locked)),
    findall(P, prerequisite(P, Skill), Prereqs),
    skill(Skill, Domain, Difficulty, Hours, XP).

handle_skill_tree(Request) :- cors_enable_with_origin(Request),
    http_read_json_dict(Request, Data),
    require_field(Data, userId), require_field(Data, careerPath),
    UserId = Data.userId, CareerPath = Data.careerPath, atom_string(CareerPathAtom, CareerPath),
    skill_tree_with_status(UserId, CareerPathAtom, SkillTree),
    reply_json_dict(json{success: true, skillTree: SkillTree}).

handle_get_resources(Request) :- cors_enable_with_origin(Request),
    http_read_json_dict(Request, Data),
    require_field(Data, topic),
    Topic = Data.topic, atom_string(TopicAtom, Topic),
    findall(json{ type: TypeStr, content: Content, example: Example },
        (resource(TopicAtom, Type, Content, Example), atom_string(Type, TypeStr)), Resources),
    reply_json_dict(json{success: true, resources: Resources}).

all_prerequisites(Skill, AllPrereqs) :-
    findall(P, prerequisite_chain(P, Skill), Prereqs),
    list_to_set(Prereqs, AllPrereqs).
prerequisite_chain(P, Skill) :- prerequisite(P, Skill).
prerequisite_chain(P, Skill) :- prerequisite(X, Skill), prerequisite_chain(P, X).

generate_learning_path(CareerPath, OrderedSkills) :-
    career_path(CareerPath, Skills, _),
    topological_sort(Skills, OrderedSkills).
topological_sort(Skills, Sorted) :- topological_sort(Skills, [], Sorted).
topological_sort([], Acc, Result) :- reverse(Acc, Result).
topological_sort(Skills, Acc, Result) :- select(Skill, Skills, Rest),
    \+ (member(Other, Rest), prerequisite_chain(Skill, Other)),
    topological_sort(Rest, [Skill|Acc], Result).

total_xp_for_skills(Skills, TotalXP) :-
    findall(XP, (member(Skill, Skills), skill(Skill, _, _, _, XP)), XPs), sum_list(XPs, TotalXP).

get_next_topic(UserId, NextTopic) :-
    user_path(UserId, Path), findall(T, (member(T, Path), user_progress(UserId, T, completed)), Completed),
    member(NextTopic, Path), \+ member(NextTopic, Completed),
    all_prerequisites(NextTopic, Prereqs),
    forall(member(P, Prereqs), member(P, Completed)), !.

cors_enable_with_origin(Request) :-
    frontend_origin(Origin),
    cors_enable(Request, [methods([get,post,options]), origins([Origin]), headers(['content-type','authorization'])]).

start_server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    format('~n🚀 Job Ready Platform Backend Started!~n', []),
    format('   Server running on http://localhost:~w~n', [Port]),
    format('   API endpoints ready at /api/*~n', []),
    format('~n💡 Ready to make students JOB READY!~n~n', []).

:- initialization(start_server(8080)).
