@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
echo 正在请求管理员权限...
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
set n=0
netsh int show int|findstr "已连接">%temp%\intlist.txt
for /f %%i in (%temp%\intlist.txt) do set /a n+=1
if %n%==1 (
::只有一个网卡
for /f "tokens=4*" %%i in (%temp%\intlist.txt) do set intname=%%i %%j
) else (
::有多个网卡
for /f "tokens=4*" %%i in (%temp%\intlist.txt) do echo %%i %%j
set /p intname=有多个网卡，请输入要设置的网卡名称。
)
title 当前选择的网卡是:%intname%
cls
set netmask=255.255.255.0
set /p ip=IP:
set gateway=
for /f "delims=. tokens=1-3" %%i in ("%ip%") do set gateway=%%i.%%j.%%k.1
set /p netmask=子网掩码[255.255.255.0]:
set /p gateway=网关:[%gateway%]
set dns1=223.5.5.5
set /p dns1=DNS1[%dns1%]:
set dns2=""
set /p dns2=DNS2:
netsh int ip set add "%intname%" static %ip% %netmask% %gateway%
netsh int ip set dnsservers "%intname%" static %dns1% primary validate=no
if not dns2=="" netsh int ip add dnsservers "%intname%" %dns2%
cls
ipconfig /all
pause
::by 911061873