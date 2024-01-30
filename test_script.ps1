
function Start-ProcessWithOutput {
    param(
        $command,
        [switch]$ignoreExitCode,
        [switch]$ignoreStdOut
    )
    $fileName = $command
    $arguments = $null

    if ($command.startsWith('"')) {
        $idx = $command.indexOf('"', 1)
        $fileName = $command.substring(1, $idx - 1)
        if ($idx -lt ($command.length - 2)) {
            $arguments = $command.substring($idx + 2)
        }
    }
    else {
        $idx = $command.indexOf(' ')
        if ($idx -ne -1) {
            $fileName = $command.substring(0, $idx)
            $arguments = $command.substring($idx + 1)
        }
    }

    # find tool in path
    if (-not (Test-Path $fileName)) {
        foreach ($pathPart in $($env:PATH).Split(';')) {
            $searchPath = [IO.Path]::Combine($pathPart, "$fileName.bat")
            if (Test-Path $searchPath) {
                $fileName = $searchPath; break;
            }            
            $searchPath = [IO.Path]::Combine($pathPart, "$fileName.cmd")
            if (Test-Path $searchPath) {
                $fileName = $searchPath; break;
            }
            $searchPath = [IO.Path]::Combine($pathPart, "$fileName.exe")
            if (Test-Path $searchPath) {
                $fileName = $searchPath; break;
            }
            $searchPath = [IO.Path]::Combine($pathPart, $fileName)
            if (Test-Path $searchPath) {
                $fileName = $searchPath; break;
            }
        }
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo 
    $psi.FileName = $fileName
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardOutput = $true
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $psi.Arguments = $arguments
    $psi.WorkingDirectory = (pwd).Path
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi

    # Adding event handers for stdout and stderr.
    $outScripBlock = {
        if (![String]::IsNullOrEmpty($EventArgs.Data)) {
            Write-Host "$($EventArgs.Data)"
        }
    }
    $errScripBlock = {
        if (![String]::IsNullOrEmpty($EventArgs.Data)) {
            Write-Host "$($EventArgs.Data)" -ForegroundColor Red
        }
    }

    if ($ignoreStdOut -eq $false) {
        $stdOutEvent = Register-ObjectEvent -InputObject $process -Action $outScripBlock -EventName 'OutputDataReceived'
    }
    $stdErrEvent = Register-ObjectEvent -InputObject $process -Action $errScripBlock -EventName 'ErrorDataReceived'

    try {
        $process.Start() | Out-Null

        $process.BeginOutputReadLine()
        $process.BeginErrorReadLine()
        [Void]$process.WaitForExit()
    
        # Unregistering events to retrieve process output.
        if ($ignoreStdOut -eq $false) {
            Unregister-Event -SourceIdentifier $stdOutEvent.Name
        }
        Unregister-Event -SourceIdentifier $stdErrEvent.Name    
    
        if ($ignoreExitCode -eq $false -and $process.ExitCode -ne 0) {
            exit $process.ExitCode
        }
    }
    catch {
        Write-Host "Error running '$($psi.FileName) $($psi.Arguments)' command: $($_.Exception.Message)" -ForegroundColor Red
        throw $_
    }
}

wsl -l -v

Write-Host "Switching Docker to Linux mode..."
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine
Start-Sleep -s 20
docker version
docker version -f '{{.Server.Os}}'

#Start-ProcessWithOutput "docker pull busybox"
docker pull busybox --quiet
docker run --rm -v 'C:\:/user-profile' busybox ls /user-profile

#Start-ProcessWithOutput "docker pull alpine"
docker pull alpine --quiet
docker run --rm alpine echo hello_world

Write-Host "Switching Docker to Windows mode..."
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchWindowsEngine
Start-Sleep -s 20
docker version
docker version -f '{{.Server.Os}}'

Write-Host "Pulling and running 'ltsc2019' images in 'hyper-v' mode"
#Start-ProcessWithOutput "docker pull mcr.microsoft.com/windows/servercore:ltsc2019"
docker pull mcr.microsoft.com/windows/servercore:ltsc2019 --quiet
docker run --rm --isolation=hyperv mcr.microsoft.com/windows/servercore:ltsc2019 cmd /c echo hello_world

Write-Host "Pulling and running 'nanoserver 1809' images in 'hyper-v' mode"
#Start-ProcessWithOutput "docker pull mcr.microsoft.com/windows/nanoserver:1809"
docker pull mcr.microsoft.com/windows/nanoserver:1809 --quiet
docker run --rm --isolation=hyperv mcr.microsoft.com/windows/nanoserver:1809 cmd /c echo hello_world	
