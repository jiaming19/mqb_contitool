@echo off
setlocal EnableExtensions
rem ContiTool Windows package build. Same layout as run.bat.
rem Double-click, or:  scripts\build_windows.bat
rem   scripts\build_windows.bat --no-pause
rem This file lives in scripts\. The repository root is the parent folder.
rem Python checks live in win_boot.py. Do not pass Python source from this file.
rem cmd treats the word for, and angle brackets, as its own syntax.
rem This file must stay ASCII, with CRLF line endings.

set "NO_PAUSE="
if /I "%~1"=="--no-pause" set "NO_PAUSE=1"

cd /d "%~dp0.."
if errorlevel 1 goto :root_missing

set "ROOT=%cd%"
set "VENV_PY=%ROOT%\.venv\Scripts\python.exe"
set "STAMP=%ROOT%\.venv\requirements-dev.stamp"
set "BOOT=%~dp0win_boot.py"
set "BASE_PY="
set "BASE_ARG="

echo.
echo ContiTool Windows package
echo Repository: %ROOT%
echo.

if not exist "%ROOT%\scripts\build_release.py" goto :root_missing
if not exist "%ROOT%\requirements-dev.txt" goto :root_missing
if not exist "%ROOT%\dpdu\VW_PDUAPI_27.2\PDUAPI_VW.dll" goto :dpdu_missing
if not exist "%BOOT%" goto :boot_missing

call :find_python
if errorlevel 1 goto :no_python

if exist "%VENV_PY%" goto :have_venv
echo Creating virtual environment .venv ...
"%BASE_PY%" %BASE_ARG% -m venv "%ROOT%\.venv" || goto :venv_fail
:have_venv

"%VENV_PY%" "%BOOT%" version
if errorlevel 1 goto :venv_old

call :imports_ok
if errorlevel 1 goto :need_install
call :pyinstaller_ok
if errorlevel 1 goto :need_install
if not exist "%STAMP%" goto :write_stamp
fc /b "%ROOT%\requirements-dev.txt" "%STAMP%" >nul 2>&1
if errorlevel 1 goto :need_install
goto :deps_ready

:need_install
call :install_deps
if errorlevel 2 goto :import_fail
if errorlevel 1 goto :pip_fail

:write_stamp
"%VENV_PY%" "%BOOT%" stamp "%ROOT%\requirements-dev.txt" "%STAMP%"
if errorlevel 1 echo Could not save the requirements stamp. Continuing anyway.

:deps_ready

set "PYTHONUTF8=1"
echo.
echo Running scripts\build_release.py
"%VENV_PY%" "%ROOT%\scripts\build_release.py"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto :build_fail

echo.
echo Build finished. Packages:
dir /b "%ROOT%\dist\release"
echo.
echo ContiTool.exe is inside the zip, next to the dpdu folder.
call :hold
exit /b 0

:install_deps
echo Installing dependencies. The first run needs a network and can take a few minutes...
"%VENV_PY%" -m pip --version >nul 2>&1 || "%VENV_PY%" -m ensurepip --upgrade >nul 2>&1
"%VENV_PY%" -m pip install --disable-pip-version-check -r "%ROOT%\requirements-dev.txt" || exit /b 1
call :imports_ok
if errorlevel 1 exit /b 2
call :pyinstaller_ok
if errorlevel 1 exit /b 2
exit /b 0

:imports_ok
"%VENV_PY%" "%BOOT%" imports
if errorlevel 1 exit /b 1
exit /b 0

:pyinstaller_ok
"%VENV_PY%" "%BOOT%" pyinstaller
if errorlevel 1 exit /b 1
exit /b 0

:find_python
rem Resolve a real python.exe. "where" lists the Microsoft Store alias first:
rem a 0-byte WindowsApps\python.exe that fails with "The system cannot find
rem the file specified. Version checks go through win_boot.py so this
rem file has no angle bracket for cmd to treat as redirection.
set "BASE_PY="
set "BASE_ARG="
call :try_py_launcher
if defined BASE_PY exit /b 0
call :scan_where python
if defined BASE_PY exit /b 0
call :scan_where python3
if defined BASE_PY exit /b 0
call :scan_dirs
if defined BASE_PY exit /b 0
call :scan_reg HKCU
if defined BASE_PY exit /b 0
call :scan_reg HKLM
if defined BASE_PY exit /b 0
exit /b 1

:try_py_launcher
set "PY_LAUNCHER="
if exist "%SystemRoot%\py.exe" call :pick_py "%SystemRoot%\py.exe"
if exist "%WINDIR%\py.exe" call :pick_py "%WINDIR%\py.exe"
for /f "delims=" %%P in ('where py 2^>nul') do call :pick_py "%%P"
if not defined PY_LAUNCHER exit /b 0
set "PY_OUT=%TEMP%\contitool-python-path.txt"
del /q "%PY_OUT%" 2>nul
"%PY_LAUNCHER%" -3 "%BOOT%" exe > "%PY_OUT%" 2>nul
set "PY_EXE="
if exist "%PY_OUT%" for /f "usebackq delims=" %%E in ("%PY_OUT%") do set "PY_EXE=%%E"
del /q "%PY_OUT%" 2>nul
if not defined PY_EXE exit /b 0
call :accept_if_real "%PY_EXE%"
exit /b 0

:pick_py
if defined PY_LAUNCHER exit /b 0
call :is_real_exe "%~1"
if errorlevel 1 exit /b 0
set "PY_LAUNCHER=%~1"
exit /b 0

:scan_where
for /f "delims=" %%P in ('where %~1 2^>nul') do call :accept_if_real "%%P"
exit /b 0

:scan_dirs
for /d %%D in ("%LocalAppData%\Programs\Python\Python3*") do call :accept_if_real "%%D\python.exe"
for /d %%D in ("%ProgramFiles%\Python\Python3*") do call :accept_if_real "%%D\python.exe"
for /d %%D in ("%ProgramFiles%\Python3*") do call :accept_if_real "%%D\python.exe"
exit /b 0

:scan_reg
for /f "delims=" %%K in ('reg query "%~1\Software\Python\PythonCore" 2^>nul') do call :reg_key "%%K"
exit /b 0

:reg_key
if defined BASE_PY exit /b 0
if "%~1"=="" exit /b 0
echo(%~1| findstr /I /L /C:"\PythonCore\3." >nul
if errorlevel 1 exit /b 0
set "REG_PATH="
for /f "tokens=1,2*" %%A in ('reg query "%~1\InstallPath" /ve 2^>nul') do if /I "%%B"=="REG_SZ" set "REG_PATH=%%C"
if not defined REG_PATH exit /b 0
call :accept_if_real "%REG_PATH%\python.exe"
exit /b 0

:accept_if_real
if defined BASE_PY exit /b 0
call :is_real_exe "%~1"
if errorlevel 1 exit /b 0
"%~1" "%BOOT%" version >nul 2>&1
if errorlevel 1 exit /b 0
set "BASE_PY=%~1"
set "BASE_ARG="
exit /b 0

:is_real_exe
if "%~1"=="" exit /b 1
set "CAND=%~1"
if not "%CAND:WindowsApps=%"=="%CAND%" exit /b 1
if not exist "%CAND%" exit /b 1
if "%~z1"=="0" exit /b 1
exit /b 0

:no_python
echo No Python 3.12 or newer was found.
echo Install Python 3.15 from python.org and tick "Add python.exe to PATH" and "py launcher".
echo Use the full installer, not the Microsoft Store shortcut.
echo.
echo where python:
where python 2>nul
echo where py:
where py 2>nul
echo Install folders:
dir /b /ad "%LocalAppData%\Programs\Python" 2>nul
dir /b /ad "%ProgramFiles%\Python" 2>nul
call :hold
exit /b 1

:venv_fail
echo Could not create the virtual environment.
echo Delete the .venv folder, then run this script again.
echo Use the full installer, not the Microsoft Store shortcut.
call :hold
exit /b 1

:venv_old
echo The Python in .venv is older than 3.12.
echo Delete the .venv folder and run this script again.
call :hold
exit /b 1

:pip_fail
echo Dependency installation failed.
echo Check that this PC can reach pypi.org, then run this script again.
echo On a network that blocks PyPI, install with a mirror and run this script again:
echo   .venv\Scripts\python.exe -m pip install -r requirements-dev.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
call :hold
exit /b 1

:root_missing
echo Could not find scripts\build_release.py or requirements-dev.txt above this script.
echo Keep build_windows.bat in the scripts folder. The repository root is the parent folder.
call :hold
exit /b 1

:dpdu_missing
echo dpdu\VW_PDUAPI_27.2\PDUAPI_VW.dll is missing.
echo The Windows package copies this driver next to ContiTool.exe.
call :hold
exit /b 1

:boot_missing
echo win_boot.py is missing next to build_windows.bat.
echo Copy the whole project folder again. Copying only the batch file leaves this file behind.
call :hold
exit /b 1

:import_fail
echo The modules named above failed to load, so the package was not built.
echo If the line says No module named can, or PyInstaller failed to load, delete the .venv folder and run this script again.
call :hold
exit /b 1

:build_fail
echo The package build failed. Exit code %RC%.
call :hold
exit /b %RC%

:hold
if defined NO_PAUSE exit /b 0
pause
exit /b 0
