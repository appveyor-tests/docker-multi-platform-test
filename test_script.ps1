
wsl -l -v

Write-Host "Switching Docker to Linux mode..."
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine
Start-Sleep -s 20
docker version
docker version -f '{{.Server.Os}}'

docker pull busybox
Start-ProcessWithOutput "docker run --rm -v 'C:\:/user-profile' busybox ls /user-profile"

docker pull alpine
Start-ProcessWithOutput "docker run --rm alpine echo hello_world"

Write-Host "Switching Docker to Windows mode..."
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchWindowsEngine
Start-Sleep -s 20
docker version
docker version -f '{{.Server.Os}}'

Write-Host "Pulling and running 'ltsc2019' images in 'hyper-v' mode"
Start-ProcessWithOutput "docker pull mcr.microsoft.com/windows/servercore:ltsc2019"
docker run --rm --isolation=hyperv mcr.microsoft.com/windows/servercore:ltsc2019 cmd /c echo hello_world

Write-Host "Pulling and running 'nanoserver 1809' images in 'hyper-v' mode"
Start-ProcessWithOutput "docker pull mcr.microsoft.com/windows/nanoserver:1809"
docker run --rm --isolation=hyperv mcr.microsoft.com/windows/nanoserver:1809 cmd /c echo hello_world	
