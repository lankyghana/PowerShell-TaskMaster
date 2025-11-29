
# PowerShell TaskMaster

## Overview
PowerShell TaskMaster is an all-in-one automation, security, network, and file management toolkit for Windows, built with PowerShell. It provides a modular, extensible platform for running built-in and custom tasks to simplify system administration and security operations.

## Features
- Modular PowerShell utility modules (file operations, network tools, security checks, etc.)
- Custom automation tasks: add your own scripts to the `CustomTasks` folder
- Easy-to-use menu interface
- Secure access with password protection

## Getting Started
1. Clone or download the repository.
2. Open PowerShell and navigate to the project folder.
3. Run the main script:
	```powershell
	powershell -ExecutionPolicy Bypass -File .\AllInOneTool.ps1
	```
4. Enter the password when prompted.
5. Use the menu to access built-in and custom tasks.

## Adding Custom Tasks
1. Create a new folder in `CustomTasks` (e.g., `CustomTasks\MyTask`).
2. Add a `task.json` file describing your task (name, description, parameters).
3. Add a `run.ps1` script implementing an `Invoke-Task` function.
4. Your task will appear in the menu automatically.

## Contributing
See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines and instructions.

## License
This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.