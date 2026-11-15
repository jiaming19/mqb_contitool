@echo off
setlocal EnableExtensions
rem ContiTool on Windows: create .venv, install requirements.txt, then launch.
rem Double-click opens the GUI. Type cn or en when asked (Enter = cn).
rem This file must stay ASCII, with CRLF line endings. cmd.exe seeks a batch
rem file by characters after the console is switched to code page 65001, so a
rem multibyte line makes it skip "pip install". The app then dies with
rem ModuleNotFoundError: No module named 'can' (the python-can package).
rem A -l / --lang already on the command line is kept, such as:
rem   run.bat -l en --help
rem Python checks live in win_boot.py. Do not pass Python source from this file.
rem cmd treats the word for, and angle brackets, as its own syntax.
rem This file lives in scripts\. The repository root is the parent folder.
cd /d "%~dp0.."
if errorlevel 1 goto :root_missing

set "ROOT=%cd%"
set "VENV_PY=%ROOT%\.venv\Scripts\python.exe"
set "STAMP=%ROOT%\.venv\requirements.stamp"
set "BOOT=%~dp0win_boot.py"
set "BASE_PY="
set "BASE_ARG="

if not exist "%ROOT%\conti_cp_tool.py" goto :root_missing
if not exist "%ROOT%\requirements.txt" goto :root_missing
if not exist "%BOOT%" goto :boot_missing

call :choose_lang %*
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
if not exist "%STAMP%" goto :write_stamp
fc /b "%ROOT%\requirements.txt" "%STAMP%" >nul 2>&1
if errorlevel 1 goto :need_install
goto :deps_ready

:need_install
call :install_deps
if errorlevel 2 goto :import_fail
if errorlevel 1 goto :pip_fail

:write_stamp
"%VENV_PY%" "%BOOT%" stamp "%ROOT%\requirements.txt" "%STAMP%"
if errorlevel 1 echo Could not save the requirements stamp. Continuing anyway.

:deps_ready

set "PYTHONUTF8=1"
if defined SKIP_LANG_PROMPT (
  "%VENV_PY%" "%ROOT%\conti_cp_tool.py" %*
) else (
  "%VENV_PY%" "%ROOT%\conti_cp_tool.py" -l %APP_LANG% %*
)
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto :app_fail
exit /b 0

:install_deps
echo Installing dependencies. The first run needs a network and can take a few minutes...
"%VENV_PY%" -m pip --version >nul 2>&1 || "%VENV_PY%" -m ensurepip --upgrade >nul 2>&1
"%VENV_PY%" -m pip install --disable-pip-version-check -r "%ROOT%\requirements.txt" || exit /b 1
call :imports_ok
if errorlevel 1 exit /b 2
exit /b 0

:imports_ok
"%VENV_PY%" "%BOOT%" imports
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
pause
exit /b 1

:venv_fail
echo Could not create the virtual environment.
echo Delete the .venv folder, then run this script again.
echo Use the full python.org installer, not the Microsoft Store shortcut.
pause
exit /b 1

:venv_old
echo The Python in .venv is older than 3.12.
echo Delete the .venv folder and run this script again.
pause
exit /b 1

:pip_fail
echo Dependency installation failed.
echo Check that this PC can reach pypi.org, then run this script again.
echo On a network that blocks PyPI, install with a mirror and run this script again:
echo   .venv\Scripts\python.exe -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
pause
exit /b 1

:root_missing
echo Could not find conti_cp_tool.py or requirements.txt above this script.
echo Keep run.bat in the scripts folder. The repository root is the parent folder.
pause
exit /b 1

:boot_missing
echo win_boot.py is missing next to run.bat.
echo Copy the whole project folder again. Copying only run.bat leaves this file behind.
pause
exit /b 1

:import_fail
echo The modules named above failed to load, so the program did not start.
echo If the line says No module named can, delete the .venv folder and run this script again.
pause
exit /b 1

:app_fail
echo The program exited with code %RC%.
pause
exit /b %RC%

:choose_lang
set "APP_LANG=cn"
set "SKIP_LANG_PROMPT="
call :scan_lang_arg %*
if defined SKIP_LANG_PROMPT exit /b 0
:ask_lang
echo.
echo Select language: cn or en
set "LANG_CHOICE="
set /p "LANG_CHOICE=Input cn or en [cn]: "
if "%LANG_CHOICE%"=="" set "LANG_CHOICE=cn"
set "LANG_CHOICE=%LANG_CHOICE: =%"
if /I "%LANG_CHOICE%"=="cn" (
  set "APP_LANG=cn"
  exit /b 0
)
if /I "%LANG_CHOICE%"=="en" (
  set "APP_LANG=en"
  exit /b 0
)
echo Please input cn or en.
goto :ask_lang

:scan_lang_arg
if "%~1"=="" exit /b 0
if /I "%~1"=="-l" (
  set "SKIP_LANG_PROMPT=1"
  exit /b 0
)
if /I "%~1"=="--lang" (
  set "SKIP_LANG_PROMPT=1"
  exit /b 0
)
echo(%~1| findstr /I /B /C:"--lang=" >nul && set "SKIP_LANG_PROMPT=1"
if defined SKIP_LANG_PROMPT exit /b 0
shift
goto :scan_lang_arg
