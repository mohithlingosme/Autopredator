<?php
// Autopredator Vehicle Management Dashboard
// This script outputs the visually appealing, high-contrast dashboard structure.
// It is ready for future integration of dynamic PHP content.
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Autopredator - Vehicle Management System</title>
    <!-- Load Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Load Inter Font -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
    <!-- Load Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <!-- Load AOS for Animations -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/aos@2.3.4/dist/aos.css">
    
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    },
                    colors: {
                        'background-dark': '#0F172A', // Slate 900
                        'card-dark': '#1E293B', // Slate 800
                        'primary-indigo': '#6366F1', // Indigo 500
                        'accent-cyan': '#06B6D4', // Cyan 500
                    }
                }
            }
        }
    </script>
    
    <style>
        /* Defaulting to dark mode for the high-tech, predator aesthetic */
        body {
            background-color: #0F172A;
            color: #E2E8F0;
            transition: background-color 0.3s, color 0.3s;
        }
        
        .feature-card {
            /* Glassmorphism/Dark Card look */
            background-color: #1E293B;
            border: 1px solid #334155; 
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .feature-card:hover {
            /* Lift and glow effect on hover */
            transform: translateY(-8px);
            box-shadow: 0 15px 30px rgba(99, 102, 241, 0.3); /* Shadow with indigo accent */
            border-color: #6366F1;
        }

        .icon-circle {
            /* Styling for the circular icon background */
            width: 56px; 
            height: 56px; 
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            background-color: #312E81; /* Dark Indigo */
        }
        
        /* Apply background to the Hero Section */
        .hero-section {
            background-image: linear-gradient(135deg, #1E293B 0%, #0F172A 100%);
            border: 1px solid #334155;
        }

        /* Ensure the search bar looks great in the dark theme */
        .search-bar-input {
            background-color: #334155;
            color: #E2E8F0;
            border: 1px solid #475569;
        }
        .search-bar-input::placeholder {
            color: #94A3B8;
        }

        .sidebar {
            position: fixed;
            top: 0;
            left: -250px;
            width: 250px;
            height: 100%;
            background: var(--base-background);
            display: flex;
            flex-direction: column;
            padding-top: 4rem;
            transition: var(--transition);
            z-index: 1000;
            box-shadow: var(--box-shadow);
        }

        .sidebar.show-sidebar {
            left: 0;
        }

        .sidebar a {
            padding: 1rem;
            color: var(--base-text);
            text-decoration: none;
            font-size: 1.1rem;
            display: block;
            transition: var(--transition);
        }

        .sidebar a:hover {
            background: #e9ecef;
            color: var(--primary-color);
        }

        .sidebar .close-btn {
            position: absolute;
            top: 1rem;
            right: 1rem;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--base-text);
            background: none;
            border: none;
        }

        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: none;
            z-index: 900;
        }

        .overlay.show-overlay {
            display: block;
        }
    </style>
</head>
<body class="font-sans min-h-screen">


    <!-- Header & Navigation -->
    <header class="sticky top-0 z-50 bg-background-dark/95 backdrop-blur-md border-b border-slate-700 shadow-xl">
        <div class="container mx-auto px-4 py-4 flex justify-between items-center">
            <!-- Logo/Title -->
            <a href="#home" class="text-3xl font-extrabold text-accent-cyan tracking-wider">
                <i class="fas fa-satellite-dish mr-2 text-primary-indigo"></i> AUTOPREDATOR
            </a>
            
            <!-- Desktop Nav Links -->
            <nav class="hidden md:flex space-x-8 items-center">
                <a href="#home" class="text-slate-300 hover:text-primary-indigo transition font-medium">Home</a>
                <a href="#features" class="text-slate-300 hover:text-primary-indigo transition font-medium">Services</a>
                <a href="#" class="text-slate-300 hover:text-primary-indigo transition font-medium">Pricing</a>
                <a href="#" class="text-slate-300 hover:text-primary-indigo transition font-medium">Contact</a>
                <button id="theme-toggle" class="p-2 rounded-full text-slate-300 hover:bg-card-dark transition">
                    <i class="fas fa-sun text-xl"></i>
                </button>
            </nav>

            <!-- Mobile Menu Button -->
            <button id="mobile-menu-button" class="md:hidden p-2 rounded-full text-slate-300 hover:bg-card-dark transition" onclick="openMenu()">
                <i class="fas fa-bars text-xl"></i>
            </button>
        </div>

        <!-- Mobile Menu (Collapsed by default) -->
        <nav id="mobile-menu" class="hidden md:hidden p-4 border-t border-slate-700">
            <a href="#home" class="block py-2 text-slate-300 hover:bg-slate-700 rounded transition">Home</a>
            <a href="#features" class="block py-2 text-slate-300 hover:bg-slate-700 rounded transition">Services</a>
            <a href="#" class="block py-2 text-slate-300 hover:bg-slate-700 rounded transition">Pricing</a>
            <a href="#" class="block py-2 text-slate-300 hover:bg-slate-700 rounded transition">Contact</a>
        </nav>
    </header>

    <div id="sidebar" class="sidebar">
    <button class="close-btn" onclick="closeMenu()">✖</button>
    <a href="#home"><i class="fas fa-home"></i> Home</a>
    <a href="#features"><i class="fas fa-cogs"></i> Features</a>
    <a href="#about"><i class="fas fa-info-circle"></i> About</a>
    <a href="#contact"><i class="fas fa-envelope"></i> Contact</a>
</div>

<div id="overlay" class="overlay" onclick="closeMenu()"></div>

    <main class="container mx-auto px-4 py-12">


        <!-- Search Bar -->
        <div class="flex max-w-2xl mx-auto mb-16 space-x-2">
            <input type="text" id="search-bar" class="search-bar-input w-full p-4 rounded-xl placeholder-slate-400 focus:ring-2 focus:ring-primary-indigo focus:outline-none transition" placeholder="Search the fleet, features, or support articles...">
            <button class="cta-button px-6 py-3 bg-primary-indigo hover:bg-indigo-600 rounded-xl text-white font-semibold shadow-xl transition-colors duration-300" onclick="searchFunction()">
                <i class="fas fa-search"></i>
            </button>
        </div>

        <!-- Hero Section -->
        <section class="hero-section text-center py-20 rounded-2xl shadow-2xl mb-16" id="home" data-aos="fade-up">
            <h1 class="text-4xl sm:text-5xl lg:text-7xl font-extrabold text-white mb-6 leading-snug tracking-wide">
                Vehicle Intelligence, <span class="text-accent-cyan block sm:inline-block">Perfected.</span>
            </h1>
            <p class="text-lg sm:text-xl text-slate-300 mb-10 max-w-4xl mx-auto">
                Track, maintain, and optimize your fleet with **AI-powered analytics and real-time telematics**. Stay ahead with Autopredator.
            </p>
            <a href="#features" class="inline-block px-12 py-4 text-white bg-primary-indigo hover:bg-indigo-600 rounded-full font-bold text-xl shadow-lg shadow-indigo-500/50 transform hover:scale-105 transition-all duration-300 uppercase tracking-wider">
                Explore the System
            </a>
        </section>

        <!-- Cars Listing Section -->
        <section class="mb-20" data-aos="fade-up">
            <h1 class="text-4xl font-extrabold text-slate-200 mb-4 pt-4 text-center">Current Fleet & Listings</h1>
            <div class="h-1 mx-auto bg-primary-indigo w-24 rounded-full mb-8"></div>
            <div class="text-center">
                <a href="#" class="px-10 py-3 border-2 border-accent-cyan text-accent-cyan hover:bg-accent-cyan hover:text-background-dark rounded-full font-semibold transition-all duration-300 text-lg">
                    <i class="fas fa-car-side mr-3"></i> View Car Listings
                </a>
            </div>
        </section>

        <!-- Features/Services Section -->
        <section class="pt-8" id="features">
            <h1 class="text-4xl font-extrabold text-slate-200 mb-4 text-center">Core Services Modules</h1>
            <div class="h-1 mx-auto bg-primary-indigo w-24 rounded-full mb-12"></div>
            
            <!-- Feature Grid - Highly Responsive -->
            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
                
                <!-- Feature 1: Documentation -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-file-lines"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Documentation</h2>
                        <p class="text-sm text-slate-400">Centralize all vehicle documents and history.</p>
                    </a>
                </div>
                
                <!-- Feature 2: Fleet Optimization -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="50">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-route"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Fleet Optimization</h2>
                        <p class="text-sm text-slate-400">Optimize routes and monitor driver performance.</p>
                    </a>
                </div>
                
                <!-- Feature 3: Financial Insights -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="100">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-chart-line"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Financial Insights</h2>
                        <p class="text-sm text-slate-400">Track expenses for strategic planning.</p>
                    </a>
                </div>
                
                <!-- Feature 4: Insurance Management -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="150">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-shield-halved"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Insurance Mgmt.</h2>
                        <p class="text-sm text-slate-400">Manage and remind about insurance renewals.</p>
                    </a>
                </div>
                
                <!-- Feature 5: Vehicle Maintenance -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="200">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-wrench"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Maintenance</h2>
                        <p class="text-sm text-slate-400">Schedule maintenance proactively.</p>
                    </a>
                </div>
                
                <!-- Feature 6: Fuel & Expense Tracking -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="250">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-gas-pump"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Fuel & Expense</h2>
                        <p class="text-sm text-slate-400">Monitor fuel use and manage costs efficiently.</p>
                    </a>
                </div>
                
                <!-- Feature 7: GPS & Telematics -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="300">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-location-dot"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">GPS & Telematics</h2>
                        <p class="text-sm text-slate-400">Real-time vehicle tracking and monitoring.</p>
                    </a>
                </div>
                
                <!-- Feature 8: Driver Safety -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="350">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-user-shield"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Driver Safety</h2>
                        <p class="text-sm text-slate-400">Monitor driver behavior for safety and compliance.</p>
                    </a>
                </div>
                
                <!-- Feature 9: EV Tools -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="400">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-charging-station"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">EV Tools</h2>
                        <p class="text-sm text-slate-400">Manage electric vehicles with specialized tools.</p>
                    </a>
                </div>
                
                <!-- Feature 10: Compliance & Regulations -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="450">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-gavel"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Compliance</h2>
                        <p class="text-sm text-slate-400">Keep abreast of regulatory changes and ensure compliance.</p>
                    </a>
                </div>
                
                <!-- Feature 11: Vehicle Search -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-magnifying-glass-car"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Vehicle Search</h2>
                        <p class="text-sm text-slate-400">Identify ideal vehicles tailored to specific requirements.</p>
                    </a>
                </div>
                
                <!-- Feature 12: Fleet Management -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="50">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-truck-field"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Fleet Management</h2>
                        <p class="text-sm text-slate-400">Efficiently manage your entire fleet with tools.</p>
                    </a>
                </div>
                
                <!-- Feature 13: Logistics and Delivery -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="100">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-box-open"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Logistics & Delivery</h2>
                        <p class="text-sm text-slate-400">Enhance delivery operations with state-of-the-art logistics tools.</p>
                    </a>
                </div>
                
                <!-- Feature 14: Agricultural Tools -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="150">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-tractor"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Agricultural Tools</h2>
                        <p class="text-sm text-slate-400">Tools specifically designed for the agricultural industry.</p>
                    </a>
                </div>
                
                <!-- Feature 15: E-commerce Integration -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="200">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-shop"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">E-commerce</h2>
                        <p class="text-sm text-slate-400">Integrate with e-commerce for vehicle sales and parts.</p>
                    </a>
                </div>
                
                <!-- Feature 16: Financial Services -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="250">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-money-bill-transfer"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Financial Services</h2>
                        <p class="text-sm text-slate-400">Access vehicle loans and other financial products.</p>
                    </a>
                </div>
                
                <!-- Feature 17: Valuation Services -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="300">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-scale-balanced"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Valuation Services</h2>
                        <p class="text-sm text-slate-400">Get accurate market valuations and trade-in options.</p>
                    </a>
                </div>
                
                <!-- Feature 18: Legal Services -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="350">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-stamp"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Legal Services</h2>
                        <p class="text-sm text-slate-400">Receive legal support for vehicle compliance and issues.</p>
                    </a>
                </div>
                
                <!-- Feature 19: Traffic Management -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="400">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-traffic-light"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Traffic Mgmt.</h2>
                        <p class="text-sm text-slate-400">Handle traffic violations and fines with effective tools.</p>
                    </a>
                </div>
                
                <!-- Feature 20: Dealership Search -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="450">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-building"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Dealership Search</h2>
                        <p class="text-sm text-slate-400">Find authorized dealers and service centers easily.</p>
                    </a>
                </div>
                
                <!-- Feature 21: Bank Auctions -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-hammer"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Bank Auctions</h2>
                        <p class="text-sm text-slate-400">Participate in bank-hosted vehicle auctions.</p>
                    </a>
                </div>
                
                <!-- Feature 22: Customer Support -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="50">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-headset"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Customer Support</h2>
                        <p class="text-sm text-slate-400">Provide 24/7 support to address any client queries.</p>
                    </a>
                </div>
                
                <!-- Feature 23: Market Trends -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="100">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-arrow-trend-up"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Market Trends</h2>
                        <p class="text-sm text-slate-400">Access up-to-date vehicle market forecasts.</p>
                    </a>
                </div>
                
                <!-- Feature 24: Customization Tools -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="150">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-paint-roller"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Customization</h2>
                        <p class="text-sm text-slate-400">Customize your vehicles to meet specific needs.</p>
                    </a>
                </div>
                
                <!-- Feature 25: Vehicle Resale -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="200">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-sack-dollar"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Vehicle Resale</h2>
                        <p class="text-sm text-slate-400">Assist with selling vehicles at optimal prices.</p>
                    </a>
                </div>
                
                <!-- Feature 26: Parts Inventory -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="250">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-warehouse"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Parts Inventory</h2>
                        <p class="text-sm text-slate-400">Track and manage parts inventory for repairs.</p>
                    </a>
                </div>
                
                <!-- Feature 27: Ridesharing -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="300">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-car-side"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Ridesharing</h2>
                        <p class="text-sm text-slate-400">Solutions for ridesharing to maximize utilization.</p>
                    </a>
                </div>
                
                <!-- Feature 28: Mobile App -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="350">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-mobile-screen-button"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Mobile App</h2>
                        <p class="text-sm text-slate-400">Manage all features from a dedicated mobile app.</p>
                    </a>
                </div>

                <!-- Feature 29: Telematics Analysis -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="400">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-signal"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Telematics Analysis</h2>
                        <p class="text-sm text-slate-400">Utilize analytics for detailed telematics insights.</p>
                    </a>
                </div>

                <!-- Feature 30: Fleet Renewal -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="450">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-recycle"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Fleet Renewal</h2>
                        <p class="text-sm text-slate-400">Advice on renewing your fleet for optimal performance.</p>
                    </a>
                </div>

                <!-- Feature 31: Safety Training -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-graduation-cap"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Safety Training</h2>
                        <p class="text-sm text-slate-400">Offer training for driver safety and compliance.</p>
                    </a>
                </div>

                <!-- Feature 32: Transport Permits -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="50">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-id-card"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Transport Permits</h2>
                        <p class="text-sm text-slate-400">Help with obtaining and managing transport permits.</p>
                    </a>
                </div>

                <!-- Feature 33: Reporting Tools -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="100">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
                        <div class="icon-circle rounded-full text-white"><i class="fas fa-file-csv"></i></div>
                        <h2 class="text-xl font-bold text-primary-indigo">Reporting Tools</h2>
                        <p class="text-sm text-slate-400">Create custom reports for audits and insights.</p>
                    </a>
                </div>

                <!-- Feature 34: Emergency Services -->
                <div class="feature-card p-6 rounded-xl shadow-lg" data-aos="fade-up" data-aos-delay="150">
                    <a href="#" class="flex flex-col items-center text-center space-y-3">
