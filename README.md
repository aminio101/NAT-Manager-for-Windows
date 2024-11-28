# NAT Manager for Windows

This is a PowerShell script with a graphical user interface (GUI) designed to manage Network Address Translation (NAT) rules on a Windows system. It leverages the `netsh` command to add, list, and delete NAT rules, allowing users to forward ports easily.

![NAT Manager GUI](https://github.com/aminio101/NAT-Manager-for-Windows/blob/main/Capture.PNG)

## Features

- **View Existing NAT Rules:** Displays all currently configured NAT rules.
- **Add New NAT Rules:** Define custom listening and connecting addresses and ports.
- **Delete Existing NAT Rules:** Select a rule from the list and remove it.
- **Administrator Mode:** Automatically restarts as administrator if required permissions are missing.

## Prerequisites

1. **Windows Operating System:** Ensure you are running a Windows system.
2. **Administrator Privileges:** The script requires admin rights to execute NAT commands.
3. **PowerShell Version:** Ensure your system has PowerShell version 5.0 or higher.
4. **.NET Framework:** The script uses Windows Forms, which requires .NET Framework.

## Installation

1. Clone the repository:
   ```bash
   https://github.com/aminio101/NAT-Manager-for-Windows.git
   ```
2. Navigate to the directory:
   ```bash
   cd NAT-Manager-for-Windows
   ```
3. Run the script:
   ```powershell
   .\NATManager.ps1
   ```

## Usage

1. Launch the script by executing it in an elevated PowerShell session.
2. Use the GUI to:
   - **View Existing NATs:** The NAT rules are displayed in the list box.
   - **Add NAT Rules:**
     - Enter the **Listen Address**, **Listen Port**, **Connect Address**, and **Connect Port**.
     - Click **Add NAT** to create the rule.
   - **Delete NAT Rules:**
     - Select a rule from the list box.
     - Click **Delete Selected NAT** to remove it.
   - **Refresh List:** Click **Refresh NATs** to reload the current rules.

## Example

To add a NAT rule:
- **Listen Address:** `192.168.1.17`
- **Listen Port:** `2222`
- **Connect Address:** `172.17.7.154`
- **Connect Port:** `22`

This will create a rule to forward traffic from `192.168.1.17:2222` to `172.17.7.154:22`.

## Script Details

### Administrator Check
The script ensures it runs with elevated privileges. If not, it automatically restarts as an administrator:
```powershell
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Restarting script as administrator..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
```

### GUI Components
- **ListBox:** Displays existing NAT rules.
- **TextBoxes:** Accept user input for `Listen Address`, `Listen Port`, `Connect Address`, and `Connect Port`.
- **Buttons:**
  - **Refresh NATs**
  - **Add NAT**
  - **Delete Selected NAT**

### NAT Commands
- Add a rule:
  ```powershell
  netsh interface portproxy add v4tov4 listenaddress=<ListenAddress> listenport=<ListenPort> connectaddress=<ConnectAddress> connectport=<ConnectPort>
  ```
- Delete a rule:
  ```powershell
  netsh interface portproxy delete v4tov4 listenaddress=<ListenAddress> listenport=<ListenPort>
  ```
- Show all rules:
  ```powershell
  netsh interface portproxy show all
  ```

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
