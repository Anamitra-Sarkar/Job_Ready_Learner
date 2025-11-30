/*
==============================================
JOB READY PLATFORM - PRODUCTION PROLOG BACKEND
Datacamp-style interactive learning platform
Rate limiting, input validation, persistence, CORS, error handling
Version: 2.0.0
==============================================
*/

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(http/http_header)).
:- use_module(library(persistency)).

% Dynamic predicates for configuration
:- dynamic config_setting/2.

% Initialize config settings
% Note: In development, '*' allows all origins. For production, replace with your actual domain.
:- assertz(config_setting(allowed_origins, ['http://localhost:3000', 'http://localhost', 'http://localhost:8080'])).
:- assertz(config_setting(enable_rate_limit, true)).
:- assertz(config_setting(max_requests_per_minute, 60)).
:- assertz(config_setting(log_level, info)).

% Config setting getter
get_config(Key, Value) :-
    config_setting(Key, Value), !.
get_config(_, _) :- fail.

% Dynamic predicates for rate limiting
:- dynamic request_count/3.  % request_count(IP, Endpoint, Count)
:- dynamic last_cleanup/1.   % last_cleanup(Timestamp)

% HTTP Route Handlers - Core
:- http_handler(root(.), http_redirect(moved, '/index.html'), []).
:- http_handler('/api/generate-path', handle_generate_path, [method(post)]).
:- http_handler('/api/progress', handle_get_progress, [method(get)]).
:- http_handler('/api/update-progress', handle_update_progress, [method(post)]).
:- http_handler('/api/next-topic', handle_next_topic, [method(get)]).
:- http_handler('/api/get-projects', handle_get_projects, [method(get)]).
:- http_handler('/api/career-paths', handle_career_paths, [method(get)]).
:- http_handler('/api/skill-tree', handle_skill_tree, [method(post)]).
:- http_handler('/api/resources', handle_get_resources, [method(post)]).
:- http_handler('/api/health', handle_health, [method(get)]).
:- http_handler(root(api/), handle_options, [method(options), prefix]).

% HTTP Route Handlers - New Interactive Learning Features
:- http_handler('/api/get-video', handle_get_video, [method(post)]).
:- http_handler('/api/get-exercises', handle_get_exercises, [method(post)]).
:- http_handler('/api/submit-exercise', handle_submit_exercise, [method(post)]).
:- http_handler('/api/get-hints', handle_get_hints, [method(post)]).
:- http_handler('/api/run-code', handle_run_code, [method(post)]).
:- http_handler('/api/get-exercise-attempts', handle_get_exercise_attempts, [method(post)]).
:- http_handler('/api/get-detailed-progress', handle_get_detailed_progress, [method(get)]).

% CORS preflight handler
handle_options(Request) :-
    cors_enable_with_origin(Request),
    format('Status: 204 No Content~n~n', []).

% Rate limiting implementation
check_rate_limit(_Request, _Endpoint) :-
    get_config(enable_rate_limit, false), !.
check_rate_limit(Request, Endpoint) :-
    get_config(enable_rate_limit, true),
    (memberchk(peer(IP), Request) -> true ; IP = unknown),
    get_time(Now),
    cleanup_old_counts(Now),
    get_config(max_requests_per_minute, MaxRequests),
    (request_count(IP, Endpoint, Count) ->
        (Count >= MaxRequests ->
            throw(http_reply(too_many_requests(
                json{error: "Rate limit exceeded", retry_after: 60, endpoint: Endpoint})))
        ;
            retract(request_count(IP, Endpoint, Count)),
            NewCount is Count + 1,
            assertz(request_count(IP, Endpoint, NewCount))
        )
    ;
        assertz(request_count(IP, Endpoint, 1))
    ).

% Cleanup old rate limit counts every minute
cleanup_old_counts(Now) :-
    (last_cleanup(LastTime) ->
        Diff is Now - LastTime,
        (Diff > 60 ->
            retractall(request_count(_, _, _)),
            retract(last_cleanup(_)),
            assertz(last_cleanup(Now))
        ; true)
    ;
        assertz(last_cleanup(Now))
    ).

% Persistent storage configuration
:- persistent
    user_progress(user_id:atom, topic:atom, status:atom),
    user_path(user_id:atom, path:list),
    user_xp(user_id:atom, xp:integer),
    user_streak(user_id:atom, streak:integer),
    user_exercise_attempt(user_id:atom, exercise_id:atom, code:atom, passed:atom, timestamp:float),
    user_last_activity(user_id:atom, timestamp:float),
    user_video_watched(user_id:atom, topic:atom, video_id:atom, watched_percent:integer),
    user_hint_used(user_id:atom, exercise_id:atom, hint_level:integer).

:- db_attach('data/user_data.db', []).

% Initialize database
initialize_db :- 
    (exists_directory('data') -> true ; make_directory('data')),
    db_attach('data/user_data.db', []),
    log_info('Database initialized: data/user_data.db').

% Logging utilities
log_debug(Message) :- get_config(log_level, debug), !, format('DEBUG: ~w~n', [Message]).
log_debug(_).

log_info(Message) :- 
    get_config(log_level, Level),
    member(Level, [debug, info]), !,
    format('INFO: ~w~n', [Message]).
log_info(_).

log_warn(Message) :- 
    get_config(log_level, Level),
    member(Level, [debug, info, warn]), !,
    format('WARN: ~w~n', [Message]).
log_warn(_).

log_error(Message) :- format('ERROR: ~w~n', [Message]).

%==============================================
% KNOWLEDGE GRAPH - PREREQUISITES
%==============================================

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

%==============================================
% SKILLS DATABASE
%==============================================

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

%==============================================
% CAREER PATHS
%==============================================

career_path(frontend_developer, 
    [variables, data_types, operators, conditionals, loops, arrays, functions,
     html_basics, css_basics, javascript_basics, dom_manipulation, events,
     async_js, fetch_api, react_basics, react_hooks, state_management,
     git_basics, github], 300).

career_path(backend_developer,
    [variables, data_types, operators, conditionals, loops, arrays, functions,
     classes, objects, nodejs_basics, express_js, rest_api, databases, sql,
     mongodb, authentication, git_basics, github, docker_basics], 350).

career_path(fullstack_developer,
    [variables, data_types, operators, conditionals, loops, arrays, functions,
     html_basics, css_basics, javascript_basics, dom_manipulation, events,
     async_js, fetch_api, react_basics, react_hooks, state_management,
     nodejs_basics, express_js, rest_api, databases, sql, mongodb,
     authentication, git_basics, github, docker_basics], 400).

career_path(data_structures_algorithms,
    [variables, data_types, operators, conditionals, loops, arrays, functions,
     recursion, linked_lists, stacks, queues, hash_tables, trees, binary_trees,
     bst, heaps, graphs, searching, sorting, divide_conquer, dynamic_programming,
     graph_algorithms, tree_traversal], 450).

career_path(devops_engineer,
    [variables, data_types, operators, conditionals, loops, functions,
     nodejs_basics, databases, git_basics, github, docker_basics,
     docker_compose, kubernetes, ci_cd], 300).

%==============================================
% LEARNING RESOURCES
%==============================================

resource(variables, tutorial, 'Variables store data in memory. Named containers.', 'let name = "value"; const PI = 3.14;').
resource(variables, exercise, 'Create 5 variables: name, age, city, country, hobby', 'Store your personal information').
resource(data_types, tutorial, 'Data types: Number, String, Boolean, Array, Object', 'let num = 42; let text = "hello";').
resource(data_types, exercise, 'Create variables of each data type', 'Practice type conversion').
resource(operators, tutorial, 'Operators: arithmetic, comparison, logical', 'let sum = 5 + 3; let isEqual = (5 === 5);').
resource(operators, exercise, 'Write expressions using all operator types', 'Create calculator function').
resource(conditionals, tutorial, 'if-else controls program flow', 'if(age >= 18) { console.log("Adult"); }').
resource(conditionals, exercise, 'Create grade calculator', 'Use nested if-else').
resource(loops, tutorial, 'Loops repeat code: for, while', 'for(let i=0; i<10; i++) { console.log(i); }').
resource(loops, exercise, 'Print multiplication table', 'Use for loop').
resource(arrays, tutorial, 'Arrays store multiple values', 'let fruits = ["apple", "banana"];').
resource(arrays, exercise, 'Find sum, average, max, min', 'Use array methods').
resource(strings, tutorial, 'Strings are text data', 'let greeting = "Hello World";').
resource(strings, exercise, 'Reverse string, count vowels', 'String manipulation').
resource(functions, tutorial, 'Functions are reusable blocks', 'function add(a, b) { return a + b; }').
resource(functions, exercise, 'Create isPrime, factorial', 'Practice recursion').
resource(recursion, tutorial, 'Recursion: function calls itself', 'function factorial(n) { return n <= 1 ? 1 : n * factorial(n-1); }').
resource(recursion, exercise, 'Implement recursive sum, power', 'Base case critical').
resource(lists, tutorial, 'Lists are ordered collections', 'Similar to arrays').
resource(lists, exercise, 'Implement append, reverse', 'Practice list methods').
resource(scope, tutorial, 'Scope defines visibility', 'Global vs local scope').
resource(scope, exercise, 'Debug scope issues', 'Understand hoisting').
resource(closures, tutorial, 'Closures: inner accesses outer', 'function outer() { let x=10; return function() { return x; } }').
resource(closures, exercise, 'Create counter with closure', 'Module pattern').
resource(classes, tutorial, 'Classes are blueprints', 'class Person { constructor(name) { this.name = name; } }').
resource(classes, exercise, 'Create Animal hierarchy', 'Methods and properties').
resource(objects, tutorial, 'Objects store key-value pairs', 'let person = { name: "John", age: 30 };').
resource(objects, exercise, 'Create objects, access properties', 'Object manipulation').
resource(inheritance, tutorial, 'Child extends parent', 'class Dog extends Animal { bark() {...} }').
resource(inheritance, exercise, 'Build class hierarchy', 'Override methods').
resource(polymorphism, tutorial, 'Same method, different behavior', 'Method overriding').
resource(polymorphism, exercise, 'Implement shape calculator', 'Circle, Rectangle').
resource(abstraction, tutorial, 'Abstraction hides complexity', 'Expose only necessary').
resource(abstraction, exercise, 'Create abstract base class', 'Force implementation').
resource(encapsulation, tutorial, 'Bundles data and methods', 'Private fields with #field').
resource(encapsulation, exercise, 'Create class with private fields', 'Getters setters').
resource(linked_lists, tutorial, 'Nodes with data and pointer', 'class Node { constructor(data) { this.data=data; this.next=null; }}').
resource(linked_lists, exercise, 'Implement insert, delete, reverse', 'Pointer manipulation').
resource(stacks, tutorial, 'LIFO: Last In First Out', 'push, pop, peek operations').
resource(stacks, exercise, 'Solve balanced parentheses', 'Stack applications').
resource(queues, tutorial, 'FIFO: First In First Out', 'enqueue, dequeue operations').
resource(queues, exercise, 'Simulate print queue', 'Circular queue').
resource(hash_tables, tutorial, 'Key-value with O(1) lookup', 'Hashing function maps keys').
resource(hash_tables, exercise, 'Handle collisions', 'Chaining vs open addressing').
resource(trees, tutorial, 'Hierarchical data structure', 'Root, parent, child, leaf').
resource(trees, exercise, 'Implement traversals', 'Tree operations').
resource(binary_trees, tutorial, 'Max 2 children per node', 'Left and right subtrees').
resource(binary_trees, exercise, 'Implement binary tree ops', 'Height, depth, level order').
resource(bst, tutorial, 'BST: left < root < right', 'Efficient search O(log n)').
resource(bst, exercise, 'Implement insert, delete, search', 'Balance considerations').
resource(heaps, tutorial, 'Complete binary tree', 'Priority queue implementation').
resource(heaps, exercise, 'Implement heapify, heap sort', 'Parent-child relationships').
resource(graphs, tutorial, 'Nodes connected by edges', 'Directed vs undirected').
resource(graphs, exercise, 'Implement adjacency list', 'Graph traversals').
resource(searching, tutorial, 'Linear, binary search', 'Binary requires sorted').
resource(searching, exercise, 'Implement both searches', 'Compare performance').
resource(sorting, tutorial, 'Bubble, selection, merge, quick', 'Time complexity varies').
resource(sorting, exercise, 'Implement 5 sorting algorithms', 'Analyze complexity').
resource(divide_conquer, tutorial, 'Break into subproblems', 'Merge sort, quick sort').
resource(divide_conquer, exercise, 'Solve using divide conquer', 'Binary search, merge sort').
resource(dynamic_programming, tutorial, 'Overlapping subproblems', 'Memoization tabulation').
resource(dynamic_programming, exercise, 'Solve fibonacci, knapsack, LCS', 'Optimal substructure').
resource(graph_algorithms, tutorial, 'BFS, DFS, Dijkstra, MST', 'Shortest path, spanning tree').
resource(graph_algorithms, exercise, 'Implement BFS, DFS, Dijkstra', 'Find shortest paths').
resource(tree_traversal, tutorial, 'Inorder, preorder, postorder, level', 'Recursive iterative').
resource(tree_traversal, exercise, 'Implement all traversals', 'Use stack queue').
resource(html_basics, tutorial, 'HTML structures web content', '<html><body><h1>Title</h1></body></html>').
resource(html_basics, exercise, 'Create resume page', 'Use semantic HTML5 tags').
resource(css_basics, tutorial, 'CSS styles HTML', 'h1 { color: blue; font-size: 24px; }').
resource(css_basics, exercise, 'Style your resume', 'Use flexbox grid').
resource(javascript_basics, tutorial, 'JavaScript adds interactivity', 'document.getElementById("btn").addEventListener("click", () => alert("Hi"))').
resource(javascript_basics, exercise, 'Create calculator', 'Use DOM manipulation').
resource(dom_manipulation, tutorial, 'Document Object Model', 'Access modify HTML elements').
resource(dom_manipulation, exercise, 'Build todo list', 'Add remove toggle items').
resource(events, tutorial, 'User actions: click, hover, keypress', 'addEventListener for handling').
resource(events, exercise, 'Create form validation', 'Prevent default, bubbling').
resource(async_js, tutorial, 'Callbacks, promises, async/await', 'Handle asynchronous operations').
resource(async_js, exercise, 'Fetch data using promises', 'Error handling with catch').
resource(fetch_api, tutorial, 'Make HTTP requests', 'fetch(url).then(res => res.json())').
resource(fetch_api, exercise, 'Build weather app', 'Display external API data').
resource(react_basics, tutorial, 'React builds UI with components', 'function App() { return <div><h1>Hello</h1></div>; }').
resource(react_basics, exercise, 'Create reusable components', 'Props and composition').
resource(react_hooks, tutorial, 'useState, useEffect, useContext', 'Add state to functional').
resource(react_hooks, exercise, 'Build counter and timer', 'Side effects with useEffect').
resource(state_management, tutorial, 'Context API, Redux', 'Global state across components').
resource(state_management, exercise, 'Implement shopping cart', 'Add remove update items').
resource(nodejs_basics, tutorial, 'Node.js runs JS on server', 'const http = require("http");').
resource(nodejs_basics, exercise, 'Create HTTP server', 'Handle routes').
resource(express_js, tutorial, 'Express: Node.js framework', 'app.get("/", (req, res) => res.send("Hello"))').
resource(express_js, exercise, 'Build REST API', 'CRUD operations').
resource(rest_api, tutorial, 'HTTP methods GET, POST, PUT, DELETE', 'RESTful architecture principles').
resource(rest_api, exercise, 'Design RESTful API', 'Endpoints for resources').
resource(databases, tutorial, 'Store structured data', 'SQL vs NoSQL').
resource(databases, exercise, 'Design schema for blog', 'Users posts comments tables').
resource(sql, tutorial, 'Query relational databases', 'SELECT * FROM users WHERE age > 18').
resource(sql, exercise, 'Write queries: JOIN, GROUP BY', 'Complex queries').
resource(mongodb, tutorial, 'NoSQL document database', 'JSON-like documents, collections').
resource(mongodb, exercise, 'CRUD with MongoDB', 'Queries and updates').
resource(authentication, tutorial, 'Verify user identity', 'JWT tokens, sessions, OAuth').
resource(authentication, exercise, 'Implement JWT authentication', 'Login, protected routes').
resource(git_basics, tutorial, 'Git tracks code changes', 'git init, add, commit, push, pull').
resource(git_basics, exercise, 'Create repo, make commits', 'Branching workflow').
resource(github, tutorial, 'Host Git repositories', 'Collaboration, pull requests, issues').
resource(github, exercise, 'Contribute to open source', 'Fork, PR workflow').
resource(docker_basics, tutorial, 'Containerize applications', 'Dockerfile, build, run containers').
resource(docker_basics, exercise, 'Dockerize Node.js app', 'Create Dockerfile and run').
resource(docker_compose, tutorial, 'Multi-container apps', 'docker-compose.yml file').
resource(docker_compose, exercise, 'Setup app with database', 'Services, networks, volumes').
resource(kubernetes, tutorial, 'Container orchestration', 'Pods, deployments, services').
resource(kubernetes, exercise, 'Deploy to Kubernetes cluster', 'Scale and manage containers').
resource(ci_cd, tutorial, 'Automate testing deployment', 'GitHub Actions, Jenkins, GitLab CI').
resource(ci_cd, exercise, 'Setup CI/CD pipeline', 'Auto test deploy on push').

%==============================================
% PROJECTS DATABASE
%==============================================

project(beginner, 'Personal Portfolio Website', [html_basics, css_basics, javascript_basics], 'Create responsive portfolio', 'Use flexbox, deploy').
project(beginner, 'Calculator App', [javascript_basics, dom_manipulation, events], 'Build calculator', 'Add keyboard support').
project(beginner, 'Todo List App', [javascript_basics, dom_manipulation, events], 'Create todo app', 'Store in localStorage').
project(intermediate, 'Weather Dashboard', [javascript_basics, async_js, fetch_api], 'Fetch weather data', 'Add 5-day forecast').
project(intermediate, 'E-commerce Product Page', [react_basics, react_hooks, state_management], 'Product listing with cart', 'Add wishlist, reviews').
project(intermediate, 'Blog Platform', [react_basics, nodejs_basics, express_js, databases], 'Full-stack blog', 'Add comments, likes').
project(advanced, 'Social Media Clone', [fullstack_developer], 'Build Twitter/Instagram clone', 'Real-time updates').
project(advanced, 'Project Management Tool', [fullstack_developer], 'Trello-like board', 'Real-time collaboration').
project(advanced, 'Code Editor Online', [react_basics, nodejs_basics, state_management], 'Browser-based code editor', 'Multiple languages').

%==============================================
% VIDEO LESSONS DATABASE
% Format: video(Topic, VideoId, Title, Duration, Description)
% VideoId is YouTube video ID for embedding
%==============================================

% Programming Basics Videos
video(variables, 'Bv_5Zv5c-Ts', 'JavaScript Variables Explained', 12, 'Learn var, let, and const in JavaScript').
video(variables, 'edlFjlzxkSI', 'Variables in Programming', 8, 'Understanding variables in any programming language').
video(data_types, 'O5H0XTz2c5k', 'JavaScript Data Types', 15, 'Strings, Numbers, Booleans, Objects, and more').
video(data_types, 'AWfA95eLdq8', 'Data Types Tutorial', 10, 'Complete guide to data types').
video(operators, 'FZzyij43A54', 'JavaScript Operators Tutorial', 18, 'Arithmetic, comparison, logical operators').
video(conditionals, 'IsG4Xd6LlsM', 'If Else Statements', 14, 'Control flow with conditionals').
video(conditionals, 'JftlCt9Lao8', 'Switch Statements in JS', 8, 'Alternative to if-else chains').
video(loops, 'x2RNw4M6cME', 'JavaScript Loops Tutorial', 20, 'For, while, do-while, for...of loops').
video(loops, 's9wW2PpJsmQ', 'Loop Through Arrays', 12, 'Iterating over arrays effectively').
video(arrays, 'oigfaZ5ApsM', 'JavaScript Arrays Explained', 25, 'Array methods and manipulation').
video(arrays, 'R8rmfD9Y5-c', 'Array Methods Tutorial', 30, 'Map, filter, reduce, and more').
video(strings, 'VRz0nbax0uI', 'JavaScript Strings', 18, 'String methods and manipulation').
video(functions, 'N8ap4k_1QEQ', 'JavaScript Functions Tutorial', 28, 'Function declarations and expressions').
video(functions, 'gigtS_5KOqo', 'Arrow Functions in JavaScript', 10, 'Modern function syntax').
video(recursion, 'vPEJSJMg4jY', 'Recursion Explained', 15, 'Understanding recursive functions').
video(recursion, 'k7-N8R0-KY4', 'Recursion Examples', 20, 'Practical recursion problems').

% OOP Videos
video(classes, 'PFmuCDHHpwk', 'JavaScript Classes Tutorial', 22, 'ES6 classes explained').
video(objects, 'PFmuCDHHpwk', 'JavaScript Objects', 25, 'Creating and using objects').
video(inheritance, '_cgHGnq2_bc', 'Inheritance in JavaScript', 18, 'Extending classes').
video(polymorphism, 'wfMtDGfHWpA', 'Polymorphism Explained', 12, 'Same method, different behavior').
video(encapsulation, '1wKSR1hCRpY', 'Encapsulation in OOP', 14, 'Private fields and methods').

% Data Structures Videos
video(linked_lists, 'F8AbOfQwl1c', 'Linked Lists Explained', 20, 'Singly and doubly linked lists').
video(stacks, 'wjI1WNcIntg', 'Stack Data Structure', 15, 'LIFO operations explained').
video(queues, 'wjI1WNcIntg', 'Queue Data Structure', 12, 'FIFO operations explained').
video(hash_tables, '2E54GqF0H4s', 'Hash Tables Explained', 22, 'Hash functions and collision handling').
video(trees, 'oSWTXtMglKE', 'Tree Data Structures', 25, 'Binary trees and traversals').
video(binary_trees, '76dhtgZt38A', 'Binary Trees Tutorial', 20, 'Implementation and operations').
video(bst, 'pYT9F8_LFTM', 'Binary Search Trees', 25, 'BST operations explained').
video(graphs, 'tWVWeAqZ0WU', 'Graph Data Structure', 30, 'Representations and traversals').

% Algorithms Videos
video(searching, 'j5uXyPJ0Pew', 'Searching Algorithms', 18, 'Linear and binary search').
video(sorting, 'RfXt_qHDEPw', 'Sorting Algorithms Explained', 35, 'Bubble, merge, quick sort').
video(divide_conquer, 'YOh6hBtX5l0', 'Divide and Conquer', 20, 'Algorithm design technique').
video(dynamic_programming, 'oBt53YbR9Kk', 'Dynamic Programming Tutorial', 45, 'Memoization and tabulation').
video(graph_algorithms, 'pVfj6mxhdMw', 'Graph Algorithms', 40, 'BFS, DFS, Dijkstra').

% Web Development Videos
video(html_basics, 'qz0aGYrrlhU', 'HTML Crash Course', 60, 'Complete HTML tutorial').
video(html_basics, 'UB1O30fR-EE', 'HTML Full Course', 120, 'HTML from scratch').
video(css_basics, '1PnVor36_40', 'CSS Crash Course', 85, 'Complete CSS tutorial').
video(css_basics, 'yfoY53QXEnI', 'CSS in 100 Seconds', 2, 'Quick CSS overview').
video(javascript_basics, 'W6NZfCO5SIk', 'JavaScript Tutorial for Beginners', 60, 'Complete JS fundamentals').
video(javascript_basics, 'PkZNo7MFNFg', 'Learn JavaScript', 200, 'Full JavaScript course').
video(dom_manipulation, '0ik6X4DJKCc', 'DOM Manipulation', 40, 'JavaScript DOM tutorial').
video(events, 'XF1_MlZ5l6M', 'JavaScript Events', 25, 'Event handling in JS').
video(async_js, '_8gHHBlbziw', 'Async JavaScript Tutorial', 30, 'Callbacks, Promises, Async/Await').
video(async_js, 'ZYb_ZU8LNxs', 'Promises in JavaScript', 18, 'Understanding promises').
video(fetch_api, 'cuEtnrL9-H0', 'Fetch API Tutorial', 22, 'Making HTTP requests').

% React Videos
video(react_basics, 'Ke90Tje7VS0', 'React Tutorial for Beginners', 60, 'Learn React from scratch').
video(react_basics, 'w7ejDZ8SWv8', 'React JS Crash Course', 90, 'Complete React fundamentals').
video(react_hooks, 'TNhaISOUy6Q', 'React Hooks Tutorial', 45, 'useState, useEffect, and more').
video(react_hooks, 'O6P86uwfdR0', 'useEffect Hook Explained', 20, 'Side effects in React').
video(state_management, 'CVpUuw9XSjY', 'Redux Tutorial', 60, 'State management with Redux').
video(state_management, '9KJxaFHotqI', 'Context API Tutorial', 25, 'React Context explained').

% Backend Videos
video(nodejs_basics, 'TlB_eWDSMt4', 'Node.js Tutorial', 60, 'Learn Node.js from scratch').
video(nodejs_basics, 'ENrzD9HAZK4', 'Node.js Crash Course', 90, 'Complete Node fundamentals').
video(express_js, 'SccSCuHhOw0', 'Express.js Tutorial', 45, 'Build APIs with Express').
video(express_js, 'L72fhGm1tfE', 'Express Crash Course', 60, 'Complete Express guide').
video(rest_api, '-MTSQjw5DrM', 'REST API Tutorial', 35, 'Build RESTful APIs').
video(databases, 'zsjvFFKOm3c', 'Database Design', 40, 'SQL and NoSQL overview').
video(sql, 'HXV3zeQKqGY', 'SQL Tutorial', 180, 'Complete SQL course').
video(mongodb, 'ExcRbA7fy_A', 'MongoDB Crash Course', 75, 'Learn MongoDB').
video(authentication, 'mbsmsi7l3r4', 'JWT Authentication', 40, 'Implement JWT auth').

% DevOps Videos
video(git_basics, 'RGOj5yH7evk', 'Git and GitHub Tutorial', 60, 'Version control fundamentals').
video(git_basics, 'SWYqp7iY_Tc', 'Git Tutorial for Beginners', 30, 'Learn Git basics').
video(github, 'iv8rSLsi1xo', 'GitHub Tutorial', 40, 'Using GitHub effectively').
video(docker_basics, 'fqMOX6JJhGo', 'Docker Tutorial', 120, 'Complete Docker guide').
video(docker_basics, 'gAkwW2tuIqE', 'Docker in 100 Seconds', 2, 'Quick Docker overview').
video(docker_compose, 'DM65_JyGxCo', 'Docker Compose Tutorial', 45, 'Multi-container apps').
video(kubernetes, 'X48VuDVv0do', 'Kubernetes Tutorial', 240, 'Complete K8s course').
video(ci_cd, 'R8_veQiYBjI', 'GitHub Actions Tutorial', 60, 'CI/CD with GitHub Actions').

%==============================================
% EXERCISES DATABASE
% Format: exercise(ExerciseId, Topic, Title, Description, StarterCode, TestCases, Hints, XP)
% TestCases: list of test_case(Input, Expected, Description)
% Hints: list of hints from basic to solution
%==============================================

% Variables Exercises
exercise(var_1, variables, 'Declare Variables', 
    'Create three variables: name (your name as string), age (your age as number), and isStudent (boolean true).',
    '// Declare your variables here\nlet name = ;\nlet age = ;\nlet isStudent = ;',
    [test_case('typeof name', 'string', 'name should be a string'),
     test_case('typeof age', 'number', 'age should be a number'),
     test_case('typeof isStudent', 'boolean', 'isStudent should be a boolean')],
    ['Think about what data type each variable needs',
     'Strings need quotes, numbers do not',
     'Booleans are either true or false',
     'let name = "John"; let age = 25; let isStudent = true;'],
    25).

exercise(var_2, variables, 'Swap Variables',
    'Swap the values of two variables a and b without using a third variable.',
    'let a = 5;\nlet b = 10;\n// Swap a and b here\n',
    [test_case('a', '10', 'a should be 10 after swap'),
     test_case('b', '5', 'b should be 5 after swap')],
    ['You can use arithmetic operations',
     'Try a = a + b first',
     'Then b = a - b, then a = a - b',
     'a = a + b; b = a - b; a = a - b;'],
    30).

% Conditionals Exercises
exercise(cond_1, conditionals, 'Grade Calculator',
    'Write a function that returns letter grade based on score: A (90+), B (80-89), C (70-79), D (60-69), F (below 60).',
    'function getGrade(score) {\n  // Your code here\n  \n}',
    [test_case('getGrade(95)', 'A', 'Score 95 should return A'),
     test_case('getGrade(85)', 'B', 'Score 85 should return B'),
     test_case('getGrade(75)', 'C', 'Score 75 should return C'),
     test_case('getGrade(65)', 'D', 'Score 65 should return D'),
     test_case('getGrade(55)', 'F', 'Score 55 should return F')],
    ['Use if-else statements to check score ranges',
     'Start with the highest grade first',
     'Check if score >= 90, then >= 80, etc.',
     'if (score >= 90) return "A"; else if (score >= 80) return "B"; else if (score >= 70) return "C"; else if (score >= 60) return "D"; else return "F";'],
    35).

exercise(cond_2, conditionals, 'FizzBuzz',
    'Write a function that returns "Fizz" if n is divisible by 3, "Buzz" if divisible by 5, "FizzBuzz" if divisible by both, otherwise return n.',
    'function fizzBuzz(n) {\n  // Your code here\n  \n}',
    [test_case('fizzBuzz(15)', 'FizzBuzz', '15 is divisible by both'),
     test_case('fizzBuzz(9)', 'Fizz', '9 is divisible by 3'),
     test_case('fizzBuzz(10)', 'Buzz', '10 is divisible by 5'),
     test_case('fizzBuzz(7)', '7', '7 is not divisible by 3 or 5')],
    ['Check the "both" condition first',
     'Use modulo operator (%) to check divisibility',
     'n % 3 === 0 means divisible by 3',
     'if (n % 3 === 0 && n % 5 === 0) return "FizzBuzz"; else if (n % 3 === 0) return "Fizz"; else if (n % 5 === 0) return "Buzz"; else return n;'],
    40).

% Loops Exercises
exercise(loop_1, loops, 'Sum of Array',
    'Write a function that returns the sum of all numbers in an array.',
    'function sumArray(arr) {\n  // Your code here\n  \n}',
    [test_case('sumArray([1,2,3,4,5])', '15', 'Sum of 1-5 is 15'),
     test_case('sumArray([10,20,30])', '60', 'Sum of 10,20,30 is 60'),
     test_case('sumArray([])', '0', 'Empty array sum is 0')],
    ['Use a for loop to iterate through the array',
     'Create a sum variable initialized to 0',
     'Add each element to sum in the loop',
     'let sum = 0; for (let i = 0; i < arr.length; i++) { sum += arr[i]; } return sum;'],
    30).

exercise(loop_2, loops, 'Find Maximum',
    'Write a function that returns the maximum value in an array of numbers.',
    'function findMax(arr) {\n  // Your code here\n  \n}',
    [test_case('findMax([1,5,3,9,2])', '9', 'Max of array is 9'),
     test_case('findMax([-1,-5,-3])', '-1', 'Max of negative numbers'),
     test_case('findMax([42])', '42', 'Single element array')],
    ['Start with the first element as max',
     'Loop through and compare each element',
     'Update max if current element is larger',
     'let max = arr[0]; for (let i = 1; i < arr.length; i++) { if (arr[i] > max) max = arr[i]; } return max;'],
    35).

% Arrays Exercises
exercise(arr_1, arrays, 'Reverse Array',
    'Write a function that reverses an array without using the built-in reverse method.',
    'function reverseArray(arr) {\n  // Your code here\n  \n}',
    [test_case('reverseArray([1,2,3,4,5]).join(",")', '5,4,3,2,1', 'Reversed array'),
     test_case('reverseArray(["a","b","c"]).join(",")', 'c,b,a', 'String array reversed')],
    ['Create a new empty array for result',
     'Loop from the end of original array to start',
     'Push each element to the new array',
     'let result = []; for (let i = arr.length - 1; i >= 0; i--) { result.push(arr[i]); } return result;'],
    40).

exercise(arr_2, arrays, 'Remove Duplicates',
    'Write a function that removes duplicate values from an array.',
    'function removeDuplicates(arr) {\n  // Your code here\n  \n}',
    [test_case('removeDuplicates([1,2,2,3,3,3]).join(",")', '1,2,3', 'Removes duplicates'),
     test_case('removeDuplicates([1,1,1]).join(",")', '1', 'All same values')],
    ['Use a new array to store unique values',
     'Check if value already exists before adding',
     'indexOf returns -1 if not found',
     'let result = []; for (let item of arr) { if (result.indexOf(item) === -1) result.push(item); } return result;'],
    45).

% Functions Exercises
exercise(func_1, functions, 'Factorial',
    'Write a function that calculates the factorial of a number (n! = n * (n-1) * ... * 1).',
    'function factorial(n) {\n  // Your code here\n  \n}',
    [test_case('factorial(5)', '120', '5! = 120'),
     test_case('factorial(0)', '1', '0! = 1'),
     test_case('factorial(1)', '1', '1! = 1')],
    ['Base case: 0! and 1! both equal 1',
     'For n > 1, factorial(n) = n * factorial(n-1)',
     'You can use iteration or recursion',
     'if (n <= 1) return 1; return n * factorial(n - 1);'],
    50).

exercise(func_2, functions, 'Is Prime',
    'Write a function that returns true if a number is prime, false otherwise.',
    'function isPrime(n) {\n  // Your code here\n  \n}',
    [test_case('isPrime(7)', 'true', '7 is prime'),
     test_case('isPrime(4)', 'false', '4 is not prime'),
     test_case('isPrime(2)', 'true', '2 is prime'),
     test_case('isPrime(1)', 'false', '1 is not prime')],
    ['Numbers less than 2 are not prime',
     'Check if n is divisible by any number from 2 to sqrt(n)',
     'If divisible by any number, its not prime',
     'if (n < 2) return false; for (let i = 2; i <= Math.sqrt(n); i++) { if (n % i === 0) return false; } return true;'],
    55).

% HTML Exercises
exercise(html_1, html_basics, 'Create a Webpage',
    'Create an HTML structure with a heading, paragraph, and an unordered list with 3 items.',
    '<!DOCTYPE html>\n<html>\n<head>\n  <title>My Page</title>\n</head>\n<body>\n  <!-- Add your HTML here -->\n  \n</body>\n</html>',
    [test_case('document.querySelector("h1")', 'exists', 'Should have an h1 element'),
     test_case('document.querySelector("p")', 'exists', 'Should have a paragraph'),
     test_case('document.querySelectorAll("li").length', '3', 'Should have 3 list items')],
    ['Use h1 for the heading',
     'Use p for paragraph',
     'Use ul and li for the list',
     '<h1>Welcome</h1><p>This is my page</p><ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul>'],
    30).

% CSS Exercises
exercise(css_1, css_basics, 'Style a Button',
    'Create CSS to style a button with blue background, white text, padding, and rounded corners.',
    '.btn {\n  /* Add your styles here */\n  \n}',
    [test_case('getComputedStyle(btn).backgroundColor', 'blue', 'Background should be blue'),
     test_case('getComputedStyle(btn).color', 'white', 'Text should be white'),
     test_case('getComputedStyle(btn).borderRadius', 'not 0', 'Should have rounded corners')],
    ['Use background-color for background',
     'Use color for text color',
     'Use padding for spacing inside',
     'Use border-radius for rounded corners',
     'background-color: blue; color: white; padding: 10px 20px; border-radius: 8px;'],
    35).

% DOM Manipulation Exercises
exercise(dom_1, dom_manipulation, 'Change Content',
    'Write JavaScript to change the text of an element with id "title" to "Hello World".',
    '// Change the title text\nconst title = document.getElementById("title");\n// Your code here\n',
    [test_case('document.getElementById("title").textContent', 'Hello World', 'Title should be changed')],
    ['Use textContent or innerHTML property',
     'Access the element first',
     'Then set its textContent',
     'title.textContent = "Hello World";'],
    25).

exercise(dom_2, dom_manipulation, 'Add Event Listener',
    'Add a click event listener to a button with id "myBtn" that shows an alert saying "Clicked!".',
    '// Add click event listener\nconst btn = document.getElementById("myBtn");\n// Your code here\n',
    [test_case('typeof btn.onclick', 'function', 'Button should have click handler')],
    ['Use addEventListener method',
     'First argument is event type ("click")',
     'Second argument is the callback function',
     'btn.addEventListener("click", () => alert("Clicked!"));'],
    30).

% React Exercises
exercise(react_1, react_basics, 'Create Component',
    'Create a React functional component called Greeting that displays "Hello, {name}!" where name is a prop.',
    'function Greeting(props) {\n  // Return JSX here\n  \n}',
    [test_case('Greeting({name: "World"})', '<h1>Hello, World!</h1>', 'Should display greeting')],
    ['Functional components return JSX',
     'Access props with props.name',
     'Use curly braces for JavaScript expressions in JSX',
     'return <h1>Hello, {props.name}!</h1>;'],
    40).

exercise(react_2, react_hooks, 'Counter with useState',
    'Create a Counter component with a count state that increments when a button is clicked.',
    'function Counter() {\n  // Use useState hook\n  \n  return (\n    <div>\n      {/* Display count and button */}\n    </div>\n  );\n}',
    [test_case('Counter state updates', 'increments', 'Count should increment on click')],
    ['Import useState from React',
     'const [count, setCount] = useState(0)',
     'Use onClick to call setCount',
     'const [count, setCount] = useState(0); return (<div><p>{count}</p><button onClick={() => setCount(count + 1)}>+</button></div>);'],
    50).

%==============================================
% INPUT VALIDATION & SANITIZATION
%==============================================

% Sanitize user input - remove dangerous characters
sanitize_input(Input, Sanitized) :-
    atom_string(Input, InputStr),
    re_replace('[^a-zA-Z0-9_@.\\-]'/g, '', InputStr, Sanitized).

% Validate required fields
require_field(Dict, Field) :- 
    catch(get_dict(Field, Dict, Value), _, fail),
    Value \== "", !.
require_field(_, Field) :- 
    throw(http_reply(bad_request(json{error: "Missing or empty field", field: Field}))).

% Validate user ID format
validate_user_id(UserId) :-
    atom_length(UserId, Len),
    Len > 0,
    Len < 256, !.
validate_user_id(_) :-
    throw(http_reply(bad_request(json{error: "Invalid user ID format"}))).

%==============================================
% API HANDLERS
%==============================================

% Health check endpoint
handle_health(_Request) :-
    get_time(Timestamp),
    db_sync(gc),
    reply_json_dict(json{
        status: "healthy",
        timestamp: Timestamp,
        service: "job-ready-backend",
        version: "2.0.0",
        database: "connected",
        features: ["videos", "exercises", "hints", "console", "progress-tracking"]
    }).

% Generate learning path
handle_generate_path(Request) :-
    check_rate_limit(Request, generate_path),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, userId),
         require_field(Data, careerPath),
         sanitize_input(Data.userId, UserId),
         validate_user_id(UserId),
         sanitize_input(Data.careerPath, CareerPath),
         atom_string(CareerPathAtom, CareerPath),
         (career_path(CareerPathAtom, _, _) -> true ; throw(error(invalid_career_path))),
         generate_learning_path(CareerPathAtom, OrderedSkills),
         retractall_user_path(UserId, _),
         assert_user_path(UserId, OrderedSkills),
         retractall_user_xp(UserId, _),
         assert_user_xp(UserId, 0),
         retractall_user_streak(UserId, _),
         assert_user_streak(UserId, 0),
         db_sync(gc),
         total_xp_for_skills(OrderedSkills, TotalXP),
         length(OrderedSkills, TotalSkills),
         maplist(skill_to_json, OrderedSkills, SkillsJson),
         log_info('Generated path for user'),
         reply_json_dict(json{
             success: true,
             path: SkillsJson,
             totalSkills: TotalSkills,
             totalXP: TotalXP,
             careerPath: CareerPath
         })),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get user progress
handle_get_progress(Request) :- 
    check_rate_limit(Request, get_progress),
    cors_enable_with_origin(Request),
    catch(
        (http_parameters(Request, [userId(UserIdRaw, [])]),
         sanitize_input(UserIdRaw, UserId),
         validate_user_id(UserId),
         (user_path(UserId, Path) -> 
            (findall(T, user_progress(UserId, T, completed), Completed),
             length(Path, Total),
             length(Completed, CompletedCount),
             Progress is (CompletedCount * 100) / Total,
             (user_xp(UserId, XP) -> true ; XP = 0),
             (user_streak(UserId, Streak) -> true ; Streak = 0),
             maplist(atom_string, Completed, CompletedStr),
             reply_json_dict(json{
                 success: true,
                 totalSkills: Total,
                 completed: CompletedCount,
                 progress: Progress,
                 xp: XP,
                 streak: Streak,
                 completedSkills: CompletedStr
             }))
          ; reply_json_dict(json{success: false, message: "No path for user"}))),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Update user progress
handle_update_progress(Request) :- 
    check_rate_limit(Request, update_progress),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, userId),
         require_field(Data, topic),
         sanitize_input(Data.userId, UserId),
         validate_user_id(UserId),
         sanitize_input(Data.topic, Topic),
         atom_string(TopicAtom, Topic),
         (skill(TopicAtom, _, _, _, _) -> true ; throw(error(invalid_topic))),
         retractall_user_progress(UserId, TopicAtom, _),
         assert_user_progress(UserId, TopicAtom, completed),
         skill(TopicAtom, _, _, _, XP),
         (user_xp(UserId, CurrentXP) ->
            (NewXP is CurrentXP + XP,
             retractall_user_xp(UserId, _),
             assert_user_xp(UserId, NewXP))
          ; (assert_user_xp(UserId, XP), NewXP = XP)),
         (user_streak(UserId, Streak) ->
            (NewStreak is Streak + 1,
             retractall_user_streak(UserId, _),
             assert_user_streak(UserId, NewStreak))
          ; (assert_user_streak(UserId, 1), NewStreak = 1)),
         db_sync(gc),
         log_info('Progress updated'),
         reply_json_dict(json{
             success: true,
             xp: NewXP,
             xpGained: XP,
             streak: NewStreak,
             message: "Progress updated!"
         })),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get next topic
handle_next_topic(Request) :- 
    check_rate_limit(Request, next_topic),
    cors_enable_with_origin(Request),
    catch(
        (http_parameters(Request, [userId(UserIdRaw, [])]),
         sanitize_input(UserIdRaw, UserId),
         validate_user_id(UserId),
         (get_next_topic(UserId, NextTopic) ->
            (atom_string(NextTopic, NextTopicStr),
             skill(NextTopic, Domain, Difficulty, Hours, XP),
             atom_string(Domain, DomainStr),
             atom_string(Difficulty, DiffStr),
             reply_json_dict(json{
                 success: true,
                 nextTopic: NextTopicStr,
                 domain: DomainStr,
                 difficulty: DiffStr,
                 hours: Hours,
                 xp: XP
             }))
          ; reply_json_dict(json{success: false, message: "All done! JOB READY!"}))),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get projects by level
handle_get_projects(Request) :- 
    check_rate_limit(Request, get_projects),
    cors_enable_with_origin(Request),
    catch(
        (http_parameters(Request, [level(LevelRaw, [])]),
         sanitize_input(LevelRaw, Level),
         atom_string(LevelAtom, Level),
         findall(json{
             title: Title,
             requiredSkills: ReqSkillsStr,
             description: Desc,
             features: Features
         }, (
             project(LevelAtom, Title, ReqSkills, Desc, Features),
             maplist(atom_string, ReqSkills, ReqSkillsStr)
         ), Projects),
         reply_json_dict(json{success: true, projects: Projects})),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get all career paths
handle_career_paths(Request) :- 
    check_rate_limit(Request, career_paths),
    cors_enable_with_origin(Request),
    catch(
        (findall(json{
             id: PathStr,
             name: NameStr,
             totalSkills: Total,
             estimatedHours: Hours
         }, (
             career_path(Path, Skills, Hours),
             atom_string(Path, PathStr),
             format_career_name(Path, NameStr),
             length(Skills, Total)
         ), Paths),
         reply_json_dict(json{success: true, paths: Paths})),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get skill tree with status
handle_skill_tree(Request) :- 
    check_rate_limit(Request, skill_tree),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, userId),
         require_field(Data, careerPath),
         sanitize_input(Data.userId, UserId),
         validate_user_id(UserId),
         sanitize_input(Data.careerPath, CareerPath),
         atom_string(CareerPathAtom, CareerPath),
         skill_tree_with_status(UserId, CareerPathAtom, SkillTree),
         reply_json_dict(json{success: true, skillTree: SkillTree})),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get learning resources for a topic
handle_get_resources(Request) :- 
    check_rate_limit(Request, get_resources),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, topic),
         sanitize_input(Data.topic, Topic),
         atom_string(TopicAtom, Topic),
         findall(json{
             type: TypeStr,
             content: Content,
             example: Example
         }, (
             resource(TopicAtom, Type, Content, Example),
             atom_string(Type, TypeStr)
         ), Resources),
         reply_json_dict(json{success: true, resources: Resources})),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

%==============================================
% NEW INTERACTIVE LEARNING API HANDLERS
%==============================================

% Get video lessons for a topic
handle_get_video(Request) :- 
    check_rate_limit(Request, get_video),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, topic),
         sanitize_input(Data.topic, Topic),
         atom_string(TopicAtom, Topic),
         findall(json{
             videoId: VideoId,
             title: Title,
             duration: Duration,
             description: Desc
         }, video(TopicAtom, VideoId, Title, Duration, Desc), Videos),
         reply_json_dict(json{success: true, videos: Videos, topic: Topic})),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get exercises for a topic
handle_get_exercises(Request) :- 
    check_rate_limit(Request, get_exercises),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, topic),
         sanitize_input(Data.topic, Topic),
         atom_string(TopicAtom, Topic),
         findall(json{
             id: ExIdStr,
             title: Title,
             description: Desc,
             starterCode: Code,
             xp: XP,
             testCount: TestCount
         }, (
             exercise(ExId, TopicAtom, Title, Desc, Code, Tests, _, XP),
             atom_string(ExId, ExIdStr),
             length(Tests, TestCount)
         ), Exercises),
         reply_json_dict(json{success: true, exercises: Exercises, topic: Topic})),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Submit exercise and record attempt
handle_submit_exercise(Request) :- 
    check_rate_limit(Request, submit_exercise),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, userId),
         require_field(Data, exerciseId),
         require_field(Data, code),
         sanitize_input(Data.userId, UserId),
         validate_user_id(UserId),
         atom_string(ExerciseIdAtom, Data.exerciseId),
         atom_string(CodeAtom, Data.code),
         (get_dict(passed, Data, PassedBool) -> true ; PassedBool = false),
         (PassedBool == true -> PassedAtom = true ; PassedAtom = false),
         get_time(Timestamp),
         % Record the attempt
         assert_user_exercise_attempt(UserId, ExerciseIdAtom, CodeAtom, PassedAtom, Timestamp),
         % Update last activity
         retractall_user_last_activity(UserId, _),
         assert_user_last_activity(UserId, Timestamp),
         % If passed, award XP
         (PassedAtom == true ->
             (exercise(ExerciseIdAtom, _, _, _, _, _, _, ExerciseXP),
              (user_xp(UserId, CurrentXP) ->
                  (NewXP is CurrentXP + ExerciseXP,
                   retractall_user_xp(UserId, _),
                   assert_user_xp(UserId, NewXP))
              ; (assert_user_xp(UserId, ExerciseXP), NewXP = ExerciseXP)),
              XPGained = ExerciseXP)
         ; (NewXP = 0, XPGained = 0, (user_xp(UserId, NewXP) -> true ; NewXP = 0))),
         db_sync(gc),
         log_info('Exercise attempt recorded'),
         reply_json_dict(json{
             success: true,
             passed: PassedBool,
             xpGained: XPGained,
             totalXp: NewXP,
             message: "Attempt recorded"
         })),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get hints for an exercise
handle_get_hints(Request) :- 
    check_rate_limit(Request, get_hints),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, exerciseId),
         atom_string(ExerciseIdAtom, Data.exerciseId),
         (get_dict(hintLevel, Data, HintLevel) -> true ; HintLevel = 0),
         % Get user ID if provided to track hint usage
         (get_dict(userId, Data, UserIdRaw) ->
             (sanitize_input(UserIdRaw, UserId),
              validate_user_id(UserId),
              assert_user_hint_used(UserId, ExerciseIdAtom, HintLevel),
              db_sync(gc))
         ; true),
         % Get the hints for this exercise
         exercise(ExerciseIdAtom, _, _, _, _, _, AllHints, _),
         length(AllHints, TotalHints),
         MaxLevel is min(HintLevel + 1, TotalHints),
         % Get hints up to the requested level
         findall(Hint, (
             nth0(Idx, AllHints, Hint),
             Idx < MaxLevel
         ), AvailableHints),
         % Calculate hasMoreHints as a proper boolean
         Remaining is TotalHints - 1,
         (HintLevel < Remaining -> HasMore = true ; HasMore = false),
         reply_json_dict(json{
             success: true,
             hints: AvailableHints,
             currentLevel: HintLevel,
             totalHints: TotalHints,
             hasMoreHints: HasMore
         })),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Run code (mock execution - frontend handles actual JS execution)
handle_run_code(Request) :- 
    check_rate_limit(Request, run_code),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, code),
         require_field(Data, exerciseId),
         atom_string(ExerciseIdAtom, Data.exerciseId),
         % Get test cases for the exercise
         exercise(ExerciseIdAtom, _, _, _, _, TestCases, _, _),
         % Convert test cases to JSON
         findall(json{
             input: Input,
             expected: Expected,
             description: Desc
         }, member(test_case(Input, Expected, Desc), TestCases), TestsJson),
         reply_json_dict(json{
             success: true,
             tests: TestsJson,
             message: "Tests retrieved for client-side execution"
         })),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get exercise attempts for a user
handle_get_exercise_attempts(Request) :- 
    check_rate_limit(Request, get_exercise_attempts),
    cors_enable_with_origin(Request),
    catch(
        (http_read_json_dict(Request, Data),
         require_field(Data, userId),
         sanitize_input(Data.userId, UserId),
         validate_user_id(UserId),
         % Get exercise ID filter if provided
         (get_dict(exerciseId, Data, ExIdRaw) ->
             (atom_string(ExIdFilter, ExIdRaw),
              findall(json{
                  exerciseId: ExIdStr,
                  passed: PassedBool,
                  timestamp: TS
              }, (
                  user_exercise_attempt(UserId, ExIdFilter, _, Passed, TS),
                  atom_string(ExIdFilter, ExIdStr),
                  (Passed == true -> PassedBool = true ; PassedBool = false)
              ), Attempts))
         ; findall(json{
              exerciseId: ExIdStr,
              passed: PassedBool,
              timestamp: TS
          }, (
              user_exercise_attempt(UserId, ExId, _, Passed, TS),
              atom_string(ExId, ExIdStr),
              (Passed == true -> PassedBool = true ; PassedBool = false)
          ), Attempts)),
         reply_json_dict(json{success: true, attempts: Attempts})),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

% Get detailed progress with all statistics
handle_get_detailed_progress(Request) :- 
    check_rate_limit(Request, get_detailed_progress),
    cors_enable_with_origin(Request),
    catch(
        (http_parameters(Request, [userId(UserIdRaw, [])]),
         sanitize_input(UserIdRaw, UserId),
         validate_user_id(UserId),
         % Basic progress
         (user_path(UserId, Path) -> true ; Path = []),
         findall(T, user_progress(UserId, T, completed), Completed),
         length(Path, Total),
         length(Completed, CompletedCount),
         (Total > 0 -> Progress is (CompletedCount * 100) / Total ; Progress = 0),
         (user_xp(UserId, XP) -> true ; XP = 0),
         (user_streak(UserId, Streak) -> true ; Streak = 0),
         (user_last_activity(UserId, LastActivity) -> true ; LastActivity = 0),
         % Exercise attempts statistics
         findall(1, user_exercise_attempt(UserId, _, _, _, _), AllAttempts),
         length(AllAttempts, TotalAttempts),
         findall(1, user_exercise_attempt(UserId, _, _, true, _), PassedAttempts),
         length(PassedAttempts, TotalPassed),
         % Videos watched
         findall(V, user_video_watched(UserId, _, V, _), VideosWatched),
         length(VideosWatched, VideoCount),
         % Hints used
         findall(1, user_hint_used(UserId, _, _), HintsUsed),
         length(HintsUsed, HintCount),
         maplist(atom_string, Completed, CompletedStr),
         reply_json_dict(json{
             success: true,
             totalSkills: Total,
             completed: CompletedCount,
             progress: Progress,
             xp: XP,
             streak: Streak,
             lastActivity: LastActivity,
             completedSkills: CompletedStr,
             statistics: json{
                 totalExerciseAttempts: TotalAttempts,
                 exercisesPassed: TotalPassed,
                 videosWatched: VideoCount,
                 hintsUsed: HintCount
             }
         })),
        Error,
        (log_error(Error),
         reply_json_dict(json{success: false, message: "Server error"}, [status(500)]))
    ).

%==============================================
% HELPER PREDICATES
%==============================================

% Convert skill to JSON
skill_to_json(Skill, Json) :- 
    skill(Skill, Domain, Difficulty, Hours, XP),
    atom_string(SkillStr, Skill),
    atom_string(DomainStr, Domain),
    atom_string(Difficulty, DiffStr),
    Json = json{
        name: SkillStr,
        domain: DomainStr,
        difficulty: DiffStr,
        hours: Hours,
        xp: XP
    }.

% Format career path names
format_career_name(frontend_developer, "Frontend Developer").
format_career_name(backend_developer, "Backend Developer").
format_career_name(fullstack_developer, "Full Stack Developer").
format_career_name(data_structures_algorithms, "DSA Expert").
format_career_name(devops_engineer, "DevOps Engineer").

% Get all prerequisites (transitive closure)
all_prerequisites(Skill, AllPrereqs) :-
    findall(P, prerequisite_chain(P, Skill), Prereqs),
    list_to_set(Prereqs, AllPrereqs).

prerequisite_chain(P, Skill) :- prerequisite(P, Skill).
prerequisite_chain(P, Skill) :- prerequisite(X, Skill), prerequisite_chain(P, X).

% Generate ordered learning path using topological sort
generate_learning_path(CareerPath, OrderedSkills) :-
    career_path(CareerPath, Skills, _),
    topological_sort(Skills, OrderedSkills).

topological_sort(Skills, Sorted) :- topological_sort(Skills, [], Sorted).
topological_sort([], Acc, Result) :- reverse(Acc, Result).
topological_sort(Skills, Acc, Result) :- 
    select(Skill, Skills, Rest),
    \+ (member(Other, Rest), prerequisite_chain(Skill, Other)),
    topological_sort(Rest, [Skill|Acc], Result).

% Calculate total XP for skills
total_xp_for_skills(Skills, TotalXP) :-
    findall(XP, (member(Skill, Skills), skill(Skill, _, _, _, XP)), XPs),
    sum_list(XPs, TotalXP).

% Get next available topic
get_next_topic(UserId, NextTopic) :-
    user_path(UserId, Path),
    findall(T, (member(T, Path), user_progress(UserId, T, completed)), Completed),
    member(NextTopic, Path),
    \+ member(NextTopic, Completed),
    all_prerequisites(NextTopic, Prereqs),
    forall(member(P, Prereqs), member(P, Completed)), !.

% Get skill tree with status
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

% CORS helper - adds CORS headers to response
% This is a simplified CORS implementation compatible with SWI-Prolog's HTTP server
cors_enable_with_origin(Request) :-
    (memberchk(origin(Origin), Request) -> true ; Origin = 'http://localhost:3000'),
    get_config(allowed_origins, AllowedOrigins),
    (member(Origin, AllowedOrigins) -> AllowedOrigin = Origin 
    ; AllowedOrigin = 'http://localhost:3000'),
    % Set CORS headers using format to current output
    format('Access-Control-Allow-Origin: ~w~n', [AllowedOrigin]),
    format('Access-Control-Allow-Methods: GET, POST, OPTIONS~n', []),
    format('Access-Control-Allow-Headers: Content-Type, Authorization~n', []),
    format('Access-Control-Max-Age: 86400~n', []).

% Alternative CORS handler that just succeeds (headers handled by nginx in production)
cors_enable_simple(_Request) :- true.

%==============================================
% SERVER STARTUP
%==============================================

start_server(Port) :-
    initialize_db,
    http_server(http_dispatch, [port(Port)]),
    format('~n╔════════════════════════════════════════════════════════════╗~n', []),
    format('║     🚀 JOB READY PLATFORM - PRODUCTION BACKEND READY      ║~n', []),
    format('╚════════════════════════════════════════════════════════════╝~n~n', []),
    format('   📡 Server:           http://localhost:~w~n', [Port]),
    format('   🔗 API Endpoints:    /api/*~n', []),
    format('   💾 Database:         data/user_data.db~n', []),
    format('   🛡️  Rate Limiting:    ENABLED (60 req/min)~n', []),
    format('   🔒 Input Validation: ENABLED~n', []),
    format('   📊 Logging Level:    INFO~n', []),
    format('~n   ✨ All systems operational! Ready for production!~n~n', []).

:- initialization(start_server(8080)).
