# Gemfile
# DELPHY COSMOS v4 Deployment Gemfile
# Defines dependencies required for DELPHY tools, procedures, and workflows.

# --------------------------------------------
# RUBY VERSION
# --------------------------------------------
ruby '3.1.2'

# --------------------------------------------
# COSMOS CORE
# --------------------------------------------
# Core COSMOS framework for command, telemetry, and scripting
gem 'cosmos', '~> 4.0'
gem 'cosmos-tool-runner', '~> 4.0'
gem 'cosmos-procedure-engine', '~> 4.0'

# --------------------------------------------
# NETWORK COMMUNICATION
# --------------------------------------------
# Libraries for managing TCP/IP communication
gem 'net-telnet', '~> 0.2.0'
gem 'socketry', '~> 0.5.1'

# --------------------------------------------
# PARSING AND SERIALIZATION
# --------------------------------------------
# YAML and JSON parsing libraries
gem 'psych', '~> 4.0'
gem 'json', '~> 2.6'

# --------------------------------------------
# LOGGING
# --------------------------------------------
# Structured logging libraries
gem 'logger', '~> 1.6'
gem 'lograge', '~> 0.12.0'

# --------------------------------------------
# ERROR HANDLING
# --------------------------------------------
# Error monitoring and structured exception handling
gem 'sentry-raven', '~> 3.1'

# --------------------------------------------
# SCHEDULING AND AUTOMATION
# --------------------------------------------
# Cron-style scheduling and task automation
gem 'rufus-scheduler', '~> 3.8'

# --------------------------------------------
# SYSTEM MONITORING
# --------------------------------------------
# Tools for monitoring system resources
gem 'sys-proctable', '~> 1.2'
gem 'sys-filesystem', '~> 1.4'

# --------------------------------------------
# DATA MANAGEMENT AND CACHING
# --------------------------------------------
# Libraries for managing in-memory cache and persistence
gem 'redis', '~> 4.8'
gem 'dalli', '~> 3.2' # Memcached client

# --------------------------------------------
# SECURITY
# --------------------------------------------
# Encryption, hashing, and security utilities
gem 'openssl', '~> 3.0'
gem 'bcrypt', '~> 3.1.18'

# --------------------------------------------
# MAILER FOR ALERTS
# --------------------------------------------
# Send alert notifications via email
gem 'mail', '~> 2.8'

# --------------------------------------------
# COMMAND LINE INTERFACE
# --------------------------------------------
# Command-line scripting support
gem 'thor', '~> 1.2'

# --------------------------------------------
# FILE MANAGEMENT
# --------------------------------------------
# Utilities for managing files and logs
gem 'fileutils', '~> 1.7'
gem 'zip', '~> 3.0'

# --------------------------------------------
# TESTING AND VALIDATION
# --------------------------------------------
# Unit and integration testing frameworks
gem 'rspec', '~> 3.12'
gem 'minitest', '~> 5.15'

# --------------------------------------------
# DOCUMENTATION
# --------------------------------------------
# Documentation generation tools
gem 'yard', '~> 0.9.34'

# --------------------------------------------
# DATABASE SUPPORT (Optional)
# --------------------------------------------
# For optional telemetry database storage
gem 'sqlite3', '~> 1.6'
gem 'activerecord', '~> 7.0'

# --------------------------------------------
# DEVELOPMENT TOOLS
# --------------------------------------------
# Debugging and code inspection tools
gem 'pry', '~> 0.14'
gem 'byebug', '~> 11.1'

# --------------------------------------------
# VERSION CONTROL
# --------------------------------------------
# Git integration library
gem 'rugged', '~> 1.4'

# --------------------------------------------
# ENVIRONMENT MANAGEMENT
# --------------------------------------------
# Manage application-level environment variables
gem 'dotenv', '~> 2.8'
gem 'dotenv-rails', '~> 2.8'

# --------------------------------------------
# DEPLOYMENT TOOLS
# --------------------------------------------
# Deployment automation tools
gem 'capistrano', '~> 3.17'
gem 'capistrano-rails', '~> 1.6'
gem 'puma', '~> 5.6'
gem 'unicorn', '~> 6.1'

# --------------------------------------------
# PERFORMANCE MONITORING
# --------------------------------------------
# Libraries for monitoring performance
gem 'newrelic_rpm', '~> 8.10'

# --------------------------------------------
# DEVELOPMENT GROUP
# --------------------------------------------
group :development do
  gem 'rubocop', '~> 1.51'
  gem 'brakeman', '~> 5.6'
  gem 'solargraph', '~> 0.44'
end

# --------------------------------------------
# PRODUCTION GROUP
# --------------------------------------------
group :production do
  gem 'puma', '~> 5.6'
  gem 'unicorn', '~> 6.1'
end

# --------------------------------------------
# TEST GROUP
# --------------------------------------------
group :test do
  gem 'rspec-rails', '~> 5.0'
  gem 'capybara', '~> 3.39'
end

# --------------------------------------------
# LOAD ENVIRONMENT VARIABLES
# --------------------------------------------
# Ensure environment variables are properly loaded
group :default do
  gem 'bundler', '~> 2.4'
end
