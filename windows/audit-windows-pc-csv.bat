::::::::::::::::::::::::::::::::::::::::::::
:: Elevate.cmd - Version 4
:: Automatically check & get admin rights
:: see "https://stackoverflow.com/a/12264592/1016343" for description
::::::::::::::::::::::::::::::::::::::::::::
 @echo off
 CLS
 ECHO.
 ECHO =============================
 ECHO Running Admin shell
 ECHO =============================

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO **************************************
  ECHO Invoking UAC for Privilege Escalation
  ECHO **************************************

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"

  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

 


REM set variables
set system=
set manufacturer=
set model=
set osname=
set sp=
setlocal ENABLEDELAYEDEXPANSION
set "volume=C:"
set totalMem=
set availableMem=
set usedMem=
set IPv4=
set Domain=
SET cpu= 
Set dob=
Set size=
Set free=
set gpu=

echo Getting data [Computer: %computername%]...
echo Please Wait....

REM Get Computer Name
FOR /F "tokens=2 delims='='" %%A in ('wmic OS Get csname /value') do SET system=%%A

REM Get Computer Manufacturer
FOR /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Manufacturer /value') do SET manufacturer=%%A

REM Get Computer Model
FOR /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Model /value') do SET model=%%A

REM Get Computer OS
FOR /F "tokens=2 delims='='" %%A in ('wmic os get Name /value') do SET osname=%%A
FOR /F "tokens=1 delims='|'" %%A in ("%osname%") do SET osname=%%A

REM Get CPU
FOR /F "tokens=2 delims='='" %%A in ('wmic cpu get name /value') do SET cpu=%%A

REM Get GPU
FOR /F "tokens=2 delims='='" %%A in ('wmic path win32_VideoController get name /value') do SET gpu=%%A

REM Get DoB
FOR /F "tokens=4" %%a in ('systeminfo ^| findstr /c:"Original Install Date"') do if defined dob (set dob=%%a) else (set dob=%%a)

REM Get Memory
FOR /F "tokens=4" %%a in ('systeminfo ^| findstr Physical') do if defined totalMem (set availableMem=%%a) else (set totalMem=%%a)
set totalMem=%totalMem:,=%
set availableMem=%availableMem:,=%
set /a usedMem=totalMem-availableMem
echo wsh.echo cdbl(%totalMem%)/1024 > %temp%.\tmp.vbs
for /f %%a in ('cscript //nologo %temp%.\tmp.vbs') do set totalMem=%%a

REM Get Disk
FOR /f "tokens=1*delims=:" %%i IN ('fsutil volume diskfree %volume%') DO (
    SET "diskfree=!disktotal!"
    SET "disktotal=!diskavail!"
    SET "diskavail=%%j"
)
FOR /f "tokens=1,2" %%i IN ("%disktotal% %diskavail%") DO SET "disktotal=%%i"& SET "diskavail=%%j"


echo wsh.echo cdbl(%disktotal%)/1024/1024/1024 > %temp%.\tmp.vbs
for /f %%a in ('cscript //nologo %temp%.\tmp.vbs') do set disktotal=%%a

echo wsh.echo cdbl(%diskavail%)/1024/1024/1024 > %temp%.\tmp.vbs
for /f %%a in ('cscript //nologo %temp%.\tmp.vbs') do set diskavail=%%a

echo wsh.echo cdbl(%diskfree%)/1024/1024/1024 > %temp%.\tmp.vbs
for /f %%a in ('cscript //nologo %temp%.\tmp.vbs') do set diskfree=%%a

FOR /F "tokens=2 delims='='" %%A in ('wmic LogicalDisk Where "DeviceID='C:'" Get FreeSpace /Format:value') do SET free=%%A
echo wsh.echo cdbl(%free%)/1024/1024/1024 > %temp%.\tmp.vbs
for /f %%a in ('cscript //nologo %temp%.\tmp.vbs') do set free=%%a

REM Get Domain
FOR /F "tokens=2 delims='='" %%A in ('wmic computersystem get domain /value') do SET domName=%%A
FOR /F "tokens=2 delims='='" %%A in ('WMIC /NODE: %system% COMPUTERSYSTEM GET USERNAME /value') do SET userName=%%A


IF NOT EXIST "%~dp0%domName%_Specs.csv" echo Domain, Name, Username, OS, RAM, HDD, FreeSpace, CPU, Graphics, DOB > %~dp0%domName%_Specs.csv
echo %domName%, %system%, %userName%, %osname%, %totalMem%, %disktotal%, %free%, %cpu%, %gpu%, %dob% >> %~dp0%domName%_Specs.csv

exit /B