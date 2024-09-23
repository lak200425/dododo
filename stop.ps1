# Define the names of the scripts to stop
$scriptsToStop = @("keylogg.ps1", "ss.ps1")

# Get the list of running PowerShell processes
$processes = Get-Process -Name "powershell"

foreach ($process in $processes) {
    # Get the command line arguments of the process
    $commandLine = (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $($process.Id)").CommandLine

    # Check if the process is running one of the target scripts
    foreach ($script in $scriptsToStop) {
        if ($commandLine -like "*$script*") {
            # Stop the process
            Stop-Process -Id $process.Id -Force
            Write-Host "Stopped $script running with PID $($process.Id)"
        }
    }
}
