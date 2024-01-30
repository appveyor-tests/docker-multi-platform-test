
wsl -l -v

Write-Host "Switching Docker to Linux mode..."
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine
Start-Sleep -s 20
docker version
docker version -f '{{.Server.Os}}'

docker pull busybox --quiet
docker run --rm -v 'C:\:/user-profile' busybox ls /user-profile

docker pull alpine --quiet
docker run --rm alpine echo hello_world

Write-Host "Switching Docker to Windows mode..."
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchWindowsEngine
Start-Sleep -s 20
docker version
docker version -f '{{.Server.Os}}'

docker pull mcr.microsoft.com/windows/servercore:ltsc2019 --quiet
docker run --rm --isolation=hyperv mcr.microsoft.com/windows/servercore:ltsc2019 cmd /c echo hello_world

docker pull mcr.microsoft.com/windows/nanoserver:1809 --quiet
docker run --rm --isolation=hyperv mcr.microsoft.com/windows/nanoserver:1809 cmd /c echo hello_world	
