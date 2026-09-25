# Secure File Vault System

## 🔐 Project Overview

**Secure File Vault System** is a Linux-based terminal application developed using **Bash scripting and Whiptail** to provide a secure environment for storing, managing, encrypting, and temporarily accessing files.

The system implements a multi-layer encryption workflow that allows users to select and combine different encryption techniques. It also provides user authentication, automatic file organization, activity logging, encrypted metadata management, and temporary file decryption.

## 🛠️ Technologies Used

* **Operating System:** Linux
* **Scripting Language:** Bash
* **Terminal UI:** Whiptail
* **File Management:** Linux File System
* **Security Concepts:** Authentication, Encryption, Access Control
* **Automation:** Bash Shell Scripting

## ✨ Key Features

### 🔐 Multi-Layer Encryption

The system supports multiple encryption techniques:

* XOR Cipher
* Caesar Cipher
* Block Reversal
* Vigenère Cipher
* Byte Rotation

Users can combine selected encryption methods to create a multi-layer encryption workflow.

The same selected layers can be reversed during the decryption process.

### 🔑 User Authentication

The system provides authentication and password management functionality to help restrict access to the secure file vault.

### 📁 Automatic File Organization

Files are automatically organized according to their type, including:

* Images
* Documents
* Audio
* Video
* Other file types

This keeps the vault organized and makes file management easier.

### 🖥️ Interactive Terminal Interface

The application uses **Whiptail** to provide an interactive menu-driven terminal interface instead of relying entirely on command-line inputs.

### ⏱️ Temporary File Decryption

Encrypted files can be temporarily decrypted for access.

After the specified operation, temporary decrypted files can be automatically removed to reduce the risk of leaving unencrypted copies behind.

### 📝 Activity Logging

The system maintains activity logs for important operations, including:

* User login
* File operations
* Encryption and decryption activities
* Password-related operations

### 📊 Encrypted File Metadata

The system maintains metadata associated with encrypted files to help manage and track stored files and their encryption information.

### 🐧 Linux File Management

The project uses Linux file-system operations and Bash automation for creating, moving, organizing, encrypting, decrypting, and managing files.

## 🔒 Encryption Methods

| Encryption Method | Description                                            |
| ----------------- | ------------------------------------------------------ |
| XOR               | Performs encryption using XOR-based byte operations    |
| Caesar            | Shifts characters using a specified key                |
| Block Reversal    | Reverses data blocks as part of the encryption process |
| Vigenère          | Uses a repeating key-based character transformation    |
| Byte Rotation     | Rotates byte values during encryption                  |

The system allows multiple methods to be combined, creating a layered encryption process.

## 🔄 Encryption Workflow

The general workflow is:

1. User logs into the system.
2. User selects a file to secure.
3. User selects one or more encryption methods.
4. The selected encryption methods are applied sequentially.
5. The encrypted file is stored in the vault.
6. File metadata is maintained for management and decryption.
7. When required, the file can be decrypted by reversing the selected encryption layers.
8. Temporary decrypted files can be automatically removed after use.

## 📂 File Management

The system provides functionality for:

* Adding files to the vault
* Encrypting files
* Decrypting files
* Organizing files by type
* Viewing encrypted file information
* Managing file metadata
* Handling temporary decrypted files
* Maintaining activity logs

## 🚀 How to Run

### 1. Clone the Repository

```bash
git clone https://github.com/aiman015/Secure-File-Vault-System.git
```

### 2. Navigate to the Project

```bash
cd Secure-File-Vault-System
```

### 3. Give the Script Execute Permission

```bash
chmod +x *.sh
```

If the project has a specific main script, run:

```bash
chmod +x <main-script-name>.sh
```

### 4. Run the Application

```bash
./<main-script-name>.sh
```

Follow the interactive Whiptail menus to navigate through the system.

> **Note:** The exact script name may vary depending on the project files.

## 🖥️ System Requirements

* Linux operating system
* Bash shell
* Whiptail
* Standard Linux file utilities
* Terminal environment

## 🎯 Project Objective

The main objective of the **Secure File Vault System** was to develop a practical Linux-based security application while gaining hands-on experience with shell scripting, file systems, encryption concepts, authentication, automation, and terminal-based interfaces.

The project demonstrates how Bash scripting can be used to combine security concepts and Linux file-management operations into a functional application.

## 📚 Learning Outcomes

Through this project, I gained practical experience in:

* Linux shell scripting
* Bash automation
* Linux file-system operations
* File encryption and decryption concepts
* Multi-layer encryption workflows
* User authentication
* Password management
* Temporary file handling
* File organization
* Activity logging
* Metadata management
* Terminal UI development using Whiptail
* Process automation

