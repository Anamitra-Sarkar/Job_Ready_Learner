/*
==============================================
JOB READY PLATFORM - PRODUCTION PROLOG BACKEND
Rate limiting, input validation, persistence, CORS, error handling
Version: 1.0.0
==============================================
*/

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/cors)).
:- use_module(library(http/json)).
:- use_module(library(http/http_header)).
:- use_module(library(persistency)).
:- use_module(library(settings)).

% Production settings
:- setting(allowed_origins, list, ['http://localhost:3000', 'http://localhost']).
:- setting(enable_rate_limit, boolean, true).
:- setting(max_requests_per_minute, integer, 60).
:- setting(log_level, atom, info). % debug, info, warn, error

% Dynamic predicates for rate limiting
:- dynamic request_count/3.  % request_count(IP, Endpoint, Count)
:- dynamic last_cleanup/1.   % last_cleanup(Timestamp)

% HTTP Route Handlers
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

% CORS preflight handler
handle_options(Request) :-
    cors_enable_with_origin(Request),
    throw(http_reply(no_content)).

% Rate limiting implementation
check_rate_limit(Request, Endpoint) :-
    setting(enable_rate_limit, false), !.
check_rate_limit(Request, Endpoint) :-
    setting(enable_rate_limit, true),
    (memberchk(peer(IP), Request) -> true ; IP = unknown),
    get_time(Now),
    cleanup_old_counts(Now),
    setting(max_requests_per_minute, MaxRequests),
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
    user_streak(user_id:atom, streak:integer).

:- db_attach('data/user_data.db', []).

% Initialize database
initialize_db :- 
    (exists_directory('data') -> true ; make_directory('data')),
    db_attach('data/user_data.db', []),
    log_info('Database initialized: data/user_data.db').

% Logging utilities
log_debug(Message) :- setting(log_level, debug), !, format('DEBUG: ~w~n', [Message]).
log_debug(_).

log_info(Message) :- 
    setting(log_level, Level),
    member(Level, [debug, info]), !,
    format('INFO: ~w~n', [Message]).
log_info(_).

log_warn(Message) :- 
    setting(log_level, Level),
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
        version: "1.0.0",
        database: "connected"
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

% CORS helper
cors_enable_with_origin(Request) :-
    (memberchk(origin(Origin), Request) -> true ; Origin = 'http://localhost:3000'),
    setting(allowed_origins, AllowedOrigins),
    (member(Origin, AllowedOrigins) -> AllowedOrigin = Origin ; AllowedOrigin = 'http://localhost:3000'),
    cors_enable(Request, [
        methods([get,post,options]), 
        origins([AllowedOrigin]), 
        headers(['content-type','authorization'])
    ]).

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
