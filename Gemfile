# Gemfile
# DELPHY COSMOS v4 Deployment Gemfile
# Defines dependencies required for DELPHY tools, procedures, and workflows.

# --------------------------------------------
# RUBY VERSION
# --------------------------------------------
ruby '3.1.2'

# --------------------------------------------
# COSMOS FRAMEWORK
# --------------------------------------------
# COSMOS Core Libraries for command, telemetry, and scripting
gem 'cosmos', '~> 4.0'

# --------------------------------------------
# NETWORK COMMUNICATION
# --------------------------------------------
# Provides robust TCP/IP communication capabilities
gem 'net-telnet', '~> 0.2.0'
gem 'socketry', '~> 0.5.1'

# --------------------------------------------
# PARSING AND SERIALIZATION
# --------------------------------------------
# YAML and JSON support for configuration files
gem 'psych', '~> 4.0'
gem 'json', '~> 2.6'

# --------------------------------------------
# LOGGING
# --------------------------------------------
# Logging library for structured logs
gem 'logger', '~> 1.6'
gem 'lograge', '~> 0.12.0'

# --------------------------------------------
# ERROR HANDLING
# --------------------------------------------
# Standardized error handling
gem 'sentry-raven', '~> 3.1'

# --------------------------------------------
# SCHEDULING AND AUTOMATION
# --------------------------------------------
# Cron and scheduling for periodic tasks
gem 'rufus-scheduler', '~> 3.8'

# --------------------------------------------
# SYSTEM MONITORING
# --------------------------------------------
# Libraries for monitoring system resources and performance
gem 'sys-proctable', '~> 1.2'
gem 'sys-filesystem', '~> 1.4'

# --------------------------------------------
# DATA HANDLING
# --------------------------------------------
# Provides caching and efficient memory management
gem 'redis', '~> 4.8'
gem 'dalli', '~> 3.2' # Memcached client

# --------------------------------------------
# SECURITY
# --------------------------------------------
# Secure communication and encryption
gem 'openssl', '~> 3.0'
gem 'bcrypt', '~> 3.1.18'

# --------------------------------------------
# MAILER FOR ALERTS
# --------------------------------------------
# Send email alerts and notifications
gem 'mail', '~> 2.8'

# --------------------------------------------
# COMMAND LINE INTERFACE
# --------------------------------------------
# CLI tools for user interaction
gem 'thor', '~> 1.2'

# --------------------------------------------
# FILE MANAGEMENT
# --------------------------------------------
# Manage and rotate log files efficiently
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
# Generates API documentation
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
# Interactive debugging and REPL tools
gem 'pry', '~> 0.14'
gem 'byebug', '~> 11.1'

# --------------------------------------------
# VERSION CONTROL
# --------------------------------------------
# Git version management
gem 'rugged', '~> 1.4'

# --------------------------------------------
# COSMOS SPECIFIC TOOLS AND UTILITIES
# --------------------------------------------
group :cosmos_tools do
  gem 'cosmos-tool-runner', '~> 4.0'
  gem 'cosmos-procedure-engine', '~> 4.0'
end

# --------------------------------------------
# ENVIRONMENT SPECIFIC GEMS
# --------------------------------------------
group :development do
  gem 'rubocop', '~> 1.51'
  gem 'brakeman', '~> 5.6'
end

group :production do
  gem 'puma', '~> 5.6'
  gem 'unicorn', '~> 6.1'
end

# --------------------------------------------
# DEPLOYMENT TOOLS
# --------------------------------------------
# Tools for deployment and orchestration
gem 'capistrano', '~> 3.17'
gem 'dotenv', '~> 2.8'

# --------------------------------------------
# LOAD ENVIRONMENT VARIABLES
# --------------------------------------------
# Manage application-level environment variables
gem 'dotenv-rails', '~> 2.8'

# --------------------------------------------
# APPLICATION STARTUP
# --------------------------------------------
# Use Bundler to ensure all gems are loaded correctly
group :default do
  gem 'bundler', '~> 2.4'
end
