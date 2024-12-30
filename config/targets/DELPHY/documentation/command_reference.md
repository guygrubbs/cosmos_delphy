# **DELPHY Command Reference Documentation**

**Version:** 1.0.0  
**Last Updated:** 2024-12-30  
**Maintainer:** DELPHY Operations Team (Guy Grubbs & Kolton Dieckow)
**Support Contact:** [guygrubbs@gmail.com](mailto:guygrubbs@gmail.com)  

---

## **1. Introduction**

This document serves as a **command reference guide** for the **DELPHY COSMOS v4 deployment**, detailing all supported commands, parameters, expected responses, and error codes.

Commands are categorized by functionality:
- **Connection Management**
- **System Commands**
- **Telemetry Commands**
- **Diagnostics**
- **Error Handling**
- **Workflow Management**

---

## **2. Command Overview**

### **2.1 General Command Structure**

All commands in DELPHY follow this structure:

```
COMMAND_NAME [PARAMETERS]
```

- **COMMAND_NAME:** The unique identifier of the command.
- **PARAMETERS:** Command-specific values.

### **2.2 Communication Protocol**

- **Interface:** TCP/IP  
- **IP Address:** `129.162.153.79`  
- **Port:** `14670`  
- **Protocol:** ASCII  
- **Timeout:** 5 seconds  

---

## **3. Connection Management**

### **3.1 CONNECT**
**Description:** Establish a connection to the DELPHY interface.

**Syntax:**  
```plaintext
CONNECT
```

**Parameters:**  
- None

**Expected Response:**  
```plaintext
CONNECTED
```

**Error Codes:**  
| Code | Description           |
|------|-----------------------|
| 1    | Connection Failed     |
| 2    | Timeout               |

---

### **3.2 DISCONNECT**
**Description:** Disconnect from the DELPHY interface.

**Syntax:**  
```plaintext
DISCONNECT
```

**Parameters:**  
- None

**Expected Response:**  
```plaintext
DISCONNECTED
```

**Error Codes:**  
| Code | Description           |
|------|-----------------------|
| 1    | Disconnection Failed  |

---

## **4. System Commands**

### **4.1 RUN_SCRIPT**
**Description:** Execute a predefined DELPHY script.

**Syntax:**  
```plaintext
RUN_SCRIPT [SCRIPT_ID] [PARAMETER]
```

**Parameters:**  
| Parameter   | Type   | Default | Description              |
|-------------|--------|---------|--------------------------|
| SCRIPT_ID   | UINT8  | 1       | Identifier for the script |
| PARAMETER   | FLOAT  | 123.45  | Parameter for the script  |

**Example:**  
```plaintext
RUN_SCRIPT 1 42.0
```

**Expected Response:**  
```plaintext
SCRIPT_EXECUTED
```

**Error Codes:**  
| Code | Description        |
|------|--------------------|
| 1    | Invalid Script ID  |
| 2    | Execution Failed   |

---

### **4.2 RESET_SYSTEM**
**Description:** Reset the DELPHY system.

**Syntax:**  
```plaintext
RESET_SYSTEM [MODE] [REASON]
```

**Parameters:**  
| Parameter | Type   | Default        | Description               |
|-----------|--------|----------------|---------------------------|
| MODE      | UINT8  | 0              | Reset mode (0: Soft Reset) |
| REASON    | STRING | "Maintenance"  | Reason for reset           |

**Example:**  
```plaintext
RESET_SYSTEM 0 "Scheduled Reset"
```

**Expected Response:**  
```plaintext
SYSTEM_RESET
```

**Error Codes:**  
| Code | Description     |
|------|-----------------|
| 1    | Invalid Mode    |
| 2    | Reset Failed    |

---

### **4.3 SEND_MESSAGE**
**Description:** Send a log message to the DELPHY system.

**Syntax:**  
```plaintext
SEND_MESSAGE [LOG_LEVEL] [MESSAGE]
```

**Parameters:**  
| Parameter | Type   | Default       | Description           |
|-----------|--------|---------------|-----------------------|
| LOG_LEVEL | UINT8  | 0             | Logging level (0-4)   |
| MESSAGE   | STRING | "Log Message" | Log message content   |

**Example:**  
```plaintext
SEND_MESSAGE 0 "Test Log Message"
```

**Expected Response:**  
```plaintext
MESSAGE_SENT
```

**Error Codes:**  
| Code | Description       |
|------|-------------------|
| 1    | Invalid Log Level |
| 2    | Message Failed    |

---

## **5. Telemetry Commands**

### **5.1 TELEMETRY_ACK**
**Description:** Monitor the ACK telemetry packet.

**Syntax:**  
```plaintext
TELEMETRY_ACK
```

**Expected Response:**  
```plaintext
ACK_RECEIVED [RESPONSE_CODE] [MESSAGE]
```

**Error Codes:**  
| Code | Description        |
|------|--------------------|
| 1    | Timeout            |
| 2    | Invalid Response   |

---

### **5.2 TELEMETRY_COMPLETE**
**Description:** Monitor the COMPLETE telemetry packet.

**Syntax:**  
```plaintext
TELEMETRY_COMPLETE
```

**Expected Response:**  
```plaintext
COMPLETE_RECEIVED [STATUS_CODE] [MESSAGE]
```

**Error Codes:**  
| Code | Description        |
|------|--------------------|
| 1    | Timeout            |
| 2    | Invalid Response   |

---

## **6. Diagnostics**

### **6.1 PERFORM_DIAGNOSTICS**
**Description:** Run diagnostic checks on DELPHY.

**Syntax:**  
```plaintext
PERFORM_DIAGNOSTICS
```

**Expected Response:**  
```plaintext
DIAGNOSTICS_COMPLETE
```

**Error Codes:**  
| Code | Description        |
|------|--------------------|
| 1    | Diagnostics Failed |
| 2    | Timeout            |

---

## **7. Error Handling**

### **7.1 INVALID_COMMAND**
**Description:** Simulate an invalid command for error handling validation.

**Syntax:**  
```plaintext
INVALID_COMMAND
```

**Expected Response:**  
```plaintext
ERROR [ERROR_CODE] [MESSAGE]
```

**Error Codes:**  
| Code | Description          |
|------|----------------------|
| 1    | Command Not Found    |
| 2    | Invalid Parameters   |

---

## **8. Workflow Management**

### **8.1 EXECUTE_FULL_WORKFLOW**
**Description:** Execute a predefined automated workflow.

**Syntax:**  
```plaintext
EXECUTE_FULL_WORKFLOW [SCRIPT_ID] [PARAMETER]
```

**Parameters:**  
| Parameter   | Type   | Default | Description            |
|-------------|--------|---------|------------------------|
| SCRIPT_ID   | UINT8  | 1       | Workflow Script ID     |
| PARAMETER   | FLOAT  | 456.78  | Parameter for workflow |

**Example:**  
```plaintext
EXECUTE_FULL_WORKFLOW 2 42.0
```

**Expected Response:**  
```plaintext
WORKFLOW_COMPLETE
```

**Error Codes:**  
| Code | Description       |
|------|-------------------|
| 1    | Workflow Failed   |
| 2    | Timeout           |

---

## **9. Error Codes**

| **Code** | **Description**           |
|----------|---------------------------|
| 0        | SUCCESS                   |
| 1        | INVALID_COMMAND           |
| 2        | TIMEOUT                   |
| 3        | CONNECTION_FAILED         |
| 4        | UNKNOWN_ERROR             |

---

## **10. Logging Levels**

| **Level** | **Description**          |
|-----------|--------------------------|
| 0         | INFO (General Information) |
| 1         | WARNING (Non-critical)    |
| 2         | ERROR (Critical Issue)    |
| 3         | DEBUG (Debug Details)     |
| 4         | CRITICAL (System Failure) |

---

## **11. Support**

For assistance, please contact:  
**Support Team:** [support@delphy.com](mailto:support@delphy.com)  
**Operations Team:** [kolton.dieckow@swri.org](mailto:kolton.dieckow@swri.org)  

---

This **Command Reference Guide** serves as a comprehensive manual for interacting with the DELPHY COSMOS deployment. Proper adherence to the command syntax and parameters is essential for maintaining operational integrity.