# **DELPHY COSMOS v4 Deployment**

**Version:** 1.1.0  
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
- **Logging:** Structured, detailed logs for troubleshooting.  

### **2.2 Architecture Overview**

- **Communication Interfaces:** TCP/IP and Serial (fallback).  
- **Configuration Files:** Centralized settings for commands, telemetry, and error handling.  
- **Logging:** Structured logging with rotation and alert integration.  
- **Monitoring:** Automated system health checks and validation workflows.  

---

## **3. Prerequisites**

Ensure the following prerequisites are met before proceeding:

- **COSMOS Version:** 4.0 or higher  
- **Ruby Version:** 3.1.2  
- **Bundler:** 2.4 or higher  
- **Network Access:** Access to DELPHY's IP and Port (`129.162.153.79:14670`)  
- **Access Permissions:** Ensure sufficient privileges for deployment and tool execution  

---

## **4. Directory Structure**

```
.
├── config
│   ├── logs
│   ├── procedures
│   │   ├── delphy_maintenance.rb
│   │   ├── delphy_script.rb
│   │   ├── delphy_test_run.rb
│   │   ├── delphy_validation_procedure.rb
│   ├── system
│   │   ├── system.txt
│   │   ├── targets.txt
│   │   ├── tools.txt
│   ├── targets
│   │   ├── DELPHY
│   │   │   ├── config.txt
│   │   │   ├── defaults.txt
│   │   │   ├── interfaces.txt
│   │   │   ├── metadata.txt
│   │   │   ├── monitors.txt
│   │   │   ├── tools
│   │   │   │   ├── delphy_script.rb
│   │   │   │   ├── delphy_tool_gui.rb
│   │   │   │   ├── delphy_tool_logger.rb
│   │   │   │   ├── delphy_tool_test.rb
│   │   │   ├── logs
│   │   │   │   ├── ack.log
│   │   │   │   ├── complete.log
│   │   │   │   ├── delphy.log
│   │   │   ├── procedures
│   │   │   │   ├── delphy_procedure_1.rb
│   │   │   │   ├── delphy_procedure_2.rb
│   │   │   │   ├── delphy_test_procedure.rb
├── lib
│   ├── delphy_constants.rb
│   ├── delphy_errors.rb
│   ├── delphy_helper.rb
│   ├── delphy_packet_parser.rb
│   ├── delphy_tool.rb
```

---

## **5. Installation**

### **5.1 Clone the Repository**

```bash
git clone https://github.com/guygrubbs/cosmos_delphy.git
cd cosmos_delphy
```

### **5.2 Install Dependencies**

Ensure all Ruby gems are installed:

```bash
gem install bundler
bundle install
```

### **5.3 Configure COSMOS**

Copy the configuration files to your COSMOS installation directory:

```bash
cp -r config/* /path/to/cosmos/config/
```

### **5.4 Environment Variables**

Create a `.env` file in the root directory to manage environment variables:

```plaintext
DELPHY_INTERFACE=TCPIP
DELPHY_IP=129.162.153.79
DELPHY_PORT=14670
```

### **5.5 Verify Installation**

Start the DELPHY Tool:

```bash
ruby config/targets/DELPHY/tools/delphy_script.rb
```

Check the logs at:
```plaintext
config/targets/DELPHY/tools/logs/delphy_script.log
```

---

## **6. Usage Instructions**

### **6.1 Command-Line Tools**

- **Run DELPHY Script:**
```bash
ruby config/targets/DELPHY/tools/delphy_script.rb workflow 1 123.45
```

- **Diagnostics:**
```bash
ruby config/targets/DELPHY/tools/delphy_script.rb diagnostics
```

### **6.2 GUI Tool**

Run the DELPHY GUI tool:

```bash
ruby config/targets/DELPHY/tools/delphy_tool_gui.rb
```

---

## **7. Testing and Validation**

### **7.1 Run Tests**

- **Run DELPHY Test Suite:**
```bash
ruby config/targets/DELPHY/tools/delphy_tool_test.rb
```

- **Verify Logs:**  
  Check logs for errors or warnings:
```plaintext
config/targets/DELPHY/tools/logs/delphy_tool_test.log
```

### **7.2 Telemetry Validation**

Run telemetry checks:

```ruby
wait_check('DELPHY METADATA SYSTEM_STATE == "NOMINAL"', 10)
```

---

## **8. Logging**

Logs are stored in:

- **System Logs:** `config/targets/DELPHY/tools/logs/delphy_script.log`  
- **GUI Logs:** `config/targets/DELPHY/tools/logs/delphy_gui.log`  
- **Test Logs:** `config/targets/DELPHY/tools/logs/delphy_tool_test.log`  

Adjust logging levels in:
```yaml
config/targets/DELPHY/tools/configs/log_levels.yml
```

---

## **9. Alerts and Notifications**

- Alerts are sent via **Email** and **Console**.
- Default recipients:
  - `kolton.dieckow@swri.org`
  - `admin@delphy.com`
- Critical alerts escalate to:
  - `escalation@delphy.com`

---

## **10. Contribution Guidelines**

1. Fork the repository.  
2. Create a feature branch: `git checkout -b feature-branch`.  
3. Commit changes: `git commit -m "Add new feature"`.  
4. Submit a pull request.  

---

## **11. License**

This project is licensed under the **MIT License**. See `LICENSE` for details.

---

**This README.md serves as the central guide for DELPHY COSMOS v4 Deployment, ensuring clarity and accuracy across installation, configuration, usage, and validation.**
