


# Reads list of apps from file and removes them for all user accounts and from the OS image.
function RemoveApps {
    param(
        $appsFile,
        $message
    )

    Write-Output $message

    # Get list of apps from file at the path provided, and remove them one by one
    Foreach ($app in (Get-Content -Path $appsFile | Where-Object { $_ -notmatch '^#.*' -and $_ -notmatch '^\s*$' } )) 
    { 
        # Remove any spaces before and after the Appname
        $app = $app.Trim()

        # Remove any comments from the Appname
        if (-not ($app.IndexOf('#') -eq -1)) {
            $app = $app.Substring(0, $app.IndexOf('#'))
        }
        # Remove any remaining spaces from the Appname
        if (-not ($app.IndexOf(' ') -eq -1)) {
            $app = $app.Substring(0, $app.IndexOf(' '))
        }
        
        $appString = $app.Trim('*')
        Write-Output "Attempting to remove $appString..."

        # Remove installed app for all existing users
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

        # Remove provisioned app from OS image, so the app won't be installed for any new users
        Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
    }

    Write-Output ""
}


# Stop & Restart the windows explorer process
function RestartExplorer {
    Write-Output "> Restarting windows explorer to apply all changes."

    Start-Sleep 0.5

    taskkill /f /im explorer.exe

    Start-Process explorer.exe

    Write-Output ""
}


RemoveApps "$PSScriptRoot/Appslist.txt" "> Removing pre-installed apps..."