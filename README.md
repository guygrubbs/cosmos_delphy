# **DELPHY COSMOS v4 Deployment**

**Version:** 1.0.0  
**Last Updated:** 2024-12-30  
**Maintainer:** DELPHY Operations Team  
**Support Contact:** [guygrubbs@gmail.com](mailto:guygrubbs@gmail.com)  

---

## **1. Introduction**

Welcome to the **DELPHY COSMOS v4 Deployment Repository**. This repository contains all necessary **tools**, **configurations**, and **documentation** required for integrating the **DELPHY System** into the **COSMOS v4 framework**. COSMOS provides advanced capabilities for **command execution**, **telemetry monitoring**, **error handling**, and **workflow automation** in embedded systems.

---

## **2. System Overview**

### **2.1 Key Components**

- **Command Execution:** Interface for sending and managing DELPHY system commands.  
- **Telemetry Monitoring:** Real-time telemetry data collection and validation.  
- **Diagnostics:** Regular system health checks and alerts.  
- **Workflow Automation:** Predefined procedures for recurring tasks.  
- **Error Handling:** Proactive error detection and alert escalation.  
- **Security:** Authentication, encryption, and IP-based access controls.  

### **2.2 Architecture Overview**

- **Communication Interfaces:** TCP/IP and Serial (fallback).  
- **Configuration Files:** Centralized settings for commands, telemetry, and error handling.  
- **Logging:** Structured logging with rotation and alert integration.  
- **Caching:** Telemetry caching with Redis/Memcached.  
- **Monitoring:** Automated system health checks and validation workflows.  

---

## **3. Prerequisites**

Ensure the following prerequisites are met before proceeding:

- **COSMOS Version:** 4.0 or higher  
- **Ruby Version:** 3.1.2  
- **Bundler:** 2.4 or higher  
- **Network Access:** Access to DELPHY's IP and Port (`129.162.153.79:5025`)  
- **Access Permissions:** Ensure sufficient privileges for deployment and tool execution  

---

## **4. Installation**

### **4.1 Clone the Repository**

```bash
git clone https://github.com/guygrubbs/cosmos_delphy.git
cd cosmos_delphy
```

### **4.2 Install Dependencies**

Ensure all Ruby gems are installed:

```bash
gem install bundler
bundle install
```

### **4.3 Configure COSMOS**

Copy the configuration files to your COSMOS installation directory:

```bash
cp -r config/* /path/to/cosmos/config/
```

### **4.4 Environment Variables**

Create a `.env` file in the root directory to manage environment variables:

```plaintext
DELPHY_INTERFACE=TCPIP
DELPHY_IP=129.162.153.79
DELPHY_PORT=5025
```

### **4.5 Verify Installation**

Start the DELPHY Tool:

```bash
ruby tools/ScriptRunner -r config/tools/delphy_tool.rb
```

Check the logs at:
```plaintext
config/tools/delphy_tool/logs/system.log
```

---

## **5. Configuration Files Overview**

### **5.1 System Configuration (`config/system/system.txt`)**
- Defines global system-level parameters, session handling, error retry settings, and telemetry defaults.

### **5.2 Target Configuration (`config/system/targets.txt`)**
- Defines DELPHY communication parameters (IP, Port, Protocol).
- Specifies telemetry packets, commands, and error handling rules.

### **5.3 Tools Configuration (`config/system/tools.txt`)**
- Lists tools, their entry points, logging levels, and configurations.
- Defines monitoring and alerting rules.

### **5.4 Tool-Specific Configurations**
- `tool_config.json`: General settings for the DELPHY tool.
- `tool_defaults.yml`: Default parameters for commands and telemetry settings.

---

## **6. Sending Commands to DELPHY Interface**

### **6.1 Command Structure**

Commands are sent to DELPHY using COSMOS's built-in `cmd` method:

```ruby
cmd('TARGET', 'COMMAND_NAME', 'PARAMETER' => VALUE)
```

- **`TARGET`:** The target system (`DELPHY`)  
- **`COMMAND_NAME`:** The name of the command (e.g., `RUN_SCRIPT`)  
- **`PARAMETER`:** Command-specific parameters  

### **6.2 Example Commands in Scripts**

#### **Run a Script on DELPHY**

```ruby
require 'cosmos'
require 'cosmos/script'

# Define command parameters
cmd('DELPHY', 'RUN_SCRIPT', 'SCRIPT_ID' => 1, 'PARAMETER' => 123.45)

# Wait for telemetry validation
wait_check('DELPHY METADATA SYSTEM_STATE == "NOMINAL"', 10)
```

#### **Reset the DELPHY System**

```ruby
cmd('DELPHY', 'RESET_SYSTEM', 'MODE' => 0, 'REASON' => 'Scheduled Maintenance')
```

#### **Send a Message to DELPHY**

```ruby
cmd('DELPHY', 'SEND_MESSAGE', 'LOG_LEVEL' => 0, 'MESSAGE' => 'Test Log Message')
```

---

### **6.3 Example Commands in Tests**

Create a test file (`delphy_command_test.rb`) with the following content:

```ruby
require 'cosmos'
require 'cosmos/tools/test_runner/test'

class DelphyCommandTest < Cosmos::Test
  def test_run_script
    cmd('DELPHY', 'RUN_SCRIPT', 'SCRIPT_ID' => 1, 'PARAMETER' => 123.45)
    wait_check('DELPHY METADATA SYSTEM_STATE == "NOMINAL"', 10)
  end
end
```

Run the test:
```bash
ruby config/procedures/delphy_test_run.rb
```

---

## **7. Monitoring Telemetry**

You can monitor telemetry in real-time via COSMOS's telemetry display tools.

**Example Telemetry Validation Script:**

```ruby
require 'cosmos'
require 'cosmos/script'

# Check telemetry values
wait_check('DELPHY METADATA SYSTEM_STATE == "NOMINAL"', 10)
wait_check('DELPHY ERROR_COUNT < 5', 10)
```

---

## **8. Maintenance and Diagnostics**

Run regular diagnostics:

```bash
ruby config/procedures/delphy_maintenance.rb
```

Clear cache:

```bash
ruby scripts/cache_manager.rb clear
```

---

## **9. Logging**

Logs are stored in:

- **System Logs:** `config/tools/delphy_tool/logs/system.log`  
- **Tool Logs:** `config/tools/delphy_tool/logs/delphy_tool.log`  

### **Adjust Logging Levels**

Edit `config/tools/delphy_tool/configs/log_levels.yml` to update log levels.

---

## **10. Testing**

Run all tests:

```bash
rspec
```

Run specific test scripts:

```bash
ruby config/procedures/delphy_test_run.rb
```

---

## **11. Alerts and Notifications**

- Alerts are sent via **Email** and **Console**.
- Default recipients:
  - `kolton.dieckow@swri.org`
  - `admin@delphy.com`
- Critical alerts escalate to:
  - `escalation@delphy.com`

---

## **12. Security**

- Enforced **IP Whitelisting** (`129.162.153.0/24`)  
- **Authentication and Encryption** enabled in network settings  

---

## **13. Support**

For issues, contact:  
- **Support Team:** [guygrubbs@gmail.com](mailto:guygrubbs@gmail.com)  
- **Operations Team:** [kolton.dieckow@swri.org](mailto:kolton.dieckow@swri.org)  

For bug reporting, open an issue in the [repository](https://github.com/guygrubbs/cosmos_delphy/issues).  

---

## **14. Contribution Guidelines**

1. Fork the repository.  
2. Create a feature branch: `git checkout -b feature-branch`.  
3. Commit changes: `git commit -m "Add new feature"`.  
4. Submit a pull request.  

---

## **15. License**

This project is licensed under the **MIT License**. See `LICENSE` for details.

---

This **README.md** serves as the central guide for **DELPHY COSMOS v4 Deployment**, providing comprehensive instructions for installation, configuration, command execution, monitoring, and maintenance. Ensure that all configurations are validated before deployment.