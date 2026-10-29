param (
    [Parameter(Mandatory = $false)]
    [string]$RepoPath = (Get-Location).Path
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 1. JetBrains Toolbox scripts directory
$ToolboxDir = "$env:LOCALAPPDATA\JetBrains\Toolbox\scripts"

if (-not (Test-Path -Path $ToolboxDir)) {
    [System.Windows.Forms.MessageBox]::Show(
        "JetBrains script directory not found at:`n$ToolboxDir",
        "JetBrains Launcher Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

# 2. Find all installed IDE starter scripts (.cmd files)
$Scripts = @(Get-ChildItem -Path $ToolboxDir -Filter "*.cmd" | Where-Object { $_.BaseName -ne "toolbox" })

if ($Scripts.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show(
        "No JetBrains shell scripts found in:`n$ToolboxDir",
        "JetBrains Launcher Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
    exit 1
}

# 3. Build GUI Dialog Form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Select JetBrains IDE"
$Form.Size = New-Object System.Drawing.Size(380, (120 + ($Scripts.Count * 45)))
$Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.TopMost = $true

$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Point(20, 15)
$Label.Size = New-Object System.Drawing.Size(330, 35)
$Label.Text = "Choose an IDE to open repository:`n$RepoPath"
$Form.Controls.Add($Label)

$Y = 55
foreach ($script in $Scripts) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Location = New-Object System.Drawing.Point(20, $Y)
    $btn.Size = New-Object System.Drawing.Size(325, 36)
    $btn.Text = $script.BaseName.ToUpper()
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btn.UseVisualStyleBackColor = $true

    # Store the exact path in this button's Tag property
    $btn.Tag = $script.FullName

    $btn.Add_Click({
        # $this refers to the specific button clicked
        Start-Process -FilePath $this.Tag -ArgumentList "`"$RepoPath`"" -WindowStyle Hidden
        $Form.Close()
    })

    $Form.Controls.Add($btn)
    $Y += 45
}

# Show window as dialog
[void]$Form.ShowDialog()