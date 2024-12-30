### **Updated `README.md` for DELPHY COSMOS Deployment**

The updated `README.md` reflects:

- **Accurate directory structure.**  
- **Correct paths for DELPHY tools.**  
- **Detailed usage instructions** for CLI and GUI tools.  
- **Testing sections** for unit and integration tests.  
- **CI/CD pipeline setup.**  
- **Reference to the `CONTRIBUTING.md`.**

---

## 📚 **DELPHY COSMOS v4 Deployment Documentation**

**Version:** 1.0.1  
**Last Updated:** 2024-12-30  
**Maintainer:** DELPHY Operations Team  
**Support Contact:** [guygrubbs@gmail.com](mailto:guygrubbs@gmail.com)  

---

## **1. Introduction**

Welcome to the **DELPHY COSMOS Deployment Repository**. This repository contains configurations, tools, and documentation for integrating **DELPHY systems** into the **COSMOS v4 framework**.

---

## **2. System Overview**

### **2.1 Key Features**

- **Command Execution:** CLI and GUI-based command interfaces for DELPHY.  
- **Telemetry Monitoring:** Real-time telemetry validation and status reporting.  
- **Error Handling:** Centralized error logging and validation workflows.  
- **Workflow Automation:** Predefined workflows for diagnostics and validation.  
- **Logging:** Structured logs for commands, telemetry, and errors.  

---

## **3. Directory Structure**

The current directory layout:

```plaintext
.
├── Gemfile
├── README.md
├── CONTRIBUTING.md
│
├── config/
│   ├── system/
│   │   ├── system.txt
│   │   ├── targets.txt
│   │   ├── tools.txt
│   │
│   ├── targets/
│   │   ├── DELPHY/
│   │   │   ├── config.txt
│   │   │   ├── defaults.txt
│   │   │   ├── interfaces.txt
│   │   │   ├── metadata.txt
│   │   │   ├── monitors.txt
│   │   │   ├── tools.txt
│   │   │   ├── logs/
│   │   │   │   ├── ack.log
│   │   │   │   ├── complete.log
│   │   │   │   ├── delphy.log
│   │   │   │
│   │   │   ├── tools/
│   │   │   │   ├── delphy_script.rb
│   │   │   │   ├── delphy_tool_gui.rb
│   │   │   │   ├── delphy_tool_logger.rb
│   │   │   │   ├── delphy_tool_test.rb
│   │   │   │   ├── configs/
│   │   │   │   │   ├── log_levels.yml
│   │   │   │   │   ├── tool_config.json
│   │   │   │   │   ├── tool_defaults.yml
│   │   │   │
│   │   │   ├── procedures/
│   │   │   │   ├── delphy_test_procedure.rb
│   │   │   │   ├── delphy_procedure_1.rb
│   │   │   │   ├── delphy_procedure_2.rb
│
├── lib/
│   ├── delphy_constants.rb
│   ├── delphy_errors.rb
│   ├── delphy_helper.rb
│   ├── delphy_packet_parser.rb
│   ├── delphy_tool.rb
│
└── tests/
    ├── targets/
    │   ├── DELPHY/
    │   │   ├── test_helper.rb
    │   │   ├── test_delphy_script.rb
    │   │   ├── test_delphy_tool_gui.rb
    │   │   ├── test_delphy_tool_logger.rb
    │   │   ├── test_delphy_tool_test.rb
    │   │   ├── integration_test.rb
```

---

## **4. Installation**

### **4.1 Clone the Repository**
```bash
git clone https://github.com/guygrubbs/cosmos_delphy.git
cd cosmos_delphy
```

### **4.2 Install Dependencies**
```bash
gem install bundler -v 1.17.3
bundle _1.17.3_ install
```

### **4.3 Validate Installation**
```bash
ruby tools/cmd_tlm_server.rb
```

---

## **5. Usage Instructions**

### **5.1 Command-Line Interface (CLI)**

Run the DELPHY Script:
```bash
ruby config/targets/DELPHY/tools/delphy_script.rb
```

### **Available Commands:**
```ruby
@script.connect
@script.run_script(1, 123.45)
@script.reset_system(0, 'Routine Reset')
@script.monitor_telemetry(:ack, 10)
@script.execute_full_workflow(1, 123.45)
@script.disconnect
```

---

### **5.2 GUI Interface**

Run the DELPHY GUI:
```bash
ruby config/targets/DELPHY/tools/delphy_tool_gui.rb
```

**Features:**
- **Connect/Disconnect:** Manage DELPHY connections.
- **Run Scripts:** Execute specific DELPHY scripts.
- **Telemetry Monitoring:** Real-time updates from telemetry packets.

---

## **6. Testing**

### **6.1 Unit Tests**
Run unit tests:
```bash
cd tests/targets/DELPHY/
rspec .
```

### **6.2 Integration Tests**
Run integration tests:
```bash
rspec integration_test.rb
```

**Test Coverage:**
- ✅ Connection/Disconnection  
- ✅ Command Execution (`RUN_SCRIPT`, `RESET_SYSTEM`)  
- ✅ Telemetry Validation (`ACK`, `COMPLETE`)  
- ✅ Workflow Execution  

Logs will be available in:
```
config/targets/DELPHY/tools/logs/
```

---

## **7. CI/CD Pipeline**

A CI/CD pipeline ensures:

1. **Dependency Installation:** Validate dependencies.
2. **Unit Tests:** Run using `rspec`.
3. **Integration Tests:** Validate workflows.
4. **Deployment Checks:** Validate COSMOS startup.

CI/CD triggers:
- On every push to the `main` branch.
- On pull request merges.

Pipeline Configuration:  
`.github/workflows/ci.yml`

---

## **8. Logging and Monitoring**

- **Tool Logs:** `config/targets/DELPHY/tools/logs/delphy_tool.log`  
- **Telemetry Logs:** `config/targets/DELPHY/tools/logs/telemetry.log`  
- **System Logs:** `config/system/logs/cosmos.log`  

View logs:  
```bash
cat config/targets/DELPHY/tools/logs/*.log
```

---

## **9. Contribution Guidelines**

We welcome contributions from the community!  
Please refer to our [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines.

---

## **10. Support**

- **Maintainer:** [guygrubbs@gmail.com](mailto:guygrubbs@gmail.com)  
- **Operations Team:** [kolton.dieckow@swri.org](mailto:kolton.dieckow@swri.org)  

Report issues via the [GitHub Issue Tracker](https://github.com/guygrubbs/cosmos_delphy/issues).

---

## **11. License**

This project is licensed under the **MIT License**. See `LICENSE` for details.

---