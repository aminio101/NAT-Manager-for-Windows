
# Check if the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Restarting script as administrator..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "NAT Manager"
$form.Width = 700
$form.Height = 500

# Create a ListBox to show existing NATs
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Top = 20
$listBox.Left = 20
$listBox.Width = 640
$listBox.Height = 200
$form.Controls.Add($listBox)

# Labels and TextBoxes for adding a new NAT
$lblListenAddress = New-Object System.Windows.Forms.Label
$lblListenAddress.Text = "Listen Address:"
$lblListenAddress.Top = 240
$lblListenAddress.Left = 20
$form.Controls.Add($lblListenAddress)

$txtListenAddress = New-Object System.Windows.Forms.TextBox
$txtListenAddress.Top = 260
$txtListenAddress.Left = 20
$txtListenAddress.Width = 150
$form.Controls.Add($txtListenAddress)

$lblListenPort = New-Object System.Windows.Forms.Label
$lblListenPort.Text = "Listen Port:"
$lblListenPort.Top = 240
$lblListenPort.Left = 200
$form.Controls.Add($lblListenPort)

$txtListenPort = New-Object System.Windows.Forms.TextBox
$txtListenPort.Top = 260
$txtListenPort.Left = 200
$txtListenPort.Width = 100
$form.Controls.Add($txtListenPort)

$lblConnectAddress = New-Object System.Windows.Forms.Label
$lblConnectAddress.Text = "Connect Address:"
$lblConnectAddress.Top = 240
$lblConnectAddress.Left = 320
$form.Controls.Add($lblConnectAddress)

$txtConnectAddress = New-Object System.Windows.Forms.TextBox
$txtConnectAddress.Top = 260
$txtConnectAddress.Left = 320
$txtConnectAddress.Width = 150
$form.Controls.Add($txtConnectAddress)

$lblConnectPort = New-Object System.Windows.Forms.Label
$lblConnectPort.Text = "Connect Port:"
$lblConnectPort.Top = 240
$lblConnectPort.Left = 500
$form.Controls.Add($lblConnectPort)

$txtConnectPort = New-Object System.Windows.Forms.TextBox
$txtConnectPort.Top = 260
$txtConnectPort.Left = 500
$txtConnectPort.Width = 100
$form.Controls.Add($txtConnectPort)

# Create buttons
$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "Refresh NATs"
$btnRefresh.Top = 300
$btnRefresh.Left = 20
$form.Controls.Add($btnRefresh)

$btnAddNat = New-Object System.Windows.Forms.Button
$btnAddNat.Text = "Add NAT"
$btnAddNat.Top = 300
$btnAddNat.Left = 200
$form.Controls.Add($btnAddNat)

$btnDeleteNat = New-Object System.Windows.Forms.Button
$btnDeleteNat.Text = "Delete Selected NAT"
$btnDeleteNat.Top = 300
$btnDeleteNat.Left = 320
$form.Controls.Add($btnDeleteNat)

# Function to refresh NAT list
function Refresh-NatList {
    $listBox.Items.Clear()
    $output = netsh interface portproxy show all | Out-String
    $lines = $output -split "`r`n"
    foreach ($line in $lines) {
        if ($line -match "^ *([^ ]+) *([^ ]+) *([^ ]+) *([^ ]+) *$") {
            $listenAddress = $matches[1]
            $listenPort = $matches[2]
            $connectAddress = $matches[3]
            $connectPort = $matches[4]
	    $listBox.Items.Add("Listen: $listenAddress"+":"+"$listenPort -> Connect: $connectAddress"+":"+"$connectPort")
            #$listBox.Items.Add("Listen: $listenAddress:$listenPort -> Connect: $connectAddress:$connectPort")
        }
    }
}

# Add NAT rule
$btnAddNat.Add_Click({
    $listenAddress = $txtListenAddress.Text
    $listenPort = $txtListenPort.Text
    $connectAddress = $txtConnectAddress.Text
    $connectPort = $txtConnectPort.Text

    if ($listenAddress -and $listenPort -and $connectAddress -and $connectPort) {
	netsh interface portproxy add v4tov4 listenaddress=$listenAddress listenport=$listenPort connectaddress=$connectAddress connectport=$connectPort
        Refresh-NatList
        [System.Windows.Forms.MessageBox]::Show("NAT rule added successfully.", "Success")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.", "Error")
    }
})

# Delete selected NAT rule
$btnDeleteNat.Add_Click({
    if ($listBox.SelectedItem) {
        $selectedNat = $listBox.SelectedItem.ToString()
        $selectedNat -match "Listen: ([^:]+):([^ ]+) -> Connect: ([^:]+):([^ ]+)"
        $listenAddress = $matches[1]
        $listenPort = $matches[2]
        $connectAddress = $matches[3]
        $connectPort = $matches[4]

        netsh interface portproxy delete v4tov4 listenaddress=$listenAddress listenport=$listenPort
        Refresh-NatList
        [System.Windows.Forms.MessageBox]::Show("NAT rule deleted successfully.", "Success")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select a NAT rule to delete.", "Error")
    }
})

# Refresh NAT list on button click
$btnRefresh.Add_Click({
    Refresh-NatList
})

# Initialize the NAT list
Refresh-NatList

# Show the form
$form.ShowDialog()
